module ysyx_26020046_minirv #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (clk,reset,code,pcReset,pc);
//32'h80000000
input clk,reset;
input [DATA_WIDTH-1:0] code,pcReset;
output reg [DATA_WIDTH-1:0] pc;
// output we,he,oe;

wire [ADDR_WIDTH-1:0] cR1,cR2,cRd;
wire add,lui,l,s,jalr,w,eRd,stop,eb;
wire [DATA_WIDTH-1:0] adr,iRd,oR1,oR2,oRAM,imm,imi,rAdr,ramAddr,wRAM,a0;
reg [DATA_WIDTH-1:0] iRAM;
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
ysyx_26020046_minirv_LSU #(DATA_WIDTH) ysyx_26020046_LSU(
    .clk(clk),
    .reset(reset),
    .s(s),
    .w(w),
    .l(l),
    .jalr(jalr),
    .pcReset(pcReset),
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

    assign iRAM = l&clk?pmem_read(ramAddr):0;
    // assign iRAM = l&(~clk)?pmem_read(ramAddr):0;
    // always @(posedge clk) begin
    //     // if (l) begin // 有读请求时
    //     if(code[6:0]==7'b0000011)begin
    //       iRAM <= pmem_read(ramAddr);
    //     end
    //     // iRAM<=l?pmem_read(ramAddr):0;
    // end
    always @(posedge clk) begin
        if (s) begin // 有写请求时
          pmem_write(ramAddr, wRAM, {4'b0,wmask});
        end
    end

    always@(*)begin
        if(stop&(~reset)) ebreak(eb);
    end

`ifdef DEBUG
    // always@(posedge clk) begin
    always@(clk) begin
        $display("code=%x",code);
        $display("cR1=%x oR1=%x cR2=%x oR2=%x cRd=%x imm=%x imi=%x", cR1,oR1,cR2,oR2,cRd,imm,imi);
        $display("add=%x lui=%x l=%x s=%x jalr=%x w=%x eRd=%x", add,lui,l,s,jalr,w,eRd);
        $display("adr=%x oRAM=%x pc=%x ramAddr=%x wRAM=%x", adr,oRAM,pc,ramAddr,wRAM);
        $display("iRd=%x rAdr=%x iRAM=%x wmask=%x a0=%x reset=%x", iRd,rAdr,iRAM,wmask,a0,reset);
    end
`endif

endmodule
