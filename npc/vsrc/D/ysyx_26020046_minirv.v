module ysyx_26020046_minirv #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
    input clk,
    input [DATA_WIDTH-1:0] code,
    output [DATA_WIDTH-1:0] pc
);
    wire cR1,cR2,cRd,uImm,imm,en;
    wire [1:0] con;
    wire [DATA_WIDTH-1:0] oR1,oR2,oRd,oRam,addr;
    assign oRam = 0;
    ysyx_26020046_IDC #(ADDR_WIDTH,DATA_WIDTH) idc(.code(code),.imm(imm),.r1(cR1),.r2(cR2),.rd(cRd),.wen(en));
    ysyx_26020046_ALU #(DATA_WIDTH) alu(.uImm(uImm),.cRd(con),.oR1(oR1),.oR2(oR2),.imm(imm),.pc(pc).oRam(oRam),.oRd(oRd),.addr(addr));
    ysyx_26020046_GPR #(ADDR_WIDTH,DATA_WIDTH) gpr(.clk(clk),.wdata(oRd),.waddr(cRd),.cR1(cR1),.cR2(cR2),.wen(en),.oR1(oR1),.oR2(oR2));
endmodule
