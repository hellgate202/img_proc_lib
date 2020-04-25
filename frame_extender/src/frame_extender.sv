module frame_extender #(
  parameter int TOP         = 1,
  parameter int BOTTOM      = 1,
  parameter int LEFT        = 1,
  parameter int RIGHT       = 1,
  parameter int FRAME_RES_X = 1920,
  parameter int FRAME_RES_Y = 1080,
  parameter int PX_WIDTH    = 10
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int TDATA_WIDTH = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH;
localparam int EXTENDED_X  = FRAME_RES_X + LEFT + RIGHT;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) extended_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

line_extender #(
  .LEFT     ( LEFT           ),
  .RIGHT    ( RIGHT          ),
  .PX_WIDTH ( PX_WIDTH       )
) line_extender_inst (
  .clk_i    ( clk_i          ),
  .rst_i    ( rst_i          ),
  .video_i  ( video_i        ),
  .video_o  ( extended_video )
);

fixed_eof_extractor #(
  .FRAME_RES_Y ( FRAME_RES_Y    ),
  .PX_WIDTH    ( PX_WIDTH       )
) eof_extractor_inst (
  .clk_i       ( clk_i          ),
  .rst_i       ( rst_i          ),
  .video_i     ( extended_video ),
  .video_o     ( video_o        ),
  .eof_o       (                )
);

endmodule
