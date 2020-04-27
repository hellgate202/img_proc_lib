module gap_buffer #(
  parameter int TDATA_WIDTH = 32,
  parameter int MIN_GAP     = 100,
  parameter int FRAME_RES_X = 1920
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int INT_CNT_WIDTH = $clog2( MIN_GAP + 1 );
localparam int WORDS_AMOUNT  = FRAME_RES_X * 2;
localparam int PKT_CNT_WIDTH = $clog2( WORDS_AMOUNT );

logic [INT_CNT_WIDTH - 1 : 0] int_cnt;
logic [PKT_CNT_WIDTH : 0]     pkt_cnt;
logic                         allow_data;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           )
) video_local (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_fifo #(
  .TDATA_WIDTH   ( TDATA_WIDTH  ),
  .TUSER_WIDTH   ( 1            ),
  .TDEST_WIDTH   ( 1            ),
  .TID_WIDTH     ( 1            ),
  .WORDS_AMOUNT  ( WORDS_AMOUNT ),
  .SMART         ( 0            ),
  .SHOW_PKT_SIZE ( 0            )
) gap_fifo (
  .clk_i         ( clk_i        ),
  .rst_i         ( rst_i        ),
  .full_o        (              ),
  .empty_o       (              ),
  .drop_o        (              ),
  .used_words_o  (              ),
  .pkts_amount_o ( pkt_cnt      ),
  .pkt_size_o    (              ),
  .pkt_i         ( video_i      ),
  .pkt_o         ( video_local  )
);

assign video_local.tready = allow_data ? video_o.tready : 1'b0;
assign allow_data         = int_cnt == INT_CNT_WIDTH'( 0 ) && pkt_cnt > PKT_CNT_WIDTH'( 0 );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    int_cnt <= INT_CNT_WIDTH'( 0 );
  else
    if( video_local.tvalid && video_local.tready && video_local.tlast )
      int_cnt <= INT_CNT_WIDTH'( MIN_GAP );
    else
      if( int_cnt > INT_CNT_WIDTH'( 0 ) )
        int_cnt <= int_cnt - 1'b1;

assign video_o.tvalid = allow_data ? video_local.tvalid : 1'b0;
assign video_o.tdata  = video_local.tdata;
assign video_o.tstrb  = video_local.tstrb;
assign video_o.tkeep  = video_local.tkeep;
assign video_o.tlast  = video_local.tlast;
assign video_o.tuser  = video_local.tuser;
assign video_o.tid    = video_local.tid;
assign video_o.tdest  = video_local.tdest;

endmodule
