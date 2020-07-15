interface blc_ctrl_if;

logic          mode;
logic          cal_stb;
logic [15 : 0] man_bl;
logic [15 : 0] cur_bl;

modport master(
  output mode,
  output cal_stb,
  output man_bl,
  input  cur_bl
);

modport slave(
  input  mode,
  input  cal_stb,
  input  man_bl,
  output cur_bl
);

endinterface
