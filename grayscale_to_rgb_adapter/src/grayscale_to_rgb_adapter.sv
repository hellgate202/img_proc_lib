module grayscale_to_rgb_adapter #(
  parameter int PX_WIDTH = 10
)(
  input                 clk_i,
  input                 rst_i,
  axi4_stream_if.slave  video_i,
  axi4_stream_if.master video_o
);

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      video_o.tvalid <= '0;
      video_o.tlast  <= '0;
      video_o.tstrb  <= '0;
      video_o.tkeep  <= '0;
      video_o.tuser  <= '0;
      video_o.tdest  <= '0;
      video_o.tid    <= '0;
    end
  else
    if( video_i.tready )
      begin
        video_o.tvalid <= video_i.tvalid;
        video_o.tlast  <= video_i.tlast;
        video_o.tstrb  <= '1;
        video_o.tkeep  <= '1;
        video_o.tuser  <= video_i.tuser;
        video_o.tdest  <= video_i.tdest;
        video_o.tid    <= video_i.tid;
      end

assign video_i.tready = !video_o.tvalid || video_o.tready;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    video_o.tdata <= '0;
  else
    if( video_i.tready )
      begin
        video_o.tdata[PX_WIDTH - 1 : 0]                <= video_i.tdata[PX_WIDTH - 1 : 0];
        video_o.tdata[2 * PX_WIDTH - 1 : PX_WIDTH]     <= video_i.tdata[PX_WIDTH - 1 : 0];
        video_o.tdata[3 * PX_WIDTH - 1 : 2 * PX_WIDTH] <= video_i.tdata[PX_WIDTH - 1 : 0]; 
      end

endmodule
