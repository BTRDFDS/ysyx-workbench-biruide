module apb_delayer(
	input         clock,
	input         reset,
	input  [31:0] in_paddr,
	input         in_psel,
	input         in_penable,
	input  [2:0]  in_pprot,
	input         in_pwrite,
	input  [31:0] in_pwdata,
	input  [3:0]  in_pstrb,
	output        in_pready,
	output [31:0] in_prdata,
	output        in_pslverr,

	output [31:0] out_paddr,
	output        out_psel,
	output        out_penable,
	output [2:0]  out_pprot,
	output        out_pwrite,
	output [31:0] out_pwdata,
	output [3:0]  out_pstrb,
	input         out_pready,
	input  [31:0] out_prdata,
	input         out_pslverr
);
logic [31:0] cnt,data;
logic has,done,err;
localparam rs = 327;//5.1118*64
// localparam s = 6;//2^6
always_ff @(posedge clock) begin
	if(reset)has <= 0;
	else if(out_pready)begin
			has	<= 1;
			data<= out_prdata;
			err	<= out_pslverr;
	end if(~in_psel | ~in_penable)has <= 'd0;
	if(reset)cnt <= 'd0;
	else if(has)cnt[31:6] <= (cnt[31:6] == 'd0)?'d0:(cnt[31:6] - 'd1);
	else if(in_psel & in_penable & ~in_pready)cnt <= cnt + rs;
	else cnt <= 'd0;
end
assign done = has & (cnt[31:6] == '0);

	assign out_paddr   = in_paddr;
	assign out_psel    = in_psel;
	assign out_penable = in_penable;
	assign out_pprot   = in_pprot;
	assign out_pwrite  = in_pwrite;
	assign out_pwdata  = in_pwdata;
	assign out_pstrb   = in_pstrb;
	assign in_pready   = done?1		:'0;
	assign in_prdata   = done?data	:'0;
	assign in_pslverr  = done?err	:'0;

endmodule
