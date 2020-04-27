module line_extender #(
  parameter int LEFT        = 1,
  parameter int RIGHT       = 1,
  parameter int PX_WIDTH    = 10
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int TDATA_WIDTH     = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH;
localparam int TDATA_WIDTH_B   = TDATA_WIDTH / 8;
localparam int LEFT_CNT_WIDTH  = LEFT == 1 || LEFT == 0 ? 1 : $clog2( LEFT );
localparam int RIGHT_CNT_WIDTH = RIGHT == 1 || RIGHT == 0 ? 1 : $clog2( RIGHT );

logic                           allow_new_data;
logic                           tfirst;
logic                           tfirst_d1;
logic [LEFT_CNT_WIDTH - 1 : 0]  left_cnt;
logic [RIGHT_CNT_WIDTH - 1 : 0] right_cnt;
logic                           left_cnt_en;
logic                           right_cnt_en;

typedef struct packed {
  logic [TDATA_WIDTH - 1 : 0]   tdata;
  logic [TDATA_WIDTH_B - 1 : 0] tstrb;
  logic [TDATA_WIDTH_B - 1 : 0] tkeep;
  logic                         tuser;
  logic                         tlast;
  logic                         tvalid;
  logic                         tid;
  logic                         tdest;
} axi4_stream_word_t;

axi4_stream_word_t output_reg;

assign video_i.tready = allow_new_data && ( !video_o.tvalid || video_o.tready );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      output_reg <= $bits( axi4_stream_word_t )'( 0 );
      tfirst_d1  <= 1'b0;
    end
  else
    if( video_i.tready )
      begin
        output_reg.tdata  <= video_i.tdata;
        output_reg.tstrb  <= video_i.tstrb;
        output_reg.tkeep  <= video_i.tkeep;
        output_reg.tuser  <= video_i.tuser;
        output_reg.tlast  <= video_i.tlast;
        output_reg.tvalid <= video_i.tvalid;
        output_reg.tid    <= video_i.tid;
        output_reg.tdest  <= video_i.tdest;
        tfirst_d1         <= tfirst;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tfirst <= 1'b1;
  else
    if( video_i.tvalid && video_i.tready )
      if( video_i.tlast )
        tfirst <= 1'b1;
      else
        tfirst <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    allow_new_data <= 1'b1;
  else
    if( video_i.tready && video_i.tvalid && ( tfirst && ( LEFT > 0 ) || 
                                              video_i.tlast && ( RIGHT > 0 ) ) )
      allow_new_data <= 1'b0;
    else
      if( ( ( left_cnt_en && left_cnt == LEFT_CNT_WIDTH'( LEFT - 1 ) ) ||
            ( right_cnt_en && right_cnt == RIGHT_CNT_WIDTH'( RIGHT - 1 ) ) ) &&
            video_o.tready )
        allow_new_data <= 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    left_cnt_en <= 1'b0;
  else
    if( video_i.tvalid && video_i.tready && tfirst && LEFT > 0 )
      left_cnt_en <= 1'b1;
    else
      if( left_cnt == LEFT_CNT_WIDTH'( LEFT - 1 ) && video_o.tready )
        left_cnt_en <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    right_cnt_en <= 1'b0;
  else
    if( video_i.tvalid && video_i.tready && video_i.tlast && RIGHT > 0 )
      right_cnt_en <= 1'b1;
    else
      if( right_cnt == RIGHT_CNT_WIDTH'( RIGHT - 1 ) && video_o.tready )
        right_cnt_en <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    left_cnt <= LEFT_CNT_WIDTH'( 0 );
  else
    if( video_o.tready )
      if( left_cnt_en )
        left_cnt <= left_cnt + 1'b1;
      else
        left_cnt <= LEFT_CNT_WIDTH'( 0 );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    right_cnt <= RIGHT_CNT_WIDTH'( 0 );
  else
    if( video_o.tready )
      if( right_cnt_en )
        right_cnt <= right_cnt + 1'b1;
      else
        right_cnt <= RIGHT_CNT_WIDTH'( 0 );

assign video_o.tdata  = output_reg.tdata;
assign video_o.tstrb  = output_reg.tstrb;
assign video_o.tkeep  = output_reg.tkeep;
assign video_o.tuser  = !allow_new_data && left_cnt == LEFT_CNT_WIDTH'( 0 ) || 
                        LEFT == 0 ? output_reg.tuser : 1'b0;
assign video_o.tlast  = allow_new_data ? output_reg.tlast : 1'b0;
assign video_o.tvalid = output_reg.tvalid;
assign video_o.tid    = output_reg.tid;
assign video_o.tdest  = output_reg.tdest;

endmodule
