module ysyx_26020046_minirv_ALU #(DATA_WIDTH=32)(oR1,oR2,imm,imi,lui,add,adr,oRAM,l,rAdr,jalr,iRd);
    input [DATA_WIDTH-1:0] oR1,oR2,imm,imi,oRAM,rAdr;
    input add,lui,l,jalr;
    output [DATA_WIDTH-1:0] adr;
    output reg [DATA_WIDTH-1:0] iRd;

    wire [DATA_WIDTH-1:0] adder;
    reg [DATA_WIDTH-1:0] in2,lmer,Ler;
    
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxAdd(.out(in2),.addr(add),.in({{1'b0,imm},{1'b1,oR2}}));
    always@(*)begin
        case(add)
            1'b0:in2=imm;
            1'b1:in2=oR2;
        endcase
    end
    assign adder=oR1+in2;
    assign adr=adder;
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxLui(.out(lmer),.addr(lui),.in({{1'b0,adder},{1'b1,imi}}));
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxI(.out(Ler),.addr(l),.in({{1'b0,lmer},{1'b1,oRAM}}));
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxJalr(.out(iRd),.addr(jalr),.in({{1'b0,Ler},{1'b1,rAdr}}));
    always@(*)begin
        case(lui)
            1'b0:lmer=adder;
            1'b1:lmer=imi;
        endcase
    end
    always@(*)begin
        case(l)
            1'b0:Ler=lmer;
            1'b1:Ler=oRAM;
        endcase
    end
    always@(*)begin
        case(jalr)
            1'b0:iRd=Ler;
            1'b1:iRd=rAdr;
        endcase
    end
endmodule
