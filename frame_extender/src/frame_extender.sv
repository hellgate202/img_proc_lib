module frame_extender #(
  parameter int    TOP                = 1,
  parameter int    BOTTOM             = 1,
  parameter int    LEFT               = 1,
  parameter int    RIGHT              = 1,
  parameter int    FRAME_RES_X        = 1920,
  parameter int    FRAME_RES_Y        = 1080,
  parameter int    PX_WIDTH           = 10,
  parameter string EOF_STRATEGY       = "FIXED",
  parameter int    ALLOW_BACKPRESSURE = 0
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int TDATA_WIDTH   = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH;
localparam int EXTENDED_X    = FRAME_RES_X + LEFT + RIGHT;
localparam int TOP_CNT_WIDTH = TOP == 1 ? 1 : $clog2( TOP );
localparam int BOT_CNT_WIDTH = BOTTOM == 1 ? 1 : $clog2( BOTTOM );
localparam int LINES_IN_FIFO = TOP > BOTTOM ? TOP : BOTTOM;
localparam int WORDS_IN_FIFO = EOF_STRATEGY == "FIXED" ? LINES_IN_FIFO * EXTENDED_X :
                                                         LINES_IN_FIFO * EXTENDED_X * 2;
localparam int DROP_ALLOWED  = !ALLOW_BACKPRESSURE;

logic                         eof;
logic                         dup_req;
logic                         flush_fifo;
logic [TOP_CNT_WIDTH - 1 : 0] top_cnt;
logic [BOT_CNT_WIDTH - 1 : 0] bot_cnt;
logic                         eof_video_tready;
logic                         eof_video_tvalid;
logic                         first_eol;
logic                         last_eol;
logic                         pop_dup_top;
logic                         pop_dup_bot;
logic                         passthrough_en;
logic                         line_buf_empty;

enum logic [2 : 0] { IDLE_S,
                     FIRST_LINE_PASS_S,
                     DUP_TOP_S,
                     LAST_LINE_PASS_S,
                     DUP_BOT_S } state, next_state;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    state <= IDLE_S;
  else
    state <= next_state;

always_comb
  begin
    next_state = state;
    case( state )
      IDLE_S:
        begin
          if( eof_video.tvalid && eof_video.tready &&
              eof_video.tuser )
            next_state = FIRST_LINE_PASS_S;
        end
      FIRST_LINE_PASS_S:
        begin
          if( eof_video.tvalid && eof_video.tready &&
              eof_video.tlast )
            next_state = DUP_TOP_S;
        end
      DUP_TOP_S:
        begin
          if( top_cnt == TOP_CNT_WIDTH'( 1 ) && duplicated_video.tvalid &&
              duplicated_video.tready && duplicated_video.tlast )
            next_state = LAST_LINE_PASS_S;
        end
      LAST_LINE_PASS_S:
        begin
          if( eof_video.tvalid && eof_video.tready && eof )
            next_state = DUP_BOT_S;
        end
      DUP_BOT_S:
        begin
          if( bot_cnt == BOT_CNT_WIDTH'( 1 ) && duplicated_video.tvalid &&
              duplicated_video.tready && duplicated_video.tlast )
            next_state = IDLE_S;
        end
    endcase
  end

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) buf_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_fifo #(
  .TDATA_WIDTH   ( TDATA_WIDTH   ),
  .TUSER_WIDTH   ( 1             ),
  .TDEST_WIDTH   ( 1             ),
  .TID_WIDTH     ( 1             ),
  .WORDS_AMOUNT  ( WORDS_IN_FIFO ),
  .SMART         ( DROP_ALLOWED  ),
  .SHOW_PKT_SIZE ( 0             )
) input_fifo (
  .clk_i         ( clk_i         ),
  .rst_i         ( rst_i         ),
  .full_o        (               ),
  .empty_o       (               ),
  .drop_o        (               ),
  .used_words_o  (               ),
  .pkts_amount_o (               ),
  .pkt_size_o    (               ),
  .pkt_i         ( video_i       ),
  .pkt_o         ( buf_video     )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) extended_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

line_extender #(
  .LEFT     ( LEFT           ),
  .RIGHT    ( RIGHT          ),
  .PX_WIDTH ( PX_WIDTH       )
) line_extender_inst (
  .clk_i    ( clk_i          ),
  .rst_i    ( rst_i          ),
  .video_i  ( buf_video      ),
  .video_o  ( extended_video )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) eof_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

generate
  if( EOF_STRATEGY == "FIXED" )
    begin : fixed_eof
      fixed_eof_extractor #(
        .FRAME_RES_Y ( FRAME_RES_Y    ),
        .PX_WIDTH    ( PX_WIDTH       )
      ) eof_extractor_inst (
        .clk_i       ( clk_i          ),
        .rst_i       ( rst_i          ),
        .video_i     ( extended_video ),
        .video_o     ( eof_video      ),
        .eof_o       ( eof            )
      );
    end
  else
    begin : adaptive_eof
      adaptive_eof_extractor #(
        .FRAME_RES_X ( FRAME_RES_X    ),
        .PX_WIDTH    ( PX_WIDTH       )
      ) eof_extractor_inst (
        .clk_i       ( clk_i          ),
        .rst_i       ( rst_i          ),
        .video_i     ( extended_video ),
        .video_o     ( eof_video      ),
        .eof_o       ( eof            )
      );
    end
endgenerate

assign eof_video_tready = state == IDLE_S || state == FIRST_LINE_PASS_S || state == LAST_LINE_PASS_S ? 
                          video_o.tready : 1'b0;
assign eof_video_tvalid = state == IDLE_S || state == FIRST_LINE_PASS_S || state == LAST_LINE_PASS_S ? 
                          eof_video.tvalid && video_o.tready : 1'b0;

assign first_eol       = state == FIRST_LINE_PASS_S && eof_video.tvalid && 
                         eof_video.tlast && eof_video.tready;
assign pop_dup_top     = state == DUP_TOP_S && duplicated_video.tvalid &&
                         duplicated_video.tlast && duplicated_video.tready &&
                         top_cnt != TOP_CNT_WIDTH'( 1 );
assign last_eol        = state == LAST_LINE_PASS_S && eof_video.tvalid &&
                         eof_video.tlast && eof_video.tready && eof;
assign pop_dup_bot     = state == DUP_BOT_S && duplicated_video.tvalid &&
                         duplicated_video.tlast && duplicated_video.tready &&
                         bot_cnt != BOT_CNT_WIDTH'( 1 );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    dup_req <= 1'b0;
  else
    if( first_eol || pop_dup_top ||
        last_eol || pop_dup_bot )
      dup_req <= 1'b1;
    else
      if( !line_buf_empty )
        dup_req <= 1'b0;

assign flush_fifo = ( passthrough_video.tvalid && passthrough_video.tready &&
                      passthrough_video.tlast && !eof && state != FIRST_LINE_PASS_S ) ||
                    ( state == DUP_TOP_S && top_cnt == TOP_CNT_WIDTH'( 1 ) &&
                      duplicated_video.tvalid && duplicated_video.tlast &&
                      duplicated_video.tready ) ||
                    ( state == DUP_BOT_S && bot_cnt == BOT_CNT_WIDTH'( 1 ) &&
                      duplicated_video.tvalid && duplicated_video.tlast &&
                      duplicated_video.tready );
assign passthrough_en  = state == IDLE_S || state == FIRST_LINE_PASS_S || state == LAST_LINE_PASS_S;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    top_cnt <= TOP_CNT_WIDTH'( 0 );
  else
    if( first_eol )
      top_cnt <= TOP_CNT_WIDTH'( TOP );
    else
      if( state == DUP_TOP_S && duplicated_video.tvalid && 
          duplicated_video.tready && duplicated_video.tlast )
        top_cnt <= top_cnt - 1'b1;;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    bot_cnt <= BOT_CNT_WIDTH'( 0 );
  else
    if( last_eol )
      bot_cnt <= BOT_CNT_WIDTH'( BOTTOM );
    else
      if( state == DUP_BOT_S && duplicated_video.tvalid && duplicated_video.tready && 
          duplicated_video.tlast )
        bot_cnt <= bot_cnt - 1'b1;;

assign eof_video_to_line_buf.tdata  = eof_video.tdata;
assign eof_video_to_line_buf.tvalid = eof_video_tvalid;
assign eof_video_to_line_buf.tstrb  = eof_video.tstrb;
assign eof_video_to_line_buf.tkeep  = eof_video.tkeep;
assign eof_video_to_line_buf.tlast  = eof_video.tlast;
assign eof_video_to_line_buf.tuser  = eof_video.tuser;
assign eof_video_to_line_buf.tid    = eof_video.tid;
assign eof_video_to_line_buf.tdest  = eof_video.tdest;

assign passthrough_video.tdata  = eof_video.tdata;
assign passthrough_video.tvalid = eof_video_tvalid;
assign passthrough_video.tstrb  = eof_video.tstrb;
assign passthrough_video.tkeep  = eof_video.tkeep;
assign passthrough_video.tlast  = eof_video.tlast;
assign passthrough_video.tuser  = eof_video.tuser;
assign passthrough_video.tid    = eof_video.tid;
assign passthrough_video.tdest  = eof_video.tdest;
assign passthrough_video.tready = video_o.tready;

assign eof_video.tready = eof_video_tready;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) eof_video_to_line_buf (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) duplicated_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) passthrough_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

line_buf #(
  .MAX_LINE_SIZE ( EXTENDED_X            ),
  .TDATA_WIDTH   ( TDATA_WIDTH           ),
  .PX_WIDTH      ( PX_WIDTH              )
) duplicate_buf (
  .clk_i         ( clk_i                 ),
  .rst_i         ( rst_i                 ),
  .pop_line_i    ( dup_req               ),
  .flush_line_i  ( flush_fifo            ),
  .video_i       ( eof_video_to_line_buf ),
  .video_o       ( duplicated_video      ),
  .unread_o      (                       ),
  .empty_o       ( line_buf_empty        )
);

assign duplicated_video.tready = video_o.tready;

assign video_o.tvalid =  passthrough_en ? passthrough_video.tvalid : duplicated_video.tvalid;
assign video_o.tdata  =  passthrough_en ? passthrough_video.tdata  : duplicated_video.tdata;
assign video_o.tstrb  =  passthrough_en ? passthrough_video.tstrb  : duplicated_video.tstrb;
assign video_o.tkeep  =  passthrough_en ? passthrough_video.tkeep  : duplicated_video.tkeep;
assign video_o.tlast  =  passthrough_en ? passthrough_video.tlast  : duplicated_video.tlast;
assign video_o.tuser  =  passthrough_en ? passthrough_video.tuser  : 1'b0;
assign video_o.tid    =  passthrough_en ? passthrough_video.tid    : duplicated_video.tid;
assign video_o.tdest  =  passthrough_en ? passthrough_video.tdest  : duplicated_video.tdest;

endmodule
