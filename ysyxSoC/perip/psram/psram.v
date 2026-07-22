import "DPI-C" function int spram_read(input int addr);
import "DPI-C" function void spram_write(input int addr, input int data);
module psram(
	input logic sck,
	input logic ce_n,
	inout logic [3:0] dio
);
	typedef enum logic [4:0] {
		Idle,
		Code1,Code2,Code3,Code4,Code5,Code6,Code7,
		Addr0,Addr1,Addr2,Addr3,Addr4,Addr5,
		Wait0,Wait1,Wait2,Wait3,Wait4,Wait5,Code0,//写没有等待,Code0是为了填平差额，因为实质上是在Idle读了
		Data0,Data1,Data2,Data3,Data4,Data5,Data6,Data7,
		Done
	}Enum;
	Enum state;
	logic [ 7:0] code;
	logic [23:0] addr;
	logic [31:0] data,temp;
	logic [3:0] dinp,dout;
	logic read,qpi;

	always_ff @(posedge sck or posedge ce_n) begin
		unique case(state)
			Idle	:temp[ 0] <= 1'b1;
			Code1	:temp[ 1] <= 1'b1;
			Code2	:temp[ 2] <= 1'b1;
			Code3	:temp[ 3] <= 1'b1;
			Code4	:temp[ 4] <= 1'b1;
			Code5	:temp[ 5] <= 1'b1;
			Code6	:temp[ 6] <= 1'b1;
			Code7	:temp[ 7] <= dinp[0];
			Addr0	:temp[ 8] <= 1'b1;
			Addr1	:temp[ 9] <= 1'b1;
			Addr2	:temp[10] <= 1'b1;
			Addr3	:temp[11] <= 1'b1;
			Addr4	:temp[12] <= 1'b1;
			Addr5	:temp[13] <= 1'b1;
			default	:;
		endcase

		if(state==Code7)begin
			$display("dinp %x",dinp);
			$strobe("dinp %x",dinp);
			$finish();
		end

		if (ce_n) state <= qpi?Code6:Idle;
		else begin
			case(state)
				Addr0	:state <= (code==8'h35)?Code6:Addr1;
				Addr5	:state <= read	?Wait0:Data0;
				Done	:state <= Done;
				default	:state <= Enum'(state + 5'h1);
			endcase
		end
		if(qpi)begin
			if(state==Code6)code[7:4] <= dinp;
			if(state==Code7)code[3:0] <= dinp;
		end else begin
			if(state==Idle )code[7] <= dinp[0];
			if(state==Code1)code[6] <= dinp[0];
			if(state==Code2)code[5] <= dinp[0];
			if(state==Code3)code[4] <= dinp[0];
			if(state==Code4)code[3] <= dinp[0];
			if(state==Code5)code[2] <= dinp[0];
			if(state==Code6)code[1] <= dinp[0];
			if(state==Code7)code[0] <= dinp[0];//？？？
		end
		if(state==Addr0)addr[23:20] <= dinp[3:0];
		if(state==Addr1)addr[19:16] <= dinp[3:0];
		if(state==Addr2)addr[15:12] <= dinp[3:0];
		if(state==Addr3)addr[11: 8] <= dinp[3:0];
		if(state==Addr4)addr[ 7: 4] <= dinp[3:0];
		if(state==Addr5)addr[ 3: 0] <= dinp[3:0];

		// if(state==Idle )temp[ 0] <= dinp[0];
		// if(state==Code1)temp[ 1] <= dinp[0];
		// if(state==Code2)temp[ 2] <= dinp[0];
		// if(state==Code3)temp[ 3] <= dinp[0];
		// if(state==Code4)temp[ 4] <= dinp[0];
		// if(state==Code5)temp[ 5] <= dinp[0];
		// if(state==Code6)temp[ 6] <= dinp[0];
		// if(state==Code7)temp[ 7] <= dinp[0];
		// if(state==Addr0)temp[ 8] <= dinp[0];
		// if(state==Addr1)temp[ 9] <= dinp[0];
		// if(state==Addr2)temp[10] <= dinp[0];
		// if(state==Addr3)temp[11] <= dinp[0];
		// if(state==Addr4)temp[12] <= dinp[0];
		// if(state==Addr5)temp[13] <= dinp[0];

		if(state==Idle)read<=1'b0;
		if(state==Addr0)begin
			case(code)
				8'hEB:read<=1'b1;
				8'h38:read<=1'b0;
				8'h35:;
				default:begin
					$display("psram code error %x",code);
					$finish();
			end endcase
			case(code)
				8'hEB:;
				8'h38:;
				8'h35:qpi<=1'b1;
				default:begin
					$display("psram code error %x",code);
					$finish();
			end endcase
		end
		if(state==Wait0)data <= spram_read({8'h0,addr});
		if(~read)begin
			if(state==Data0)data[ 7: 4] <= dinp;
			if(state==Data1)spram_write(({8'h0,addr}+32'h0),{24'h0,data[ 7: 4],dinp});
			if(state==Data2)data[15:12] <= dinp;
			if(state==Data3)spram_write(({8'h0,addr}+32'h1),{24'h0,data[15:12],dinp});
			if(state==Data4)data[23:20] <= dinp;
			if(state==Data5)spram_write(({8'h0,addr}+32'h2),{24'h0,data[23:20],dinp});
			if(state==Data6)data[31:28] <= dinp;
			if(state==Data7)spram_write(({8'h0,addr}+32'h3),{24'h0,data[31:28],dinp});
		end
	end always_comb if(read)case(state)
		Data0	:dout = data[ 7: 4];
		Data1	:dout = data[ 3: 0];
		Data2	:dout = data[15:12];
		Data3	:dout = data[11: 8];
		Data4	:dout = data[23:20];
		Data5	:dout = data[19:16];
		Data6	:dout = data[31:28];
		Data7	:dout = data[27:24];
		default	:dout = 4'b0;
	endcase else dout = 4'b0;
	// initial $display("%m");
	initial qpi = 1'b0;
	assign dio = read?dout:4'bz;
	assign dinp = dio;
endmodule
