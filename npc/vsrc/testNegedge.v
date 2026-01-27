module Reg #(WIDTH = 1, RESET_VAL = 0) (
  input clk,
  input rst,
  input [WIDTH-1:0] din,
  output reg [WIDTH-1:0] dout,
  input wen
);
  always @(negedge clk) begin
    if (rst) dout <= RESET_VAL;
    else if (wen) dout <= din;
  end
endmodule

module testNegedge(input clk, input rst, input in, output out);
  wire t0, t1;
  Reg r1(clk, rst, in, t0, 1'b1);
  Reg r2(clk, rst, t0, t1, 1'b1);
  Reg r3(clk, rst, t1, out, 1'b1);
endmodule
