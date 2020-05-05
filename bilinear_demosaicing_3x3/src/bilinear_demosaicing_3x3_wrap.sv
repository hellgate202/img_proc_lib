module bilinear_demosaicing_3x3_wrap #(
  parameter CSR_BASE_ADDR     = 0,
  parameter RAW_PX_WIDTH      = 10,
  parameter FRAME_RES_X       = 1920,
  parameter FRAME_RES_Y       = 1080,
  parameter RAW_TDATA_WIDTH   = 16,
  parameter RAW_TDATA_WIDTH_B = 2,
  parameter RGB_TDATA_WIDTH   = 32,
  parameter RGB_TDATA_WIDTH_B = 4,
  parameter COMPENSATE_EN     = 1,
  parameter INTERLINE_GAP     = 280
)(
  input                              clk_i,
  input                              rst_i,
  input                              csr_awvalid,
  input  [31 : 0]                    csr_awaddr,
  output                             csr_awready,
  input  [2 : 0]                     csr_awprot,
  input                              csr_wvalid,
  input  [31 : 0]                    csr_wdata,
  input  [3 : 0]                     csr_wstrb,
  output                             csr_wready,
  output                             csr_bvalid,
  input                              csr_bready,
  output [1 : 0]                     csr_bresp,
  input                              csr_arvalid,
  input  [31 : 0]                    csr_araddr,
  output                             csr_arready,
  input  [2 : 0]                     csr_arprot,
  output                             csr_rvalid,
  output [31 : 0]                    csr_rdata,
  output [1 : 0]                     csr_rresp,
  input                              csr_rready,
  input [RAW_TDATA_WIDTH - 1 : 0]    raw_tdata,
  input [RAW_TDATA_WIDTH_B - 1 : 0]  raw_tstrb,
  input [RAW_TDATA_WIDTH_B - 1 : 0]  raw_tkeep,
  input                              raw_tvalid,
  input                              raw_tlast,
  input                              raw_tuser,
  input                              raw_tid,
  input                              raw_tdest,
  output                             raw_tready,
  output [RGB_TDATA_WIDTH - 1 : 0]   rgb_tdata,
  output [RGB_TDATA_WIDTH_B - 1 : 0] rgb_tstrb,
  output [RGB_TDATA_WIDTH_B - 1 : 0] rgb_tkeep,
  output                             rgb_tvalid,
  output                             rgb_tlast,
  output                             rgb_tuser,
  output                             rgb_tid,
  output                             rgb_tdest,
  input                              rgb_tready
);

axi4_lite_if #(
  .ADDR_WIDTH ( 32     ),
  .DATA_WIDTH ( 32     )
) csr (
  .aclk       ( clk_i  ),
  .aresetn    ( !rst_i )
);

assign csr.awvalid = csr_awvalid;
assign csr.awaddr  = csr_awaddr;
assign csr_awready = csr.awready;
assign csr.awprot  = csr_awprot;
assign csr.wvalid  = csr_wvalid;
assign csr.wstrb   = csr_wstrb;
assign csr_wready  = csr.wready;
assign csr.wdata   = csr_wdata;
assign csr.arvalid = csr_arvalid;
assign csr.araddr  = csr_araddr;
assign csr_arready = csr.arready;
assign csr.arprot  = csr_arprot;
assign csr_bvalid  = csr.bvalid;
assign csr.bready  = csr_bready;
assign csr_bresp   = csr.bresp;
assign csr_rdata   = csr.rdata;
assign csr_rvalid  = csr.rvalid;
assign csr_rresp   = csr.rresp;
assign csr.rready  = csr_rready;

axi4_stream_if #(
  .TDATA_WIDTH ( RAW_TDATA_WIDTH ),
  .TDEST_WIDTH ( 1               ),
  .TID_WIDTH   ( 1               ),
  .TUSER_WIDTH ( 1               )
) raw (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

assign raw.tdata  = raw_tdata;
assign raw.tvalid = raw_tvalid;
assign raw.tkeep  = raw_tkeep;
assign raw.tstrb  = raw_tstrb;
assign raw.tlast  = raw_tlast;
assign raw.tuser  = raw_tuser;
assign raw.tdest  = raw_tdest;
assign raw.tid    = raw_tid;
assign raw_tready = raw.tready;

axi4_stream_if #(
  .TDATA_WIDTH ( RGB_TDATA_WIDTH ),
  .TDEST_WIDTH ( 1               ),
  .TID_WIDTH   ( 1               ),
  .TUSER_WIDTH ( 1               )
) rgb (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

assign rgb_tdata  = rgb.tdata;
assign rgb_tvalid = rgb.tvalid;
assign rgb_tkeep  = rgb.tkeep;
assign rgb_tstrb  = rgb.tstrb;
assign rgb_tlast  = rgb.tlast;
assign rgb_tuser  = rgb.tuser;
assign rgb_tdest  = rgb.tdest;
assign rgb_tid    = rgb.tid;
assign rgb.tready = rgb_tready;

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
  .FRAME_RES_X        ( FRAME_RES_X      ),
  .FRAME_RES_Y        ( FRAME_RES_Y      ),
  .COMPENSATE_EN      ( COMPENSATE_EN    ),
  .INTERLINE_GAP      ( INTERLINE_GAP    )
) bilinear_demosaicing_3x3 (
  .clk_i              ( clk_i            ),
  .rst_i              ( rst_i            ),
  .demosaicing_ctrl_i ( demosaicing_ctrl ),
  .raw_video_i        ( raw              ),
  .rgb_video_o        ( rgb              )
);

endmodule
