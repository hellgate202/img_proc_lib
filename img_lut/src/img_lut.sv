module img_lut #(
  parameter int PX_WIDTH  = 10,
  parameter     INIT_FILE = ""
)(
  input                 clk_i,
  input                 rst_i,
  img_lut_ctrl_if.slave img_lut_ctrl_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int TDATA_WIDTH   = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH;
localparam int TDATA_WIDTH_B = TDATA_WIDTH / 8;

logic [PX_WIDTH - 1 : 0] lut_tdata;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      video_o.tvalid <= 1'b0;
      video_o.tlast  <= 1'b0;
      video_o.tuser  <= 1'b0;
      video_o.tstrb  <= TDATA_WIDTH_B'( 0 );
      video_o.tkeep  <= TDATA_WIDTH_B'( 0 );
      video_o.tid    <= 1'b0;
      video_o.tdest  <= 1'b0;
    end
  else
    if( video_i.tready )
      begin
        video_o.tvalid <= video_i.tvalid;
        video_o.tlast  <= video_i.tlast;
        video_o.tuser  <= video_i.tuser;
        video_o.tstrb  <= video_i.tstrb;
        video_o.tkeep  <= video_i.tkeep;
        video_o.tid    <= video_i.tid;
        video_o.tdest  <= video_i.tdest;
      end

assign video_i.tready = !video_o.tvalid || video_o.tready;

dual_port_ram #(
  .DATA_WIDTH ( PX_WIDTH                                 ),
  .ADDR_WIDTH ( PX_WIDTH                                 ),
  .INIT_FILE  ( INIT_FILE                                )
) lut (
  .wr_clk_i   ( clk_i                                    ),
  .wr_addr_i  ( img_lut_ctrl_i.orig_px[PX_WIDTH - 1 : 0] ),
  .wr_data_i  ( img_lut_ctrl_i.mod_px[PX_WIDTH - 1 : 0]  ),
  .wr_i       ( img_lut_ctrl_i.wr_stb                    ),
  .rd_clk_i   ( clk_i                                    ),
  .rd_addr_i  ( video_i.tdata[PX_WIDTH - 1 : 0]          ),
  .rd_data_o  ( lut_tdata                                ),
  .rd_i       ( 1'b1                                     )
);

assign video_o.tdata = TDATA_WIDTH'( lut_tdata );

endmodule
