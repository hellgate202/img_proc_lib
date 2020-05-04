module color_corrector #(
  parameter int PX_WIDTH    = 10,
  parameter int FRACT_WIDTH = 10
)(
  input                 clk_i,
  input                 rst_i,
  cc_ctrl_if.slave      cc_ctrl_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

localparam int COEF_WIDTH  = PX_WIDTH + FRACT_WIDTH;
localparam int TDATA_WIDTH = PX_WIDTH % 8 ?
                             ( PX_WIDTH * 3 / 8 + 1 ) * 8 :
                             PX_WIDTH * 3;

localparam logic [COEF_WIDTH : 0] FIXED_ONE = { 1'b0, PX_WIDTH'( 1 ), FRACT_WIDTH'( 0 ) };

function logic [COEF_WIDTH * 2 : 0] oc_to_tc(
  input logic                          sign_i,
  input logic [COEF_WIDTH * 2 - 1 : 0] abs_i
);

logic [COEF_WIDTH * 2 : 0] tc;

tc[COEF_WIDTH * 2] = sign_i;
if( sign_i )
  tc[COEF_WIDTH * 2 - 1 : 0] = ~( abs_i - 1'b1 );
else
  tc[COEF_WIDTH * 2 - 1 : 0] = abs_i;
return tc;

endfunction

function logic [PX_WIDTH - 1 : 0] clip(
  input logic [COEF_WIDTH * 2 : 0] f_s_i
);

logic [PX_WIDTH - 1 : 0] clip_value;

if( f_s_i[COEF_WIDTH * 2] )
  clip_value = PX_WIDTH'( 0 );
else
  if( f_s_i[COEF_WIDTH * 2 - 1 -: PX_WIDTH] != PX_WIDTH'( 0 ) )
    clip_value = PX_WIDTH'( 2 ** PX_WIDTH - 1 );
  else
    clip_value = f_s_i[PX_WIDTH * 3 - 1 -: PX_WIDTH];
return clip_value;

endfunction

logic [COEF_WIDTH : 0]         a11;
logic [COEF_WIDTH : 0]         a12;
logic [COEF_WIDTH : 0]         a13;
logic [COEF_WIDTH : 0]         a14;
logic [COEF_WIDTH : 0]         a21;
logic [COEF_WIDTH : 0]         a22;
logic [COEF_WIDTH : 0]         a23;
logic [COEF_WIDTH : 0]         a24;
logic [COEF_WIDTH : 0]         a31;
logic [COEF_WIDTH : 0]         a32;
logic [COEF_WIDTH : 0]         a33;
logic [COEF_WIDTH : 0]         a34;
logic [COEF_WIDTH - 1 : 0]     r_fixed;
logic [COEF_WIDTH - 1 : 0]     g_fixed;
logic [COEF_WIDTH - 1 : 0]     b_fixed;
logic [COEF_WIDTH * 2 - 1 : 0] a11r_u;
logic [COEF_WIDTH * 2 - 1 : 0] a12g_u;
logic [COEF_WIDTH * 2 - 1 : 0] a13b_u;
logic [COEF_WIDTH * 2 - 1 : 0] a21r_u;
logic [COEF_WIDTH * 2 - 1 : 0] a22g_u;
logic [COEF_WIDTH * 2 - 1 : 0] a23b_u;
logic [COEF_WIDTH * 2 - 1 : 0] a31r_u;
logic [COEF_WIDTH * 2 - 1 : 0] a32g_u;
logic [COEF_WIDTH * 2 - 1 : 0] a33b_u;
logic [COEF_WIDTH * 2 : 0]     a11r;
logic [COEF_WIDTH * 2 : 0]     a12g;
logic [COEF_WIDTH * 2 : 0]     a13b;
logic [COEF_WIDTH * 2 : 0]     a141;
logic [COEF_WIDTH * 2 : 0]     a21r;
logic [COEF_WIDTH * 2 : 0]     a22g;
logic [COEF_WIDTH * 2 : 0]     a23b;
logic [COEF_WIDTH * 2 : 0]     a241;
logic [COEF_WIDTH * 2 : 0]     a31r;
logic [COEF_WIDTH * 2 : 0]     a32g;
logic [COEF_WIDTH * 2 : 0]     a33b;
logic [COEF_WIDTH * 2 : 0]     a341;
logic [COEF_WIDTH * 2 : 0]     a11ra12g;
logic [COEF_WIDTH * 2 : 0]     a21ra22g;
logic [COEF_WIDTH * 2 : 0]     a31ra32g;
logic [COEF_WIDTH * 2 : 0]     a13ba14;
logic [COEF_WIDTH * 2 : 0]     a23ba24;
logic [COEF_WIDTH * 2 : 0]     a33ba34;
logic [COEF_WIDTH * 2 : 0]     r_f_s;
logic [COEF_WIDTH * 2 : 0]     g_f_s;
logic [COEF_WIDTH * 2 : 0]     b_f_s;
logic [PX_WIDTH - 1 : 0]       r_clip;
logic [PX_WIDTH - 1 : 0]       g_clip;
logic [PX_WIDTH - 1 : 0]       b_clip;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      a11 <= FIXED_ONE;
      a12 <= FIXED_ONE;
      a13 <= FIXED_ONE;
      a14 <= FIXED_ONE;
      a21 <= FIXED_ONE;
      a22 <= FIXED_ONE;
      a23 <= FIXED_ONE;
      a24 <= FIXED_ONE;
      a31 <= FIXED_ONE;
      a32 <= FIXED_ONE;
      a33 <= FIXED_ONE;
      a34 <= FIXED_ONE;
    end
  else
    if( cc_ctrl_i.coef_lock )
      case( cc_ctrl_i.coef_sel )
        4'd0:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd1:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd2:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd3:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd4:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd5:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd6:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd7:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd8:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd9:  a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd10: a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        4'd11: a11 <= cc_ctrl_i.coef[COEF_WIDTH : 0];
        default:;
      endcase

axi4_stream_if #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_d [4 : 0] (
  .aclk        ( clk_i       ),
  .aresetn     ( !rst_i      )
);

axi4_stream_delay #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_delay_0 (
  .clk_i       ( clk_i       ),
  .rst_i       ( rst_i       ),
  .pkt_i       ( video_i     ),
  .pkt_o       ( video_d[0]  )
);

axi4_stream_delay #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_delay_1 (
  .clk_i       ( clk_i       ),
  .rst_i       ( rst_i       ),
  .pkt_i       ( video_d[0]  ),
  .pkt_o       ( video_d[1]  )
);

axi4_stream_delay #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_delay_2 (
  .clk_i       ( clk_i       ),
  .rst_i       ( rst_i       ),
  .pkt_i       ( video_d[1]  ),
  .pkt_o       ( video_d[2]  )
);

axi4_stream_delay #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_delay_3 (
  .clk_i       ( clk_i       ),
  .rst_i       ( rst_i       ),
  .pkt_i       ( video_d[2]  ),
  .pkt_o       ( video_d[3]  )
);

axi4_stream_delay #(
  .TDATA_WIDTH ( TDATA_WIDTH ),
  .TUSER_WIDTH ( 1           ),
  .TID_WIDTH   ( 1           ),
  .TDEST_WIDTH ( 1           )
) video_delay_4 (
  .clk_i       ( clk_i       ),
  .rst_i       ( rst_i       ),
  .pkt_i       ( video_d[3]  ),
  .pkt_o       ( video_d[4]  )
);

assign r_fixed = ( COEF_WIDTH * 2 )'( video_i.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH] << FRACT_WIDTH );
assign g_fixed = ( COEF_WIDTH * 2 )'( video_i.tdata[PX_WIDTH - 1 -: PX_WIDTH] << FRACT_WIDTH );
assign b_fixed = ( COEF_WIDTH * 2 )'( video_i.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH] << FRACT_WIDTH );

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      a11r_u <= ( COEF_WIDTH * 2 )'( 0 );
      a12g_u <= ( COEF_WIDTH * 2 )'( 0 );
      a13b_u <= ( COEF_WIDTH * 2 )'( 0 );
      a21r_u <= ( COEF_WIDTH * 2 )'( 0 );
      a22g_u <= ( COEF_WIDTH * 2 )'( 0 );
      a23b_u <= ( COEF_WIDTH * 2 )'( 0 );
      a31r_u <= ( COEF_WIDTH * 2 )'( 0 );
      a32g_u <= ( COEF_WIDTH * 2 )'( 0 );
      a33b_u <= ( COEF_WIDTH * 2 )'( 0 );
    end
  else
    if( video_i.tvalid && video_i.tready )
      begin
        a11r_u <= a11[COEF_WIDTH * 2 - 1 : 0] * r_fixed;
        a12g_u <= a12[COEF_WIDTH * 2 - 1 : 0] * g_fixed;
        a13b_u <= a13[COEF_WIDTH * 2 - 1 : 0] * b_fixed;
        a21r_u <= a21[COEF_WIDTH * 2 - 1 : 0] * r_fixed;
        a22g_u <= a22[COEF_WIDTH * 2 - 1 : 0] * g_fixed;
        a23b_u <= a23[COEF_WIDTH * 2 - 1 : 0] * b_fixed;
        a31r_u <= a31[COEF_WIDTH * 2 - 1 : 0] * r_fixed;
        a32g_u <= a32[COEF_WIDTH * 2 - 1 : 0] * g_fixed;
        a33b_u <= a33[COEF_WIDTH * 2 - 1 : 0] * b_fixed;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      a11r <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a12g <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a13b <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a141 <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a21r <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a22g <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a23b <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a241 <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a31r <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a32g <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a33b <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a341 <= ( COEF_WIDTH * 2 + 1 )'( 0 );
    end
  else
    if( video_d[0].tvalid && video_d[0].tready )
      begin
        a141 <= oc_to_tc( a14[COEF_WIDTH * 2], 
                          { ( PX_WIDTH * 3 )'( a14[COEF_WIDTH - 1 : 0] ), FRACT_WIDTH'( 0 ) } );
        a241 <= oc_to_tc( a24[COEF_WIDTH * 2], 
                          { ( PX_WIDTH * 3 )'( a24[COEF_WIDTH - 1 : 0] ), FRACT_WIDTH'( 0 ) } );
        a341 <= oc_to_tc( a34[COEF_WIDTH * 2], 
                          { ( PX_WIDTH * 3 )'( a34[COEF_WIDTH - 1 : 0] ), FRACT_WIDTH'( 0 ) } );
        a11r <= oc_to_tc( a11[PX_WIDTH * 2], a11r_u );
        a12g <= oc_to_tc( a12[PX_WIDTH * 2], a12g_u );
        a13b <= oc_to_tc( a13[PX_WIDTH * 2], a13b_u );
        a21r <= oc_to_tc( a21[PX_WIDTH * 2], a21r_u );
        a22g <= oc_to_tc( a22[PX_WIDTH * 2], a22g_u );
        a23b <= oc_to_tc( a23[PX_WIDTH * 2], a23b_u );
        a31r <= oc_to_tc( a31[PX_WIDTH * 2], a31r_u );
        a32g <= oc_to_tc( a32[PX_WIDTH * 2], a32g_u );
        a33b <= oc_to_tc( a33[PX_WIDTH * 2], a33b_u );
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      a11ra12g <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a21ra22g <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a31ra32g <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a13ba14  <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a23ba24  <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      a33ba34  <= ( COEF_WIDTH * 2 + 1 )'( 0 );
    end
  else
    if( video_d[1].tvalid && video_d[1].tready )
      begin
        a11ra12g <= a11r + a12g;
        a21ra22g <= a21r + a22g;
        a31ra32g <= a31r + a32g;
        a13ba14  <= a13b + a141;
        a23ba24  <= a23b + a241;
        a33ba34  <= a33b + a341;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      r_f_s <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      g_f_s <= ( COEF_WIDTH * 2 + 1 )'( 0 );
      b_f_s <= ( COEF_WIDTH * 2 + 1 )'( 0 );
    end
  else
    if( video_d[2].tvalid && video_d[2].tready )
      begin
        r_f_s <= a11ra12g + a13ba14;
        g_f_s <= a21ra22g + a23ba24;
        b_f_s <= a31ra32g + a33ba34;
      end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      r_clip <= PX_WIDTH'( 0 );
      g_clip <= PX_WIDTH'( 0 );
      b_clip <= PX_WIDTH'( 0 );
    end
  else
    if( video_d[3].tvalid && video_d[3].tready )
      begin
        r_clip <= clip( r_f_s );
        g_clip <= clip( g_f_s );
        b_clip <= clip( b_f_s );
      end

generate
  if( ( PX_WIDTH * 3 ) == TDATA_WIDTH )
    begin : n_append
      assign video_o.tdata[PX_WIDTH - 1 -: PX_WIDTH]     = g_clip;
      assign video_o.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH] = b_clip;
      assign video_o.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH] = r_clip;
    end
  else
    begin : append
      assign video_o.tdata[TDATA_WIDTH - 1 : PX_WIDTH * 3] = ( TDATA_WIDTH - PX_WIDTH * 3 )'( 0 );
      assign video_o.tdata[PX_WIDTH - 1 -: PX_WIDTH]       = g_clip;
      assign video_o.tdata[PX_WIDTH * 2 - 1 -: PX_WIDTH]   = b_clip;
      assign video_o.tdata[PX_WIDTH * 3 - 1 -: PX_WIDTH]   = r_clip;
    end
endgenerate

assign video_o.tvalid    = video_d[4].tvalid;
assign video_o.tlast     = video_d[4].tlast;
assign video_o.tuser     = video_d[4].tuser;
assign video_o.tstrb     = video_d[4].tstrb;
assign video_o.tkeep     = video_d[4].tkeep;
assign video_o.tid       = video_d[4].tid;
assign video_o.tdest     = video_d[4].tdest;
assign video_d[4].tready = video_o.tready;

endmodule
