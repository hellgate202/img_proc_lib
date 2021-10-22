module conv_2d_coef_bridge #(
  parameter int COEF_WIDTH       = 13,
  parameter int COEF_FRACT_WIDTH = 8,
  parameter int PX_WIDTH         = 8,
  parameter int TDATA_WIDTH      = 8,
  parameter int WIN_SIZE         = 3,
  parameter int FRAME_RES_X      = 1920,
  parameter int FRAME_RES_Y      = 1080,
  parameter int INTERLINE_GAP    = 100,
  parameter int COMPENSATE_EN    = 1
)(
  input                 clk_i,
  input                 rst_i,
  conv_2d_if.slave      conv_2d_ctrl_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int COEF_AMOUNT = WIN_SIZE * WIN_SIZE;

logic [COEF_AMOUNT - 1 : 0][COEF_WIDTH - 1 : 0] coef;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    coef <= ( COEF_AMOUNT * COEF_WIDTH )'( 0 );
  else
    if( conv_2d_ctrl_i.wr_stb )
      for( int i = 0; i < COEF_AMOUNT; i++ )
        if( conv_2d_ctrl_i.coef_num == i )
          begin
            coef[i] <= COEF_WIDTH'( conv_2d_ctrl_i.coef_val );
            break;
          end

conv_2d #(
  .COEF_WIDTH       ( COEF_WIDTH       ),
  .COEF_FRACT_WIDTH ( COEF_FRACT_WIDTH ),
  .PX_WIDTH         ( PX_WIDTH         ),
  .TDATA_WIDTH      ( TDATA_WIDTH      ),
  .WIN_SIZE         ( WIN_SIZE         ),
  .FRAME_RES_X      ( FRAME_RES_X      ),
  .FRAME_RES_Y      ( FRAME_RES_Y      ),
  .INTERLINE_GAP    ( INTERLINE_GAP    ),
  .COMPENSATE_EN    ( COMPENSATE_EN    )
) conv_2d_inst (
  .clk_i            ( clk_i            ),
  .rst_i            ( rst_i            ),
  .coef_i           ( coef             ),
  .video_i          ( video_i          ),
  .video_o          ( video_o          )
);

endmodule
