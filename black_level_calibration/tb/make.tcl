quietly set x_res 640
quietly set y_res 480
quietly set total_x 700
quietly set total_y 500

exec ../../lib/axi4_lib/scripts/rgb_img2bayer_hex.py ../../test.png $x_res $y_res 10

vlib work
vlog -sv -f ./files 
#vopt +acc tb_blc -o tb_blc_opt -G/tb_blc/FRAME_RES_X=$x_res -G/tb_blc/FRAME_RES_Y=$y_res -G/tb_blc/TOTAL_X=$total_x -G/tb_blc/TOTAL_Y=$total_y
vsim -G/tb_blc/FRAME_RES_X=$x_res -G/tb_blc/FRAME_RES_Y=$y_res -G/tb_blc/TOTAL_X=$total_x -G/tb_blc/TOTAL_Y=$total_y tb_blc
do wave.do
run -all

exec ../../lib/axi4_lib/scripts/display_grayscale_hex.py ./rx_img.hex [expr {$x_res}] [expr {$y_res}] 10
