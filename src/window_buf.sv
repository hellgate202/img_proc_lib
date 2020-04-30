module window_buf #(
  parameter int TDATA_WIDTH   = 32,
  parameter int PX_WIDTH      = 30,
  parameter int WIN_SIZE      = 5,
  parameter int MAX_LINE_SIZE = 1920
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master window_data_o
);

localparam int BUF_CNT_W  = $clog2( WIN_SIZE );
localparam int SHIFT_POOL = ( WIN_SIZE + 1 ) * 2;

typedef struct packed {
  logic [PX_WIDTH - 1 : 0] tdata;
  logic                    tvalid;
  logic                    tlast;
  logic                    tuser;
} axi4_stream_word_t;

axi4_stream_word_t video_i_d1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_i_d1 <= '0;
  else
    if( video_i.tready )
      begin
        video_i_d1.tdata  <= video_i.tdata[PX_WIDTH - 1 : 0];
        video_i_d1.tvalid <= video_i.tvalid;
        video_i_d1.tlast  <= video_i.tlast;
        video_i_d1.tuser  <= video_i.tuser;
      end

logic                                                   push_data;
logic [WIN_SIZE : 0]                                    active_wr_buf;
logic [WIN_SIZE : 0]                                    tvalid_masked;
logic [WIN_SIZE : 0]                                    active_rd_buf;
logic [BUF_CNT_W - 1 : 0]                               rd_inact_pos;
logic [BUF_CNT_W - 1 : 0]                               wr_act_pos;
logic [WIN_SIZE : 0]                                    read_buf;
logic [WIN_SIZE : 0]                                    active_flush_buf;
logic [WIN_SIZE : 0]                                    flush_buf;
logic                                                   read_ready;
logic [WIN_SIZE : 0]                                    pre_line_buf_tready;
logic                                                   post_line_buf_tready;
axi4_stream_word_t [WIN_SIZE : 0]                       data_from_buf;
axi4_stream_word_t [SHIFT_POOL - 1 : 0]                 shifted_data_from_buf;
axi4_stream_word_t [WIN_SIZE - 1 : 0]                   data_to_shift_reg;
logic [WIN_SIZE : 0]                                    unread_from_buf;
logic [SHIFT_POOL : 0]                                  shifted_unread_from_buf;
logic [WIN_SIZE - 1 : 0]                                unread_to_shift_reg;
axi4_stream_word_t [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0] data_shift_reg;
logic                                                   read_done;

assign video_i.tready = pre_line_buf_tready[wr_act_pos];

assign push_data  = video_i_d1.tvalid;
assign read_done  = data_shift_reg[0][0].tlast && post_line_buf_tready;
assign read_ready = unread_to_shift_reg[WIN_SIZE - 1];

assign post_line_buf_tready = window_data_o.tready || !window_data_o.tvalid;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    active_wr_buf <= 'b1;
  else
    if( video_i.tvalid && video_i.tuser )
      active_wr_buf <= 'b1;
    else
      if( push_data && video_i_d1.tvalid && video_i_d1.tlast && video_i.tready )
        begin
          active_wr_buf[0]            <= active_wr_buf[WIN_SIZE];
          active_wr_buf[WIN_SIZE : 1] <= active_wr_buf[WIN_SIZE - 1 : 0];
        end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    wr_act_pos <= '0;
  else
    if( video_i.tvalid && video_i.tuser )
      wr_act_pos <= '0;
    else
      if( push_data && video_i_d1.tvalid && video_i_d1.tlast && video_i.tready ) 
        if( wr_act_pos == WIN_SIZE )
          wr_act_pos <= '0;
        else
          wr_act_pos <= wr_act_pos + 1'b1;

always_comb
  for( int i = 0; i <= WIN_SIZE; i++ )
    if( active_wr_buf[i] )
      tvalid_masked[i] = video_i_d1.tvalid;
    else
      tvalid_masked[i] = 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    active_rd_buf <= { 1'b0, { WIN_SIZE{ 1'b1 } } };
  else
    if( video_i.tvalid && video_i.tuser )
      active_rd_buf <= { 1'b0, { WIN_SIZE{ 1'b1 } } };
    else
      if( read_done )
        begin
          active_rd_buf[0]            <= active_rd_buf[WIN_SIZE];
          active_rd_buf[WIN_SIZE : 1] <= active_rd_buf[WIN_SIZE - 1 : 0];
        end

always_comb
  for( int i = 0; i <= WIN_SIZE; i++ )
    if( active_rd_buf[i] && read_ready )
      read_buf[i] = 1'b1;
    else
      read_buf[i] = 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    active_flush_buf <= 'b1;
  else
    if( video_i.tvalid && video_i.tuser )
      active_flush_buf <= 'b1;
    else
      if( read_done )
        begin
          active_flush_buf[0]            <= active_flush_buf[WIN_SIZE];
          active_flush_buf[WIN_SIZE : 1] <= active_flush_buf[WIN_SIZE - 1 : 0];
        end

always_comb
  if( video_i.tvalid && video_i.tuser )
    flush_buf = '1;
  else
    for( int i = 0; i <= WIN_SIZE; i++ )
      if( active_flush_buf[i] && read_done )
        flush_buf[i] = 1'b1;
      else
        flush_buf[i] = 1'b0;

genvar i;

generate
  for( i = 0; i <= WIN_SIZE; i++ )
    begin : line_buffers
      axi4_stream_if #(
        .TDATA_WIDTH ( TDATA_WIDTH )
      ) pre_line_buf (
        .aclk        ( clk_i       ),
        .aresetn     ( !rst_i      )
      );

      assign pre_line_buf.tdata     = video_i_d1.tdata;
      assign pre_line_buf.tvalid    = tvalid_masked[i];
      assign pre_line_buf.tlast     = video_i_d1.tlast;
      assign pre_line_buf.tuser     = video_i_d1.tuser;
      assign pre_line_buf_tready[i] = pre_line_buf.tready;

      axi4_stream_if #(
        .TDATA_WIDTH ( TDATA_WIDTH )
      ) post_line_buf (
        .aclk        ( clk_i       ),
        .aresetn     ( !rst_i      )
      );

      assign post_line_buf.tready = post_line_buf_tready;

      line_buf #(
        .MAX_LINE_SIZE ( MAX_LINE_SIZE      ),
        .TDATA_WIDTH   ( TDATA_WIDTH        ),
        .PX_WIDTH      ( PX_WIDTH           )
      ) line_buf_inst (
        .clk_i         ( clk_i              ),
        .rst_i         ( rst_i              ),
        .pop_line_i    ( read_buf[i]        ),
        .flush_line_i  ( flush_buf[i]       ),
        .video_i       ( pre_line_buf       ),
        .video_o       ( post_line_buf      ),
        .empty_o       (                    ),
        .unread_o      ( unread_from_buf[i] )
      );

      assign data_from_buf[i].tdata  = post_line_buf.tdata[PX_WIDTH - 1 : 0];
      assign data_from_buf[i].tvalid = post_line_buf.tvalid;
      assign data_from_buf[i].tlast  = post_line_buf.tlast;
      assign data_from_buf[i].tuser  = post_line_buf.tuser;
    end
endgenerate

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    rd_inact_pos <= WIN_SIZE;
  else
    if( video_i.tvalid && video_i.tuser )
      rd_inact_pos <= WIN_SIZE;
    else
      if( read_done )
        if( rd_inact_pos == WIN_SIZE )
          rd_inact_pos = '0;
        else
          rd_inact_pos = rd_inact_pos + 1'b1;

always_comb
  begin
    shifted_data_from_buf   = { 2{ data_from_buf } } >> ( rd_inact_pos + 1'b1 ) * $bits(axi4_stream_word_t);
    shifted_unread_from_buf = { 2{ unread_from_buf } } >> ( rd_inact_pos + 1'b1 );
  end

assign data_to_shift_reg   = shifted_data_from_buf[WIN_SIZE - 1 : 0];
assign unread_to_shift_reg = shifted_unread_from_buf[WIN_SIZE - 1 : 0];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    data_shift_reg   <= '0;
  else
    if( post_line_buf_tready )
      begin
        data_shift_reg[WIN_SIZE - 1] <= data_to_shift_reg;
        for( int i = 0; i < ( WIN_SIZE - 1 ); i++ )
          data_shift_reg[i]   <= data_shift_reg[i + 1];
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    window_data_o.tdata <= '0;
  else
    if( post_line_buf_tready )
      for( int y = 0; y < WIN_SIZE; y++ )
        for( int x = 0; x < WIN_SIZE; x++ )
          window_data_o.tdata[( y * WIN_SIZE + x + 1 ) * PX_WIDTH - 1 -: PX_WIDTH] <= data_shift_reg[x][y].tdata;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    window_data_o.tvalid <= 1'b0;
  else
    if( post_line_buf_tready )
      if( !data_shift_reg[WIN_SIZE - 1][0].tvalid )
        window_data_o.tvalid <= 1'b0;
      else
        if( data_shift_reg[0][0].tvalid )
          window_data_o.tvalid <= 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    window_data_o.tlast <= 1'b0;
  else
    if( post_line_buf_tready )
    window_data_o.tlast <= data_shift_reg[WIN_SIZE - 1][WIN_SIZE - 1].tlast;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    window_data_o.tuser <= 1'b0;
  else
    if( post_line_buf_tready )
      window_data_o.tuser <= data_shift_reg[0][0].tuser;

endmodule
