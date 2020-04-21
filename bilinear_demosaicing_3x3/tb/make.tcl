vlib work
vlog -sv -f ./files 
vopt +acc tb_bilinear_demosaicing_3x3 -o tb_bilinear_demosaicing_3x3_opt
vsim tb_bilinear_demosaicing_3x3_opt
do wave.do
run -all
