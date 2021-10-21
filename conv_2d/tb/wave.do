onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider video_i
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/aclk
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/aresetn
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tvalid
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tready
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tdata
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tstrb
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tkeep
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tlast
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tid
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tdest
add wave -noupdate -radix hexadecimal /tb_conv_2d/video_i/tuser
add wave -noupdate -divider video_o
add wave -noupdate /tb_conv_2d/video_o/aclk
add wave -noupdate /tb_conv_2d/video_o/aresetn
add wave -noupdate /tb_conv_2d/video_o/tvalid
add wave -noupdate /tb_conv_2d/video_o/tready
add wave -noupdate /tb_conv_2d/video_o/tdata
add wave -noupdate /tb_conv_2d/video_o/tstrb
add wave -noupdate /tb_conv_2d/video_o/tkeep
add wave -noupdate /tb_conv_2d/video_o/tlast
add wave -noupdate /tb_conv_2d/video_o/tid
add wave -noupdate /tb_conv_2d/video_o/tdest
add wave -noupdate /tb_conv_2d/video_o/tuser
add wave -noupdate -divider DUT
add wave -noupdate /tb_conv_2d/DUT/clk_i
add wave -noupdate /tb_conv_2d/DUT/rst_i
add wave -noupdate /tb_conv_2d/DUT/coef_i
add wave -noupdate /tb_conv_2d/DUT/raw_window
add wave -noupdate /tb_conv_2d/DUT/casted_raw_window
add wave -noupdate /tb_conv_2d/DUT/casted_coef_window
add wave -noupdate /tb_conv_2d/DUT/mult_window
add wave -noupdate /tb_conv_2d/DUT/tc_mult_window
add wave -noupdate /tb_conv_2d/DUT/adder_valid
add wave -noupdate /tb_conv_2d/DUT/adder_ready
add wave -noupdate /tb_conv_2d/DUT/mult_sum
add wave -noupdate /tb_conv_2d/DUT/sum_valid
add wave -noupdate /tb_conv_2d/DUT/sum_ready
add wave -noupdate /tb_conv_2d/DUT/tuser_delay_mult
add wave -noupdate /tb_conv_2d/DUT/tlast_delay_mult
add wave -noupdate /tb_conv_2d/DUT/tuser_delay_add
add wave -noupdate /tb_conv_2d/DUT/tlast_delay_add
add wave -noupdate /tb_conv_2d/DUT/sum_int
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/COEF_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/COEF_FRACT_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/PX_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/TDATA_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/WIN_SIZE
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/FRAME_RES_X
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/FRAME_RES_Y
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/INTERLINE_GAP
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/COMPENSATE_EN
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/COEF_INT_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/WIN_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/WIN_TDATA_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/BIGGEST_INT_PART
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/CAST_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/MULT_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/MULT_WIN_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/MULT_TDATA_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/SUM_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/SUM_INT_WIDTH
add wave -noupdate -radix unsigned /tb_conv_2d/DUT/ADD_DELAY
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25488950 ps} 0}
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
WaveRestoreZoom {0 ps} {2498470734 ps}