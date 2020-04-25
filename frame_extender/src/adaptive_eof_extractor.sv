module adaptive_eof_extractor #(
  parameter int FRAME_RES_X = 1920,
  parameter int PX_WIDTH    = 10
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o,
  output                eof_o
);

localparam int TDATA_WIDTH    = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH;
localparam int FIFO_DEPTH     = FRAME_RES_X * 2;
localparam int LINE_CNT_WIDTH = $clog2( FIFO_DEPTH ) + 1;

logic [LINE_CNT_WIDTH - 1 : 0] lines_in_fifo;
logic                          read_allowed;
logic                          input_backpressure;
logic                          tfirst;
logic                          was_sof;

assign input_backpressure = lines_in_fifo == LINE_CNT_WIDTH'( 2 );

assign video_i_local.tvalid = input_backpressure ? 1'b0 : video_i.tvalid;
assign video_i_local.tdata  = video_i.tdata;
assign video_i_local.tlast  = video_i.tlast;
assign video_i_local.tuser  = video_i.tuser;
assign video_i_local.tstrb  = video_i.tstrb;
assign video_i_local.tkeep  = video_i.tkeep;
assign video_i_local.tid    = video_i.tid;
assign video_i_local.tdest  = video_i.tdest;
assign video_i.tready       = !input_backpressure && video_i_local.tready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tfirst <= 1'b1;
  else
    if( video_i.tvalid )
      if( video_i.tlast )
        tfirst <= 1'b1;
      else
        if( video_i.tready )
          tfirst <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    read_allowed <= 1'b0;
  else
    if( video_o_local.tvalid && video_o_local.tready && video_o_local.tlast )
      read_allowed <= 1'b0;
    else
      if( lines_in_fifo > LINE_CNT_WIDTH'( 0 ) && video_i.tvalid && video_i.tready && tfirst )
        read_allowed <= 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    was_sof <= 1'b0;
  else
    if( lines_in_fifo > LINE_CNT_WIDTH'( 0 ) && video_i.tready && video_i.tvalid && video_i.tuser )
      was_sof <= 1'b1;
    else
      if( video_o.tvalid && video_o.tlast && video_o.tready )
        was_sof <= 1'b0;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           )
) video_i_local (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           )
) video_o_local (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_fifo #(
  .TDATA_WIDTH   ( TDATA_WIDTH   ),
  .TUSER_WIDTH   ( 1             ),
  .TDEST_WIDTH   ( 1             ),
  .TID_WIDTH     ( 1             ),
  .WORDS_AMOUNT  ( FIFO_DEPTH    ),
  .SMART         ( 0             ),
  .SHOW_PKT_SIZE ( 0             )
) input_fifo (
  .clk_i         ( clk_i         ),
  .rst_i         ( rst_i         ),
  .full_o        (               ),
  .empty_o       (               ),
  .drop_o        (               ),
  .used_words_o  (               ),
  .pkts_amount_o ( lines_in_fifo ),
  .pkt_size_o    (               ),
  .pkt_i         ( video_i_local ),
  .pkt_o         ( video_o_local )
);

assign video_o.tvalid       = read_allowed ? video_o_local.tvalid : 1'b0;
assign video_o.tdata        = video_o_local.tdata;
assign video_o.tlast        = video_o_local.tlast;
assign video_o.tuser        = video_o_local.tuser;
assign video_o.tid          = video_o_local.tid;
assign video_o.tdest        = video_o_local.tdest;
assign video_o.tstrb        = video_o_local.tstrb;
assign video_o.tkeep        = video_o_local.tkeep;
assign video_o_local.tready = video_o.tready && read_allowed;

assign eof_o                = video_o.tvalid && video_o.tlast && was_sof;

endmodule
