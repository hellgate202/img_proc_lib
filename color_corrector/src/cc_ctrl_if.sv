interface cc_ctrl_if;

logic          coef_lock;
logic [3 : 0]  coef_sel;
logic [31 : 0] coef;
logic [31 : 0] cur_coef;

modport master
(
  output coef_lock,
  output coef_sel,
  output coef,
  input  cur_coef
);

modport slave
(
  input  coef_lock,
  input  coef_sel,
  input  coef,
  output cur_coef
);

endinterface
