module median_filter #(
  parameter int CHANNELS_AMOUNT   = 3,
  parameter int PX_WIDTH          = 10,
  parameter int WIN_SIZE          = 5,
  parameter int FRAME_RES_X       = 1920,
  parameter int FRAME_RES_Y       = 1080,
  parameter int COMPENSATE_EN     = 1,
  parameter int INTERLINE_GAP     = 200
)(
  input                 clk_i,
  input                 rst_i,
  mf_ctrl_if.slave      mf_ctrl_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int COMP_TDATA_WIDTH   = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 :
                                    PX_WIDTH;
localparam int COMP_TDATA_WIDTH_B = COMP_TDATA_WIDTH / 8;
localparam int WIN_WIDTH          = PX_WIDTH * WIN_SIZE * WIN_SIZE;
localparam int WIN_TDATA_WIDTH    = WIN_WIDTH % 8 ?
                                    ( WIN_WIDTH / 8 + 1 ) * 8 :
                                    WIN_WIDTH;
localparam int TDATA_WIDTH        = PX_WIDTH % 8 ? 
                                    ( PX_WIDTH * CHANNELS_AMOUNT / 8 + 1 ) * 8 :
                                    PX_WIDTH * CHANNELS_AMOUNT;
localparam int TDATA_WIDTH_B      = TDATA_WIDTH / 8;
localparam int DELAY_VALUE        = 2 * ( WIN_SIZE + 1 ) + 4;
localparam int MEDIAN_POS         = WIN_SIZE / 2;
localparam int EXTEND_VALUE       = WIN_SIZE / 2;
localparam int WIN_CENTER         = ( WIN_SIZE ** 2 ) / 2;

logic [CHANNELS_AMOUNT - 1 : 0][PX_WIDTH - 1 : 0] median_value;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) extended_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

generate
  if( COMPENSATE_EN )
    begin : duplicator
      frame_extender #(
        .TOP                ( EXTEND_VALUE               ),
        .BOTTOM             ( EXTEND_VALUE               ),
        .LEFT               ( EXTEND_VALUE               ),
        .RIGHT              ( EXTEND_VALUE               ),
        .FRAME_RES_X        ( FRAME_RES_X                ),
        .FRAME_RES_Y        ( FRAME_RES_Y                ),
        .PX_WIDTH           ( PX_WIDTH * CHANNELS_AMOUNT ),
        .EOF_STRATEGY       ( "FIXED"                    ),
        .ALLOW_BACKPRESSURE ( 0                          ),
        .MIN_INTERLINE_GAP  ( INTERLINE_GAP              )
      ) frame_extender_inst (
        .clk_i              ( clk_i                      ),
        .rst_i              ( rst_i                      ),
        .video_i            ( video_i                    ),
        .video_o            ( extended_video             )
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
  .TDATA_WIDTH ( COMP_TDATA_WIDTH ),
  .TUSER_WIDTH ( 1                ),
  .TID_WIDTH   ( 1                ),
  .TDEST_WIDTH ( 1                )
) comp_stream [CHANNELS_AMOUNT - 1 : 0] (
  .aclk        ( clk_i            ),
  .aresetn     ( !rst_i           )
);

axi4_stream_if #(
  .TDATA_WIDTH ( WIN_TDATA_WIDTH ),
  .TUSER_WIDTH ( 1               ),
  .TID_WIDTH   ( 1               ),
  .TDEST_WIDTH ( 1               )
) comp_win_stream [CHANNELS_AMOUNT - 1 : 0] (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

axi4_stream_if #(
  .TDATA_WIDTH ( WIN_TDATA_WIDTH ),
  .TUSER_WIDTH ( 1               ),
  .TID_WIDTH   ( 1               ),
  .TDEST_WIDTH ( 1               )
) bypass_stream (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_d [DELAY_VALUE - 1 : 0] (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

genvar c, p, sr, se;

generate
  if( ( PX_WIDTH * CHANNELS_AMOUNT ) == TDATA_WIDTH )
    begin : n_append_bypass
      for( c = 0; c < CHANNELS_AMOUNT; c++ )
        assign bypass_stream.tdata[PX_WIDTH * ( c + 1 ) - 1 -: PX_WIDTH] = comp_win_stream[c].tdata[( WIN_CENTER + 1 ) * PX_WIDTH - 1 -: PX_WIDTH];
    end
  else
    begin : append_bypass
      assign bypass_stream.tdata[TDATA_WIDTH - 1 : PX_WIDTH * CHANNELS_AMOUNT] = ( TDATA_WIDTH - PX_WIDTH * CHANNELS_AMOUNT )'( 0 );
      for( c = 0; c < CHANNELS_AMOUNT; c++ )
        assign bypass_stream.tdata[PX_WIDTH * ( c + 1 ) - 1 -: PX_WIDTH] = comp_win_stream[c].tdata[( WIN_CENTER + 1 ) * PX_WIDTH - 1 -: PX_WIDTH];
    end
endgenerate

assign bypass_stream.tvalid = comp_win_stream[0].tvalid;
assign bypass_stream.tlast  = comp_win_stream[0].tlast;
assign bypass_stream.tuser  = comp_win_stream[0].tuser;
assign bypass_stream.tstrb  = comp_win_stream[0].tstrb;
assign bypass_stream.tkeep  = comp_win_stream[0].tkeep;
assign bypass_stream.tdest  = comp_win_stream[0].tdest;
assign bypass_stream.tid    = comp_win_stream[0].tid;

assign extended_video.tready = comp_stream[0].tready;

generate
  for( c = 0; c < CHANNELS_AMOUNT; c++ )
    begin : win_for_color
      assign comp_stream[c].tvalid = extended_video.tvalid;
      assign comp_stream[c].tlast  = extended_video.tlast;
      assign comp_stream[c].tuser  = extended_video.tuser;
      assign comp_stream[c].tstrb  = extended_video.tstrb;
      assign comp_stream[c].tkeep  = extended_video.tkeep;
      assign comp_stream[c].tdest  = extended_video.tdest;
      assign comp_stream[c].tid    = extended_video.tid;
      assign comp_stream[c].tdata  = extended_video.tdata[( c + 1 ) * PX_WIDTH - 1 -: PX_WIDTH];

      window_buf #(
        .TDATA_WIDTH   ( COMP_TDATA_WIDTH   ),
        .PX_WIDTH      ( PX_WIDTH           ),
        .WIN_SIZE      ( WIN_SIZE           ),
        .MAX_LINE_SIZE ( FRAME_RES_X        )
      ) window_buf_inst (
        .clk_i         ( clk_i              ),
        .rst_i         ( rst_i              ),
        .video_i       ( comp_stream[c]     ),
        .window_data_o ( comp_win_stream[c] )
      );
    end
endgenerate

generate
  for( c = 0; c < CHANNELS_AMOUNT; c++ )
    begin : median_calc
      logic [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][PX_WIDTH - 1 : 0] unsorted_data;
      logic [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][PX_WIDTH - 1 : 0] sorted_row;
      logic [WIN_SIZE - 1 : 0]                                     sorted_row_valid;
      logic [2 : 0]                                                extremum_sort_ready;
      logic [2 : 0][WIN_SIZE - 1 : 0][PX_WIDTH - 1 : 0]            extremums;
      logic [2 : 0][WIN_SIZE - 1 : 0][PX_WIDTH - 1 : 0]            sorted_extremums;
      logic [2 : 0]                                                sorted_extremums_valid;
      logic                                                        median_sort_ready;
      logic [2 : 0][PX_WIDTH - 1 : 0]                              median_candidates;
      logic [2 : 0][PX_WIDTH - 1 : 0]                              sorted_median_candidates;

      assign unsorted_data = comp_win_stream[c].tdata[WIN_WIDTH - 1 : 0];

      for( sr = 0; sr < WIN_SIZE; sr++ )
        begin : sort_rows
          sorting_network #(
            .NUMBER_WIDTH   ( PX_WIDTH                  ),
            .NUMBERS_AMOUNT ( WIN_SIZE                  )
          ) sorting_network_inst (
            .clk_i          ( clk_i                     ),
            .rst_i          ( rst_i                     ),
            .data_i         ( unsorted_data[sr]         ),
            .data_valid_i   ( comp_win_stream[c].tvalid ),
            .ready_o        (                           ),
            .data_o         ( sorted_row[sr]            ),
            .data_valid_o   ( sorted_row_valid[sr]      ),
            .ready_i        ( extremum_sort_ready[0]    )
          );

          assign extremums[0][sr] = sorted_row[sr][0];
          assign extremums[1][sr] = sorted_row[sr][MEDIAN_POS];
          assign extremums[2][sr] = sorted_row[sr][WIN_SIZE - 1];
        end

      assign comp_win_stream[c].tready = bypass_stream.tready;

      for( se = 0; se < 3; se++ )
        begin : sort_extremums
          sorting_network #(
            .NUMBER_WIDTH   ( PX_WIDTH                   ),
            .NUMBERS_AMOUNT ( WIN_SIZE                   )
          ) sorting_network_inst (
            .clk_i          ( clk_i                      ),
            .rst_i          ( rst_i                      ),
            .data_i         ( extremums[se]              ),
            .data_valid_i   ( sorted_row_valid[0]        ),
            .ready_o        ( extremum_sort_ready[se]    ),
            .data_o         ( sorted_extremums[se]       ),
            .data_valid_o   ( sorted_extremums_valid[se] ),
            .ready_i        ( median_sort_ready          )
          );
        end

      assign median_candidates[0] = sorted_extremums[0][0];
      assign median_candidates[1] = sorted_extremums[1][MEDIAN_POS];
      assign median_candidates[2] = sorted_extremums[2][WIN_SIZE - 1];

      sorting_network #(
        .NUMBER_WIDTH   ( PX_WIDTH                  ),
        .NUMBERS_AMOUNT ( 3                         )
      ) sorting_network_inst (
        .clk_i          ( clk_i                     ),
        .rst_i          ( rst_i                     ),
        .data_i         ( median_candidates         ),
        .data_valid_i   ( sorted_extremums_valid[0] ),
        .ready_o        ( median_sort_ready         ),
        .data_o         ( sorted_median_candidates  ),
        .data_valid_o   (                           ),
        .ready_i        ( video_o.tready            )
      );

      assign median_value[c] = sorted_median_candidates[1];
    end
endgenerate

genvar d;

generate
  for( d = 0; d < DELAY_VALUE; d++ )
    if( d == 0 )
      begin : first_stage
        axi4_stream_delay #(
          .TDATA_WIDTH ( TDATA_WIDTH   ),
          .TUSER_WIDTH ( 1             ),
          .TDEST_WIDTH ( 1             ),
          .TID_WIDTH   ( 1             )
        ) delay_0 (
          .clk_i       ( clk_i         ),
          .rst_i       ( rst_i         ),
          .pkt_i       ( bypass_stream ),
          .pkt_o       ( video_d[0]    )
        ); 
      end
    else
      begin : later_stages
        axi4_stream_delay #(
          .TDATA_WIDTH ( TDATA_WIDTH    ),
          .TUSER_WIDTH ( 1              ),
          .TDEST_WIDTH ( 1              ),
          .TID_WIDTH   ( 1              )
        ) delay_0 (
          .clk_i       ( clk_i          ),
          .rst_i       ( rst_i          ),
          .pkt_i       ( video_d[d - 1] ),
          .pkt_o       ( video_d[d]     )
        ); 
      end
endgenerate

assign video_d[DELAY_VALUE - 1].tready = video_o.tready;

assign video_o.tvalid = video_d[DELAY_VALUE - 1].tvalid;
assign video_o.tlast  = video_d[DELAY_VALUE - 1].tlast;
assign video_o.tuser  = video_d[DELAY_VALUE - 1].tuser;
assign video_o.tstrb  = TDATA_WIDTH_B'( TDATA_WIDTH_B ** 2 - 1 );
assign video_o.tkeep  = TDATA_WIDTH_B'( TDATA_WIDTH_B ** 2 - 1 );
assign video_o.tid    = video_d[DELAY_VALUE - 1].tid;
assign video_o.tdest  = video_d[DELAY_VALUE - 1].tdest;

generate
  if( ( PX_WIDTH * CHANNELS_AMOUNT ) == TDATA_WIDTH )
    begin : n_append_output
      for( c = 0; c < CHANNELS_AMOUNT; c++ )
        assign video_o.tdata[PX_WIDTH * ( c + 1 ) - 1 -: PX_WIDTH] = mf_ctrl_i.en ? median_value[c] : video_d[DELAY_VALUE - 1].tdata[PX_WIDTH * ( c + 1 ) - 1 -: PX_WIDTH];
    end
  else
    begin : append_output
      assign video_o.tdata[TDATA_WIDTH - 1 : PX_WIDTH * CHANNELS_AMOUNT] = ( TDATA_WIDTH - PX_WIDTH * CHANNELS_AMOUNT )'( 0 );
      for( c = 0; c < CHANNELS_AMOUNT; c++ )
        assign video_o.tdata[PX_WIDTH * ( c + 1 ) - 1 -: PX_WIDTH] = mf_ctrl_i.en ? median_value[c] : video_d[DELAY_VALUE - 1].tdata[PX_WIDTH * ( c + 1 ) - 1 -: PX_WIDTH];
    end
endgenerate


endmodule
