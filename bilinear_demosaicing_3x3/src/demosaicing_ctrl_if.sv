interface demosaicing_ctrl_if;

logic         en;
logic [1 : 0] pattern;

modport master
(
  output en,
  output pattern
);

modport slave
(
  input en,
  input pattern
);

endinterface
