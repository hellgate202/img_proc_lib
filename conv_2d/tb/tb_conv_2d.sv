`include "../../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../../lib/axi4_lib/src/class/AXI4StreamSlave.sv"
`include "../../lib/axi4_lib/src/class/AXI4LiteMaster.sv"

`timescale 1 ps / 1 ps

module tb_conv_2d;

parameter int    CLK_T           = 6734;
parameter int    PX_WIDTH        = 8;
parameter int    FRAME_RES_X     = 1920;
parameter int    FRAME_RES_Y     = 1080;
parameter int    COMPENSATE_EN   = 1;
parameter int    TOTAL_X         = 2200;
parameter int    TOTAL_Y         = 1125;
parameter string FILE_PATH       = "./img.hex";
parameter int    RANDOM_TVALID   = 0;
parameter int    RANDOM_TREADY   = 0;
parameter int    TDATA_WIDTH     = PX_WIDTH % 8 ?
                                   ( PX_WIDTH / 8 + 1 ) * 8 :
                                   PX_WIDTH;
parameter int    GAP             = TOTAL_X - FRAME_RES_X;
parameter int    WIN_SIZE        = 3;

bit clk;
bit rst;
bit [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][PX_WIDTH - 1 : 0] coef = {8'd129, 8'd130, 8'd129, 8'd0, 8'd0, 8'd0, 8'd1, 8'd2, 8'd1 };

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
          if( rx_bytes.size() != ( FRAME_RES_X * ( TDATA_WIDTH / 8 ) ) )
            begin
              $display( "Wrong size of the line: %0d. Should be %0d", rx_bytes.size(), ( FRAME_RES_X * ( TDATA_WIDTH / 8 ) ) );
              $stop();
            end 
          while( rx_bytes.size() > 0 )
            begin
              for( int i = 0; i < ( TDATA_WIDTH / 8 ); i++ )
                rx_px[( i + 1 ) * 8 - 1 -: 8] = rx_bytes.pop_front();
              $fwrite( rx_file, "%0h", rx_px[PX_WIDTH - 1 : 0] );
              $fwrite( rx_file, "\n" );
            end
        end
      else
        @( posedge clk );
    end
endtask

conv_2d #(
  .COEF_WIDTH    ( PX_WIDTH    ),
  .PX_WIDTH      ( PX_WIDTH    ),
  .TDATA_WIDTH   ( TDATA_WIDTH ),
  .WIN_SIZE      ( 3           ),
  .FRAME_RES_X   ( FRAME_RES_X ),
  .FRAME_RES_Y   ( FRAME_RES_Y ),
  .INTERLINE_GAP ( GAP         ),
  .COMPENSATE_EN ( 1           )
) DUT (
  .clk_i         ( clk         ),
  .rst_i         ( rst         ),
  .coef_i        ( coef        ),
  .video_i       ( video_i     ),
  .video_o       ( video_o     )
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
    repeat( 2 )
      begin
        while( !( video_o.tvalid && video_o.tready && video_o.tuser ) )
          @( posedge clk );
        @( posedge clk );
      end
    $stop();
  end

endmodule
