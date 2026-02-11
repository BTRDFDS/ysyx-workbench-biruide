module ysyx_26020046_minirv_LSU #(DATA_WIDTH=32)(clk,s,lw,l,jalr,sw,adr,oR2,pc,oRAM,ramAddr,wRAM);
input clk,s,lw,l,jalr,sw;
input [DATA_WIDTH-1:0] adr,oR2;
output [DATA_WIDTH-1:0] pc,oRAM,ramAddr,wRAM;

wire [1:0] adr01;
ysyx_26020046_mux2nM #(1,DATA_WIDTH) (.out(wRAM),.addr(sw),.in({{1'b0,4{oR2[7:0]}},{1'b1,oR2}}));
endmodule
