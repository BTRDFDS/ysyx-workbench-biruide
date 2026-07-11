// module ex7N(clk,clrn,ps2_clk,ps2_data,data,ready,nextdata_n,overflow,segD0,segD1);
module ex7N(clk,clrn,ps2_clk,ps2_data,data,ascll,segD0,segD1,segA0,segA1,segT0,segT1);
    input clk,clrn,ps2_clk,ps2_data;//系统时钟(应该是比键盘快)、同步复位
    // input nextdata_n;
    output [7:0] data,ascll,segD0,segD1,segA0,segA1,segT0,segT1;
    // output reg ready;
    // output reg overflow;     // fifo overflow
    // internal signal, for test
    reg [9:0] buffer;        // ps2_data bits
    reg [7:0] fifo[7:0];     // data fifo一个8*8的空间，横是buffer[8:1]，即数据位，
    // reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
    reg [2:0] w_ptr;   // fifo write and read pointers
    reg [3:0] count;  // count ps2_data bits
    // detect falling edge of ps2_clk
    reg [2:0] ps2_clk_sync;
    reg over;
    reg [7:0] times;

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




    always @(posedge clk) begin
        ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};//两个ps2的时钟周期的信号
        // $strobe("ps2_clk_sync",ps2_clk_sync);
    end

    wire ps2Neg = ps2_clk_sync[2] & ~ps2_clk_sync[1];//ps2_clk下降沿，即上一个clk时ps2clk还是1，下一个就是0了，原名sampling

    always @(posedge clk) begin
        if (clrn == 1) begin // reset
            // count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
            count <= 0; w_ptr <= 0;over <= 0;times<=0;
        end else begin
            // if ( ready ) begin // read to output next data上一个已经读取完成，可以处理下一个按键了

            // //$display("key: %b",data);
            //     if(nextdata_n == 1'b0) //read next data
            //     begin
            //         r_ptr <= r_ptr + 3'b1;
            //         if(w_ptr==(r_ptr+1'b1)) //empty
            //             ready <= 1'b0;
            //     end
            // end
            
            if (ps2Neg) begin//ps2时钟下降沿开始
              if (count == 4'd10) begin//10stop
                if ((buffer[0] == 0) &&  // start bit 判断上一个10位是否合法
                    (ps2_data)       &&  // stop bit，其实是==1
                    (^buffer[9:1])) begin      // odd  parity奇校验
                    if(over==1)begin//上i一个是不是F0
                        over<=0;
                        fifo[w_ptr] <= 8'b0;
                        w_ptr <= w_ptr+3'b1;
                    end else begin
                        fifo[w_ptr] <= buffer[8:1];  // kbd键盘 scan code
                        w_ptr <= w_ptr+3'b1;
                        if(buffer[8:1]==8'hf0)begin
                            over<=1;
                        end
                        if(buffer[8:1]!=fifo[w_ptr-1]&&buffer[8:1]!=8'hf0)begin
                            times<=times+8'b1;
                        end
                    end
                    // ready <= 1'b1;
                    // overflow <= overflow | (r_ptr == (w_ptr + 3'b1));//只要读得比写的快就一直判定溢出直到复位
                    // $strobe("key: %b %h over:%b",fifo[w_ptr-1],fifo[w_ptr-1],over);
                    // $strobe("fifo",fifo[w_ptr-1]," ",fifo[r_ptr]," w_ptr:",w_ptr," r_ptr:",r_ptr," overflow:",overflow);
                end
                count <= 0;     // for next
              end else begin//常规读取
                buffer[count] <= ps2_data;  // store ps2_data
                count <= count + 3'b1;
                $strobe("ps2:",ps2_data," count:",count);
              end
            //   $strobe(w_ptr," ",r_ptr);
            end
        end
    end
    assign data = fifo[w_ptr-1]; //always set output data
    assign ascll = rom[data];
    seg SegD0(.in(data[3:0]),.out(segD0));
    seg SegD1(.in(data[7:4]),.out(segD1));
    seg SegA0(.in(ascll[3:0]),.out(segA0));
    seg SegA1(.in(ascll[7:4]),.out(segA1));
    seg SegT0(.in(times[3:0]),.out(segT0));
    seg SegT1(.in(times[7:4]),.out(segT1));
    // seg SegD0(.in(fifo[w_ptr-1][3:0]),.out(segD0));
    // seg SegD1(.in(fifo[w_ptr-1][7:4]),.out(segD1));
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
            4'h8:out[7:0] = 8'b00000001;
            4'h9:out[7:0] = 8'b00001001;
            4'ha:out[7:0] = 8'b00010001;
            4'hb:out[7:0] = 8'b11000001;
            4'hc:out[7:0] = 8'b01100011;
            4'hd:out[7:0] = 8'b10000101;
            4'he:out[7:0] = 8'b01100001;
            4'hf:out[7:0] = 8'b01110001;
        default :out[7:0] = 8'b11111111;
        endcase
    end
endmodule
