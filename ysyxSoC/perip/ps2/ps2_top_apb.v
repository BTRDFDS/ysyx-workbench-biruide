module ps2_top_apb(
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
 
	input  logic        ps2_clk,
	input  logic        ps2_data
);

// internal signal, for test
logic [9:0] buffer;		// ps2_data bits
logic [7:0] fifo[7:0];	// data fifo
logic [2:0] w_ptr,r_ptr;// fifo write and read pointers
logic [3:0] count;		// count ps2_data bits
logic ready;
// detect falling edge of ps2_clk
logic [2:0] ps2_clk_sync;
always_ff@(posedge clock)ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
logic sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

always_ff@(posedge clock) begin
	if(reset)begin // reset
		count		<= 0;
		w_ptr		<= 0;
		r_ptr		<= 0;
		ready	<= 0;
	end else begin
		if(ready)begin
				if(in_psel&&in_penable)	begin//读新数据
					r_ptr <= r_ptr + 3'b1;
					if(w_ptr==(r_ptr+1'b1))ready <= 1'b0;//空
				end
		end
		if(sampling)begin
			if (count == 4'd10) begin
				if ((buffer[0] == 0) && (ps2_data) && (^buffer[9:1])) begin // start bit,stop bit,odd parity
					if(fifo[w_ptr-1]==8'hf0)fifo[w_ptr] <= 8'b0;
					else					fifo[w_ptr] <= buffer[8:1];
					w_ptr		<= w_ptr+3'b1;
					ready	<= 1'b1;
				end
				count <= 0;
			end else begin
				buffer[count] <= ps2_data;
				count <= count + 3'b1;
			end
		end
	end
end
assign in_pready = (in_psel&&in_penable)?ready:1'b0;
assign in_pslverr = 1'b0;
always_comb if(in_psel&&in_penable)case(fifo[r_ptr])
	8'h1C		:in_prdata=32'h41;
	8'h32		:in_prdata=32'h42;
	8'h21		:in_prdata=32'h43;
	8'h23		:in_prdata=32'h44;
	8'h24		:in_prdata=32'h45;
	8'h2B		:in_prdata=32'h46;
	8'h34		:in_prdata=32'h47;
	8'h33		:in_prdata=32'h48;
	8'h43		:in_prdata=32'h49;
	8'h3B		:in_prdata=32'h4A;
	8'h42		:in_prdata=32'h4B;
	8'h4B		:in_prdata=32'h4C;
	8'h3A		:in_prdata=32'h4D;
	8'h31		:in_prdata=32'h4E;
	8'h44		:in_prdata=32'h4F;
	8'h4D		:in_prdata=32'h50;
	8'h15		:in_prdata=32'h51;
	8'h2D		:in_prdata=32'h52;
	8'h1B		:in_prdata=32'h53;
	8'h2C		:in_prdata=32'h54;
	8'h3C		:in_prdata=32'h55;
	8'h2A		:in_prdata=32'h56;
	8'h1D		:in_prdata=32'h57;
	8'h22		:in_prdata=32'h58;
	8'h35		:in_prdata=32'h59;
	8'h1A		:in_prdata=32'h5A;
	8'h16		:in_prdata=32'h31;
	8'h1E		:in_prdata=32'h32;
	8'h26		:in_prdata=32'h33;
	8'h25		:in_prdata=32'h34;
	8'h2E		:in_prdata=32'h35;
	8'h36		:in_prdata=32'h36;
	8'h3D		:in_prdata=32'h37;
	8'h3E		:in_prdata=32'h38;
	8'h46		:in_prdata=32'h39;
	8'h45		:in_prdata=32'h30;
	default		:in_prdata=32'hff;
endcase else	 in_prdata=32'hzz;
endmodule