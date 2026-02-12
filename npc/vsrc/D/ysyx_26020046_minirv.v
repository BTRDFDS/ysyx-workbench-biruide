module ysyx_26020046_minirv #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (clk,code,pc);
//,we,he,oe
input clk;
input [DATA_WIDTH-1:0] code;
output reg [DATA_WIDTH-1:0] pc;
// output we,he,oe;

wire [ADDR_WIDTH-1:0] cR1,cR2,cRd;
wire add,lui,l,s,jalr,w,eRd,stop,eb;
wire [DATA_WIDTH-1:0] adr,iRd,oR1,oR2,oRAM,imm,imi,rAdr,iRAM,ramAddr,wRAM,a0;
wire [3:0] wmask;

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
    .iRd(iRd),
    .cRd(cRd),
    .cR1(cR1),
    .cR2(cR2),
    .en(eRd),
    .oR1(oR1),
    .oR2(oR2),
    .a0(a0)
);
ysyx_26020046_minirv_LSU #(DATA_WIDTH) ysyx_26020046_LSU(
    .clk(clk),
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

import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);
import "DPI-C" function void ebreak(input bit eb);

    assign iRAM = l?pmem_read(ramAddr):0;
    always @(*) begin
        if (s) begin // 有写请求时
          pmem_write(ramAddr, wRAM, {4'b0,wmask});
        end
    end

    always@(*)begin
        if(stop) ebreak(eb);
    end

    always@(posedge clk) begin
        $display("code=%x",code);
        $display("cR1=%x,oR1=%x,cR2=%x,oR2=%x,cRd=%x,imm=%x,imi=%x", cR1,oR1,cR2,oR2,cRd,imm,imi);
        $display("add=%x,lui=%x,l=%x,s=%x,jalr=%x,w=%x,eRd=%x", add,lui,l,s,jalr,w,eRd);
        $display("adr=%x,oRAM=%x,pc=%x,ramAddr=%x,wRAM=%x", adr,oRAM,pc,ramAddr,wRAM);
        $display("iRd=%x,rAdr=%x", iRd,rAdr);
        $display("iRAM=%x", iRAM);
        $display("wmask=%x", wmask);
        $display("a0=%x", a0);

    end

endmodule
