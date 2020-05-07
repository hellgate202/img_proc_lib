# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CHANNELS_AMOUNT" -parent ${Page_0}
  ipgui::add_param $IPINST -name "COMPENSATE_EN" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INTERLINE_GAP" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CSR_BASE_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_RES_X" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FRAME_RES_Y" -parent ${Page_0}
  ipgui::add_param $IPINST -name "PX_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TDATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "TDATA_WIDTH_B" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIN_SIZE" -parent ${Page_0}


}

proc update_PARAM_VALUE.CHANNELS_AMOUNT { PARAM_VALUE.CHANNELS_AMOUNT } {
	# Procedure called to update CHANNELS_AMOUNT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CHANNELS_AMOUNT { PARAM_VALUE.CHANNELS_AMOUNT } {
	# Procedure called to validate CHANNELS_AMOUNT
	return true
}

proc update_PARAM_VALUE.COMPENSATE_EN { PARAM_VALUE.COMPENSATE_EN } {
	# Procedure called to update COMPENSATE_EN when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.COMPENSATE_EN { PARAM_VALUE.COMPENSATE_EN } {
	# Procedure called to validate COMPENSATE_EN
	return true
}

proc update_PARAM_VALUE.INTERLINE_GAP { PARAM_VALUE.INTERLINE_GAP } {
	# Procedure called to update INTERLINE_GAP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INTERLINE_GAP { PARAM_VALUE.INTERLINE_GAP } {
	# Procedure called to validate INTERLINE_GAP
	return true
}

proc update_PARAM_VALUE.CSR_BASE_ADDR { PARAM_VALUE.CSR_BASE_ADDR } {
	# Procedure called to update CSR_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CSR_BASE_ADDR { PARAM_VALUE.CSR_BASE_ADDR } {
	# Procedure called to validate CSR_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.FRAME_RES_X { PARAM_VALUE.FRAME_RES_X } {
	# Procedure called to update FRAME_RES_X when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_RES_X { PARAM_VALUE.FRAME_RES_X } {
	# Procedure called to validate FRAME_RES_X
	return true
}

proc update_PARAM_VALUE.FRAME_RES_Y { PARAM_VALUE.FRAME_RES_Y } {
	# Procedure called to update FRAME_RES_Y when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FRAME_RES_Y { PARAM_VALUE.FRAME_RES_Y } {
	# Procedure called to validate FRAME_RES_Y
	return true
}

proc update_PARAM_VALUE.PX_WIDTH { PARAM_VALUE.PX_WIDTH } {
	# Procedure called to update PX_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.PX_WIDTH { PARAM_VALUE.PX_WIDTH } {
	# Procedure called to validate PX_WIDTH
	return true
}

proc update_PARAM_VALUE.TDATA_WIDTH { PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to update TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDATA_WIDTH { PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to validate TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.TDATA_WIDTH_B { PARAM_VALUE.TDATA_WIDTH_B } {
	# Procedure called to update TDATA_WIDTH_B when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.TDATA_WIDTH_B { PARAM_VALUE.TDATA_WIDTH_B } {
	# Procedure called to validate TDATA_WIDTH_B
	return true
}

proc update_PARAM_VALUE.WIN_SIZE { PARAM_VALUE.WIN_SIZE } {
	# Procedure called to update WIN_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIN_SIZE { PARAM_VALUE.WIN_SIZE } {
	# Procedure called to validate WIN_SIZE
	return true
}


proc update_MODELPARAM_VALUE.CSR_BASE_ADDR { MODELPARAM_VALUE.CSR_BASE_ADDR PARAM_VALUE.CSR_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CSR_BASE_ADDR}] ${MODELPARAM_VALUE.CSR_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.CHANNELS_AMOUNT { MODELPARAM_VALUE.CHANNELS_AMOUNT PARAM_VALUE.CHANNELS_AMOUNT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CHANNELS_AMOUNT}] ${MODELPARAM_VALUE.CHANNELS_AMOUNT}
}

proc update_MODELPARAM_VALUE.PX_WIDTH { MODELPARAM_VALUE.PX_WIDTH PARAM_VALUE.PX_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.PX_WIDTH}] ${MODELPARAM_VALUE.PX_WIDTH}
}

proc update_MODELPARAM_VALUE.WIN_SIZE { MODELPARAM_VALUE.WIN_SIZE PARAM_VALUE.WIN_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIN_SIZE}] ${MODELPARAM_VALUE.WIN_SIZE}
}

proc update_MODELPARAM_VALUE.FRAME_RES_X { MODELPARAM_VALUE.FRAME_RES_X PARAM_VALUE.FRAME_RES_X } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_RES_X}] ${MODELPARAM_VALUE.FRAME_RES_X}
}

proc update_MODELPARAM_VALUE.FRAME_RES_Y { MODELPARAM_VALUE.FRAME_RES_Y PARAM_VALUE.FRAME_RES_Y } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FRAME_RES_Y}] ${MODELPARAM_VALUE.FRAME_RES_Y}
}

proc update_MODELPARAM_VALUE.COMPENSATE_EN { MODELPARAM_VALUE.COMPENSATE_EN PARAM_VALUE.COMPENSATE_EN } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.COMPENSATE_EN}] ${MODELPARAM_VALUE.COMPENSATE_EN}
}

proc update_MODELPARAM_VALUE.INTERLINE_GAP { MODELPARAM_VALUE.INTERLINE_GAP PARAM_VALUE.INTERLINE_GAP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INTERLINE_GAP}] ${MODELPARAM_VALUE.INTERLINE_GAP}
}

proc update_MODELPARAM_VALUE.TDATA_WIDTH { MODELPARAM_VALUE.TDATA_WIDTH PARAM_VALUE.TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDATA_WIDTH}] ${MODELPARAM_VALUE.TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.TDATA_WIDTH_B { MODELPARAM_VALUE.TDATA_WIDTH_B PARAM_VALUE.TDATA_WIDTH_B } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.TDATA_WIDTH_B}] ${MODELPARAM_VALUE.TDATA_WIDTH_B}
}

