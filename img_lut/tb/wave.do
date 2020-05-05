onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_img_lut/img_lut_ctrl/orig_px
add wave -noupdate /tb_img_lut/img_lut_ctrl/mod_px
add wave -noupdate /tb_img_lut/img_lut_ctrl/wr_stb
add wave -noupdate /tb_img_lut/video_i/aclk
add wave -noupdate /tb_img_lut/video_i/aresetn
add wave -noupdate /tb_img_lut/video_i/tvalid
add wave -noupdate /tb_img_lut/video_i/tready
add wave -noupdate /tb_img_lut/video_i/tdata
add wave -noupdate /tb_img_lut/video_i/tstrb
add wave -noupdate /tb_img_lut/video_i/tkeep
add wave -noupdate /tb_img_lut/video_i/tlast
add wave -noupdate /tb_img_lut/video_i/tid
add wave -noupdate /tb_img_lut/video_i/tdest
add wave -noupdate /tb_img_lut/video_i/tuser
add wave -noupdate /tb_img_lut/DUT/clk_i
add wave -noupdate /tb_img_lut/DUT/rst_i
add wave -noupdate /tb_img_lut/DUT/lut_tdata
add wave -noupdate /tb_img_lut/video_o/aclk
add wave -noupdate /tb_img_lut/video_o/aresetn
add wave -noupdate /tb_img_lut/video_o/tvalid
add wave -noupdate /tb_img_lut/video_o/tready
add wave -noupdate /tb_img_lut/video_o/tdata
add wave -noupdate /tb_img_lut/video_o/tstrb
add wave -noupdate /tb_img_lut/video_o/tkeep
add wave -noupdate /tb_img_lut/video_o/tlast
add wave -noupdate /tb_img_lut/video_o/tid
add wave -noupdate /tb_img_lut/video_o/tdest
add wave -noupdate /tb_img_lut/video_o/tuser
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24730615 ps} 0}
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
WaveRestoreZoom {0 ps} {12214192331 ps}
