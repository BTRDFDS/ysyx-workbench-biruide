module ysyx_26020046_minirv #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
    input clk,
    input [DATA_WIDTH-1:0] code,
    output reg [DATA_WIDTH-1:0] pc
);
wire [ADDR_WIDTH-1:0] cR1,cR2,cRd;
wire add,addi,lui,l,s,jalr,w,eRd,lbu,lw,sw,sb;
wire [DATA_WIDTH-1:0] adr,iRd,oR1,oR2


ysyx_26020046_minirv_IDC #(ADDR_WIDTH = 5, DATA_WIDTH = 32) ysyx_26020046_IDC(
    .code(code),
    .cR1(cR1),
    .cR2(cR2),
    .cRd(cRd),
    .imm(imm),
    .imi(imi),
    .add(add),
    .addi(addi),
    .lui(lui),
    .l(l),
    .s(s),
    .jalr(jalr),
    .w(w),
    .eRd(eRd),
    .lbu(lbu),
    .lw(lw),
    .sw(sw),
    .sb(sb)
);
ysyx_26020046_minirv_ALU #(DATA_WIDTH=32)(
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
ysyx_26020046_minirv_Reg #(ADDR_WIDTH = 5, DATA_WIDTH = 32) ysyx_26020046_Reg(
    .clk(ckl),
    .iRd(iRd),
    .cRd(cRd),
    .cR1(cR1),
    .cR2(cR2),
    .en(eRd),
    .oR1(oR1),
    .oR2(oR2)
);
    always@(posedge clk) pc <= pc+1;
endmodule
