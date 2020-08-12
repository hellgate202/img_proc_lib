interface px_ss_if;

logic [15 : 0] px_to_skip;
logic [15 : 0] px_skip_interval;
logic [15 : 0] add_px_skip_interval;
logic [15 : 0] ln_to_skip;
logic [15 : 0] ln_skip_interval;
logic [15 : 0] add_ln_skip_interval;
logic          apply_stb;

modport master
(
  output px_to_skip,
  output px_skip_interval,
  output add_px_skip_interval,
  output ln_to_skip,
  output ln_skip_interval,
  output add_ln_skip_interval,
  output apply_stb
);

modport slave
(
  input px_to_skip,
  input px_skip_interval,
  input add_px_skip_interval,
  input ln_to_skip,
  input ln_skip_interval,
  input add_ln_skip_interval,
  input apply_stb
);

endinterface
