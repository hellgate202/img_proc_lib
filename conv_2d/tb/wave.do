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
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/clk_i
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/rst_i
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/coef_i
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/raw_window
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/casted_raw_window
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/casted_coef_window
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/mult_window
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/tc_mult_window
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/adder_valid
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/adder_ready
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/mult_sum
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/sum_valid
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/sum_ready
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/tuser_delay_mult
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/tlast_delay_mult
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/tuser_delay_add
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/tlast_delay_add
add wave -noupdate /tb_conv_2d/DUT/conv_2d_inst/sum_int
add wave -noupdate /tb_conv_2d/DUT/clk_i
add wave -noupdate /tb_conv_2d/DUT/rst_i
add wave -noupdate -expand /tb_conv_2d/DUT/coef
add wave -noupdate /tb_conv_2d/csr_if/aclk
add wave -noupdate /tb_conv_2d/csr_if/aresetn
add wave -noupdate /tb_conv_2d/csr_if/awvalid
add wave -noupdate /tb_conv_2d/csr_if/awready
add wave -noupdate /tb_conv_2d/csr_if/awaddr
add wave -noupdate /tb_conv_2d/csr_if/awprot
add wave -noupdate /tb_conv_2d/csr_if/wvalid
add wave -noupdate /tb_conv_2d/csr_if/wready
add wave -noupdate /tb_conv_2d/csr_if/wdata
add wave -noupdate /tb_conv_2d/csr_if/wstrb
add wave -noupdate /tb_conv_2d/csr_if/bvalid
add wave -noupdate /tb_conv_2d/csr_if/bready
add wave -noupdate /tb_conv_2d/csr_if/bresp
add wave -noupdate /tb_conv_2d/csr_if/arvalid
add wave -noupdate /tb_conv_2d/csr_if/arready
add wave -noupdate /tb_conv_2d/csr_if/araddr
add wave -noupdate /tb_conv_2d/csr_if/arprot
add wave -noupdate /tb_conv_2d/csr_if/rvalid
add wave -noupdate /tb_conv_2d/csr_if/rready
add wave -noupdate /tb_conv_2d/csr_if/rdata
add wave -noupdate /tb_conv_2d/csr_if/rresp
add wave -noupdate /tb_conv_2d/DUT/conv_2d_ctrl_i/wr_stb
add wave -noupdate /tb_conv_2d/DUT/conv_2d_ctrl_i/coef_num
add wave -noupdate /tb_conv_2d/DUT/conv_2d_ctrl_i/coef_val
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68420 ps} 0}
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
WaveRestoreZoom {25198 ps} {111642 ps}
