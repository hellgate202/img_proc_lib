`include "../../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../../lib/axi4_lib/src/class/AXI4StreamSlave.sv"

`timescale 1 ps / 1 ps

module tb_bilinear_demosaicing_3x3;

parameter int    CLK_T           = 6734;
parameter int    RAW_PX_WIDTH    = 10;
parameter int    FRAME_RES_X     = 1920;
parameter int    FRAME_RES_Y     = 1080;
parameter int    TOTAL_X         = 2200;
parameter int    TOTAL_Y         = 1125;
parameter string FILE_PATH       = "./img.hex";
parameter int    RANDOM_TVALID   = 1;
parameter int    RANDOM_TREADY   = 1;
parameter int    RGB_TDATA_WIDTH = ( RAW_PX_WIDTH * 3 ) % 8 ?
                                   ( RAW_PX_WIDTH * 3 / 8 + 1 ) * 8 :
                                   RAW_PX_WIDTH * 3 * 8;
parameter int    RAW_TDATA_WIDTH = RAW_PX_WIDTH % 8 ?
                                   ( RAW_PX_WIDTH  / 8 + 1 ) * 8 :
                                   RAW_PX_WIDTH * 8;

localparam bit [1 : 0] GBRG = 2'b00;
localparam bit [1 : 0] BGGR = 2'b01;
localparam bit [1 : 0] GRBG = 2'b10;
localparam bit [1 : 0] RGGB = 2'b11;

bit clk;
bit rst;

mailbox rx_video_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( RAW_TDATA_WIDTH ),
  .TID_WIDTH   ( 1               ),
  .TDEST_WIDTH ( 1               ),
  .TUSER_WIDTH ( 1               )
) raw_video (
  .aclk        ( clk             ),
  .aresetn     ( !rst            )
);

axi4_stream_if #(
  .TDATA_WIDTH ( RGB_TDATA_WIDTH ),
  .TID_WIDTH   ( 1               ),
  .TDEST_WIDTH ( 1               ),
  .TUSER_WIDTH ( 1               )
) rgb_video (
  .aclk        ( clk             ),
  .aresetn     ( !rst            )
);

demosaicing_ctrl_if demosaicing_ctrl();

assign demosaicing_ctrl.en      = 1'b1;
assign demosaicing_ctrl.pattern = RGGB;

AXI4StreamVideoSource #(
  .PX_WIDTH      ( RAW_PX_WIDTH  ),
  .FRAME_RES_X   ( FRAME_RES_X   ),
  .FRAME_RES_Y   ( FRAME_RES_Y   ),
  .TOTAL_X       ( TOTAL_X       ),
  .TOTAL_Y       ( TOTAL_Y       ),
  .FILE_PATH     ( FILE_PATH     ),
  .RANDOM_TVALID ( RANDOM_TVALID )
) video_source;

AXI4StreamSlave #(
  .TDATA_WIDTH   ( RGB_TDATA_WIDTH ),
  .TID_WIDTH     ( 1               ),
  .TDEST_WIDTH   ( 1               ),
  .TUSER_WIDTH   ( 1               ),
  .RANDOM_TREADY ( RANDOM_TREADY   )
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
  bit [RGB_TDATA_WIDTH - 1 : 0] rx_px;

  int rx_file = $fopen( "./rx_img.hex", "w" );

  forever
    begin
      if( rx_video_mbx.num() > 0 )
        begin
          rx_video_mbx.get( rx_bytes );
          if( rx_bytes.size() != ( ( FRAME_RES_X - 2 ) * ( RGB_TDATA_WIDTH / 8 ) ) )
            begin
              $display( "Wrong size of the line: %0d. Should be %0d", rx_bytes.size(), ( FRAME_RES_X - 2 ) * ( RGB_TDATA_WIDTH / 8 ) );
              $stop();
            end 
          while( rx_bytes.size() > 0 )
            begin
              for( int i = 0; i < ( RGB_TDATA_WIDTH / 8 ); i++ )
                rx_px[( i + 1 ) * 8 - 1 -: 8] = rx_bytes.pop_front();
              $fwrite( rx_file, "%0h", rx_px[RAW_PX_WIDTH - 1 : 0] );
              $fwrite( rx_file, "\n" );
              $fwrite( rx_file, "%0h", rx_px[RAW_PX_WIDTH * 2 - 1 -: RAW_PX_WIDTH] );
              $fwrite( rx_file, "\n" );
              $fwrite( rx_file, "%0h", rx_px[RAW_PX_WIDTH * 3 - 1 -: RAW_PX_WIDTH] );
              $fwrite( rx_file, "\n" );
            end
        end
      else
        @( posedge clk );
    end
endtask

bilinear_demosaicing_3x3 #(
  .RAW_PX_WIDTH       ( RAW_PX_WIDTH     ),
  .MAX_LINE_SIZE      ( FRAME_RES_X      )
) DUT (
  .clk_i              ( clk              ),
  .rst_i              ( rst              ),
  .demosaicing_ctrl_i ( demosaicing_ctrl ),
  .raw_video_i        ( raw_video        ),
  .rgb_video_o        ( rgb_video        )
);

initial
  begin
    video_source = new( raw_video );
    video_sink   = new( .axi4_stream_if_v ( rgb_video    ),
                        .rx_data_mbx      ( rx_video_mbx ) );
    fork
      clk_gen();
      apply_rst();
      video_recorder();
    join_none
    repeat( 10 )
      @( posedge clk );
    video_source.run();
    repeat( 2 )
      begin
        while( !( rgb_video.tvalid && rgb_video.tready && rgb_video.tuser ) )
          @( posedge clk );
        @( posedge clk );
      end
    $stop();
  end

endmodule
