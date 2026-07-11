module ex2(input en,input [7:0] sw,output [3:0] ld,output [7:0] seg);
    always@(*)begin
        casez({~en,sw[7:0]})
            9'b1zzzzzzzz:ld[2:0]=3'b000;
            9'b01zzzzzzz:ld[2:0]=3'b111;
            9'b001zzzzzz:ld[2:0]=3'b110;
            9'b0001zzzzz:ld[2:0]=3'b101;
            9'b00001zzzz:ld[2:0]=3'b100;
            9'b000001zzz:ld[2:0]=3'b011;
            9'b0000001zz:ld[2:0]=3'b010;
            9'b00000001z:ld[2:0]=3'b001;
            9'b000000001:ld[2:0]=3'b000;
            default:ld[2:0]='b000;
        endcase
    end
    assign ld[3]=(|sw[7:0])&en;
    always@(*)begin
        if(~en)seg[7:0]='b11111110;
        else begin
            seg[0]=1'b1;
            case(ld[2:0])
                3'd0:seg[7:1]=7'b0000001;
                3'd1:seg[7:1]=7'b1001111;
                3'd2:seg[7:1]=7'b0010010;
                3'd3:seg[7:1]=7'b0000110;
                3'd4:seg[7:1]=7'b1001100;
                3'd5:seg[7:1]=7'b0100100;
                3'd6:seg[7:1]=7'b0100000;
                3'd7:seg[7:1]=7'b0001111;
                default:seg[7:1]=7'b1111111;
            endcase
        end
    end
endmodule
