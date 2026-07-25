import "DPI-C" function int sdram_read(input int addr);
import "DPI-C" function void sdram_write(input int addr, input int data);
module sdram(
	input logic        clk,
	input logic        cke,
	input logic        cs,
	input logic        ras,
	input logic        cas,
	input logic        we,
	input logic [12:0] a,
	input logic [ 1:0] ba,
	input logic [ 1:0] dqm,
	inout logic [15:0] dq
);

	typedef enum logic [2:0] {Mode,AutoFresh,Precharge,Activ,Write,Read,BurstStop,Nop} Enum;
	Enum code;assign code = Enum'({ras,cas,we});

	typedef enum logic [1:0] {Idle,Wait,Burst,Done} State;
	State state;

	typedef struct packed {
		logic [2:0] Reserved;//略
		logic 		WB;//略
		logic [1:0] Op;//略
		logic [2:0] Latency;
		logic		BT;//略
		logic [2:0] Length;
	} mode_t;
	mode_t mode;
	logic [24:1] addr;
	logic [2:0] cnt;
	logic [12:0] row [3:0];

	logic write;

	logic [15:0] dai,dao,data;
	assign dq	= (state==Burst && write==1'b0) ? dao	: 16'bz;
	assign dai	= dq;

	always_comb begin
		if(state==Burst && write==1'b0)dao = data;
		else dao = 16'hffff;
	end

	logic [2:0] burstLen;

	always_ff @(posedge clk) begin
		if(cke & ~cs)begin
			case(state)
				Idle	:state <= (code==Read)?(mode.Latency[2:0]==1?Burst:Wait):(code==Write?Burst:Idle);
				Wait	:state <= (cnt<mode.Latency[2:0]) ? Wait : Burst;
				Burst	:state <= (code==BurstStop || cnt==burstLen) ? Idle : Burst;
				Done	:state <= Idle;
			endcase
			case(state)
				Idle	:cnt <= code==Write?3'b0:3'd2;
				Wait	:cnt <= (cnt<mode.Latency[2:0]) ? cnt+3'b1 : 3'b0;
				Burst	:cnt <= cnt+3'b1;
				Done	:cnt <= 3'b1;
			endcase
			if(state==Idle)begin
				if(code==Mode)	mode<=a;
				if(code==Activ)	row[ba] <= a;
				if(code==Write||code==Read)addr<={row[ba],ba,a[8:0]};
				if(code==Write)	write <= 1'b1;
				if(code==Read)	write <= 1'b0;
			end
			if(state==Idle && code == Write)begin
				if(~dqm[0])sdram_write({7'b0,addr[24:10],a[8:0],1'b0},{24'b0,dai[ 7:0]});
				if(~dqm[1])sdram_write({7'b0,addr[24:10],a[8:0],1'b1},{24'b0,dai[15:8]});
			end
			if(state==Burst && write==1'b1 && cnt!=burstLen)begin
				if(~dqm[0])sdram_write({7'b0,addr+{21'b0,cnt}+24'b1,1'b0},{24'b0,dai[ 7:0]});
				if(~dqm[1])sdram_write({7'b0,addr+{21'b0,cnt}+24'b1,1'b1},{24'b0,dai[15:8]});
			end
			if(state==Wait && cnt==mode.Latency[2:0])data <= sdram_read({7'b0,addr,1'b0})[15:0];
			if(state==Burst && write==1'b0 && cnt!=burstLen) data <= sdram_read({7'b0,{addr+{21'b0,cnt}+24'b1},1'b0})[15:0];
		end else begin
			state	<= Idle;
			cnt		<= 3'b1;
			write	<= 1'b0;
		end
	end
	always_comb case(mode.Length)
		3'b000:burstLen=3'd0;
		3'b001:burstLen=3'd1;
		3'b010:burstLen=3'd3;
		3'b011:burstLen=3'd7;
		default:burstLen=3'd0;
	endcase
	initial $display("%m");
endmodule
