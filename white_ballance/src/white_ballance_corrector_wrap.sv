module white_ballance_corrector_wrap #(
  parameter BASE_ADDR     = 32'h0000_0000,
  parameter PX_WIDTH      = 30,
  parameter TDATA_WIDTH   = 32,
  parameter TDATA_WIDTH_B = 4,
  parameter FRAME_RES_X   = 1920,
  parameter FRAME_RES_Y   = 1080,
  parameter FRACT_WIDTH   = 10
)(
  input                          clk_i,
  input                          rst_i,
  input                          video_i_tvalid,
  input  [TDATA_WIDTH - 1 : 0]   video_i_tdata,
  input  [TDATA_WIDTH_B - 1 : 0] video_i_tstrb,
  input  [TDATA_WIDTH_B - 1 : 0] video_i_tkeep,
  input                          video_i_tlast,
  input                          video_i_tuser,
  input                          video_i_tid,
  input                          video_i_tdest,
  output                         video_i_tready,
  output                         video_o_tvalid,
  output [TDATA_WIDTH - 1 : 0]   video_o_tdata,
  output [TDATA_WIDTH_B - 1 : 0] video_o_tstrb,
  output [TDATA_WIDTH_B - 1 : 0] video_o_tkeep,
  output                         video_o_tlast,
  output                         video_o_tuser,
  output                         video_o_tid,
  output                         video_o_tdest,
  input                          video_o_tready,
  input                          csr_awvalid_i,
  input  [31 : 0]                csr_awaddr_i,
  output                         csr_awready_o,
  input  [2 : 0]                 csr_awprot_i,
  input                          csr_wvalid_i,
  input  [31 : 0]                csr_wdata_i,
  input  [3 : 0]                 csr_wstrb_i,
  output                         csr_wready_o,
  output                         csr_bvalid_o,
  input                          csr_bready_i,
  output [1 : 0]                 csr_bresp_o,
  input                          csr_arvalid_i,
  input  [31 : 0]                csr_araddr_i,
  output                         csr_arready_o,
  input  [2 : 0]                 csr_arprot_i,
  output                         csr_rvalid_o,
  output [31 : 0]                csr_rdata_o,
  output [1 : 0]                 csr_rresp_o,
  input                          csr_rready_i
);

axi4_lite_if #(
  .ADDR_WIDTH ( 32     ),
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
) rgb (
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

wb_ctrl_if wb_ctrl();

white_ballance_corrector_csr #(
  .BASE_ADDR ( CSR_BASE_ADDR )
) white_ballance_corrector_csr (
  .clk_i     ( clk_i         ),
  .rst_i     ( rst_i         ),
  .csr_i     ( csr           ),
  .wb_ctrl_o ( wb_ctrl       )
);

white_ballance_corrector #(
  .PX_WIDTH    ( PX_WIDTH    ),
  .FRAME_RES_X ( FRAME_RES_X ),
  .FRAME_RES_Y ( FRAME_RES_Y ),
  .FRACT_WIDTH ( FRACT_WIDTH )
) white_ballance_corrector (
  .clk_i       ( clk_i       ),
  .rst_i       ( rst_i       ),
  .wb_ctrl_i   ( wb_ctrl     ),
  .video_i     ( video_i     ),
  .video_o     ( video_o     )
);

endmodule
