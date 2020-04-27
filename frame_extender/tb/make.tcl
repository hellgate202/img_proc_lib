quietly set x_res 1920
quietly set y_res 1080
quietly set total_x 2200
quietly set total_y 1125
quietly set top 1
quietly set bottom 1
quietly set left 1
quietly set right 1
quietly set frames 3

exec ../../lib/axi4_lib/scripts/rgb_img2rgb_hex.py ../../test.png $x_res $y_res 10

vlib work
vlog -sv -f ./files 
vopt +acc tb_frame_extender -o tb_frame_extender_opt -G/tb_frame_extender/FRAME_RES_X=$x_res -G/tb_frame_extender/FRAME_RES_Y=$y_res -G/tb_frame_extender/TOTAL_X=$total_x -G/tb_frame_extender/TOTAL_Y=$total_y -G/tb_frame_extender/TOP=$top -G/tb_frame_extender/BOTTOM=$bottom -G/tb_frame_extender/LEFT=$left -G/tb_frame_extender/RIGHT=$right -G/tb_frame_extender/FRAMES_AMOUNT=$frames
vsim tb_frame_extender_opt
do wave.do
run -all

exec ../../lib/axi4_lib/scripts/display_rgb_hex.py ./rx_img.hex [expr {$x_res + $left + $right }] [expr {( $y_res + $top + $bottom ) * $frames}] 10
