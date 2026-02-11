module ysyx_26020046_minirv_ALU #(DATA_WIDTH=32)(oR1,oR2,imm,imi,lui,add,adr,oRAM,l,rAdr,jalr,iRd);
    input [DATA_WIDTH-1:0] oR1,oR2,imm,imi,oRAM,rAdr;
    input add,lui,I,jalr;
    output [DATA_WIDTH-1:0] adr,iRd;

    wire [DATA_WIDTH-1:0] in2,adder,lmer,Ler;
    
    ysyx_26020046_mux2nM #(2,DATA_WIDTH) muxAdd(.out(in2),.addr(add),.in({{1'b0,imm},{1'b1,oR2}}));
    assign adder=oR1+in2;
    assign adr=adder;
    ysyx_26020046_mux2nM #(2,DATA_WIDTH) muxLui(.out(lmer),.addr(lui),.in({{1'b0,adder},{1'b1,imi}}));
    ysyx_26020046_mux2nM #(2,DATA_WIDTH) muxI(.out(Ier),.addr(l),.in({{1'b0,lmer},{1'b1,oRAM}}));
    ysyx_26020046_mux2nM #(2,DATA_WIDTH) muxJalr(.out(iRd),.addr(jalr),.in({{1'b0,Ier},{1'b1,rAdr}}));
endmodule
