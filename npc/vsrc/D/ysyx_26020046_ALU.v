module ysyx_26020046_ALU #(DATA_WIDTH=32)(
    input uImm,
    input [1:0] cRd,
    input [DATA_WIDTH-1:0] oR1,oR2,imm,pc,oRam,
    output [DATA_WIDTH-1:0] oRd,addr
)
    wire [DATA_WIDTH-1:0] in2,snpc,imi;

    ysyx_26020046_mux2nM #(1,DATA_WIDTH) mux0(in2,uImm,{{1'b0,oR2},{1'b1,imm}});

    assign addr = oR1 + in2;
    assign snpc = pc + 4;

    ysyx_26020046_mux2nM #(2,DATA_WIDTH) mux1(oRd,cRd,{{2'b00,addr},{2'b01,imm},{2'b10,snpc},{2'b11,oRam}});
endmodule
