module bilinear_demosaicing_3x3_wrap #(
  parameter CSR_BASE_ADDR     = 0,
  parameter RAW_PX_WIDTH      = 10,
  parameter MAX_LINE_SIZE     = 1920,
  parameter RAW_TDATA_WIDTH   = 16,
  parameter RAW_TDATA_WIDTH_B = 2,
  parameter RGB_TDATA_WIDTH   = 32,
  parameter RGB_TDATA_WIDTH_B = 4
)(
  input                              clk_i,
  input                              rst_i,
  input                              csr_awvalid_i,
  input  [11 : 0]                    csr_awaddr_i,
  output                             csr_awready_o,
  input  [2 : 0]                     csr_awprot_i,
  input                              csr_wvalid_i,
  input  [31 : 0]                    csr_wdata_i,
  input  [3 : 0]                     csr_wstrb_i,
  output                             csr_wready_o,
  output                             csr_bvalid_o,
  input                              csr_bready_i,
  output [1 : 0]                     csr_bresp_o,
  input                              csr_arvalid_i,
  input  [11 : 0]                    csr_araddr_i,
  output                             csr_arready_o,
  input  [2 : 0]                     csr_arprot_i,
  output                             csr_rvalid_o,
  output [31 : 0]                    csr_rdata_o,
  output [1 : 0]                     csr_rresp_o,
  input                              csr_rready_i,
  input [RAW_TDATA_WIDTH - 1 : 0]    raw_tdata_i,
  input [RAW_TDATA_WIDTH_B - 1 : 0]  raw_tstrb_i,
  input [RAW_TDATA_WIDTH_B - 1 : 0]  raw_tkeep_i,
  input                              raw_tvalid_i,
  input                              raw_tlast_i,
  input                              raw_tuser_i,
  input                              raw_tid_i,
  input                              raw_tdest_i,
  output                             raw_tready_o,
  output [RGB_TDATA_WIDTH - 1 : 0]   rgb_tdata_o,
  output [RGB_TDATA_WIDTH_B - 1 : 0] rgb_tstrb_o,
  output [RGB_TDATA_WIDTH_B - 1 : 0] rgb_tkeep_o,
  output                             rgb_tvalid_o,
  output                             rgb_tlast_o,
  output                             rgb_tuser_o,
  output                             rgb_tid_o,
  output                             rgb_tdest_o,
  input                              rgb_tready_i
);

axi4_lite_if #(
  .ADDR_WIDTH ( 1      ),
  .DATA_WIDTH ( 32     )
) csr (
  .aclk       ( clk_i  ),
  .aresetn    ( !rst_i )
);

assign csr.awvalid   = csr_awvalid_i;
assign csr.awaddr    = csr_awaddr_i;
assign csr_awready_o = csr.awready;
assign csr.awprot    = csr_awprot_i;
assign csr.wvalid    = csr_wvalid_i;
assign csr.wstrb     = csr_wstrb_i;
assign csr_wready_o  = csr.wready;
assign csr.wdata     = csr_wdata_i;
assign csr.arvalid   = csr_arvalid_i;
assign csr.araddr    = csr_araddr_i;
assign csr_arready_o = csr.arready;
assign csr_bvalid_o  = csr.bvalid;
assign csr.bready    = csr_bready_i;
assign csr_bresp_o   = csr.bresp;
assign csr_rdata_o   = csr.rdata;
assign csr_rvalid_o  = csr.rvalid;
assign csr_rresp_o   = csr.rresp;
assign csr.rready    = csr_rready_i;

axi4_stream_if #(
  .TDATA_WIDTH ( RAW_TDATA_WIDTH ),
  .TDEST_WIDTH ( 1               ),
  .TID_WIDTH   ( 1               ),
  .TUSER_WIDTH ( 1               )
) raw (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

assign raw.tdata    = raw_tdata_i;
assign raw.tvalid   = raw_tvalid_i;
assign raw.tkeep    = raw_tkeep_i;
assign raw.tstrb    = raw_tstrb_i;
assign raw.tlast    = raw_tlast_i;
assign raw.tuser    = raw_tuser_i;
assign raw.tdest    = raw_tdest_i;
assign raw.tid      = raw_tid_i;
assign raw_tready_o = raw.tready;

axi4_stream_if #(
  .TDATA_WIDTH ( RGB_TDATA_WIDTH ),
  .TDEST_WIDTH ( 1               ),
  .TID_WIDTH   ( 1               ),
  .TUSER_WIDTH ( 1               )
) rgb (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

assign rgb_tdata_o  = rgb.tdata;
assign rgb_tvalid_o = rgb.tvalid;
assign rgb_tkeep_o  = rgb.tkeep;
assign rgb_tstrb_o  = rgb.tstrb;
assign rgb_tlast_o  = rgb.tlast;
assign rgb_tuser_o  = rgb.tuser;
assign rgb_tdest_o  = rgb.tdest;
assign rgb_tid_o    = rgb.tid;
assign rgb.tready   = rgb_tready_i;

demosaicing_ctrl_if demosaicing_ctrl();

bilinear_demosaicing_3x3_csr #(
  .BASE_ADDR          ( CSR_BASE_ADDR    )
) bilinear_demosaicing_3x3_csr (
  .clk_i              ( clk_i            ),
  .rst_i              ( rst_i            ),
  .csr_i              ( csr              ),
  .demosaicing_ctrl_o ( demosaicing_ctrl )
);

bilinear_demosaicing_3x3 #(
  .RAW_PX_WIDTH       ( RAW_PX_WIDTH     ),
  .MAX_LINE_SIZE      ( MAX_LINE_SIZE    )
) bilinear_demosaicing_3x3 (
  .clk_i              ( clk_i            ),
  .rst_i              ( rst_i            ),
  .demosaicing_ctrl_i ( demosaicing_ctrl ),
  .raw_video_i        ( raw              ),
  .rgb_video_o        ( rgb              )
);

endmodule
