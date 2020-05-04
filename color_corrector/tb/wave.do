onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_color_corrector/DUT/clk_i
add wave -noupdate /tb_color_corrector/DUT/video_i/aclk
add wave -noupdate /tb_color_corrector/DUT/video_i/aresetn
add wave -noupdate /tb_color_corrector/DUT/video_i/tvalid
add wave -noupdate /tb_color_corrector/DUT/video_i/tready
add wave -noupdate /tb_color_corrector/DUT/video_i/tdata
add wave -noupdate /tb_color_corrector/DUT/video_i/tstrb
add wave -noupdate /tb_color_corrector/DUT/video_i/tkeep
add wave -noupdate /tb_color_corrector/DUT/video_i/tlast
add wave -noupdate /tb_color_corrector/DUT/video_i/tid
add wave -noupdate /tb_color_corrector/DUT/video_i/tdest
add wave -noupdate /tb_color_corrector/DUT/video_i/tuser
add wave -noupdate /tb_color_corrector/DUT/rst_i
add wave -noupdate /tb_color_corrector/DUT/a11
add wave -noupdate /tb_color_corrector/DUT/a12
add wave -noupdate /tb_color_corrector/DUT/a13
add wave -noupdate /tb_color_corrector/DUT/a14
add wave -noupdate /tb_color_corrector/DUT/a21
add wave -noupdate /tb_color_corrector/DUT/a22
add wave -noupdate /tb_color_corrector/DUT/a23
add wave -noupdate /tb_color_corrector/DUT/a24
add wave -noupdate /tb_color_corrector/DUT/a31
add wave -noupdate /tb_color_corrector/DUT/a32
add wave -noupdate /tb_color_corrector/DUT/a33
add wave -noupdate /tb_color_corrector/DUT/a34
add wave -noupdate /tb_color_corrector/DUT/r_fixed
add wave -noupdate /tb_color_corrector/DUT/g_fixed
add wave -noupdate /tb_color_corrector/DUT/b_fixed
add wave -noupdate /tb_color_corrector/DUT/a11r_u
add wave -noupdate /tb_color_corrector/DUT/a12g_u
add wave -noupdate /tb_color_corrector/DUT/a13b_u
add wave -noupdate /tb_color_corrector/DUT/a21r_u
add wave -noupdate /tb_color_corrector/DUT/a22g_u
add wave -noupdate /tb_color_corrector/DUT/a23b_u
add wave -noupdate /tb_color_corrector/DUT/a31r_u
add wave -noupdate /tb_color_corrector/DUT/a32g_u
add wave -noupdate /tb_color_corrector/DUT/a33b_u
add wave -noupdate /tb_color_corrector/DUT/a11r
add wave -noupdate /tb_color_corrector/DUT/a12g
add wave -noupdate /tb_color_corrector/DUT/a13b
add wave -noupdate /tb_color_corrector/DUT/a141
add wave -noupdate /tb_color_corrector/DUT/a21r
add wave -noupdate /tb_color_corrector/DUT/a22g
add wave -noupdate /tb_color_corrector/DUT/a23b
add wave -noupdate /tb_color_corrector/DUT/a241
add wave -noupdate /tb_color_corrector/DUT/a31r
add wave -noupdate /tb_color_corrector/DUT/a32g
add wave -noupdate /tb_color_corrector/DUT/a33b
add wave -noupdate /tb_color_corrector/DUT/a341
add wave -noupdate /tb_color_corrector/DUT/a11ra12g
add wave -noupdate /tb_color_corrector/DUT/a21ra22g
add wave -noupdate /tb_color_corrector/DUT/a31ra32g
add wave -noupdate /tb_color_corrector/DUT/a13ba14
add wave -noupdate /tb_color_corrector/DUT/a23ba24
add wave -noupdate /tb_color_corrector/DUT/a33ba34
add wave -noupdate /tb_color_corrector/DUT/r_f_s
add wave -noupdate /tb_color_corrector/DUT/g_f_s
add wave -noupdate /tb_color_corrector/DUT/b_f_s
add wave -noupdate /tb_color_corrector/DUT/r_clip
add wave -noupdate /tb_color_corrector/DUT/g_clip
add wave -noupdate /tb_color_corrector/DUT/b_clip
add wave -noupdate /tb_color_corrector/DUT/video_o/aclk
add wave -noupdate /tb_color_corrector/DUT/video_o/aresetn
add wave -noupdate /tb_color_corrector/DUT/video_o/tvalid
add wave -noupdate /tb_color_corrector/DUT/video_o/tready
add wave -noupdate /tb_color_corrector/DUT/video_o/tdata
add wave -noupdate /tb_color_corrector/DUT/video_o/tstrb
add wave -noupdate /tb_color_corrector/DUT/video_o/tkeep
add wave -noupdate /tb_color_corrector/DUT/video_o/tlast
add wave -noupdate /tb_color_corrector/DUT/video_o/tid
add wave -noupdate /tb_color_corrector/DUT/video_o/tdest
add wave -noupdate /tb_color_corrector/DUT/video_o/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {138450536 ps} 0}
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
WaveRestoreZoom {0 ps} {4949606667 ps}
