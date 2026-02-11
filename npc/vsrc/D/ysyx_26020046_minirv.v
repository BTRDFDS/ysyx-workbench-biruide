module ysyx_26020046_minirv #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
    input clk,
    input [DATA_WIDTH-1:0] code,
    output reg [DATA_WIDTH-1:0] pc
);
    wire uImm,en;
    wire [1:0] con;
    /* verilator lint_off UNUSEDSIGNAL */
    wire [DATA_WIDTH-1:0] oR1,oR2,oRd,oRam,addr,imm;
    wire [ADDR_WIDTH-1:0] cR1,cR2,cRd;
    assign oRam = 0;
    ysyx_26020046_IDC #(ADDR_WIDTH,DATA_WIDTH) ysyx_26020046_idc(.code(code),.imm(imm),.r1(cR1),.r2(cR2),.rd(cRd),.wen(en),.uImm(uImm),.cho(con));
    ysyx_26020046_ALU #(DATA_WIDTH) ysyx_26020046_alu(.uImm(uImm),.cRd(con),.oR1(oR1),.oR2(oR2),.imm(imm),.pc(pc),.oRam(oRam),.oRd(oRd),.addr(addr));
    ysyx_26020046_Reg #(ADDR_WIDTH,DATA_WIDTH) ysyx_26020046_reg(.clk(clk),.wdata(oRd),.waddr(cRd),.cR1(cR1),.cR2(cR2),.wen(en),.oR1(oR1),.oR2(oR2));
    always@(posedge clk) begin
        pc <= pc+1;
    end
endmodule
