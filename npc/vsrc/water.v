module water(input clk,reset,output [9:0] out);
	parameter N = 1000000;
	reg [31:0] Utime;
	always @(posedge clk) begin
		Utime <= (Utime < N-1)? Utime+1:0;
	end
	wire is;
	assign is = (Utime == N-1)? 1:0;
	reg [9:0] s;
	always @(posedge clk) begin
		if(reset) s <= 10'b1111100000;
		else begin
			if(is) s <= {s[8:0],s[9]};
		end
	end
	initial begin
		s = 10'b1111100000;
	end
assign out = s;
endmodule
