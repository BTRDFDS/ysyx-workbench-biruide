import "DPI-C" function int spram_read(input int addr);
import "DPI-C" function void spram_write(input int addr, input int data);
module psram(
	input logic sck,
	input logic ce_n,
	inout logic [3:0] dio
);
	typedef enum logic [4:0] {
		Idle,
		Code0,Code1,Code2,Code3,Code4,Code5,Code6,Code7,
		Addr0,Addr1,Addr2,Addr3,Addr4,Addr5,
		Wait0,Wait1,Wait2,Wait3,Wait4,Wait5,//写没有等待
		Data0,Data1,Data2,Data3,Data4,Data5,Data6,Data7,
		Done
	}Enum;
	Enum state;
	logic [ 7:0] code;
	logic [23:0] addr;
	logic [31:0] data;
	logic write;
	always_ff @(posedge sck) begin
		if (ce_n) state <= Idle;
		else begin
			case(state)
				Addr5	:state <= write?Data0:Wait0;
				Done	:state <= Done;
				default	:state <= Enum'(state + 5'h1);
			endcase
		end
		if(state==Code0)code[7] <= dio[0];
		if(state==Code1)code[6] <= dio[0];
		if(state==Code2)code[5] <= dio[0];
		if(state==Code3)code[4] <= dio[0];
		if(state==Code4)code[3] <= dio[0];
		if(state==Code5)code[2] <= dio[0];
		if(state==Code6)code[1] <= dio[0];
		if(state==Code7)code[0] <= dio[0];
		if(state==Addr0)addr[23:20] <= dio[3:0];
		if(state==Addr1)addr[19:16] <= dio[3:0];
		if(state==Addr2)addr[15:12] <= dio[3:0];
		if(state==Addr3)addr[11: 8] <= dio[3:0];
		if(state==Addr4)addr[ 7: 4] <= dio[3:0];
		if(state==Addr5)addr[ 3: 0] <= dio[3:0];

		if(state==Idle)write<=1'b0;
		if(state==Addr0)case(code)
			8'hEB:write<=1'b0;
			8'h38:write<=1'b1;
			default:begin
				$display("psram code error %x",code);
				$finish();
		end endcase
		if(state==Wait0)data <= spram_read({8'h0,addr});
		if(write)begin
			if(state==Data0)data[ 7: 4] <= dio;
			// if(state==Data1)data[ 3: 0] <= dio;
			if(state==Data1)spram_write({8'h0,addr},{24'h0,dio,data[ 3: 0]});
			if(state==Data2)data[15:12] <= dio;
			// if(state==Data3)data[11: 8] <= dio;
			if(state==Data3)spram_write({8'h0,addr},{24'h0,dio,data[11: 8]});
			if(state==Data4)data[23:20] <= dio;
			// if(state==Data5)data[19:16] <= dio;
			if(state==Data5)spram_write({8'h0,addr},{24'h0,dio,data[19:16]});
			if(state==Data6)data[31:28] <= dio;
			// if(state==Data7)data[27:24] <= dio;
			if(state==Data7)spram_write({8'h0,addr},{24'h0,dio,data[27:24]});
			// if(state==Done)spram_write({8'h0,addr},data);
		end
	end always_comb if(~write)case(state)
		Data0	:dio = data[ 7: 4];
		Data1	:dio = data[ 3: 0];
		Data2	:dio = data[15:12];
		Data3	:dio = data[11: 8];
		Data4	:dio = data[23:20];
		Data5	:dio = data[19:16];
		Data6	:dio = data[31:28];
		Data7	:dio = data[27:24];
		default	:dio = 4'bz;
	endcase

endmodule
