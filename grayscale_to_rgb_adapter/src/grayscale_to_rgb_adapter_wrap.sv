module grayscale_to_rgb_adapter_wrap #(
  parameter PX_WIDTH         = 10,
  parameter RX_TDATA_WIDTH   = PX_WIDTH % 8 > 0 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH,
  parameter TX_TDATA_WIDTH   = ( PX_WIDTH * 3 ) % 8 > 0 ? ( PX_WIDTH * 3 / 8 + 1 ) * 8 :
                               PX_WIDTH * 3,
  parameter RX_TDATA_WIDTH_B = RX_TDATA_WIDTH / 8,
  parameter TX_TDATA_WIDTH_B = TX_TDATA_WIDTH / 8
)(
  input                             clk_i,
  input                             rst_i,
  input                             video_i_tvalid,
  input  [RX_TDATA_WIDTH - 1 : 0]   video_i_tdata,
  input                             video_i_tlast,
  input  [RX_TDATA_WIDTH_B - 1 : 0] video_i_tstrb,
  input  [RX_TDATA_WIDTH_B - 1 : 0] video_i_tkeep,
  input                             video_i_tuser,
  input                             video_i_tdest,
  input                             video_i_tid,
  output                            video_i_tready,
  output                            video_o_tvalid,
  output [TX_TDATA_WIDTH - 1 : 0]   video_o_tdata,
  output                            video_o_tlast,
  output [TX_TDATA_WIDTH_B - 1 : 0] video_o_tstrb,
  output [TX_TDATA_WIDTH_B - 1 : 0] video_o_tkeep,
  output                            video_o_tuser,
  output                            video_o_tdest,
  output                            video_o_tid,
  input                             video_o_tready
);

axi4_stream_if #(
  .TDATA_WIDTH ( RX_TDATA_WIDTH ),
  .TID_WIDTH   ( 1              ),
  .TDEST_WIDTH ( 1              ),
  .TUSER_WIDTH ( 1              )
) video_i (
  .aclk        ( clk_i          ),
  .aresetn     ( !rst_i         )
);

assign video_i.tvalid = video_i_tvalid;
assign video_i.tdata  = video_i_tdata;
assign video_i.tlast  = video_i_tlast;
assign video_i.tstrb  = video_i_tstrb;
assign video_i.tkeep  = video_i_tkeep;
assign video_i.tuser  = video_i_tuser;
assign video_i.tdest  = video_i_tdest;
assign video_i.tid    = video_i_tid;
assign video_i_tready = video_i.tready;

axi4_stream_if #(
  .TDATA_WIDTH ( TX_TDATA_WIDTH ),
  .TID_WIDTH   ( 1              ),
  .TDEST_WIDTH ( 1              ),
  .TUSER_WIDTH ( 1              )
) video_o (
  .aclk        ( clk_i          ),
  .aresetn     ( !rst_i         )
);

assign video_o_tvalid = video_o.tvalid;
assign video_o_tdata  = video_o.tdata;
assign video_o_tlast  = video_o.tlast;
assign video_o_tstrb  = video_o.tstrb;
assign video_o_tkeep  = video_o.tkeep;
assign video_o_tuser  = video_o.tuser;
assign video_o_tdest  = video_o.tdest;
assign video_o_tid    = video_o.tid;
assign video_o.tready = video_o_tready;

grayscale_to_rgb_adapter #(
  .PX_WIDTH ( PX_WIDTH )
) grayscale_to_rgb_adapter (
  .clk_i    ( clk_i    ),
  .rst_i    ( rst_i    ),
  .video_i  ( video_i  ),
  .video_o  ( video_o  )
);

endmodule
