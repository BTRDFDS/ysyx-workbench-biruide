module gpio_top_apb(
	input  logic        clock,
	input  logic        reset,
	input  logic [31:0] in_paddr,
	input  logic        in_psel,
	input  logic        in_penable,
	input  logic [2:0]  in_pprot,
	input  logic        in_pwrite,
	input  logic [31:0] in_pwdata,
	input  logic [3:0]  in_pstrb,
	output logic        in_pready,
	output logic [31:0] in_prdata,
	output logic        in_pslverr,

	output [15:0] gpio_out,
	input  [15:0] gpio_in,
	output [7:0]  gpio_seg_0,
	output [7:0]  gpio_seg_1,
	output [7:0]  gpio_seg_2,
	output [7:0]  gpio_seg_3,
	output [7:0]  gpio_seg_4,
	output [7:0]  gpio_seg_5,
	output [7:0]  gpio_seg_6,
	output [7:0]  gpio_seg_7
);
logic [4:0] addr;
logic [15:0]led;
logic [3:0]seg[7:0];
always_ff @(posedge clock) begin
	if(reset) addr <='0;
	else if(in_psel && ~in_penable)addr<=in_paddr[4:0];

	if(reset)begin
		led		<='0;
		seg[0]	<='0;
		seg[1]	<='0;
		seg[2]	<='0;
		seg[3]	<='0;
		seg[4]	<='0;
		seg[5]	<='0;
		seg[6]	<='0;
		seg[7]	<='0;
	end
	else if(in_psel && in_penable && in_pwrite)begin
		if(addr == 5'h0)begin
			if(in_pstrb[0])led[ 7:0]<=in_pwdata[7:0];
			if(in_pstrb[1])led[15:8]<=in_pwdata[15:8];
		end
		if(addr == 5'h8)begin
			if(in_pstrb[0]){seg[1],seg[0]}<=in_pwdata[ 7: 0];
			if(in_pstrb[1]){seg[3],seg[2]}<=in_pwdata[15: 8];
			if(in_pstrb[2]){seg[5],seg[4]}<=in_pwdata[23:16];
			if(in_pstrb[3]){seg[7],seg[6]}<=in_pwdata[31:24];
		end
	end

	if(~reset && in_psel && in_penable)in_pready <= 1'b1;
	else in_pready <= 1'b0;
end
assign in_prdata = (addr == 5'h04 && in_psel && in_penable && ~in_pwrite) ? {16'h0,gpio_in} : 32'h0;
assign gpio_out = led;

Seg seg0(.in(seg[0]),.out(gpio_seg_0));
Seg seg1(.in(seg[1]),.out(gpio_seg_1));
Seg seg2(.in(seg[2]),.out(gpio_seg_2));
Seg seg3(.in(seg[3]),.out(gpio_seg_3));
Seg seg4(.in(seg[4]),.out(gpio_seg_4));
Seg seg5(.in(seg[5]),.out(gpio_seg_5));
Seg seg6(.in(seg[6]),.out(gpio_seg_6));
Seg seg7(.in(seg[7]),.out(gpio_seg_7));

endmodule
module Seg(
	input	logic [3:0] in,
	output	logic [7:0] out
);
	always_comb case(in)
		4'h0	:out = 8'b00000011;
		4'h1	:out = 8'b10011111;
		4'h2	:out = 8'b00100101;
		4'h3	:out = 8'b00001101;
		4'h4	:out = 8'b10011001;
		4'h5	:out = 8'b01001001;
		4'h6	:out = 8'b01000001;
		4'h7	:out = 8'b00011111;
		4'h8	:out = 8'b00000001;
		4'h9	:out = 8'b00001001;
		4'ha	:out = 8'b00010001;
		4'hb	:out = 8'b11000001;
		4'hc	:out = 8'b01100011;
		4'hd	:out = 8'b10000101;
		4'he	:out = 8'b01100001;
		4'hf	:out = 8'b01110001;
		default :out = 8'b11111111;
	endcase
endmodule