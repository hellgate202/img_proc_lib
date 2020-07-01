module white_balance_corrector #(
  parameter int PX_WIDTH    = 10,
  parameter int FRAME_RES_X = 1920,
  parameter int FRAME_RES_Y = 1080,
  parameter int FRACT_WIDTH = 10
)(
  input                 clk_i,
  input                 rst_i,
  wb_ctrl_if.slave      wb_ctrl_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam bit [1 : 0]              AUTO_GW_MODE     = 2'd0;
localparam bit [1 : 0]              AUTO_R_MODE      = 2'd1;
localparam bit [1 : 0]              MANUAL_MODE      = 2'd2;
localparam bit [1 : 0]              CALIBRATION_MODE = 2'd3;
localparam bit [1 : 0]              MANUAL_RED       = 2'd0;
localparam bit [1 : 0]              MANUAL_GREEN     = 2'd1;
localparam bit [1 : 0]              MANUAL_BLUE      = 2'd2;
localparam int                      TDATA_WIDTH      = PX_WIDTH % 8 ? 
                                                       ( PX_WIDTH * 3 / 8 + 1 ) * 8 : 
                                                       PX_WIDTH * 3;
localparam int                      TDATA_WIDTH_B    = TDATA_WIDTH / 8;
localparam int                      COEF_WIDTH       = PX_WIDTH + FRACT_WIDTH;
localparam bit [COEF_WIDTH - 1 : 0] FIXED_ONE = { PX_WIDTH'( 1 ), FRACT_WIDTH'( 0 ) };
localparam bit [COEF_WIDTH - 1 : 0] R_INIT    = { PX_WIDTH'( 2 ), FRACT_WIDTH'( 10'h14c ) }; //2.324
localparam bit [COEF_WIDTH - 1 : 0] B_INIT    = { PX_WIDTH'( 1 ), FRACT_WIDTH'( 10'h183 ) }; //1.377

logic [COEF_WIDTH - 1 : 0]     gw_r_corr;
logic [COEF_WIDTH - 1 : 0]     gw_b_corr;
logic [COEF_WIDTH - 1 : 0]     r_r_corr;
logic [COEF_WIDTH - 1 : 0]     r_b_corr;
logic [COEF_WIDTH - 1 : 0]     man_r_corr;
logic [COEF_WIDTH - 1 : 0]     man_g_corr;
logic [COEF_WIDTH - 1 : 0]     man_b_corr;
logic [COEF_WIDTH - 1 : 0]     r_corr;
logic [COEF_WIDTH - 1 : 0]     g_corr;
logic [COEF_WIDTH - 1 : 0]     b_corr;
logic [COEF_WIDTH - 1 : 0]     r_fixed;
logic [COEF_WIDTH - 1 : 0]     g_fixed;
logic [COEF_WIDTH - 1 : 0]     b_fixed;
logic [COEF_WIDTH * 2 - 1 : 0] balanced_r;
logic [COEF_WIDTH * 2 - 1 : 0] balanced_g;
logic [COEF_WIDTH * 2 - 1 : 0] balanced_b;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) gw_path_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) r_path_video (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

assign gw_path_video.tdata  = video_i.tdata;
assign gw_path_video.tvalid = video_i.tvalid && video_i.tready;
assign gw_path_video.tstrb  = video_i.tstrb;
assign gw_path_video.tkeep  = video_i.tkeep;
assign gw_path_video.tlast  = video_i.tlast;
assign gw_path_video.tuser  = video_i.tuser;
assign gw_path_video.tid    = video_i.tid;
assign gw_path_video.tdest  = video_i.tdest;

assign r_path_video.tdata  = video_i.tdata;
assign r_path_video.tvalid = video_i.tvalid && video_i.tready;
assign r_path_video.tstrb  = video_i.tstrb;
assign r_path_video.tkeep  = video_i.tkeep;
assign r_path_video.tlast  = video_i.tlast;
assign r_path_video.tuser  = video_i.tuser;
assign r_path_video.tid    = video_i.tid;
assign r_path_video.tdest  = video_i.tdest;

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_d1 (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

assign video_i.tready = video_d1.tready || !video_d1.tvalid;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      video_d1.tvalid <= 1'b0;
      video_d1.tdata  <= TDATA_WIDTH'( 0 );
      video_d1.tlast  <= 1'b0;
      video_d1.tuser  <= 1'b0;
      video_d1.tstrb  <= TDATA_WIDTH_B'( 0 );
      video_d1.tkeep  <= TDATA_WIDTH_B'( 0 );
      video_d1.tid    <= 1'b0;
      video_d1.tdest  <= 1'b0;
    end
  else
    if( video_i.tready )
      begin
        video_d1.tvalid <= video_i.tvalid;
        video_d1.tdata  <= video_i.tdata;
        video_d1.tlast  <= video_i.tlast;
        video_d1.tuser  <= video_i.tuser;
        video_d1.tstrb  <= video_i.tstrb;
        video_d1.tkeep  <= video_i.tkeep;
        video_d1.tid    <= video_i.tid;
        video_d1.tdest  <= video_i.tdest;
      end

assign video_d1.tready = video_o.tready || !video_o.tvalid;

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
    if( video_d1.tready )
      begin
        video_o.tvalid <= video_d1.tvalid;
        video_o.tlast  <= video_d1.tlast;
        video_o.tuser  <= video_d1.tuser;
        video_o.tstrb  <= video_d1.tstrb;
        video_o.tkeep  <= video_d1.tkeep;
        video_o.tid    <= video_d1.tid;
        video_o.tdest  <= video_d1.tdest;
      end

awb_gray_world #(
  .PX_WIDTH    ( PX_WIDTH      ),
  .FRAME_RES_X ( FRAME_RES_X   ),
  .FRAME_RES_Y ( FRAME_RES_Y   ),
  .FRACT_WIDTH ( FRACT_WIDTH   )
) awb_gw (
  .clk_i       ( clk_i         ),
  .rst_i       ( rst_i         ),
  .video_i     ( gw_path_video ),
  .r_corr_o    ( gw_r_corr     ),
  .b_corr_o    ( gw_b_corr     )
);

awb_retinex #(
  .PX_WIDTH    ( PX_WIDTH     ),
  .FRACT_WIDTH ( FRACT_WIDTH  )
) awb_r (
  .clk_i       ( clk_i        ),
  .rst_i       ( rst_i        ),
  .video_i     ( r_path_video ),
  .r_corr_o    ( r_r_corr     ),
  .b_corr_o    ( r_b_corr     )
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      man_r_corr <= R_INIT;
      man_g_corr <= FIXED_ONE;
      man_b_corr <= B_INIT;
    end
  else
    if( wb_ctrl_i.man_lock )
      case( wb_ctrl_i.man_sel )
        MANUAL_RED:   man_r_corr <= wb_ctrl_i.man_coef[COEF_WIDTH - 1 : 0];
        MANUAL_GREEN: man_g_corr <= wb_ctrl_i.man_coef[COEF_WIDTH - 1 : 0];
        MANUAL_BLUE:  man_b_corr <= wb_ctrl_i.man_coef[COEF_WIDTH - 1 : 0];
        default:;
      endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    wb_ctrl_i.cur_coef <= '0;
  else
    case( wb_ctrl_i.man_sel )
      MANUAL_RED:   wb_ctrl_i.cur_coef <= r_corr;
      MANUAL_GREEN: wb_ctrl_i.cur_coef <= g_corr;
      MANUAL_BLUE:  wb_ctrl_i.cur_coef <= b_corr;
      default:;
    endcase

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      r_corr <= FIXED_ONE;
      g_corr <= FIXED_ONE;
      b_corr <= FIXED_ONE;
    end
  else
    case( wb_ctrl_i.mode )
      AUTO_GW_MODE:
        begin
          r_corr <= gw_r_corr;
          g_corr <= FIXED_ONE;
          b_corr <= gw_b_corr;
        end
      AUTO_R_MODE:
        begin
          r_corr <= r_r_corr;
          g_corr <= FIXED_ONE;
          b_corr <= r_b_corr;
        end
      MANUAL_MODE:
        begin
          r_corr <= man_r_corr;
          g_corr <= man_g_corr;
          b_corr <= man_b_corr;
        end
      CALIBRATION_MODE:
        begin
          if( wb_ctrl_i.cal_stb )
            begin
              r_corr <= gw_r_corr;
              g_corr <= FIXED_ONE;
              b_corr <= gw_b_corr;
            end
        end
    endcase

assign r_fixed = COEF_WIDTH'( video_i.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH] ) << FRACT_WIDTH;
assign g_fixed = COEF_WIDTH'( video_i.tdata[PX_WIDTH - 1 -: PX_WIDTH] ) << FRACT_WIDTH;
assign b_fixed = COEF_WIDTH'( video_i.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH] ) << FRACT_WIDTH;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      balanced_r <= ( COEF_WIDTH * 2 )'( 0 );
      balanced_g <= ( COEF_WIDTH * 2 )'( 0 );
      balanced_b <= ( COEF_WIDTH * 2 )'( 0 );
    end
  else
    if( video_i.tvalid && video_i.tready )
      begin
        balanced_r <= r_fixed * r_corr;
        balanced_g <= g_fixed * g_corr;
        balanced_b <= b_fixed * b_corr;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tdata <= TDATA_WIDTH'( 0 );
  else
    if( video_d1.tvalid && video_d1.tready )
      begin
        if( balanced_r[COEF_WIDTH * 2 - 1 -: PX_WIDTH] != PX_WIDTH'( 0 ) )
          video_o.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH] <= PX_WIDTH'( 2 ** PX_WIDTH - 1 );
        else
          video_o.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH] <= balanced_r[COEF_WIDTH * 2 - PX_WIDTH - 1 -: PX_WIDTH];
        if( balanced_g[COEF_WIDTH * 2 - 1 -: PX_WIDTH] != PX_WIDTH'( 0 ) )
          video_o.tdata[PX_WIDTH - 1 -: PX_WIDTH] <= PX_WIDTH'( 2 ** PX_WIDTH - 1 );
        else
          video_o.tdata[PX_WIDTH - 1 -: PX_WIDTH] <= balanced_g[COEF_WIDTH * 2 - PX_WIDTH - 1 -: PX_WIDTH];
        if( balanced_b[COEF_WIDTH * 2 - 1 -: PX_WIDTH] != PX_WIDTH'( 0 ) )
          video_o.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH] <= PX_WIDTH'( 2 ** PX_WIDTH - 1 );
        else
          video_o.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH] <= balanced_b[COEF_WIDTH * 2 - PX_WIDTH - 1 -: PX_WIDTH];
      end

endmodule
