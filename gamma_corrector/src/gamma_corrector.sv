module gamma_corrector #(
  parameter int PX_WIDTH        = 10,
  parameter int CHANNELS_AMOUNT = 3
)(
  input                 clk_i,
  input                 rst_i,
  img_lut_ctrl_if.slave gc_ctrl_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int COMP_TDATA_WIDTH   = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 :
                                    PX_WIDTH;
localparam int COMP_TDATA_WIDTH_B = COMP_TDATA_WIDTH / 8;
localparam int TDATA_WIDTH        = PX_WIDTH % 8 ? 
                                    ( PX_WIDTH * CHANNELS_AMOUNT / 8 + 1 ) * 8 :
                                    PX_WIDTH * CHANNELS_AMOUNT;
localparam int TDATA_WIDTH_B      = TDATA_WIDTH / 8;
localparam     INIT_FILE          = "../../../gamma_corrector/scripts/gamma_rom.hex";

assign video_i.tready = comp_stream[0].tready;

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
  .TDATA_WIDTH ( COMP_TDATA_WIDTH ),
  .TUSER_WIDTH ( 1                ),
  .TID_WIDTH   ( 1                ),
  .TDEST_WIDTH ( 1                )
) comp_gamma_stream [CHANNELS_AMOUNT - 1 : 0] (
  .aclk        ( clk_i            ),
  .aresetn     ( !rst_i           )
);

genvar g;

generate
  for( g = 0; g < CHANNELS_AMOUNT; g++ )
    begin : gamma_correction
      assign comp_stream[g].tvalid = video_i.tvalid;
      assign comp_stream[g].tdata  = video_i.tdata[PX_WIDTH * ( g + 1 ) - 1 -: PX_WIDTH];
      assign comp_stream[g].tstrb  = COMP_TDATA_WIDTH_B'( 2 ** COMP_TDATA_WIDTH_B - 1 ); 
      assign comp_stream[g].tkeep  = COMP_TDATA_WIDTH_B'( 2 ** COMP_TDATA_WIDTH_B - 1 ); 
      assign comp_stream[g].tlast  = video_i.tlast;
      assign comp_stream[g].tuser  = video_i.tuser;
      assign comp_stream[g].tid    = video_i.tid;
      assign comp_stream[g].tdest  = video_i.tdest;

      img_lut #(
        .PX_WIDTH       ( PX_WIDTH             ),
        .INIT_FILE      ( INIT_FILE            )
      ) gamma_lut (
        .clk_i          ( clk_i                ),
        .rst_i          ( rst_i                ),
        .img_lut_ctrl_i ( gc_ctrl_i            ),
        .video_i        ( comp_stream[g]       ),
        .video_o        ( comp_gamma_stream[g] )
      );
      
      assign comp_gamma_stream[g].tready = video_o.tready;
    end
endgenerate

generate
  if( ( PX_WIDTH * CHANNELS_AMOUNT ) == TDATA_WIDTH )
    begin : n_append
      for( g = 0; g < CHANNELS_AMOUNT; g++ )
        assign video_o.tdata[PX_WIDTH * ( g + 1 ) - 1 -: PX_WIDTH] = comp_gamma_stream[g].tdata[PX_WIDTH - 1 : 0];
    end
  else
    begin : append
      assign video_o.tdata[TDATA_WIDTH - 1 : PX_WIDTH * CHANNELS_AMOUNT] = ( TDATA_WIDTH - PX_WIDTH * CHANNELS_AMOUNT )'( 0 );
      for( g = 0; g < CHANNELS_AMOUNT; g++ )
        assign video_o.tdata[PX_WIDTH * ( g + 1 ) - 1 -: PX_WIDTH] = comp_gamma_stream[g].tdata[PX_WIDTH - 1 : 0];

    end
endgenerate


assign video_o.tvalid = comp_gamma_stream[0].tvalid;
assign video_o.tlast  = comp_gamma_stream[0].tlast;
assign video_o.tuser  = comp_gamma_stream[0].tuser;
assign video_o.tstrb  = TDATA_WIDTH_B'( TDATA_WIDTH_B ** 2 - 1 );
assign video_o.tkeep  = TDATA_WIDTH_B'( TDATA_WIDTH_B ** 2 - 1 );
assign video_o.tdest  = comp_gamma_stream[0].tdest;
assign video_o.tid    = comp_gamma_stream[0].tid;


endmodule
