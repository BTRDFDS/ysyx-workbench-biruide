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
localparam Width = 3;
localparam Size = 2**Width;
logic [9:0] buffer;
logic [7:0] fifo[Size-1:0];
logic [Width-1:0] w_ptr,r_ptr;
logic [3:0] count;//state
logic ready,over;
// detect falling edge of ps2_clk
logic [2:0] ps2_clk_sync;
always_ff@(posedge clock)ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
logic sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
//交互读取
always_ff@(posedge clock)
	if(ready&&in_psel&&in_penable)begin//读新数据
		$display("r_ptr:%h r_fifo:%h w_ptr:%h w_fifo:%h buffer:%h over:%b",r_ptr,fifo[r_ptr],w_ptr,fifo[w_ptr],buffer[8:1],over);
		r_ptr <= r_ptr + 3'b1;
		if(w_ptr==r_ptr+1'b1)ready <= 1'b0;//空
	end
assign in_pready = (in_psel&&in_penable)?ready:1'b0;
assign in_pslverr = 1'b0;
assign in_prdata = (in_psel&&in_penable)?{24'b0,fifo[r_ptr]}:32'h00;
//内部状态机
always_ff @(posedge clock)if(sampling)begin
	if (count == 4'd10) begin
		if ((buffer[0] == 0) && (ps2_data) && (^buffer[9:1]))begin
			$display("r_ptr:%h r_fifo:%h w_ptr:%h w_fifo:%h buffer:%h over:%b",r_ptr,fifo[r_ptr],w_ptr,fifo[w_ptr],buffer[8:1],over);
			fifo[w_ptr] <= buffer[8:1];
			w_ptr		<= w_ptr+3'b1;
			ready		<= 1'b1;
		end
		count <= 0;
	end else begin
		buffer[count] <= ps2_data;
		count <= count + 3'b1;
	end
end
endmodule