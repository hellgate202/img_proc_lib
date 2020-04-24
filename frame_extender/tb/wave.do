onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider video_i
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/aclk
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/aresetn
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tvalid
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tready
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tdata
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tstrb
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tkeep
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tlast
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tid
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tdest
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_i/tuser
add wave -noupdate -divider DUT
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/clk_i
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/rst_i
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/allow_new_data
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/tfirst
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/tfirst_d1
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/left_cnt
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/right_cnt
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/left_cnt_en
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/right_cnt_en
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/output_reg
add wave -noupdate -divider video_o
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/aclk
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/aresetn
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tvalid
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tready
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tdata
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tstrb
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tkeep
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tlast
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tid
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tdest
add wave -noupdate /tb_frame_extender/DUT/line_extender_inst/video_o/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1515331 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 728
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
WaveRestoreZoom {0 ps} {32025784641 ps}
