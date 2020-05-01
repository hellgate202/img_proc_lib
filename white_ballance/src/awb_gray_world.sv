module awb_gray_world #(
  parameter int PX_WIDTH    = 10,
  parameter int FRAME_RES_X = 1920,
  parameter int FRAME_RES_Y = 1080,
  parameter int FRACT_WIDTH = 10,
  parameter int COEF_WIDTH  = PX_WIDTH + FRACT_WIDTH
)(
  input                             clk_i,
  input                             rst_i,
  axi4_stream_if.slave              video_i,
  output logic [COEF_WIDTH - 1 : 0] r_corr_o,
  output logic [COEF_WIDTH - 1 : 0] b_corr_o
);

localparam int PX_AMOUNT                      = FRAME_RES_X * FRAME_RES_Y;
localparam int PX_CNT_WIDTH                   = $clog2( PX_AMOUNT + 1 );
localparam int PX_ACC_WIDTH                   = PX_WIDTH + PX_CNT_WIDTH;
localparam bit [COEF_WIDTH - 1 : 0] FIXED_ONE = { PX_WIDTH'( 1 ), FRACT_WIDTH'( 0 ) };

logic [PX_ACC_WIDTH - 1 : 0] r_sum;
logic [PX_ACC_WIDTH - 1 : 0] g_sum;
logic [PX_ACC_WIDTH - 1 : 0] b_sum;
logic [PX_CNT_WIDTH - 1 : 0] px_cnt;
logic                        mean_calc_start;
logic [PX_ACC_WIDTH - 1 : 0] r_mean;
logic [PX_ACC_WIDTH - 1 : 0] g_mean;
logic [PX_ACC_WIDTH - 1 : 0] b_mean;
logic                        r_mean_valid;
logic                        g_mean_valid;
logic                        b_mean_valid;
logic [COEF_WIDTH - 1 : 0]   g_mean_fixed;
logic [COEF_WIDTH - 1 : 0]   r_corr;
logic [COEF_WIDTH - 1 : 0]   b_corr;
logic                        r_corr_valid;

assign video_i.tready = 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      r_sum <= PX_ACC_WIDTH'( 0 );
      g_sum <= PX_ACC_WIDTH'( 0 );
      b_sum <= PX_ACC_WIDTH'( 0 );
    end
  else
    if( video_i.tvalid && video_i.tready )
      if( video_i.tuser )
        begin
          r_sum <= video_i.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH];
          g_sum <= video_i.tdata[PX_WIDTH - 1 : 0];
          b_sum <= video_i.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH];
        end
      else
        begin
          r_sum <= r_sum + video_i.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH];
          g_sum <= g_sum + video_i.tdata[PX_WIDTH - 1 -: PX_WIDTH];
          b_sum <= b_sum + video_i.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH];
        end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_cnt <= PX_CNT_WIDTH'( 0 );
  else
    if( video_i.tvalid && video_i.tready )
      if( video_i.tuser )
        px_cnt <= PX_CNT_WIDTH'( 1 );
      else
        px_cnt <= px_cnt + 1'b1;

assign mean_calc_start = video_i.tvalid && video_i.tready && video_i.tuser;

division #(
  .WORD_W     ( PX_ACC_WIDTH            )
) r_mean_calc (
  .clk_i      ( clk_i                   ),
  .rst_i      ( rst_i                   ),
  .start_i    ( mean_calc_start         ),
  .divinded_i ( r_sum                   ),
  .divisor_i  ( PX_ACC_WIDTH'( px_cnt ) ),
  .ready_o    (                         ),
  .valid_o    ( r_mean_valid            ),
  .quotient_o ( r_mean                  ),
  .reminder_o (                         )
);

division #(
  .WORD_W     ( PX_ACC_WIDTH            )
) g_mean_calc (
  .clk_i      ( clk_i                   ),
  .rst_i      ( rst_i                   ),
  .start_i    ( mean_calc_start         ),
  .divinded_i ( g_sum                   ),
  .divisor_i  ( PX_ACC_WIDTH'( px_cnt ) ),
  .ready_o    (                         ),
  .valid_o    ( g_mean_valid            ),
  .quotient_o ( g_mean                  ),
  .reminder_o (                         )
);

division #(
  .WORD_W     ( PX_ACC_WIDTH            )
) b_mean_calc (
  .clk_i      ( clk_i                   ),
  .rst_i      ( rst_i                   ),
  .start_i    ( mean_calc_start         ),
  .divinded_i ( b_sum                   ),
  .divisor_i  ( PX_ACC_WIDTH'( px_cnt ) ),
  .ready_o    (                         ),
  .valid_o    ( b_mean_valid            ),
  .quotient_o ( b_mean                  ),
  .reminder_o (                         )
);

assign g_mean_fixed = COEF_WIDTH'( g_mean ) << FRACT_WIDTH;

division #(
  .WORD_W     ( COEF_WIDTH            )
) r_corr_calc (
  .clk_i      ( clk_i                 ),
  .rst_i      ( rst_i                 ),
  .start_i    ( r_mean_valid          ),
  .divinded_i ( g_mean_fixed          ),
  .divisor_i  ( COEF_WIDTH'( r_mean ) ),
  .ready_o    (                       ),
  .valid_o    ( r_corr_valid          ),
  .quotient_o ( r_corr                ),
  .reminder_o (                       )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    r_corr_o <= FIXED_ONE;
  else
    if( r_corr_valid )
      r_corr_o <= r_corr;

division #(
  .WORD_W     ( COEF_WIDTH            )
) b_corr_calc (
  .clk_i      ( clk_i                 ),
  .rst_i      ( rst_i                 ),
  .start_i    ( b_mean_valid          ),
  .divinded_i ( g_mean_fixed          ),
  .divisor_i  ( COEF_WIDTH'( b_mean ) ),
  .ready_o    (                       ),
  .valid_o    ( b_corr_valid          ),
  .quotient_o ( b_corr                ),
  .reminder_o (                       )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    b_corr_o <= FIXED_ONE;
  else
    if( r_corr_valid )
      b_corr_o <= r_corr;

endmodule
