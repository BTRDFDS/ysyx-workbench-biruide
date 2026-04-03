module ex7Nout(clk,ps2_clk,ps2_data,ascll);
	parameter sizeF=4;
	parameter sizeW=2;
	input logic clk,ps2_clk,ps2_data;//系统时钟(应该是比键盘快)、同步复位
	output logic [7:0] ascll;
	logic [9:0] buffer;        // ps2_data bits
	logic [7:0] fifo[sizeF-1:0];     // data_fifo一个8*8的空间，横是buffer[8:1]，即数据位，
	logic [sizeW-1:0] w_ptr;   // fifo write and read pointers
	logic [3:0] count;  // count ps2_data bits
	logic [2:0] ps2_clk_sync;
	logic over;
	logic [7:0] times;
	always @(posedge clk) begin
		ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};//两个ps2的时钟周期的信号
	end
	wire ps2Neg = ps2_clk_sync[2] & ~ps2_clk_sync[1];//ps2_clk下降沿，即上一个clk时ps2clk还是1，下一个就是0了，原名sampling
	always @(posedge clk) begin
			if (ps2Neg) begin//ps2时钟下降沿开始
			  if (count == 4'd10) begin//10stop
				if ((buffer[0] == 0) &&  // start bit 判断上一个10位是否合法
					(ps2_data)       &&  // stop bit，其实是==1
					(^buffer[9:1])) begin      // odd  parity奇校验
					if(over==1)begin//上i一个是不是F0
						over<=0;
						fifo[w_ptr] <= 8'b0;
						w_ptr <= w_ptr+'b1;
					end else begin
						fifo[w_ptr] <= buffer[8:1];  // kbd键盘 scan code
						w_ptr <= w_ptr+'b1;
						if(buffer[8:1]==8'hf0)begin over<=1;end
						if(buffer[8:1]!=fifo[w_ptr-1]&&buffer[8:1]!=8'hf0)begin times<=times+8'b1;end
					end
				end
				count <= 0;     // for next
			  end else begin//常规读取
				buffer[count] <= ps2_data;  // store ps2_data
				count <= count + 3'b1;
			  end
		end
	end
	always_comb begin
		case(fifo[w_ptr-1])
			8'h1C:ascll=8'h41;
			8'h32:ascll=8'h42;
			8'h21:ascll=8'h43;
			8'h23:ascll=8'h44;
			8'h24:ascll=8'h45;
			8'h2B:ascll=8'h46;
			8'h34:ascll=8'h47;
			8'h33:ascll=8'h48;
			8'h43:ascll=8'h49;
			8'h3B:ascll=8'h4A;
			8'h42:ascll=8'h4B;
			8'h4B:ascll=8'h4C;
			8'h3A:ascll=8'h4D;
			8'h31:ascll=8'h4E;
			8'h44:ascll=8'h4F;
			8'h4D:ascll=8'h50;
			8'h15:ascll=8'h51;
			8'h2D:ascll=8'h52;
			8'h1B:ascll=8'h53;
			8'h2C:ascll=8'h54;
			8'h3C:ascll=8'h55;
			8'h2A:ascll=8'h56;
			8'h1D:ascll=8'h57;
			8'h22:ascll=8'h58;
			8'h35:ascll=8'h59;
			8'h1A:ascll=8'h5A;
			8'h16:ascll=8'h31;
			8'h1E:ascll=8'h32;
			8'h26:ascll=8'h33;
			8'h25:ascll=8'h34;
			8'h2E:ascll=8'h35;
			8'h36:ascll=8'h36;
			8'h3D:ascll=8'h37;
			8'h3E:ascll=8'h38;
			8'h46:ascll=8'h39;
			8'h45:ascll=8'h30;
			default:ascll=8'h00;
		endcase
	end
endmodule
