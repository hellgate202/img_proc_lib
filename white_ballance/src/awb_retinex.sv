module awb_retinex #(
  parameter int PX_WIDTH    = 10,
  parameter int FRACT_WIDTH = 10,
  parameter int COEF_WIDTH  = PX_WIDTH + FRACT_WIDTH
)(
  input                             clk_i,
  input                             rst_i,
  axi4_stream_if.slave              video_i,
  output logic [COEF_WIDTH - 1 : 0] r_corr_o,
  output logic [COEF_WIDTH - 1 : 0] b_corr_o
);

localparam bit [COEF_WIDTH - 1 : 0] FIXED_ONE = { PX_WIDTH'( 1 ), FRACT_WIDTH'( 0 ) };

logic [PX_WIDTH - 1 : 0]   r_max;
logic [PX_WIDTH - 1 : 0]   g_max;
logic [PX_WIDTH - 1 : 0]   b_max;
logic [COEF_WIDTH - 1 : 0] g_max_fixed;
logic                      corr_calc_start;
logic [COEF_WIDTH - 1 : 0] r_corr;
logic [COEF_WIDTH - 1 : 0] b_corr;
logic                      r_corr_valid;
logic                      b_corr_valid;

assign video_i.tready  = 1'b1;
assign corr_calc_start = video_i.tvalid && video_i.tready && video_i.tuser;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      r_max <= PX_WIDTH'( 0 );
      g_max <= PX_WIDTH'( 0 );
      b_max <= PX_WIDTH'( 0 );
    end
  else
    if( video_i.tvalid && video_i.tready )
      if( video_i.tuser )
        begin
          r_max <= video_i.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH];
          g_max <= video_i.tdata[PX_WIDTH - 1 -: PX_WIDTH];
          b_max <= video_i.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH];
        end
      else
        begin
          if( video_i.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH] > r_max )
            r_max <= video_i.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH];
          if( video_i.tdata[PX_WIDTH - 1 -: PX_WIDTH] > g_max )
            g_max <= video_i.tdata[PX_WIDTH - 1 -: PX_WIDTH];
          if( video_i.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH] > b_max )
            b_max <= video_i.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH];
        end

assign g_max_fixed = COEF_WIDTH'( g_max ) << FRACT_WIDTH;

division #(
  .WORD_W     ( COEF_WIDTH           )
) r_corr_calc (
  .clk_i      ( clk_i                ),
  .rst_i      ( rst_i                ),
  .start_i    ( corr_calc_start      ),
  .divinded_i ( g_max_fixed          ),
  .divisor_i  ( COEF_WIDTH'( r_max ) ),
  .ready_o    (                      ),
  .valid_o    ( r_corr_valid         ),
  .quotient_o ( r_corr               ),
  .reminder_o (                      )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    r_corr_o <= FIXED_ONE;
  else
    if( r_corr_valid )
      r_corr_o <= r_corr;

division #(
  .WORD_W     ( COEF_WIDTH           )
) b_corr_calc (
  .clk_i      ( clk_i                ),
  .rst_i      ( rst_i                ),
  .start_i    ( corr_calc_start      ),
  .divinded_i ( g_max_fixed          ),
  .divisor_i  ( COEF_WIDTH'( b_max ) ),
  .ready_o    (                      ),
  .valid_o    ( b_corr_valid         ),
  .quotient_o ( b_corr               ),
  .reminder_o (                      )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    b_corr_o <= FIXED_ONE;
  else
    if( r_corr_valid )
      b_corr_o <= r_corr;

endmodule
