module ex6(input clk,output reg [7:0] out,output [7:0] seg0,output [7:0] seg1);
    always@(posedge clk)begin
        if(out==8'h0) out<=8'h1;
        else out<={(^out[4:2])^out[0],out[7:1]};
    end
    always@(*)begin
        case(out[3:0])
            4'h0:seg0 = 8'b00000011;
            4'h1:seg0 = 8'b10011111;
            4'h2:seg0 = 8'b00100101;
            4'h3:seg0 = 8'b00001101;
            4'h4:seg0 = 8'b10011001;
            4'h5:seg0 = 8'b01001001;
            4'h6:seg0 = 8'b01000001;
            4'h7:seg0 = 8'b00011111;
            4'h8:seg0 = 8'b00000001;
            4'h9:seg0 = 8'b00001001;
            4'ha:seg0 = 8'b00010001;
            4'hb:seg0 = 8'b11000001;
            4'hc:seg0 = 8'b01100011;
            4'hd:seg0 = 8'b10000101;
            4'he:seg0 = 8'b01100001;
            4'hf:seg0 = 8'b01110001;
        default :seg0 = 8'b11111111;
        endcase
    end
    always@(*)begin
        case(out[7:4])
            4'h0:seg1 = 8'b00000011;
            4'h1:seg1 = 8'b10011111;
            4'h2:seg1 = 8'b00100101;
            4'h3:seg1 = 8'b00001101;
            4'h4:seg1 = 8'b10011001;
            4'h5:seg1 = 8'b01001001;
            4'h6:seg1 = 8'b01000001;
            4'h7:seg1 = 8'b00011111;
            4'h8:seg1 = 8'b00000001;
            4'h9:seg1 = 8'b00001001;
            4'ha:seg1 = 8'b00010001;
            4'hb:seg1 = 8'b11000001;
            4'hc:seg1 = 8'b01100011;
            4'hd:seg1 = 8'b10000101;
            4'he:seg1 = 8'b01100001;
            4'hf:seg1 = 8'b01110001;
        default :seg1 = 8'b11111111;
        endcase
    end
endmodule
