onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_blc/DUT/clk_i
add wave -noupdate /tb_blc/DUT/rst_i
add wave -noupdate /tb_blc/DUT/px_cnt
add wave -noupdate /tb_blc/DUT/px_acc
add wave -noupdate /tb_blc/DUT/round_threshold
add wave -noupdate /tb_blc/DUT/mean_calc_start
add wave -noupdate /tb_blc/DUT/mean_valid
add wave -noupdate /tb_blc/DUT/mean
add wave -noupdate /tb_blc/DUT/mean_reminder
add wave -noupdate /tb_blc/DUT/mean_black
add wave -noupdate /tb_blc/DUT/black_level
add wave -noupdate /tb_blc/video_i/aclk
add wave -noupdate /tb_blc/video_i/aresetn
add wave -noupdate /tb_blc/video_i/tvalid
add wave -noupdate /tb_blc/video_i/tready
add wave -noupdate /tb_blc/video_i/tdata
add wave -noupdate /tb_blc/video_i/tstrb
add wave -noupdate /tb_blc/video_i/tkeep
add wave -noupdate /tb_blc/video_i/tlast
add wave -noupdate /tb_blc/video_i/tid
add wave -noupdate /tb_blc/video_i/tdest
add wave -noupdate /tb_blc/video_i/tuser
add wave -noupdate /tb_blc/video_o/aclk
add wave -noupdate /tb_blc/video_o/aresetn
add wave -noupdate /tb_blc/video_o/tvalid
add wave -noupdate /tb_blc/video_o/tready
add wave -noupdate /tb_blc/video_o/tdata
add wave -noupdate /tb_blc/video_o/tstrb
add wave -noupdate /tb_blc/video_o/tkeep
add wave -noupdate /tb_blc/video_o/tlast
add wave -noupdate /tb_blc/video_o/tid
add wave -noupdate /tb_blc/video_o/tdest
add wave -noupdate /tb_blc/video_o/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68662905 ps} 0}
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
WaveRestoreZoom {0 ps} {2474833384 ps}
