interface mf_ctrl_if;

logic en;

modport master
(
  output en
);

modport slave
(
  input en
);

endinterface
