module vga_top_apb(
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

	output logic [7:0]  vga_r,
	output logic [7:0]  vga_g,
	output logic [7:0]  vga_b,
	output logic        vga_hsync,
	output logic        vga_vsync,
	output logic        vga_valid
);

logic [9:0] x;	//行像素计数
parameter hFrontporch	= 96;
parameter hActive		= 144;
parameter hBackporch	= 784;
parameter hTotal		= 800;
always_ff@(posedge clock)
	if(reset)				x <= 1;
	else if (x == hTotal)	x <= 1;
	else					x <= x + 10'd1;

logic [9:0] y;	//列像素计数
parameter vFrontporch	= 2;
parameter vActive		= 35;
parameter vBackporch	= 515;
parameter vTotal		= 525;
always_ff@(posedge clock)
	if(reset)							y <= 1;
	else if(y == vTotal && x == hTotal)	y <= 1;
	else if(x == hTotal)				y <= y + 10'd1;

logic [7:0] ramRed		[307199:0];
logic [7:0] ramGreen	[307199:0];
logic [7:0] ramBlue		[307199:0];

logic 			hValid	= (x>hActive)&(x <= hBackporch);
logic 			vValid	= (y>vActive)&(y <= vBackporch);
logic [9:0]		vAddr	= vValid?(y-10'd36) :10'd0;
logic [9:0]		hAddr	= hValid?(x-10'd145):10'd0;
logic [18:0]	locate	= {vAddr,9'b0}+{2'b0,vAddr,7'b0}+{9'b0,hAddr};
//vga接口
// assign vga_r = vga_valid?ramRed		[locate]:8'd0;
// assign vga_g = vga_valid?ramGreen	[locate]:8'd0;
// assign vga_b = vga_valid?ramBlue	[locate]:8'd0;
assign vga_r = vga_valid?8'h0f:8'd0;
assign vga_g = vga_valid?8'h0f:8'd0;
assign vga_b = vga_valid?8'h0f:8'd0;
assign vga_hsync = (x>hFrontporch);
assign vga_vsync = (y>vFrontporch);
assign vga_valid = hValid&vValid;
//apb接口
always_ff @(posedge clock) begin
	if(in_psel & in_penable) begin
		if(in_pwrite) begin
			if(in_pstrb[0]) ramBlue	[in_paddr[20:2]] <= in_pwdata[7:0];
			if(in_pstrb[1]) ramGreen[in_paddr[20:2]] <= in_pwdata[7:0];
			if(in_pstrb[2]) ramRed	[in_paddr[20:2]] <= in_pwdata[7:0];
		end
		in_pready <= 1;
	end else in_pready <= 0;
end
endmodule