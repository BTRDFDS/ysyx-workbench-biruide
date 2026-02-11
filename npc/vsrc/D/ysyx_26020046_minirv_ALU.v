module ysyx_26020046_ALU #(DATA_WIDTH=32)(
    input uImm,
    input [1:0] cRd,
    input [DATA_WIDTH-1:0] oR1,oR2,imm,pc,oRam,
    input [3:0] funct3A7,
    output [DATA_WIDTH-1:0] oRd,addr
);
    wire [DATA_WIDTH-1:0] in2,snpc;
    reg [DATA_WIDTH-1:0] res;

    ysyx_26020046_mux2nM #(1,DATA_WIDTH) mux0(in2,uImm,{{1'b0,oR2},{1'b1,imm}});

    // assign res = oR1 + in2;
    always@(*)begin
        case(funct3A7)
            4'b0000:res=oR1+in2;//add
            4'b1000:res=oR1-in2;//sub
            4'b0001:res=oR1<<(in2&32'b11111);//sll
            4'b0010:res=($signed(oR1) < $signed(in2)) ? 32'b1 : 32'b0;//slt
            4'b0011:res=(oR1 < in2) ? 32'b1 : 32'b0;//sltu
            4'b0100:res=oR1^in2;//xor
            4'b0101:res=oR1>> (in2&32'b11111);//srl
            4'b1101:res=oR1>>>(in2&32'b11111);//sra
            4'b0110:res=oR1|in2;//or
            4'b0111:res=oR1&in2;//and
            default:res=32'b0;
        endcase
    end
    assign snpc = pc + 4;

    ysyx_26020046_mux2nM #(2,DATA_WIDTH) mux1(oRd,cRd,{{2'b00,res},{2'b01,imm},{2'b10,snpc},{2'b11,oRam}});
endmodule
