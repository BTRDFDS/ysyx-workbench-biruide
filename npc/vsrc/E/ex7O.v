module ex7O(
    input clk,
    input ps2_data,
    output reg [7:0] key0,
    output reg [7:0] key1,
    output reg [7:0] ascll0,
    output reg [7:0] ascll1,
    output reg [7:0] number0,
    output reg [7:0] number1,
    output reg [7:0] number2,
    output reg [7:0] number3
    );
    reg [10:0] data;
    reg [7:0] keyAscll;
    reg [7:0] keyData;
    reg [3:0] count;
    reg [15:0] num;
    reg [7:0] rom['hff:0];
    reg [7:0] last;
    reg isNo;
    initial begin
        last=8'h0;
        num[15:0]=16'h0;
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
    always@(negedge clk)begin
        if(count<4'd11) begin
            data[count] <= ps2_data; 
            count <= count + 1'b1;
        end else if(count==4'd11)begin
            data[0] <= ps2_data;
            count <= 1;
        end else count<=0;
    end
    always@(data)begin
        if((data[0]==1'b0&data[10]==1'b1&(^data[9:1]==1'b1))&(count==4'd11))begin
            // keyAscll[7:0]=rom[data[8:1]];
            if(isNo==1)begin
                isNo=0;
                keyAscll[7:0]=8'h00;
                keyData[7:0]=8'h00;
                data[10:0]=11'h00;
                last=0;
                // num =num+1;
            end
            else if(data[8:1]=='hF0)begin
                isNo=1;
                keyAscll[7:0]=8'h00;
                keyData[7:0]=8'h00;
                data[10:0]=11'h00;
            end
            else begin
                keyAscll[7:0]=rom[data[8:1]];
                if(keyAscll[7:0]!=0)begin
                    keyData[7:0]=data[8:1];
                    data[10:0]=11'h00;
                    //     $strobe("data",data[8:1],"last",last,"count",count,"num",num);
                    if(last!=keyData&count==4'd11)begin
                        last=keyData;
                        num[15:0]=num[15:0]+16'h1;
                        // $strobe(num);
                    end
                end else begin
                    keyData[7:0]=8'b0;
                    data[10:0]=11'h00;
                end

            end
        end
    end
    // always@(keyData)begin
    //     if(last!=keyData&count==4'd11&keyData!='hF0)begin
    //         last=keyData;
    //         num[15:0]=num[15:0]+16'h1;
    //         $strobe(num);
    //     end
    // end
        
    always@(*)begin
        case(keyData[3:0])
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
        case(keyData[7:4])
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
        case(keyAscll[3:0])
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
        case(keyAscll[7:4])
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

    always@(*)begin
        case(num[3:0])
            4'h0:number0 = 8'b00000011;
            4'h1:number0 = 8'b10011111;
            4'h2:number0 = 8'b00100101;
            4'h3:number0 = 8'b00001101;
            4'h4:number0 = 8'b10011001;
            4'h5:number0 = 8'b01001001;
            4'h6:number0 = 8'b01000001;
            4'h7:number0 = 8'b00011111;
            4'h8:number0 = 8'b00000001;
            4'h9:number0 = 8'b00001001;
            4'ha:number0 = 8'b00010001;
            4'hb:number0 = 8'b11000001;
            4'hc:number0 = 8'b01100011;
            4'hd:number0 = 8'b10000101;
            4'he:number0 = 8'b01100001;
            4'hf:number0 = 8'b01110001;
        default :number0 = 8'b11111111;
        endcase
    end
    always@(*)begin
        case(num[7:4])
            4'h0:number1 = 8'b00000011;
            4'h1:number1 = 8'b10011111;
            4'h2:number1 = 8'b00100101;
            4'h3:number1 = 8'b00001101;
            4'h4:number1 = 8'b10011001;
            4'h5:number1 = 8'b01001001;
            4'h6:number1 = 8'b01000001;
            4'h7:number1 = 8'b00011111;
            4'h8:number1 = 8'b00000001;
            4'h9:number1 = 8'b00001001;
            4'ha:number1 = 8'b00010001;
            4'hb:number1 = 8'b11000001;
            4'hc:number1 = 8'b01100011;
            4'hd:number1 = 8'b10000101;
            4'he:number1 = 8'b01100001;
            4'hf:number1 = 8'b01110001;
        default :number1 = 8'b11111111;
        endcase
    end
    always@(*)begin
        case(num[11:8])
            4'h0:number2 = 8'b00000011;
            4'h1:number2 = 8'b10011111;
            4'h2:number2 = 8'b00100101;
            4'h3:number2 = 8'b00001101;
            4'h4:number2 = 8'b10011001;
            4'h5:number2 = 8'b01001001;
            4'h6:number2 = 8'b01000001;
            4'h7:number2 = 8'b00011111;
            4'h8:number2 = 8'b00000001;
            4'h9:number2 = 8'b00001001;
            4'ha:number2 = 8'b00010001;
            4'hb:number2 = 8'b11000001;
            4'hc:number2 = 8'b01100011;
            4'hd:number2 = 8'b10000101;
            4'he:number2 = 8'b01100001;
            4'hf:number2 = 8'b01110001;
        default :number2 = 8'b11111111;
        endcase
    end
    always@(*)begin
        case(num[15:12])
            4'h0:number3 = 8'b00000011;
            4'h1:number3 = 8'b10011111;
            4'h2:number3 = 8'b00100101;
            4'h3:number3 = 8'b00001101;
            4'h4:number3 = 8'b10011001;
            4'h5:number3 = 8'b01001001;
            4'h6:number3 = 8'b01000001;
            4'h7:number3 = 8'b00011111;
            4'h8:number3 = 8'b00000001;
            4'h9:number3 = 8'b00001001;
            4'ha:number3 = 8'b00010001;
            4'hb:number3 = 8'b11000001;
            4'hc:number3 = 8'b01100011;
            4'hd:number3 = 8'b10000101;
            4'he:number3 = 8'b01100001;
            4'hf:number3 = 8'b01110001;
        default :number3 = 8'b11111111;
        endcase
    end
endmodule
