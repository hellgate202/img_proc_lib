interface wb_ctrl_if;

logic [1 : 0]  mode;
logic          cal_stb;
logic [1 : 0]  man_sel;
logic [31 : 0] man_coef;
logic          man_lock;
logic [31 : 0] cur_coef;

modport master
(
  output mode,
  output cal_stb,
  output man_sel,
  output man_coef,
  output man_lock,
  input  cur_coef
);

modport slave
(
  input  mode,
  input  cal_stb,
  input  man_sel,
  input  man_coef,
  input  man_lock,
  output cur_coef
);

endinterface
