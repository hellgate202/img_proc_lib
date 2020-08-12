module px_subsampler #(
  parameter int PX_WIDTH    = 30,
  parameter int FRAME_RES_X = 1920
)(
  input                 clk_i,
  input                 rst_i,
  px_ss_if.slave        px_ss_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int TDATA_WIDTH = PX_WIDTH % 8 ? ( PX_WIDTH / 8 + 1 ) * 8 : PX_WIDTH;

logic          tfirst;
logic          frame_start;
logic          line_start;
logic [15 : 0] valid_px_per_interval;
logic [15 : 0] valid_ln_per_interval;
logic [15 : 0] px_skip_lock;
logic [15 : 0] px_add_lock;
logic [15 : 0] line_skip_lock;
logic [15 : 0] line_add_lock;
logic [15 : 0] px_pass_cnt;
logic [15 : 0] px_skip_cnt;
logic [15 : 0] px_add_cnt;
logic [15 : 0] ln_pass_cnt;
logic [15 : 0] ln_skip_cnt;
logic [15 : 0] ln_add_cnt;
logic          force_valid;
logic          skiped_valid;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           )
) video_i_d1 (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_delay #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TUSER_WIDTH ( 1           )
) input_delay (
  .clk_i       ( clk_i       ),
  .rst_i       ( rst_i       ),
  .pkt_i       ( video_i     ),
  .pkt_o       ( video_i_d1  )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    tfirst <= 1'b1;
  else
    if( video_i.tvalid && video_i.tready )
      if( video_i.tlast )
        tfirst <= 1'b1;
      else
        tfirst <= 1'b0;

assign line_start = tfirst && video_i.tvalid && video_i.tready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      valid_px_per_interval <= 16'd0;
      valid_ln_per_interval <= 16'd0;
      px_skip_lock          <= 16'd0;
      px_add_lock           <= 16'd0;
      line_skip_lock        <= 16'd0;
      line_add_lock         <= 16'd0;
    end
  else
    if( frame_start )
      begin
        valid_px_per_interval <= px_ss_i.px_skip_interval - px_ss_i.px_to_skip - 'd1;
        px_skip_lock          <= px_ss_i.px_to_skip - 'd1;
        px_add_lock           <= px_ss_i.add_px_skip_interval;
        valid_ln_per_interval <= px_ss_i.ln_skip_interval - px_ss_i.ln_to_skip - 'd1;
        line_skip_lock        <= px_ss_i.ln_to_skip - 'd1;
        line_add_lock         <= px_ss_i.add_ln_skip_interval;
      end

assign frame_start = video_i.tvalid && video_i.tuser && video_i.tready;

enum logic [2 : 0] { PASS_S,
                     SKIP_PX_S,
                     SKIP_ADD_PX_S,
                     SKIP_LN_S,
                     SKIP_ADD_LN_S } state, next_state;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    state <= PASS_S;
  else
    if( frame_start )
      state <= PASS_S;
    else
      state <= next_state;

always_comb
  begin
    next_state = state;
    case( state )
      PASS_S:
        begin
          if( video_i_d1.tvalid && video_i_d1.tready )
            if( video_i_d1.tlast && ln_pass_cnt == valid_ln_per_interval && px_ss_i.ln_to_skip != '0 )
              next_state = SKIP_LN_S;
            else
              if( px_pass_cnt == valid_px_per_interval && px_ss_i.px_to_skip != '0 && !video_i_d1.tlast )
                next_state = SKIP_PX_S;
        end
      SKIP_PX_S:
        begin
          if( video_i_d1.tvalid && video_i_d1.tready )
            if( video_i_d1.tlast && ln_pass_cnt == valid_ln_per_interval && px_ss_i.ln_to_skip != '0 )
              next_state = SKIP_LN_S;
            else
              if( px_skip_cnt == px_skip_lock )
                if( px_add_cnt == px_add_lock && px_add_lock != '0 )
                  next_state = SKIP_ADD_PX_S;
                else
                  next_state = PASS_S;
        end
      SKIP_ADD_PX_S:
        begin
          if( video_i_d1.tvalid && video_i_d1.tready )
            if( video_i_d1.tlast && ln_pass_cnt == valid_ln_per_interval && px_ss_i.ln_to_skip != '0 )
              next_state = SKIP_LN_S;
            else
              next_state = PASS_S;
        end
      SKIP_LN_S:
        begin
          if( video_i_d1.tvalid && video_i_d1.tlast && video_i_d1.tready )
            if( ln_skip_cnt == line_skip_lock )
              if( ln_add_cnt == line_add_lock && line_add_lock != '0 )
                next_state = SKIP_ADD_LN_S;
              else
                next_state = PASS_S;
        end
      SKIP_ADD_LN_S:
        begin
          if( video_i_d1.tvalid && video_i_d1.tlast && video_i_d1.tready )
            next_state = PASS_S;
        end
    endcase
  end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_pass_cnt <= 16'd0;
  else
    if( line_start )
      px_pass_cnt <= 16'd0;
    else
      if( state == SKIP_PX_S )
        px_pass_cnt <= 16'd0;
      else
        if( video_i_d1.tvalid && video_i_d1.tready && state == PASS_S )
          px_pass_cnt <= px_pass_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_skip_cnt <= 16'd0;
  else
    if( line_start )
      px_skip_cnt <= 16'd0;
    else
      if( state == PASS_S )
        px_skip_cnt <= 16'd0;
      else
        if( video_i_d1.tvalid && video_i_d1.tready && state == SKIP_PX_S )
          px_skip_cnt <= px_skip_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_add_cnt <= 16'd0;
  else
    if( line_start )
      px_add_cnt <= 16'd0;
    else
      if( state == SKIP_ADD_PX_S )
        px_add_cnt <= 16'd0;
      else
        if( video_i_d1.tvalid && video_i_d1.tready && px_pass_cnt == valid_px_per_interval )
          px_add_cnt <= px_add_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ln_pass_cnt <= 16'd0;
  else
    if( frame_start )
      ln_pass_cnt <= 16'd0;
    else
      if( state == SKIP_LN_S )
        ln_pass_cnt <= 16'd0;
      else
        if( video_i_d1.tvalid && video_i_d1.tready && video_i_d1.tlast &&
            state != SKIP_LN_S && state != SKIP_ADD_LN_S )
          ln_pass_cnt <= ln_pass_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ln_skip_cnt <= 16'd0;
  else
    if( frame_start )
      ln_skip_cnt <= 16'd0;
    else
      if( state == PASS_S )
        ln_skip_cnt <= 16'd0;
      else
        if( video_i_d1.tvalid && video_i_d1.tready && video_i_d1.tlast &&
            state == SKIP_LN_S )
          ln_skip_cnt <= ln_skip_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ln_add_cnt <= 16'd0;
  else
    if( frame_start )
      ln_add_cnt <= 16'd0;
    else
      if( state == SKIP_ADD_LN_S )
        ln_add_cnt <= 16'd0;
      else
        if( video_i_d1.tvalid && video_i_d1.tready && video_i_d1.tlast  && ln_pass_cnt == valid_ln_per_interval )
          ln_add_cnt <= ln_add_cnt + 1'b1;

assign force_valid  = ( state == SKIP_PX_S || state == SKIP_ADD_PX_S ) && video_i_d1.tvalid && video_i_d1.tready && video_i_d1.tlast;
assign skiped_valid = state == PASS_S || force_valid ? video_i_d1.tvalid : 1'b0;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TDEST_WIDTH ( 1           ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           )
) uncut_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

assign uncut_video.tvalid = skiped_valid;
assign uncut_video.tlast  = video_i_d1.tlast;
assign uncut_video.tuser  = video_i_d1.tuser;
assign uncut_video.tstrb  = video_i_d1.tstrb;
assign uncut_video.tkeep  = video_i_d1.tkeep;
assign uncut_video.tid    = video_i_d1.tid;
assign uncut_video.tdest  = video_i_d1.tdest;
assign uncut_video.tdata  = video_i_d1.tdata;
assign video_i_d1.tready  = uncut_video.tready;

axi4_stream_fifo #(
  .TDATA_WIDTH   ( TDATA_WIDTH ),
  .TUSER_WIDTH   ( 1           ),
  .TDEST_WIDTH   ( 1           ),
  .TID_WIDTH     ( 1           ),
  .WORDS_AMOUNT  ( FRAME_RES_X ),
  .SMART         ( 1           ),
  .SHOW_PKT_SIZE ( 0           )
) output_fifo (
  .clk_i         ( clk_i       ),
  .rst_i         ( rst_i       ),
  .full_o        (             ),
  .empty_o       (             ),
  .used_words_o  (             ),
  .pkts_amount_o (             ),
  .pkt_size_o    (             ),
  .drop_o        (             ),
  .pkt_i         ( uncut_video ),
  .pkt_o         ( video_o     )
);

endmodule
