module frame_extender #(
  parameter int TOP         = 1,
  parameter int BOTTOM      = 1,
  parameter int LEFT        = 1,
  parameter int RIGHT       = 1,
  parameter int FRAME_RES_X = 1920,
  parameter int PX_WIDTH    = 10
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

line_extender #(
  .LEFT     ( LEFT     ),
  .RIGHT    ( RIGHT    ),
  .PX_WIDTH ( PX_WIDTH )
) line_extender_inst (
  .clk_i    ( clk_i    ),
  .rst_i    ( rst_i    ),
  .video_i  ( video_i  ),
  .video_o  ( video_o  )
);

endmodule
