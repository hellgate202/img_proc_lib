onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/aclk
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/aresetn
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tvalid
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tready
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tdata
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tstrb
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tkeep
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tlast
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tid
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tdest
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/video_i_d1/tuser
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/clk_i
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/rst_i
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/tfirst
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/frame_start
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/line_start
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/valid_px_per_interval
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/valid_ln_per_interval
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/px_skip_lock
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/px_add_lock
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/line_skip_lock
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/line_add_lock
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/px_pass_cnt
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/px_skip_cnt
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/px_add_cnt
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/ln_pass_cnt
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/ln_skip_cnt
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/ln_add_cnt
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/force_valid
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/skiped_valid
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/state
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/next_state
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/aclk
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/aresetn
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tvalid
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tready
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tdata
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tstrb
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tkeep
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tlast
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tid
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tdest
add wave -noupdate -radix hexadecimal /tb_px_subsampler/DUT/uncut_video/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {114478 ps} 0}
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
WaveRestoreZoom {0 ps} {1721673026 ps}
