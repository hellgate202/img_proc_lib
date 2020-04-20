interface demosaicing_ctrl_if;

logic en;
logic first_px_is_odd;
logic first_line_is_odd;

modport csr
(
  output en,
  output first_px_is_odd,
  output first_line_is_odd
);

modport app
(
  input en,
  input first_px_is_odd,
  input first_line_is_odd
);

endinterface
