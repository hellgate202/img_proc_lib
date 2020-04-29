`include "../../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../../lib/axi4_lib/src/class/AXI4StreamSlave.sv"
`include "../../lib/axi4_lib/src/class/AXI4LiteMaster.sv"

`timescale 1 ps / 1 ps

module tb_frame_extender;

parameter int    CLK_T              = 6734;
parameter int    PX_WIDTH           = 30;
parameter int    TOP                = 1;
parameter int    BOTTOM             = 1;
parameter int    LEFT               = 1;
parameter int    RIGHT              = 1;
parameter int    FRAME_RES_X        = 1920;
parameter int    FRAME_RES_Y        = 1080;
parameter int    TOTAL_X            = 2200;
parameter int    TOTAL_Y            = 1125;
parameter string FILE_PATH          = "./img.hex";
parameter int    RANDOM_TVALID      = 1;
parameter int    RANDOM_TREADY      = 1;
parameter int    TDATA_WIDTH        = PX_WIDTH % 8 ?
                                      ( PX_WIDTH  / 8 + 1 ) * 8 :
                                      PX_WIDTH * 8;
parameter int    FRAMES_AMOUNT      = 1;
parameter        EOF_STRATEGY       = "FIXED";
parameter int    ALLOW_BACKPRESSURE = 0;
parameter int    MIN_INTERLINE_GAP  = TOTAL_X - FRAME_RES_X;

bit clk;
bit rst;

int line_cnt;

mailbox rx_video_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           )
) video_i (
  .aclk        ( clk         ),
  .aresetn     ( !rst        )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           )
) video_o (
  .aclk        ( clk         ),
  .aresetn     ( !rst        )
);

AXI4StreamVideoSource #(
  .PX_WIDTH      ( PX_WIDTH      ),
  .FRAME_RES_X   ( FRAME_RES_X   ),
  .FRAME_RES_Y   ( FRAME_RES_Y   ),
  .TOTAL_X       ( TOTAL_X       ),
  .TOTAL_Y       ( TOTAL_Y       ),
  .FILE_PATH     ( FILE_PATH     ),
  .RANDOM_TVALID ( RANDOM_TVALID )
) video_source;

AXI4StreamSlave #(
  .TDATA_WIDTH   ( TDATA_WIDTH   ),
  .TID_WIDTH     ( 1             ),
  .TDEST_WIDTH   ( 1             ),
  .TUSER_WIDTH   ( 1             ),
  .RANDOM_TREADY ( RANDOM_TREADY )
) video_sink;

task automatic clk_gen();

forever
  begin
    #( CLK_T / 2 );
    clk = !clk;
  end

endtask

task automatic apply_rst();

@( posedge clk );
rst <= 1'b1;
@( posedge clk );
rst <= 1'b0;
@( posedge clk );

endtask

task automatic video_recorder();
  
  bit [7 : 0] rx_bytes [$]; 
  bit [TDATA_WIDTH - 1 : 0] rx_px;

  int rx_file = $fopen( "./rx_img.hex", "w" );

  forever
    begin
      if( rx_video_mbx.num() > 0 )
        begin
          rx_video_mbx.get( rx_bytes );
          if( rx_bytes.size() != ( ( FRAME_RES_X + LEFT + RIGHT ) * ( TDATA_WIDTH / 8 ) ) )
            begin
              $display( "Wrong size of the line: %0d. Should be %0d", rx_bytes.size(), ( FRAME_RES_X + LEFT + RIGHT ) * ( TDATA_WIDTH / 8 ) );
              $stop();
            end 
          while( rx_bytes.size() > 0 )
            begin
              for( int i = 0; i < ( TDATA_WIDTH / 8 ); i++ )
                rx_px[( i + 1 ) * 8 - 1 -: 8] = rx_bytes.pop_front();
              $fwrite( rx_file, "%0h", rx_px[PX_WIDTH / 3 - 1 : 0] );
              $fwrite( rx_file, "\n" );
              $fwrite( rx_file, "%0h", rx_px[PX_WIDTH / 3 * 2 - 1 -: PX_WIDTH / 3] );
              $fwrite( rx_file, "\n" );
              $fwrite( rx_file, "%0h", rx_px[PX_WIDTH / 3 * 3 - 1 -: PX_WIDTH / 3] );
              $fwrite( rx_file, "\n" );
            end
          line_cnt++;
        end
      else
        @( posedge clk );
    end
endtask

frame_extender #(
  .TOP                ( TOP                ),
  .BOTTOM             ( BOTTOM             ),
  .LEFT               ( LEFT               ),
  .RIGHT              ( RIGHT              ),
  .FRAME_RES_X        ( FRAME_RES_X        ),
  .FRAME_RES_Y        ( FRAME_RES_Y        ),
  .PX_WIDTH           ( PX_WIDTH           ),
  .EOF_STRATEGY       ( EOF_STRATEGY       ),
  .ALLOW_BACKPRESSURE ( ALLOW_BACKPRESSURE ),
  .MIN_INTERLINE_GAP  ( MIN_INTERLINE_GAP  )
) DUT (
  .clk_i              ( clk                ),
  .rst_i              ( rst                ),
  .video_i            ( video_i            ),
  .video_o            ( video_o            )
);

initial
  begin
    video_source = new( video_i );
    video_sink   = new( .axi4_stream_if_v ( video_o      ),
                        .rx_data_mbx      ( rx_video_mbx ) );
    fork
      clk_gen();
      apply_rst();
      video_recorder();
    join_none
    repeat( 10 )
      @( posedge clk );
    video_source.run();
    repeat( FRAMES_AMOUNT + 1 )
      begin
        while( !( video_o.tvalid && video_o.tready && video_o.tuser ) )
          @( posedge clk );
        @( posedge clk );
      end
    @( posedge clk );
    if( line_cnt != ( FRAME_RES_Y + TOP + BOTTOM ) * FRAMES_AMOUNT )
      $display( "Wrong frame size! Was %0d, should be %0d", line_cnt, ( FRAME_RES_Y + TOP + BOTTOM ) * FRAMES_AMOUNT );
    else
      $display( "Everything is fine" );
    $stop();
  end

endmodule
