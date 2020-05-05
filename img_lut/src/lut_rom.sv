import lut_rom_pkg::*;

module lut_rom #(
  parameter int DATA_WIDTH = 8,
  parameter int ADDR_WIDTH = 5
)(
  input                       wr_clk_i,
  input [ADDR_WIDTH - 1 : 0]  wr_addr_i,
  input [DATA_WIDTH - 1 : 0]  wr_data_i,
  input                       wr_i,
  input                       rd_clk_i,
  input  [ADDR_WIDTH - 1 : 0] rd_addr_i,
  output [DATA_WIDTH - 1 : 0] rd_data_o,
  input                       rd_i
);

logic [DATA_WIDTH - 1 : 0] ram [2 ** ADDR_WIDTH - 1 : 0] = INIT_DATA;
logic [DATA_WIDTH - 1 : 0] rd_data;

always_ff @( posedge wr_clk_i )
  if( wr_i )
    ram[wr_addr_i] <= wr_data_i;

always_ff @( posedge rd_clk_i )
  if( rd_i )
    rd_data <= ram[rd_addr_i];

assign rd_data_o = rd_data;

endmodule
