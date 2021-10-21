module conv_2d #(
  parameter int COEF_WIDTH    = 8,
  parameter int PX_WIDTH      = 8,
  parameter int TDATA_WIDTH   = 8,
  parameter int WIN_SIZE      = 3,
  parameter int FRAME_RES_X   = 1920,
  parameter int FRAME_RES_Y   = 1080,
  parameter int INTERLINE_GAP = 100,
  parameter int COMPENSATE_EN = 1
)(
  input                                                          clk_i,
  input                                                          rst_i,
  input [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][COEF_WIDTH - 1 : 0] coef_i,
  axi4_stream_if.slave                                           video_i,
  axi4_stream_if.master                                          video_o
);

localparam int WIN_WIDTH        = PX_WIDTH * WIN_SIZE * WIN_SIZE;
localparam int WIN_TDATA_WIDTH  = WIN_WIDTH % 8 ?
                                  ( WIN_WIDTH / 8 + 1 ) * 8 :
                                  WIN_WIDTH;
localparam int MULT_WIDTH       = COEF_WIDTH + PX_WIDTH;
localparam int MULT_WIN_WIDTH   = MULT_WIDTH * WIN_SIZE * WIN_SIZE;
localparam int MULT_TDATA_WIDTH = MULT_WIN_WIDTH % 8 ?
                                  ( MULT_WIN_WIDTH / 8 + 1 ) * 8 :
                                  MULT_WIN_WIDTH;
localparam int SUM_WIDTH        = MULT_WIDTH + $clog2( WIN_SIZE * WIN_SIZE );
localparam int ADD_DELAY        = $clog2( WIN_SIZE * WIN_SIZE ) + 1;

function logic [MULT_WIDTH - 1 : 0] signed_abs_to_tc(
  input [MULT_WIDTH - 1 : 0] signed_abs
);

logic [MULT_WIDTH - 1 : 0] abs;

abs[MULT_WIDTH - 2 : 0] = signed_abs[MULT_WIDTH - 2 : 0];
abs[MULT_WIDTH - 1]     = 1'b0;

if( signed_abs[MULT_WIDTH - 1] )
  signed_abs_to_tc = ~abs + 1'b1;
else
  signed_abs_to_tc = abs;

endfunction

logic [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][PX_WIDTH - 1 : 0]   raw_window;
logic [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][MULT_WIDTH - 1 : 0] mult_window;
logic [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][MULT_WIDTH - 1 : 0] tc_mult_window;
logic                                                          adder_valid;
logic                                                          adder_ready;
logic [SUM_WIDTH - 1 : 0]                                      mult_sum;
logic                                                          sum_valid;
logic                                                          sum_ready;
logic                                                          tuser_delay_mult;
logic                                                          tlast_delay_mult;
logic [ADD_DELAY - 1 : 0]                                      tuser_delay_add;
logic [ADD_DELAY - 1 : 0]                                      tlast_delay_add;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           )
) extended_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

generate
  if( COMPENSATE_EN )
    begin : duplicator
      frame_extender #(
        .TOP                ( WIN_SIZE / 2   ),
        .BOTTOM             ( WIN_SIZE / 2   ),
        .LEFT               ( WIN_SIZE / 2   ),
        .RIGHT              ( WIN_SIZE / 2   ),
        .FRAME_RES_X        ( FRAME_RES_X    ),
        .FRAME_RES_Y        ( FRAME_RES_Y    ),
        .PX_WIDTH           ( PX_WIDTH       ),
        .EOF_STRATEGY       ( "FIXED"        ),
        .ALLOW_BACKPRESSURE ( 0              ),
        .MIN_INTERLINE_GAP  ( INTERLINE_GAP  )
      ) frame_extender_inst (
        .clk_i              ( clk_i          ),
        .rst_i              ( rst_i          ),
        .video_i            ( video_i        ),
        .video_o            ( extended_video )
      );
    end
  else
    begin : passthrough
      assign extended_video.tvalid = video_i.tvalid;
      assign extended_video.tdata  = video_i.tdata;
      assign extended_video.tlast  = video_i.tlast;
      assign extended_video.tuser  = video_i.tuser;
      assign extended_video.tstrb  = video_i.tstrb;
      assign extended_video.tkeep  = video_i.tkeep;
      assign extended_video.tid    = video_i.tid;
      assign extended_video.tdest  = video_i.tdest;
      assign video_i.tready        = extended_video.tready;
    end
endgenerate

axi4_stream_if #(
  .TDATA_WIDTH ( WIN_TDATA_WIDTH ),
  .TID_WIDTH   ( 1               ),
  .TDEST_WIDTH ( 1               ),
  .TUSER_WIDTH ( 1               )
) win_stream (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

window_buf #(
  .TDATA_WIDTH   ( TDATA_WIDTH    ),
  .PX_WIDTH      ( PX_WIDTH       ),
  .WIN_SIZE      ( WIN_SIZE       ),
  .MAX_LINE_SIZE ( FRAME_RES_X    )
) window_maker_inst (
  .clk_i         ( clk_i          ),
  .rst_i         ( rst_i          ),
  .video_i       ( extended_video ),
  .window_data_o ( win_stream     )
);

assign raw_window = win_stream.tdata[WIN_WIDTH - 1 : 0];

assign win_stream.tready = adder_ready || !adder_valid;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      adder_valid      <= 1'b0;
      tuser_delay_mult <= 1'b0;
      tlast_delay_mult <= 1'b0;
    end
  else
    if( win_stream.tready )
      begin
        adder_valid      <= win_stream.tvalid;
        tuser_delay_mult <= win_stream.tuser;
        tlast_delay_mult <= win_stream.tlast;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mult_window <= MULT_WIN_WIDTH'( 0 );
  else
    if( win_stream.tready )
      for( int i = 0; i < WIN_SIZE; i++ )
        for( int j = 0; j < WIN_SIZE; j++ )
          begin
            mult_window[i][j]                 <= raw_window[i][j] * coef_i[i][j][COEF_WIDTH - 2 : 0];
            mult_window[i][j][MULT_WIDTH - 1] <= coef_i[i][j][COEF_WIDTH - 1];
          end

always_comb
  for( int i = 0; i < WIN_SIZE; i++ )
    for( int j = 0; j < WIN_SIZE; j++ )
      tc_mult_window[i][j] = signed_abs_to_tc( mult_window[i][j] );

pipeline_adder #(
  .NUMBERS_AMOUNT ( WIN_SIZE * WIN_SIZE ),
  .NUMBER_WIDTH   ( MULT_WIDTH          ),
  .SIGNED         ( 1                   )
) sum_of_window (
  .clk_i          ( clk_i               ),
  .rst_i          ( rst_i               ),
  .data_i         ( tc_mult_window      ),
  .data_valid_i   ( adder_valid         ),
  .ready_o        ( adder_ready         ),
  .data_o         ( mult_sum            ),
  .data_valid_o   ( sum_valid           ),
  .ready_i        ( sum_ready           )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      tuser_delay_add <= ADD_DELAY'( 0 );
      tlast_delay_add <= ADD_DELAY'( 0 );
    end
  else
    if( adder_ready )
      begin
        tuser_delay_add[0] <= tuser_delay_mult;
        tlast_delay_add[0] <= tlast_delay_mult;
        for( int i = 1; i < ADD_DELAY; i++ )
          begin
            tuser_delay_add[i] <= tuser_delay_add[i - 1];
            tlast_delay_add[i] <= tlast_delay_add[i - 1];
          end
      end

assign video_o.tvalid = sum_valid;
assign video_o.tdata  = mult_sum[SUM_WIDTH - 1] ? '0 :
                        mult_sum[SUM_WIDTH - 2 : PX_WIDTH] ? TDATA_WIDTH'( 2 ** PX_WIDTH - 1 ) :
                        TDATA_WIDTH'( mult_sum );
assign video_o.tlast  = tlast_delay_add[ADD_DELAY - 1];
assign video_o.tuser  = tuser_delay_add[ADD_DELAY - 1];
assign video_o.tkeep  = '1;
assign video_o.tstrb  = '1;
assign sum_ready      = video_o.tready;

endmodule
