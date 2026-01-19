module ex7(
    input ps2_clk,
    input ps2_data,
    output reg [7:0] key0,
    output reg [7:0] key1,
    output reg [7:0] ascll0,
    output reg [7:0] ascll1//,
    // output reg [15:0] number
    );
    reg [10:0] data;
    reg [7:0] keyData;
    reg [3:0] count;
    reg [7:0] rom['hff:0];

    initial begin
        rom['h1C]=8'h41;
        rom['h32]=8'h42;
        rom['h21]=8'h43;
        rom['h23]=8'h44;
        rom['h24]=8'h45;
        rom['h2B]=8'h46;
        rom['h34]=8'h47;
        rom['h33]=8'h48;
        rom['h43]=8'h49;
        rom['h3B]=8'h4A;
        rom['h42]=8'h4B;
        rom['h4B]=8'h4C;
        rom['h3A]=8'h4D;
        rom['h31]=8'h4E;
        rom['h44]=8'h4F;
        rom['h4D]=8'h50;
        rom['h15]=8'h51;
        rom['h2D]=8'h52;
        rom['h1B]=8'h53;
        rom['h2C]=8'h54;
        rom['h3C]=8'h55;
        rom['h2A]=8'h56;
        rom['h1D]=8'h57;
        rom['h22]=8'h58;
        rom['h35]=8'h59;
        rom['h1A]=8'h5A;
        rom['h16]=8'h31;
        rom['h1E]=8'h32;
        rom['h26]=8'h33;
        rom['h25]=8'h34;
        rom['h2E]=8'h35;
        rom['h36]=8'h36;
        rom['h3D]=8'h37;
        rom['h3E]=8'h38;
        rom['h46]=8'h39;
        rom['h45]=8'h30;
    end
    always@(negedge ps2_clk)begin
        if(count<4'd11) begin
            data[count] <= ps2_data; 
            count <= count + 1'b1;
        end else if(count==4'd11)begin
            data[0] <= ps2_data;
            count <= 1;
        end else count<=0;
    end
    always_latch@(*)begin
        if((data[0]==1'b0|data[10]==1'b1|(^data[9:1]==1'b1))&(count==4'd11)) keyData[7:0]=rom[data[8:1]];
    end
    always@(*)begin
        case(data[4:1])
            4'h0:key0 = 8'b00000011;
            4'h1:key0 = 8'b10011111;
            4'h2:key0 = 8'b00100101;
            4'h3:key0 = 8'b00001101;
            4'h4:key0 = 8'b10011001;
            4'h5:key0 = 8'b01001001;
            4'h6:key0 = 8'b01000001;
            4'h7:key0 = 8'b00011111;
            4'h8:key0 = 8'b00000001;
            4'h9:key0 = 8'b00001001;
            4'ha:key0 = 8'b00010001;
            4'hb:key0 = 8'b11000001;
            4'hc:key0 = 8'b01100011;
            4'hd:key0 = 8'b10000101;
            4'he:key0 = 8'b01100001;
            4'hf:key0 = 8'b01110001;
        default :key0 = 8'b11111111;
        endcase
    end
    always@(*)begin
        case(data[8:5])
            4'h0:key1 = 8'b00000011;
            4'h1:key1 = 8'b10011111;
            4'h2:key1 = 8'b00100101;
            4'h3:key1 = 8'b00001101;
            4'h4:key1 = 8'b10011001;
            4'h5:key1 = 8'b01001001;
            4'h6:key1 = 8'b01000001;
            4'h7:key1 = 8'b00011111;
            4'h8:key1 = 8'b00000001;
            4'h9:key1 = 8'b00001001;
            4'ha:key1 = 8'b00010001;
            4'hb:key1 = 8'b11000001;
            4'hc:key1 = 8'b01100011;
            4'hd:key1 = 8'b10000101;
            4'he:key1 = 8'b01100001;
            4'hf:key1 = 8'b01110001;
        default :key1 = 8'b11111111;
        endcase
    end
    always@(*)begin
        case(keyData[3:0])
            4'h0:ascll0 = 8'b00000011;
            4'h1:ascll0 = 8'b10011111;
            4'h2:ascll0 = 8'b00100101;
            4'h3:ascll0 = 8'b00001101;
            4'h4:ascll0 = 8'b10011001;
            4'h5:ascll0 = 8'b01001001;
            4'h6:ascll0 = 8'b01000001;
            4'h7:ascll0 = 8'b00011111;
            4'h8:ascll0 = 8'b00000001;
            4'h9:ascll0 = 8'b00001001;
            4'ha:ascll0 = 8'b00010001;
            4'hb:ascll0 = 8'b11000001;
            4'hc:ascll0 = 8'b01100011;
            4'hd:ascll0 = 8'b10000101;
            4'he:ascll0 = 8'b01100001;
            4'hf:ascll0 = 8'b01110001;
        default :ascll0 = 8'b11111111;
        endcase
    end
    always@(*)begin
        case(keyData[7:4])
            4'h0:ascll1 = 8'b00000011;
            4'h1:ascll1 = 8'b10011111;
            4'h2:ascll1 = 8'b00100101;
            4'h3:ascll1 = 8'b00001101;
            4'h4:ascll1 = 8'b10011001;
            4'h5:ascll1 = 8'b01001001;
            4'h6:ascll1 = 8'b01000001;
            4'h7:ascll1 = 8'b00011111;
            4'h8:ascll1 = 8'b00000001;
            4'h9:ascll1 = 8'b00001001;
            4'ha:ascll1 = 8'b00010001;
            4'hb:ascll1 = 8'b11000001;
            4'hc:ascll1 = 8'b01100011;
            4'hd:ascll1 = 8'b10000101;
            4'he:ascll1 = 8'b01100001;
            4'hf:ascll1 = 8'b01110001;
        default :ascll1 = 8'b11111111;
        endcase
    end
endmodule
