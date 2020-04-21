module line_buf #(
  parameter int MAX_LINE_SIZE = 1920,
  parameter int TDATA_WIDTH   = 32,
  parameter int PX_WIDTH      = 30
)(
  input                 clk_i,
  input                 rst_i,
  input                 pop_line_i,
  input                 flush_line_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o,
  output                empty_o,
  output                unread_o
);

localparam int ADDR_WIDTH = $clog2( MAX_LINE_SIZE + 1 );

logic [PX_WIDTH - 1 : 0]    tdata_d1;
logic                       tvalid_d1;
logic                       tlast_d1;
logic                       tuser_d1;
logic [ADDR_WIDTH - 1 : 0]  wr_ptr;
logic [ADDR_WIDTH - 1 : 0]  line_size;
logic [ADDR_WIDTH - 1 : 0]  rd_ptr;
logic                       read_in_progress;
logic                       empty;
logic                       was_sof;
logic                       unread;
logic                       rd_req;
logic                       line_locked;
logic [PX_WIDTH - 1 : 0]    buf_data;
logic                       rd_mem;

assign video_i.tready = !line_locked;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    line_locked <= 1'b0;
  else
    if( video_i.tuser && video_i.tready )
      line_locked <= 1'b0;
    else
      if( !line_locked && tvalid_d1 && tlast_d1 )
        line_locked <= 1'b1;
      else
        if( flush_line_i )
          line_locked <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      tdata_d1  <= PX_WIDTH'( 0 );
      tvalid_d1 <= 1'b0;
      tlast_d1  <= 1'b0;
      tuser_d1  <= 1'b0;
    end
  else
    if( video_i.tready )
      begin
        tdata_d1  <= video_i.tdata;
        tvalid_d1 <= video_i.tvalid;
        tlast_d1  <= video_i.tlast;
        tuser_d1  <= video_i.tuser;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    wr_ptr <= ADDR_WIDTH'( 0 );
  else
    if( video_i.tuser && video_i.tvalid )
      wr_ptr <= ADDR_WIDTH'( 0 );
    else
      if( tvalid_d1 && video_i.tready )
        if( tlast_d1 )
          wr_ptr <= ADDR_WIDTH'( 0 );
        else
          wr_ptr <= wr_ptr + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    line_size <= ADDR_WIDTH'( 0 );
  else
    if( video_i.tuser && video_i.tvalid )
      line_size <= ADDR_WIDTH'( 0 );
    else
      if( tvalid_d1 && tlast_d1 && video_i.tready )
        line_size <= wr_ptr + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    empty <= 1'b1;
  else
    if( video_i.tuser && video_i.tvalid )
      empty <= 1'b1;
    else
      if( tvalid_d1 && video_i.tready )
        if( tlast_d1 )
          empty <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    read_in_progress <= 1'b0;
  else
    if( video_i.tuser && video_i.tvalid )
      read_in_progress <= 1'b0;
    else
      if( rd_ptr == ( line_size - 1'b1 ) && video_o.tready )
        read_in_progress <= 1'b0;
      else
        if( pop_line_i && !empty )
          read_in_progress <= 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    rd_ptr <= ADDR_WIDTH'( 0 );
  else
    if( video_i.tuser && video_i.tvalid )
      rd_ptr <= ADDR_WIDTH'( 0 );
    else
      if( pop_line_i && !empty )
        rd_ptr <= ADDR_WIDTH'( 0 );
      else
        if( read_in_progress && video_o.tready )
          rd_ptr <= rd_ptr + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tvalid <= 1'b0;
  else
    if( video_i.tuser && video_i.tvalid )
      video_o.tvalid <= 1'b0;
    else
      if( read_in_progress )
        video_o.tvalid <= 1'b1;
      else
        if( video_o.tready )
          video_o.tvalid <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tlast <= 1'b0;
  else
    if( video_i.tuser && video_i.tvalid )
      video_o.tlast <= 1'b0;
    else
      if( read_in_progress && rd_ptr == ( line_size - 1'b1 ) && video_o.tready )
        video_o.tlast <= 1'b1;
      else
        if( video_o.tready )
          video_o.tlast <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    was_sof <= 1'b0;
  else
    if( video_i.tuser && video_i.tvalid )
      was_sof <= 1'b0;
    else
      if( tvalid_d1 && tuser_d1 )
        was_sof <= 1'b1;
      else
        if( video_o.tvalid && video_o.tready )
          was_sof <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tuser <= 1'b0;
  else
    if( video_i.tuser && video_i.tvalid )
      video_o.tuser <= 1'b0;
    else
      if( rd_req && was_sof )
        video_o.tuser <= 1'b1;
      else
        if( video_o.tready )
          video_o.tuser <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    unread <= 1'b0;
  else
    if( video_i.tuser && video_i.tvalid )
      unread <= 1'b0;
    else
      if( tvalid_d1 && tlast_d1 && video_i.tready )
        unread <= 1'b1;
      else
        if( !empty && pop_line_i )
          unread <= 1'b0;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    rd_req <= 1'b0;
  else
    if( video_i.tuser && video_i.tvalid )
      rd_req <= 1'b0;
    else
      rd_req <= pop_line_i && !empty;

assign rd_mem = video_o.tready || pop_line_i;

dual_port_ram #(
  .DATA_WIDTH ( PX_WIDTH   ),
  .ADDR_WIDTH ( ADDR_WIDTH )
) buf_ram (
  .wr_clk_i   ( clk_i      ),
  .wr_addr_i  ( wr_ptr     ),
  .wr_data_i  ( tdata_d1   ),
  .wr_i       ( tvalid_d1  ),
  .rd_clk_i   ( clk_i      ),
  .rd_addr_i  ( rd_ptr     ),
  .rd_data_o  ( buf_data   ),
  .rd_i       ( rd_mem     )
);

assign empty_o       = empty;
assign unread_o      = unread;
assign video_o.tdata = TDATA_WIDTH'( buf_data );


endmodule
