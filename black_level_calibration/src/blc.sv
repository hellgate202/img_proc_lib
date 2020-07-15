module blc #(
  parameter int PX_WIDTH         = 10,
  parameter int FRAME_RES_X      = 1920,
  parameter int FRAME_RES_Y      = 1080,
  parameter int INIT_BLACK_LEVEL = 16
)(
  input                 clk_i,
  input                 rst_i,
  blc_ctrl_if.slave     blc_ctrl_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int PX_AMOUNT     = FRAME_RES_X * FRAME_RES_Y;
localparam int PX_CNT_WIDTH  = $clog2( PX_AMOUNT + 1 );
localparam int PX_ACC_WIDTH  = PX_WIDTH + PX_CNT_WIDTH;
localparam int TDATA_WIDTH   = PX_WIDTH % 8 ? 
                               ( PX_WIDTH / 8 + 1 ) * 8 : 
                               PX_WIDTH;
localparam int TDATA_WIDTH_B = TDATA_WIDTH / 8;

logic [PX_CNT_WIDTH - 1 : 0] px_cnt;
logic [PX_ACC_WIDTH - 1 : 0] px_acc;
logic [PX_ACC_WIDTH - 1 : 0] round_threshold;
logic                        mean_calc_start;
logic                        mean_valid;
logic [PX_ACC_WIDTH - 1 : 0] mean;
logic [PX_ACC_WIDTH - 1 : 0] mean_reminder;
logic [PX_WIDTH - 1 : 0]     mean_black;
logic [PX_WIDTH - 1 : 0]     black_level;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_cnt <= PX_CNT_WIDTH'( 0 );
  else
    if( video_i.tvalid && video_i.tready )
      if( video_i.tuser )
        px_cnt <= PX_WIDTH'( 1 );
      else
        px_cnt <= px_cnt + 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    round_threshold <= PX_CNT_WIDTH'( 0 );
  else
    if( mean_calc_start )
      round_threshold <= px_cnt >> 1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    px_acc <= PX_ACC_WIDTH'( 0 );
  else
    if( video_i.tvalid && video_i.tready )
      if( video_i.tuser )
        px_acc <= video_i.tdata[PX_WIDTH - 1 : 0];
      else
        px_acc <= px_acc + video_i.tdata[PX_WIDTH - 1 : 0];

assign mean_calc_start = video_i.tvalid && video_i.tready && video_i.tuser;

division #(
  .WORD_W     ( PX_ACC_WIDTH            )
) mean_calc (
  .clk_i      ( clk_i                   ),
  .rst_i      ( rst_i                   ),
  .start_i    ( mean_calc_start         ),
  .divinded_i ( px_acc                  ),
  .divisor_i  ( PX_ACC_WIDTH'( px_cnt ) ),
  .ready_o    (                         ),
  .valid_o    ( mean_valid              ),
  .quotient_o ( mean                    ),
  .reminder_o ( mean_reminder           )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    mean_black <= PX_WIDTH'( 0 );
  else
    if( mean_valid )
      if( mean_reminder >= round_threshold )
        mean_black <= mean[PX_WIDTH - 1 : 0] + 1'b1;
      else
        mean_black <= mean[PX_WIDTH - 1 : 0];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    black_level <= PX_WIDTH'( INIT_BLACK_LEVEL );
  else
    if( blc_ctrl_i.mode )
      black_level <= blc_ctrl_i.man_bl;
    else
      if( blc_ctrl_i.cal_stb )
        black_level <= mean_black;

assign blc_ctrl_i.cur_bl = black_level;

assign video_i.tready = video_o.tready || !video_o.tvalid;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      video_o.tvalid <= 1'b0;
      video_o.tstrb  <= TDATA_WIDTH_B'( 0 );
      video_o.tkeep  <= TDATA_WIDTH_B'( 0 );
      video_o.tlast  <= 1'b0;
      video_o.tuser  <= 1'b0;
      video_o.tid    <= 1'b0;
      video_o.tdest  <= 1'b0;
    end
  else
    if( video_i.tready )
      begin
        video_o.tvalid <= video_i.tvalid;
        video_o.tstrb  <= video_i.tstrb;
        video_o.tkeep  <= video_i.tkeep;
        video_o.tlast  <= video_i.tlast;
        video_o.tuser  <= video_i.tuser;
        video_o.tid    <= video_i.tid;
        video_o.tdest  <= video_i.tdest;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tdata <= TDATA_WIDTH'( 0 );
  else
    if( video_i.tready )
      if( video_i.tdata[PX_WIDTH - 1 : 0] < black_level )
        video_o.tdata <= TDATA_WIDTH'( 0 );
      else
        video_o.tdata <= TDATA_WIDTH'( video_o.tdata - black_level );

endmodule
