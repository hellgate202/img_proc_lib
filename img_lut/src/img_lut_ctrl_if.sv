interface img_lut_ctrl_if;

logic [31 : 0] orig_px;
logic [31 : 0] mod_px;
logic          wr_stb;

modport master
(
  output orig_px,
  output mod_px,
  output wr_stb
);

modport slave
(
  input orig_px,
  input mod_px,
  input wr_stb
);

endinterface
