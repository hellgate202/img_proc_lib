interface conv_2d_if;

logic          wr_stb;
logic [5 : 0]  coef_num;
logic [15 : 0] coef_val;

modport master (
  output wr_stb,
  output coef_num,
  output coef_val
);

modport slave (
  input wr_stb,
  input coef_num,
  input coef_val
);

endinterface
