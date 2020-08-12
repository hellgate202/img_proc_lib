`include "../../lib/axi4_lib/src/class/AXI4StreamVideoSource.sv"
`include "../../lib/axi4_lib/src/class/AXI4StreamSlave.sv"
`include "../../lib/axi4_lib/src/class/AXI4LiteMaster.sv"

`timescale 1 ps / 1 ps

import px_ss_csr_pkg::*; 

module tb_px_subsampler;

parameter int    CLK_T           = 6734;
parameter int    PX_WIDTH        = 30;
parameter int    FRAME_RES_X     = 640;
parameter int    FRAME_RES_Y     = 480;
parameter int    TOTAL_X         = 700;
parameter int    TOTAL_Y         = 500;
parameter string FILE_PATH       = "./img.hex";
parameter int    RANDOM_TVALID   = 1;
parameter int    RANDOM_TREADY   = 1;
parameter int    CSR_BASE_ADDR   = 32'h0000_0000;
parameter int    TDATA_WIDTH     = PX_WIDTH % 8 ?
                                   ( PX_WIDTH / 8 + 1 ) * 8 :
                                   PX_WIDTH;
parameter int    FRAMES_AMOUNT   = 2;

bit clk;
bit rst;

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

axi4_lite_if #(
  .DATA_WIDTH ( 32   ),
  .ADDR_WIDTH ( 8    )
) csr (
  .aclk       ( clk  ),
  .aresetn    ( !rst )
);

px_ss_if px_ss();

AXI4LiteMaster #(
  .DATA_WIDTH ( 32 ),
  .ADDR_WIDTH ( 8  )
) csr_master;

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
        end
      else
        @( posedge clk );
    end
endtask

px_ss_csr #(
  .BASE_ADDR ( CSR_BASE_ADDR )
) DUT_CSR (
  .clk_i     ( clk           ),
  .rst_i     ( rst           ),
  .csr_i     ( csr           ),
  .px_ss_o   ( px_ss         )
);

px_subsampler #(
  .PX_WIDTH    ( PX_WIDTH    ),
  .FRAME_RES_X ( FRAME_RES_X )
) DUT (
  .clk_i       ( clk         ),
  .rst_i       ( rst         ),
  .px_ss_i     ( px_ss       ),
  .video_i     ( video_i     ),
  .video_o     ( video_o     )
);

initial
  begin
    csr_master   = new( csr );
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
    csr_master.wr_data( CSR_BASE_ADDR + PS_PX_SKIP_CR << 2, 32'd2 );
    csr_master.wr_data( CSR_BASE_ADDR + PS_PX_INTERVAL_CR << 2, 32'd6 );
    csr_master.wr_data( CSR_BASE_ADDR + PS_PX_ADD_INTERVAL_CR << 2, 32'd3 );
    csr_master.wr_data( CSR_BASE_ADDR + PS_LN_SKIP_CR << 2, 32'd2 );
    csr_master.wr_data( CSR_BASE_ADDR + PS_LN_INTERVAL_CR << 2, 32'd6 );
    csr_master.wr_data( CSR_BASE_ADDR + PS_LN_ADD_INTERVAL_CR << 2, 32'd3 );
    @( posedge clk );
    video_source.run();
    repeat( FRAMES_AMOUNT + 1 )
      begin
        while( !( video_o.tvalid && video_o.tready && video_o.tuser ) )
          @( posedge clk );
        @( posedge clk );
      end
    $stop();
  end

endmodule
