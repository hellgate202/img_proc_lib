module fixed_eof_extractor #(
  parameter int FRAME_RES_Y = 1080,
  parameter int PX_WIDTH    = 10
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o,
  output                eof_o
);

localparam int TDATA_WIDTH    = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH;
localparam int TDATA_WIDTH_B  = TDATA_WIDTH / 8;
localparam int LINE_CNT_WIDTH = $clog2( FRAME_RES_Y + 1 );

logic [LINE_CNT_WIDTH - 1 : 0] line_cnt;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      video_o.tvalid <= 1'b0;
      video_o.tdata  <= TDATA_WIDTH'( 0 );
      video_o.tuser  <= 1'b0;
      video_o.tlast  <= 1'b0;
      video_o.tstrb  <= TDATA_WIDTH_B'( 0 );
      video_o.tkeep  <= TDATA_WIDTH_B'( 0 );
      video_o.tid    <= 1'b0;
      video_o.tdest  <= 1'b0;
    end
  else
    if( video_i.tready )
      begin
        video_o.tvalid <= video_i.tvalid;
        video_o.tdata  <= video_i.tdata;
        video_o.tuser  <= video_i.tuser;
        video_o.tlast  <= video_i.tlast;
        video_o.tstrb  <= video_i.tstrb;
        video_o.tkeep  <= video_i.tkeep;
        video_o.tid    <= video_i.tid;
        video_o.tdest  <= video_i.tdest;
      end

assign video_i.tready = !video_o.tvalid || video_o.tready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    line_cnt <= LINE_CNT_WIDTH'( 0 );
  else
    if( video_i.tvalid && video_i.tuser )
      line_cnt <= LINE_CNT_WIDTH'( 0 );
    else
      if( video_o.tvalid && video_o.tready && video_o.tlast && line_cnt < FRAME_RES_Y )
        line_cnt <= line_cnt + 1'b1;

assign eof_o = line_cnt == ( FRAME_RES_Y - 1 ) && video_o.tvalid && video_o.tlast;


endmodule
