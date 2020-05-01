interface wb_ctrl_if;

logic [1 : 0]  mode_sel;
logic          cal_stb;
logic [1 : 0]  man_sel;
logic [31 : 0] man_coef;
logic          man_lock;

modport master
(
  output mode_sel,
  output cal_stb,
  output man_sel,
  output man_coef,
  output man_lock,
);

modport slave
(
  input mode_sel,
  input cal_stb,
  input man_sel,
  input man_coef,
  input man_lock
);

endinterface
