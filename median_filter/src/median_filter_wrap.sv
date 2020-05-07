module median_filter_wrap #(
  parameter CSR_BASE_ADDR   = 0,
  parameter CHANNELS_AMOUNT = 3,
  parameter PX_WIDTH        = 10,
  parameter WIN_SIZE        = 3,
  parameter FRAME_RES_X     = 1920,
  parameter FRAME_RES_Y     = 1080,
  parameter COMPENSATE_EN   = 1,
  parameter TDATA_WIDTH     = 32,
  parameter TDATA_WIDTH_B   = 4,
  parameter INTERLINE_GAP   = 100
)(
  input                           clk_i,
  input                           rst_i,
  input                           csr_awvalid,
  input  [31 : 0]                 csr_awaddr,
  output                          csr_awready,
  input  [2 : 0]                  csr_awprot,
  input                           csr_wvalid,
  input  [31 : 0]                 csr_wdata,
  input  [3 : 0]                  csr_wstrb,
  output                          csr_wready,
  output                          csr_bvalid,
  input                           csr_bready,
  output [1 : 0]                  csr_bresp,
  input                           csr_arvalid,
  input  [31 : 0]                 csr_araddr,
  output                          csr_arready,
  input  [2 : 0]                  csr_arprot,
  output                          csr_rvalid,
  output [31 : 0]                 csr_rdata,
  output [1 : 0]                  csr_rresp,
  input                           csr_rready,
  input  [TDATA_WIDTH - 1 : 0]    video_i_tdata,
  input  [TDATA_WIDTH_B - 1 : 0]  video_i_tstrb,
  input  [TDATA_WIDTH_B - 1 : 0]  video_i_tkeep,
  input                           video_i_tvalid,
  input                           video_i_tlast,
  input                           video_i_tuser,
  input                           video_i_tid,
  input                           video_i_tdest,
  output                          video_i_tready,
  output [TDATA_WIDTH - 1 : 0]    video_o_tdata,
  output [TDATA_WIDTH_B - 1 : 0]  video_o_tstrb,
  output [TDATA_WIDTH_B - 1 : 0]  video_o_tkeep,
  output                          video_o_tvalid,
  output                          video_o_tlast,
  output                          video_o_tuser,
  output                          video_o_tid,
  output                          video_o_tdest,
  input                           video_o_tready
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
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) video_i (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

assign video_i.tdata  = video_i_tdata;
assign video_i.tvalid = video_i_tvalid;
assign video_i.tkeep  = video_i_tkeep;
assign video_i.tstrb  = video_i_tstrb;
assign video_i.tlast  = video_i_tlast;
assign video_i.tuser  = video_i_tuser;
assign video_i.tdest  = video_i_tdest;
assign video_i.tid    = video_i_tid;
assign video_i_tready = video_i.tready;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) video_o (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

assign video_o_tdata  = video_o.tdata;
assign video_o_tvalid = video_o.tvalid;
assign video_o_tkeep  = video_o.tkeep;
assign video_o_tstrb  = video_o.tstrb;
assign video_o_tlast  = video_o.tlast;
assign video_o_tuser  = video_o.tuser;
assign video_o_tdest  = video_o.tdest;
assign video_o_tid    = video_o.tid;
assign video_o.tready = video_o_tready;

mf_ctrl_if mf_ctrl();

median_filter_csr #(
  .BASE_ADDR ( CSR_BASE_ADDR )
) median_filter_csr (
  .clk_i     ( clk_i         ),
  .rst_i     ( rst_i         ),
  .csr_i     ( csr           ),
  .mf_ctrl_o ( mf_ctrl       )
);

median_filter #(
  .PX_WIDTH        ( PX_WIDTH        ),
  .CHANNELS_AMOUNT ( CHANNELS_AMOUNT ),
  .WIN_SIZE        ( WIN_SIZE        ),
  .FRAME_RES_X     ( FRAME_RES_X     ),
  .FRAME_RES_Y     ( FRAME_RES_Y     ),
  .COMPENSATE_EN   ( COMPENSATE_EN   ),
  .INTERLINE_GAP   ( INTERLINE_GAP   )
) median_filter (
  .clk_i           ( clk_i           ),
  .rst_i           ( rst_i           ),
  .mf_ctrl_i       ( mf_ctrl         ),
  .video_i         ( video_i         ),
  .video_o         ( video_o         )
);

endmodule
