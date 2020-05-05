onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_gamma_corrector/video_i/aclk
add wave -noupdate /tb_gamma_corrector/video_i/aresetn
add wave -noupdate /tb_gamma_corrector/video_i/tvalid
add wave -noupdate /tb_gamma_corrector/video_i/tready
add wave -noupdate /tb_gamma_corrector/video_i/tdata
add wave -noupdate /tb_gamma_corrector/video_i/tstrb
add wave -noupdate /tb_gamma_corrector/video_i/tkeep
add wave -noupdate /tb_gamma_corrector/video_i/tlast
add wave -noupdate /tb_gamma_corrector/video_i/tid
add wave -noupdate /tb_gamma_corrector/video_i/tdest
add wave -noupdate /tb_gamma_corrector/video_i/tuser
add wave -noupdate /tb_gamma_corrector/video_o/aclk
add wave -noupdate /tb_gamma_corrector/video_o/aresetn
add wave -noupdate /tb_gamma_corrector/video_o/tvalid
add wave -noupdate /tb_gamma_corrector/video_o/tready
add wave -noupdate /tb_gamma_corrector/video_o/tdata
add wave -noupdate /tb_gamma_corrector/video_o/tstrb
add wave -noupdate /tb_gamma_corrector/video_o/tkeep
add wave -noupdate /tb_gamma_corrector/video_o/tlast
add wave -noupdate /tb_gamma_corrector/video_o/tid
add wave -noupdate /tb_gamma_corrector/video_o/tdest
add wave -noupdate /tb_gamma_corrector/video_o/tuser
add wave -noupdate /tb_gamma_corrector/gc_ctrl/orig_px
add wave -noupdate /tb_gamma_corrector/gc_ctrl/mod_px
add wave -noupdate /tb_gamma_corrector/gc_ctrl/wr_stb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {484574800 ps} 0}
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
WaveRestoreZoom {0 ps} {6634243366 ps}
