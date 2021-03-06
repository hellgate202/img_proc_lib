import white_balance_corrector_csr_pkg::*; 

module white_balance_corrector_csr #(
  parameter int BASE_ADDR = 32'h0000_0000 
)(
  input              clk_i,
  input              rst_i,
  axi4_lite_if.slave csr_i,
  wb_ctrl_if.master  wb_ctrl_o
);

localparam REG_ADDR_W = TOTAL_CSR_CNT == 1 ? 1 : $clog2( TOTAL_CSR_CNT );

logic [REG_ADDR_W - 1 : 0] wr_addr_reg;
logic [REG_ADDR_W - 1 : 0] rd_addr_reg;
logic                      wr_addr_match;
logic                      rd_addr_match;
logic [31 : 0]             wdata_lock;
logic [3 : 0]              wstrb_lock;
logic [REG_ADDR_W - 1 : 0] awaddr_lock;
logic                      aw_handshake;
logic                      ar_handshake;
logic                      w_handshake;
logic                      b_handshake;
logic                      r_handshake;
logic                      was_aw_handshake;
logic                                                was_ar_handshake;
logic                      was_w_handshake;
logic                      backpressure;
logic                      wr_req;

logic [1 : 0]              mode_cr;
logic                      cal_stb_cr;
logic                      cal_stb_cr_d1;
logic [1 : 0]              man_sel_cr;
logic [31 : 0]             man_coef_cr;
logic                      man_lock_cr;
logic [31 : 0]             cur_coef_sr;       

assign wr_addr_match = csr_i.awaddr >= ( ( WB_MODE_CR << 2 ) + BASE_ADDR ) &&
                       csr_i.awaddr <= ( ( WB_MAN_LOCK_CR << 2 ) + BASE_ADDR );
assign rd_addr_match = csr_i.araddr >= ( ( WB_MODE_CR << 2 ) + BASE_ADDR ) &&
                       csr_i.araddr <= ( ( WB_CUR_COEF_SR << 2 ) + BASE_ADDR );
assign aw_handshake  = csr_i.awvalid && csr_i.awready && wr_addr_match;
assign ar_handshake  = csr_i.arvalid && csr_i.arready && rd_addr_match;
assign w_handshake   = csr_i.wvalid && csr_i.wready && ( wr_addr_match || was_aw_handshake );
assign b_handshake   = csr_i.bvalid && csr_i.bready;
assign r_handshake   = csr_i.rvalid && csr_i.rready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      wr_addr_reg <= REG_ADDR_W'( 0 );
      rd_addr_reg <= REG_ADDR_W'( 0 );
    end
  else
    begin
      if( aw_handshake )
        wr_addr_reg <= REG_ADDR_W'( ( csr_i.awaddr - BASE_ADDR ) >> 2 );
      if( ar_handshake )
        rd_addr_reg <= REG_ADDR_W'( ( csr_i.araddr - BASE_ADDR ) >> 2 );
    end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      was_aw_handshake <= 1'b0;
      was_w_handshake  <= 1'b0;
      was_ar_handshake <= 1'b0;
    end
  else
    begin
      was_aw_handshake <= aw_handshake;
      was_w_handshake  <= w_handshake;
      was_ar_handshake <= ar_handshake;
    end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    csr_i.rvalid <= 1'b0;
  else
    if( was_ar_handshake )
      csr_i.rvalid <= 1'b1;
    else
      if( r_handshake )
        csr_i.rvalid <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    awaddr_lock <= REG_ADDR_W'( 0 );
  else
    if( aw_handshake )
      awaddr_lock <= csr_i.awaddr;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      wdata_lock <= 32'b0;
      wstrb_lock <= 8'b0;
    end
  else
    if( w_handshake )
      begin
        wdata_lock <= csr_i.wdata;
        wstrb_lock <= csr_i.wstrb;
      end

assign backpressure  = was_aw_handshake ^ was_w_handshake;
assign wr_req        = was_aw_handshake && was_w_handshake;
assign csr_i.arready = 1'b1;
assign csr_i.awready = !backpressure;
assign csr_i.wready  = !backpressure;
assign csr_i.rresp   = 2'b0;
assign csr_i.bresp   = 2'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      mode_cr     <= 2'd2;
      cal_stb_cr  <= 1'd0;
      man_sel_cr  <= 2'd0;
      man_coef_cr <= 32'd0;
      man_lock_cr <= 1'd0;
    end
  else
    if( wr_req )
      case( wr_addr_reg )
        WB_MODE_CR:
          begin
            if( wstrb_lock[0] )
              mode_cr <= wdata_lock[1 : 0];
          end
        WB_CAL_STB_CR:
          begin
            if( wstrb_lock[0] )
              cal_stb_cr <= wdata_lock[0];
          end
        WB_MAN_SEL_CR:
          begin
            if( wstrb_lock[0] )
              man_sel_cr <= wdata_lock[1 : 0];
          end
        WB_MAN_COEF_CR:
          begin
            for( int i = 0; i < 4; i++ )
              if( wstrb_lock[i] )
                man_coef_cr[( i + 1 ) * 8 - 1 -: 8] <= wdata_lock[( i + 1 ) * 8 - 1 -: 8];
          end
        WB_MAN_LOCK_CR:
          begin
            if( wstrb_lock[0] )
              man_lock_cr <= wdata_lock[0];
          end
        default:;
      endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    csr_i.bvalid <= 1'b0;
  else
    if( wr_req )
      csr_i.bvalid <= 1'b1;
    else
      if( b_handshake )
        csr_i.bvalid <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    csr_i.rdata <= 32'b0;
  else
    if( was_ar_handshake )
      case( rd_addr_reg )
        WB_MODE_CR:     csr_i.rdata <= 32'( mode_cr );
        WB_CAL_STB_CR:  csr_i.rdata <= 32'( cal_stb_cr );
        WB_MAN_SEL_CR:  csr_i.rdata <= 32'( man_sel_cr );
        WB_MAN_COEF_CR: csr_i.rdata <= 32'( man_coef_cr );
        WB_MAN_LOCK_CR: csr_i.rdata <= 32'( man_lock_cr );
        WB_CUR_COEF_SR: csr_i.rdata <= 32'( cur_coef_sr );
        default:;
      endcase
    else
      if( r_handshake )
        csr_i.rdata <= 32'd0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    cal_stb_cr_d1 <= 1'b0;
  else
    cal_stb_cr_d1 <= cal_stb_cr;

assign cur_coef_sr        = wb_ctrl_o.cur_coef;
assign wb_ctrl_o.mode     = mode_cr;
assign wb_ctrl_o.cal_stb  = cal_stb_cr && !cal_stb_cr_d1;
assign wb_ctrl_o.man_sel  = man_sel_cr;
assign wb_ctrl_o.man_coef = man_coef_cr;
assign wb_ctrl_o.man_lock = man_lock_cr;

endmodule
