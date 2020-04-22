
# Loading additional proc with user specified bodies to compute parameter values.
source [file join [file dirname [file dirname [info script]]] gui/bilinear_demosaicing_3x3_v1_0.gtcl]

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

proc update_PARAM_VALUE.RAW_TDATA_WIDTH { PARAM_VALUE.RAW_TDATA_WIDTH PARAM_VALUE.RAW_PX_WIDTH } {
	# Procedure called to update RAW_TDATA_WIDTH when any of the dependent parameters in the arguments change
	
	set RAW_TDATA_WIDTH ${PARAM_VALUE.RAW_TDATA_WIDTH}
	set RAW_PX_WIDTH ${PARAM_VALUE.RAW_PX_WIDTH}
	set values(RAW_PX_WIDTH) [get_property value $RAW_PX_WIDTH]
	set_property value [gen_USERPARAMETER_RAW_TDATA_WIDTH_VALUE $values(RAW_PX_WIDTH)] $RAW_TDATA_WIDTH
}

proc validate_PARAM_VALUE.RAW_TDATA_WIDTH { PARAM_VALUE.RAW_TDATA_WIDTH } {
	# Procedure called to validate RAW_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RAW_TDATA_WIDTH_B { PARAM_VALUE.RAW_TDATA_WIDTH_B PARAM_VALUE.RAW_TDATA_WIDTH } {
	# Procedure called to update RAW_TDATA_WIDTH_B when any of the dependent parameters in the arguments change
	
	set RAW_TDATA_WIDTH_B ${PARAM_VALUE.RAW_TDATA_WIDTH_B}
	set RAW_TDATA_WIDTH ${PARAM_VALUE.RAW_TDATA_WIDTH}
	set values(RAW_TDATA_WIDTH) [get_property value $RAW_TDATA_WIDTH]
	set_property value [gen_USERPARAMETER_RAW_TDATA_WIDTH_B_VALUE $values(RAW_TDATA_WIDTH)] $RAW_TDATA_WIDTH_B
}

proc validate_PARAM_VALUE.RAW_TDATA_WIDTH_B { PARAM_VALUE.RAW_TDATA_WIDTH_B } {
	# Procedure called to validate RAW_TDATA_WIDTH_B
	return true
}

proc update_PARAM_VALUE.RGB_TDATA_WIDTH { PARAM_VALUE.RGB_TDATA_WIDTH PARAM_VALUE.RAW_PX_WIDTH } {
	# Procedure called to update RGB_TDATA_WIDTH when any of the dependent parameters in the arguments change
	
	set RGB_TDATA_WIDTH ${PARAM_VALUE.RGB_TDATA_WIDTH}
	set RAW_PX_WIDTH ${PARAM_VALUE.RAW_PX_WIDTH}
	set values(RAW_PX_WIDTH) [get_property value $RAW_PX_WIDTH]
	set_property value [gen_USERPARAMETER_RGB_TDATA_WIDTH_VALUE $values(RAW_PX_WIDTH)] $RGB_TDATA_WIDTH
}

proc validate_PARAM_VALUE.RGB_TDATA_WIDTH { PARAM_VALUE.RGB_TDATA_WIDTH } {
	# Procedure called to validate RGB_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.RGB_TDATA_WIDTH_B { PARAM_VALUE.RGB_TDATA_WIDTH_B PARAM_VALUE.RGB_TDATA_WIDTH } {
	# Procedure called to update RGB_TDATA_WIDTH_B when any of the dependent parameters in the arguments change
	
	set RGB_TDATA_WIDTH_B ${PARAM_VALUE.RGB_TDATA_WIDTH_B}
	set RGB_TDATA_WIDTH ${PARAM_VALUE.RGB_TDATA_WIDTH}
	set values(RGB_TDATA_WIDTH) [get_property value $RGB_TDATA_WIDTH]
	set_property value [gen_USERPARAMETER_RGB_TDATA_WIDTH_B_VALUE $values(RGB_TDATA_WIDTH)] $RGB_TDATA_WIDTH_B
}

proc validate_PARAM_VALUE.RGB_TDATA_WIDTH_B { PARAM_VALUE.RGB_TDATA_WIDTH_B } {
	# Procedure called to validate RGB_TDATA_WIDTH_B
	return true
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

