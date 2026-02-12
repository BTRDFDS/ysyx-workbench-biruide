module ysyx_26020046_minirv_Reg #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input clk,
  input [DATA_WIDTH-1:0] iRd,
  input [ADDR_WIDTH-1:0] cRd,cR1,cR2,
  input en,
  output [DATA_WIDTH-1:0] oR1,oR2
);
  reg [DATA_WIDTH-1:0] gpr [2**ADDR_WIDTH-1:1];
  always @(posedge clk) begin
    if (en&&cRd!=0) gpr[cRd] <= iRd;
    $display("Reg[%d](0x%x)<=0x%x",cRd,gpr[cRd],iRd);
    $strobe("Reg[%d]=%d", cRd, gpr[cRd]);
  end
  assign oR1 = (cR1==0)?0:gpr[cR1];
  assign oR2 = (cR2==0)?0:gpr[cR2];
endmodule
