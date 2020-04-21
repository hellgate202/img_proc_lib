onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/aclk
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/aresetn
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tvalid
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tready
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tdata
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tstrb
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tkeep
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tlast
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tid
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tdest
add wave -noupdate /tb_bilinear_demosaicing_3x3/raw_video/tuser
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/clk_i
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/rst_i
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/video_i_d1
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/push_data
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/active_wr_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/tvalid_masked
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/active_rd_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/rd_inact_pos
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/wr_act_pos
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/read_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/active_flush_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/flush_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/read_ready
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/pre_line_buf_tready
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/post_line_buf_tready
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_from_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/shifted_data_from_buf
add wave -noupdate -expand -subitemconfig {{/tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_to_shift_reg[2]} -expand {/tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_to_shift_reg[1]} -expand {/tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_to_shift_reg[0]} -expand} /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_to_shift_reg
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/unread_from_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/shifted_unread_from_buf
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/unread_to_shift_reg
add wave -noupdate -expand -subitemconfig {{/tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_shift_reg[2]} -expand {/tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_shift_reg[1]} -expand {/tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_shift_reg[0]} -expand} /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/data_shift_reg
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/read_done
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/aclk
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/aresetn
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tvalid
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tready
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tdata
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tstrb
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tkeep
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tlast
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tid
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tdest
add wave -noupdate /tb_bilinear_demosaicing_3x3/DUT/window_buf_inst/window_data_o/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {19562350 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 541
configure wave -valuecolwidth 147
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {42441677 ps} {43078584 ps}
