quietly set x_res 640
quietly set y_res 480
quietly set total_x 700
quietly set total_y 500
quietly set frames  2

exec ../../lib/axi4_lib/scripts/rgb_img2grayscale_hex.py ../../test.png $x_res $y_res 10

vlib work
vlog -sv -f ./files 
vopt +acc tb_img_lut -o tb_img_lut_opt                     \
                          -G/tb_img_lut/FRAME_RES_X=$x_res   \
                          -G/tb_img_lut/FRAME_RES_Y=$y_res   \
                          -G/tb_img_lut/TOTAL_X=$total_x     \
                          -G/tb_img_lut/TOTAL_Y=$total_y     \
                          -G/tb_img_lut/FRAMES_AMOUNT=$frames
vsim tb_img_lut_opt
do wave.do
run -all

exec ../../lib/axi4_lib/scripts/display_grayscale_hex.py ./rx_img.hex [expr {$x_res}] [expr {$y_res * $frames}] 10
