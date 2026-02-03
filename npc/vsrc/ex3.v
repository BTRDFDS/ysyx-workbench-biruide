module ex3(input [3:0]in1,input [3:0]in2,input [2:0]code,output reg [3:0]out,output [7:0] seg1,output [7:0] seg2,output [7:0] seg3,output cin);
    always @(*) begin
        case(code)
            3'b000:out=in1+in2;
            3'b001:out=in1-in2;
            3'b010:out=~in1;
            3'b011:out=in1&in2;
            3'b100:out=in1|in2;
            3'b101:out=in1^in2;
            3'b110:out=(in1<in2) ?4'b1:4'b0;
            3'b111:out=(in1==in2)?4'b1:4'b0;
        endcase
    end
    assign cin=((code==3'b000)|(code==3'b001))?~((in1[3]&in2[3])^out[3]):1;

    seg Seg1(.in(in1),.out(seg1));
    seg Seg2(.in(in2),.out(seg2));
    seg Seg3(.in(out),.out(seg3));
endmodule

module seg(input [3:0] in,output [7:0] out);
    always@(*)begin
        // $strobe("in",in);
        case(in[3:0])
            4'h0:out[7:0] = 8'b00000011;
            4'h1:out[7:0] = 8'b10011111;
            4'h2:out[7:0] = 8'b00100101;
            4'h3:out[7:0] = 8'b00001101;
            4'h4:out[7:0] = 8'b10011001;
            4'h5:out[7:0] = 8'b01001001;
            4'h6:out[7:0] = 8'b01000001;
            4'h7:out[7:0] = 8'b00011111;
            4'h8:out[7:0] = 8'b00000000;
            4'h9:out[7:0] = 8'b00011110;
            4'ha:out[7:0] = 8'b01000000;
            4'hb:out[7:0] = 8'b01001000;
            4'hc:out[7:0] = 8'b10011000;
            4'hd:out[7:0] = 8'b00001100;
            4'he:out[7:0] = 8'b00100100;
            4'hf:out[7:0] = 8'b10011110;
        default :out[7:0] = 8'b11111111;
        endcase
    end
endmodule
