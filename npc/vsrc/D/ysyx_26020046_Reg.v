module ysyx_26020046_GPR #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input clk,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,cR1,cR2,
  input wen,
  output [DATA_WIDTH-1:0] oR1,oR2
);
  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:1];
  always @(posedge clk) begin
    if (wen&&waddr!=0) rf[waddr] <= wdata;
  end
  assign oR1 = (cR1==0)?0:rf[cR1];
  assign oR2 = (cR2==0)?0:rf[cR2];
endmodule