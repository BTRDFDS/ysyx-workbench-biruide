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

// // internal signal, for test
// logic [9:0] buffer;		// ps2_data bits
// logic [7:0] fifo[7:0];	// data fifo
// logic [2:0] w_ptr,r_ptr;// fifo write and read pointers
// logic [3:0] count;		// count ps2_data bits
// logic ready,over;
// // detect falling edge of ps2_clk
// logic [2:0] ps2_clk_sync;
// always_ff@(posedge clock)ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
// logic sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

// always_ff@(posedge clock) begin
// 	if(reset)begin // reset
// 		count <= 'b0;
// 		w_ptr <= 'b0;
// 		r_ptr <= 'b0;
// 		ready <= 'b0;
// 	end else begin
// 		if(ready)begin
// 				if(in_psel&&in_penable)	begin//读新数据
// 					r_ptr <= r_ptr + 3'b1;
// 					if(w_ptr==(r_ptr+1'b1))ready <= 1'b0;//空
// 				end
// 		end
// 		if(sampling)begin
// 			if (count == 4'd10) begin
// 				if ((buffer[0] == 0) && (ps2_data) && (^buffer[9:1])) begin // start bit,stop bit,odd parity
// 					// if(fifo[w_ptr-1]==8'hf0)fifo[w_ptr] <= 8'b0;
// 					// else					fifo[w_ptr] <= buffer[8:1];
// 					w_ptr <= w_ptr+3'b1;
// 					ready <= 1'b1;

// 					$strobe("r_ptr:%h r_fifo:%h w_ptr:%h w_fifo:%h buffer:%h over:%b",r_ptr,fifo[r_ptr],w_ptr,fifo[w_ptr],buffer[8:1],over);
// 					if(over==1)begin//上i一个是不是F0
// 						over<=0;
// 						fifo[w_ptr] <= 8'b0;
// 					end else begin
// 						fifo[w_ptr] <= buffer[8:1];  // kbd键盘 scan code
// 						if(buffer[8:1]==8'hf0)begin
// 							// $strobe("key:%h over:%b",fifo[w_ptr-1],over);
// 							over<=1;
// 						end
// 					end
// 					// $strobe("key: %b %h over:%b",fifo[w_ptr-1],fifo[w_ptr-1],over);
// 					// $strobe("fifo",fifo[w_ptr-1]," ",fifo[r_ptr]," w_ptr:",w_ptr," r_ptr:",r_ptr," overflow:",overflow);

// 				end
// 				count <= 0;
// 			end else begin
// 				buffer[count] <= ps2_data;
// 				count <= count + 3'b1;
// 			end
// 		end
// 	end
// end
// assign in_pready = (in_psel&&in_penable)?ready:1'b0;
// assign in_pslverr = 1'b0;
// always_comb
// 	if(in_psel&&in_penable)	in_prdata = {24'b0,fifo[r_ptr]};
// 	else	 				in_prdata = 32'hzz;

localparam Width = 3;
localparam Size = 2**Width;
logic [9:0] buffer;
logic [7:0] fifo[Size-1:0];
logic [Width-1:0] w_ptr,r_ptr;
logic [Width-1:0] count;//state
logic ready,over;
// detect falling edge of ps2_clk
logic [2:0] ps2_clk_sync;
always_ff@(posedge clock)ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
logic sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];
//交互读取
always_ff@(posedge clock)
	if(ready&&in_psel&&in_penable)begin//读新数据
		r_ptr <= r_ptr + 3'b1;
		if(w_ptr==r_ptr+1'b1)ready <= 1'b0;//空
	end
assign in_pready = (in_psel&&in_penable)?ready:1'b0;
assign in_pslverr = 1'b0;
assign in_prdata = (in_psel&&in_penable)?{24'b0,fifo[r_ptr]}:32'h00;
//内部状态机

endmodule