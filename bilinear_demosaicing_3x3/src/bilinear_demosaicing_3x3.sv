module bilinear_demosaicing_3x3 #(
  parameter int RAW_PX_WIDTH  = 10,
  parameter int MAX_LINE_SIZE = 1920
)(
  input                     clk_i,
  input                     rst_i,
  demosaicing_ctrl_if.slave demosaicing_ctrl_i,
  axi4_stream_if.slave     raw_video_i,
  axi4_stream_if.master    rgb_video_o
);

localparam WIN_SIZE        = 3;
localparam RGB_PX_WIDTH    = RAW_PX_WIDTH * 3;
localparam RAW_TDATA_WIDTH = RAW_PX_WIDTH % 8 ?
                             ( RAW_PX_WIDTH / 8 + 1 ) * 8 :
                             RAW_PX_WIDTH;
localparam RGB_TDATA_WIDTH = RGB_PX_WIDTH % 8 ?
                             ( RGB_PX_WIDTH / 8 + 1 ) * 8 :
                             RGB_PX_WIDTH;
localparam WIN_WIDTH       = RAW_PX_WIDTH * WIN_SIZE * WIN_SIZE;
localparam WIN_TDATA_WIDTH = WIN_WIDTH % 8 ?
                            ( WIN_WIDTH / 8 + 1 ) * 8 :
                            WIN_WIDTH;

localparam bit [1 : 0] GBRG = 2'b00;
localparam bit [1 : 0] BGGR = 2'b01;
localparam bit [1 : 0] GRBG = 2'b10;
localparam bit [1 : 0] RGGB = 2'b11;

logic [WIN_SIZE - 1 : 0][WIN_SIZE - 1 : 0][RAW_PX_WIDTH - 1 : 0] win_data;
logic [RAW_PX_WIDTH : 0]                                         g_in_rb_half_sum_0;
logic [RAW_PX_WIDTH : 0]                                         g_in_rb_half_sum_1;
logic [RAW_PX_WIDTH + 1 : 0]                                     g_in_rb_sum;
logic [RAW_PX_WIDTH : 0]                                         rb_in_br_half_sum_0;
logic [RAW_PX_WIDTH : 0]                                         rb_in_br_half_sum_1;
logic [RAW_PX_WIDTH + 1 : 0]                                     rb_in_br_sum;
logic [RAW_PX_WIDTH : 0]                                         r_in_odd_b_in_even_g_sum;
logic [RAW_PX_WIDTH : 0]                                         r_in_odd_b_in_even_g_sum_d1;
logic [RAW_PX_WIDTH : 0]                                         r_in_even_b_in_odd_g_sum;
logic [RAW_PX_WIDTH : 0]                                         r_in_even_b_in_odd_g_sum_d1;
logic [RAW_PX_WIDTH - 1 : 0]                                     g_in_rb;
logic [RAW_PX_WIDTH - 1 : 0]                                     rb_in_br;
logic [RAW_PX_WIDTH - 1 : 0]                                     r_in_odd_b_in_even_g;
logic [RAW_PX_WIDTH - 1 : 0]                                     r_in_even_b_in_odd_g;
logic [RAW_PX_WIDTH - 1 : 0]                                     raw_d1, raw_d2;
logic                                                            odd_px, odd_px_reg;
logic                                                            odd_line, odd_line_reg;
logic                                                            odd_px_d1, odd_px_d2;
logic                                                            odd_line_d1, odd_line_d2;
logic                                                            win_data_val_d1, win_data_val_d2;
logic                                                            win_line_end_d1, win_line_end_d2;
logic                                                            win_frame_start_d1, win_frame_start_d2;
logic                                                            first_px_is_odd;
logic                                                            first_line_is_odd;

assign first_px_is_odd   = demosaicing_ctrl_i.pattern == RGGB || demosaicing_ctrl_i.pattern == GBRG;
assign first_line_is_odd = demosaicing_ctrl_i.pattern == RGGB || demosaicing_ctrl_i.pattern == GRBG;

axi4_stream_if #(
  .TDATA_WIDTH ( WIN_TDATA_WIDTH ),
  .TID_WIDTH   ( 1               ),
  .TDEST_WIDTH ( 1               ),
  .TUSER_WIDTH ( 1               )
) win_stream (
  .aclk        ( clk_i           ),
  .aresetn     ( !rst_i          )
);

window_buf #(
  .TDATA_WIDTH   ( RAW_TDATA_WIDTH ),
  .PX_WIDTH      ( RAW_PX_WIDTH    ),
  .WIN_SIZE      ( WIN_SIZE        ),
  .MAX_LINE_SIZE ( MAX_LINE_SIZE   )
) window_buf_inst (
  .clk_i         ( clk_i           ),
  .rst_i         ( rst_i           ),
  .video_i       ( raw_video_i     ),
  .window_data_o ( win_stream      )
);

assign win_stream.tready = !rgb_video_o.tvalid || rgb_video_o.tready;
assign win_data          = win_stream.tdata[WIN_WIDTH - 1 : 0];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    odd_px_reg <= 1'b0;
  else
    if( win_stream.tready && win_stream.tvalid )
      if( win_stream.tuser )
        odd_px_reg <= first_px_is_odd;
      else
        odd_px_reg <= !odd_px_reg;

assign odd_px = win_stream.tvalid && win_stream.tuser ? !first_px_is_odd :
                                                        odd_px_reg;
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    odd_line_reg <= 1'b0;
  else
    if( win_stream.tvalid && win_stream.tready )
      if( win_stream.tuser )
        odd_line_reg <= !first_line_is_odd;
      else
        if( win_stream.tlast )
          odd_line_reg <= !odd_line_reg;

assign odd_line = win_stream.tvalid && win_stream.tuser ? !first_line_is_odd :
                                                          odd_line_reg;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      g_in_rb_half_sum_0 <= ( RAW_PX_WIDTH + 1 )'( 0 );
      g_in_rb_half_sum_1 <= ( RAW_PX_WIDTH + 1 )'( 0 );
      g_in_rb_sum        <= ( RAW_PX_WIDTH + 2 )'( 0 );
    end
  else
    if( win_stream.tready )
      begin
        g_in_rb_half_sum_0 <= win_data[1][0] + win_data[0][1];
        g_in_rb_half_sum_1 <= win_data[1][2] + win_data[2][1];
        g_in_rb_sum        <= g_in_rb_half_sum_0 + g_in_rb_half_sum_1;
      end

assign g_in_rb = g_in_rb_sum[RAW_PX_WIDTH + 1 : 2];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      rb_in_br_half_sum_0 <= ( RAW_PX_WIDTH + 1 )'( 0 );
      rb_in_br_half_sum_1 <= ( RAW_PX_WIDTH + 1 )'( 0 );
      rb_in_br_sum        <= ( RAW_PX_WIDTH + 2 )'( 0 );
    end
  else
    if( win_stream.tready )
      begin
        rb_in_br_half_sum_0 <= win_data[0][0] + win_data[0][2];
        rb_in_br_half_sum_1 <= win_data[2][0] + win_data[2][2];
        rb_in_br_sum        <= rb_in_br_half_sum_0 + rb_in_br_half_sum_1;
      end

assign rb_in_br = rb_in_br_sum[RAW_PX_WIDTH + 1 : 2];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      r_in_odd_b_in_even_g_sum    <= ( RAW_PX_WIDTH + 1 )'( 0 );
      r_in_odd_b_in_even_g_sum_d1 <= ( RAW_PX_WIDTH + 1 )'( 0 );
    end
  else
    if( win_stream.tready )
      begin
        r_in_odd_b_in_even_g_sum    <= win_data[1][0] + win_data[1][2];
        r_in_odd_b_in_even_g_sum_d1 <= r_in_odd_b_in_even_g_sum;
      end

assign r_in_odd_b_in_even_g = r_in_odd_b_in_even_g_sum_d1[RAW_PX_WIDTH : 1];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      r_in_even_b_in_odd_g_sum    <= ( RAW_PX_WIDTH + 1 )'( 0 );
      r_in_even_b_in_odd_g_sum_d1 <= ( RAW_PX_WIDTH + 1 )'( 0 );
    end
  else
    if( win_stream.tready )
      begin
        r_in_even_b_in_odd_g_sum    <= win_data[0][1] + win_data[2][1];
        r_in_even_b_in_odd_g_sum_d1 <= r_in_even_b_in_odd_g_sum;
      end

assign r_in_even_b_in_odd_g = r_in_even_b_in_odd_g_sum_d1[RAW_PX_WIDTH : 1];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      raw_d1 <= RAW_PX_WIDTH'( 0 );
      raw_d2 <= RAW_PX_WIDTH'( 0 );
    end
  else
    if( win_stream.tready )
      begin
        raw_d1 <= win_data[1][1];
        raw_d2 <= raw_d1;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      win_data_val_d1    <= 1'b0;
      win_data_val_d2    <= 1'b0;
      win_line_end_d1    <= 1'b0;
      win_line_end_d2    <= 1'b0;
      win_frame_start_d1 <= 1'b0;
      win_frame_start_d2 <= 1'b0;
      odd_px_d1          <= 1'b0;
      odd_px_d2          <= 1'b0;
      odd_line_d1        <= 1'b0;
      odd_line_d2        <= 1'b0;
    end
  else
    if( win_stream.tready )
      begin
        win_data_val_d1    <= win_stream.tvalid;
        win_data_val_d2    <= win_data_val_d1;
        win_line_end_d1    <= win_stream.tlast;
        win_line_end_d2    <= win_line_end_d1;
        win_frame_start_d1 <= win_stream.tuser;
        win_frame_start_d2 <= win_frame_start_d1;
        odd_px_d1          <= odd_px;
        odd_px_d2          <= odd_px_d1;
        odd_line_d1        <= odd_line;
        odd_line_d2        <= odd_line_d1;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    rgb_video_o.tdata <= RGB_TDATA_WIDTH'( 0 );
  else
    if( win_stream.tready )
      if( !demosaicing_ctrl_i.en )
        begin
          rgb_video_o.tdata[RAW_PX_WIDTH - 1 : 0]                 <= raw_d2;
          rgb_video_o.tdata[RAW_PX_WIDTH * 2 - 1 -: RAW_PX_WIDTH] <= raw_d2;
          rgb_video_o.tdata[RAW_PX_WIDTH * 3 - 1 -: RAW_PX_WIDTH] <= raw_d2;
        end
      else
        if( odd_line_d2 )
          if( odd_px_d2 )
            begin
              rgb_video_o.tdata[RAW_PX_WIDTH - 1 : 0]                 <= g_in_rb;
              rgb_video_o.tdata[RAW_PX_WIDTH * 2 - 1 -: RAW_PX_WIDTH] <= rb_in_br;
              rgb_video_o.tdata[RAW_PX_WIDTH * 3 - 1 -: RAW_PX_WIDTH] <= raw_d2;
            end
          else
            begin
              rgb_video_o.tdata[RAW_PX_WIDTH - 1 : 0]                 <= raw_d2;
              rgb_video_o.tdata[RAW_PX_WIDTH * 2 - 1 -: RAW_PX_WIDTH] <= r_in_even_b_in_odd_g;
              rgb_video_o.tdata[RAW_PX_WIDTH * 3 - 1 -: RAW_PX_WIDTH] <= r_in_odd_b_in_even_g;
            end
        else
          if( odd_px_d2 )
            begin
              rgb_video_o.tdata[RAW_PX_WIDTH - 1 : 0]                 <= raw_d2;
              rgb_video_o.tdata[RAW_PX_WIDTH * 2 - 1 -: RAW_PX_WIDTH] <= r_in_odd_b_in_even_g;
              rgb_video_o.tdata[RAW_PX_WIDTH * 3 - 1 -: RAW_PX_WIDTH] <= r_in_even_b_in_odd_g;
            end
          else
            begin
              rgb_video_o.tdata[RAW_PX_WIDTH - 1 : 0]                 <= g_in_rb;
              rgb_video_o.tdata[RAW_PX_WIDTH * 2 - 1 -: RAW_PX_WIDTH] <= raw_d2;
              rgb_video_o.tdata[RAW_PX_WIDTH * 3 - 1 -: RAW_PX_WIDTH] <= rb_in_br;
            end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      rgb_video_o.tvalid <= 1'b0;
      rgb_video_o.tlast  <= 1'b0;
      rgb_video_o.tuser  <= 1'b0;
    end
  else
    if( win_stream.tready )
      begin
        rgb_video_o.tvalid <= win_data_val_d2;
        rgb_video_o.tlast  <= win_line_end_d2;
        rgb_video_o.tuser  <= win_frame_start_d2;
      end

assign rgb_video_o.tkeep = '1;
assign rgb_video_o.tstrb = '1;
assign rgb_video_o.tid   = 1'b0;
assign rgb_video_o.tdest = 1'b0;

endmodule
