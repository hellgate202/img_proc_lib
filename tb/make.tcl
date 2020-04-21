proc compile_src { name } {
  vlib work
  vlog -sv -f ./$name/files 
}

proc draw_waveforms { tb_name } {
  if { [file exists "./$tb_name/wave.do"] } {
    do ./$tb_name/wave.do
  }
}

proc bilinear_demosaicing_3x3 {} {
  compile_src bilinear_demosaicing_3x3
  vopt +acc bilinear_demosaicing_3x3 -o bilinear_demosaicing_3x3_opt
  vsim bilinear_demosaicing_3x3_opt
  #draw_waveforms bilinear_demosaicing_3x3
  run -all
}

proc help {} {
  echo "bilinear_demosaicing_3x3 - bilinear demosaicing with 3x3 kernel."
  echo "Type help to repeat this message."
}

help
