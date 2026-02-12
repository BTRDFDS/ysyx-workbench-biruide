module ysyx_26020046_minirv_sta #(ADDR_WIDTH = 5, DATA_WIDTH = 32,PC_RESET=32'h80000000) (clk,reset,code,iRAM,ramAddr,wRAM,pc,wmask,rEn,wEn,stop,eb);
//32'h80000000
input clk,reset;
input [DATA_WIDTH-1:0] code,iRAM;
output [DATA_WIDTH-1:0] ramAddr,wRAM,pc;
output [3:0] wmask;
output rEn,wEn,stop,eb;
// output we,he,oe;

wire [ADDR_WIDTH-1:0] cR1,cR2,cRd;
wire add,lui,l,s,jalr,w,eRd;
wire [DATA_WIDTH-1:0] adr,iRd,oR1,oR2,oRAM,imm,imi,rAdr,a0;

ysyx_26020046_minirv_IDC #(ADDR_WIDTH,DATA_WIDTH) ysyx_26020046_IDC(
    .code(code),
    .a0(a0),
    .cR1(cR1),
    .cR2(cR2),
    .cRd(cRd),
    .imm(imm),
    .imi(imi),
    .add(add),
    .lui(lui),
    .l(l),
    .s(s),
    .jalr(jalr),
    .w(w),
    .eRd(eRd),
    .stop(stop),
    .eb(eb)
);
ysyx_26020046_minirv_ALU #(DATA_WIDTH) ysyx_26020046_ALU(
    .oR1(oR1),
    .oR2(oR2),
    .imm(imm),
    .imi(imi),
    .lui(lui),
    .add(add),
    .adr(adr),
    .oRAM(oRAM),
    .l(l),
    .rAdr(rAdr),
    .jalr(jalr),
    .iRd(iRd)
);
ysyx_26020046_minirv_Reg #(ADDR_WIDTH,DATA_WIDTH) ysyx_26020046_Reg(
    .clk(clk),
    .reset(reset),
    .iRd(iRd),
    .cRd(cRd),
    .cR1(cR1),
    .cR2(cR2),
    .en(eRd),
    .oR1(oR1),
    .oR2(oR2),
    .a0(a0)
);
ysyx_26020046_minirv_LSU #(DATA_WIDTH,PC_RESET) ysyx_26020046_LSU(
    .clk(clk),
    .reset(reset),
    .s(s),
    .w(w),
    .l(l),
    .jalr(jalr),
    .adr(adr),
    .oR2(oR2),
    .iRAM(iRAM),
    .pc(pc),
    .oRAM(oRAM),
    .ramAddr(ramAddr),
    .wRAM(wRAM),
    .rAdr(rAdr),
    .wmask(wmask)
);
    assign rEn=l;
    assign wEn=s;
endmodule
