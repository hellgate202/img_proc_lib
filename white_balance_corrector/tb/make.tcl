quietly set x_res 640
quietly set y_res 480
quietly set total_x 700
quietly set total_y 500
quietly set frames  2

exec ../../lib/axi4_lib/scripts/rgb_img2rgb_hex.py ../../test.png $x_res $y_res 10

vlib work
vlog -sv -f ./files 
vopt +acc tb_white_balance_corrector -o tb_white_balance_corrector_opt                 \
                                     -G/tb_white_balance_corrector/FRAME_RES_X=$x_res   \
                                     -G/tb_white_balance_corrector/FRAME_RES_Y=$y_res   \
                                     -G/tb_white_balance_corrector/TOTAL_X=$total_x     \
                                     -G/tb_white_balance_corrector/TOTAL_Y=$total_y     \
                                     -G/tb_white_balance_corrector/FRAMES_AMOUNT=$frames
vsim tb_white_balance_corrector_opt
do wave.do
run -all

exec ../../lib/axi4_lib/scripts/display_rgb_hex.py ./rx_img.hex [expr {$x_res}] [expr {$y_res * $frames}] 10
