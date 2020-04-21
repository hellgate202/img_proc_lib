interface demosaicing_ctrl_if;

logic         en;
logic [1 : 0] pattern;

modport csr
(
  output en,
  output pattern
);

modport app
(
  input en,
  input pattern
);

endinterface
