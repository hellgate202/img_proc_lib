`include "../../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../../lib/axi4_lib/src/class/AXI4StreamSlave.sv"

`timescale 1 ps / 1 ps

module tb_bilinear_demosaicing_3x3;

parameter int CLK_T         = 6734;
parameter int RAW_PX_WIDTH  = 10;
parameter int FRAME_RES_X   = 1920;
parameter int FRAME_RES_Y   = 1080;
parameter int TOTAL_X       = 2200;
parameter int TOTAL_Y       = 1125;
parameter int FILE_PATH     = "../img.hex";
parameter int RANDOM_TVALID = 0;
parameter int RANDOM_TREADY = 0;

bit clk;
bit rst;

mailbox rx_video_mbx = new();

axi4_stream_if #(
  .TDATA_WIDTH ( 16   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TKEEP_WIDTH ( 1    )
) raw_video (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

axi4_stream_if #(
  .TDATA_WIDTH ( 32   ),
  .TID_WIDTH   ( 1    ),
  .TDEST_WIDTH ( 1    ),
  .TKEEP_WIDTH ( 1    )
) rgb_video (
  .aclk        ( clk  ),
  .aresetn     ( !rst )
);

demosaicing_ctrl_if demosaicing_ctrl();

AXI4StreamVideoSource #(
  .PX_WIDTH    ( RAW_PX_WIDTH ),
  .FRAME_RES_X ( FRAME_RES_X  ),
  .FRAME_RES_Y ( FRAME_RES_Y  ),
  .TOTAL_X     ( TOTAL_X      ),
  .TOTAL_Y     ( TOTAL_Y      ),
  .FILE_PATH   ( FILE_PATH    )
) video_source;

AXI4StreamSlave #(
  .TDATA_WIDTH   ( 32            ),
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
                        .rd_data_mbx      ( rx_video_mbx ) );
    fork
      clk_gen();
      apply_rst();
    join_none
    repeat( 1000 )
      @( posedge clk );
    $stop();
  end

endmodule
