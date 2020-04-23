# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "CSR_BASE_ADDR" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MAX_LINE_SIZE" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RAW_PX_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RAW_TDATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RAW_TDATA_WIDTH_B" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RGB_TDATA_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "RGB_TDATA_WIDTH_B" -parent ${Page_0}


}

proc update_PARAM_VALUE.CSR_BASE_ADDR { PARAM_VALUE.CSR_BASE_ADDR } {
	# Procedure called to update CSR_BASE_ADDR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CSR_BASE_ADDR { PARAM_VALUE.CSR_BASE_ADDR } {
	# Procedure called to validate CSR_BASE_ADDR
	return true
}

proc update_PARAM_VALUE.MAX_LINE_SIZE { PARAM_VALUE.MAX_LINE_SIZE } {
	# Procedure called to update MAX_LINE_SIZE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MAX_LINE_SIZE { PARAM_VALUE.MAX_LINE_SIZE } {
	# Procedure called to validate MAX_LINE_SIZE
	return true
}

proc update_PARAM_VALUE.RAW_PX_WIDTH { PARAM_VALUE.RAW_PX_WIDTH } {
	# Procedure called to update RAW_PX_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAW_PX_WIDTH { PARAM_VALUE.RAW_PX_WIDTH } {
	# Procedure called to validate RAW_PX_WIDTH
	return true
}

proc update_PARAM_VALUE.RAW_TDATA_WIDTH { PARAM_VALUE.RAW_TDATA_WIDTH } {
	# Procedure called to update RAW_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAW_TDATA_WIDTH { PARAM_VALUE.RAW_TDATA_WIDTH } {
	# Procedure called to validate RAW_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RAW_TDATA_WIDTH_B { PARAM_VALUE.RAW_TDATA_WIDTH_B } {
	# Procedure called to update RAW_TDATA_WIDTH_B when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RAW_TDATA_WIDTH_B { PARAM_VALUE.RAW_TDATA_WIDTH_B } {
	# Procedure called to validate RAW_TDATA_WIDTH_B
	return true
}

proc update_PARAM_VALUE.RGB_TDATA_WIDTH { PARAM_VALUE.RGB_TDATA_WIDTH } {
	# Procedure called to update RGB_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RGB_TDATA_WIDTH { PARAM_VALUE.RGB_TDATA_WIDTH } {
	# Procedure called to validate RGB_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RGB_TDATA_WIDTH_B { PARAM_VALUE.RGB_TDATA_WIDTH_B } {
	# Procedure called to update RGB_TDATA_WIDTH_B when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.RGB_TDATA_WIDTH_B { PARAM_VALUE.RGB_TDATA_WIDTH_B } {
	# Procedure called to validate RGB_TDATA_WIDTH_B
	return true
}


proc update_MODELPARAM_VALUE.CSR_BASE_ADDR { MODELPARAM_VALUE.CSR_BASE_ADDR PARAM_VALUE.CSR_BASE_ADDR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CSR_BASE_ADDR}] ${MODELPARAM_VALUE.CSR_BASE_ADDR}
}

proc update_MODELPARAM_VALUE.RAW_PX_WIDTH { MODELPARAM_VALUE.RAW_PX_WIDTH PARAM_VALUE.RAW_PX_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RAW_PX_WIDTH}] ${MODELPARAM_VALUE.RAW_PX_WIDTH}
}

proc update_MODELPARAM_VALUE.MAX_LINE_SIZE { MODELPARAM_VALUE.MAX_LINE_SIZE PARAM_VALUE.MAX_LINE_SIZE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MAX_LINE_SIZE}] ${MODELPARAM_VALUE.MAX_LINE_SIZE}
}

proc update_MODELPARAM_VALUE.RAW_TDATA_WIDTH { MODELPARAM_VALUE.RAW_TDATA_WIDTH PARAM_VALUE.RAW_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RAW_TDATA_WIDTH}] ${MODELPARAM_VALUE.RAW_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.RAW_TDATA_WIDTH_B { MODELPARAM_VALUE.RAW_TDATA_WIDTH_B PARAM_VALUE.RAW_TDATA_WIDTH_B } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RAW_TDATA_WIDTH_B}] ${MODELPARAM_VALUE.RAW_TDATA_WIDTH_B}
}

proc update_MODELPARAM_VALUE.RGB_TDATA_WIDTH { MODELPARAM_VALUE.RGB_TDATA_WIDTH PARAM_VALUE.RGB_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RGB_TDATA_WIDTH}] ${MODELPARAM_VALUE.RGB_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.RGB_TDATA_WIDTH_B { MODELPARAM_VALUE.RGB_TDATA_WIDTH_B PARAM_VALUE.RGB_TDATA_WIDTH_B } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.RGB_TDATA_WIDTH_B}] ${MODELPARAM_VALUE.RGB_TDATA_WIDTH_B}
}

