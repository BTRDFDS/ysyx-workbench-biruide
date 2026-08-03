module axi4_delayer(
	input         clock,
	input         reset,

	output        in_arready,
	input         in_arvalid,
	input  [3:0]  in_arid,
	input  [31:0] in_araddr,
	input  [7:0]  in_arlen,
	input  [2:0]  in_arsize,
	input  [1:0]  in_arburst,
	input         in_rready,
	output        in_rvalid,
	output [3:0]  in_rid,
	output [31:0] in_rdata,
	output [1:0]  in_rresp,
	output        in_rlast,
	output        in_awready,
	input         in_awvalid,
	input  [3:0]  in_awid,
	input  [31:0] in_awaddr,
	input  [7:0]  in_awlen,
	input  [2:0]  in_awsize,
	input  [1:0]  in_awburst,
	output        in_wready,
	input         in_wvalid,
	input  [31:0] in_wdata,
	input  [3:0]  in_wstrb,
	input         in_wlast,
								in_bready,
	output        in_bvalid,
	output [3:0]  in_bid,
	output [1:0]  in_bresp,

	input         out_arready,
	output        out_arvalid,
	output [3:0]  out_arid,
	output [31:0] out_araddr,
	output [7:0]  out_arlen,
	output [2:0]  out_arsize,
	output [1:0]  out_arburst,
	output        out_rready,
	input         out_rvalid,
	input  [3:0]  out_rid,
	input  [31:0] out_rdata,
	input  [1:0]  out_rresp,
	input         out_rlast,
	input         out_awready,
	output        out_awvalid,
	output [3:0]  out_awid,
	output [31:0] out_awaddr,
	output [7:0]  out_awlen,
	output [2:0]  out_awsize,
	output [1:0]  out_awburst,
	input         out_wready,
	output        out_wvalid,
	output [31:0] out_wdata,
	output [3:0]  out_wstrb,
	output        out_wlast,
								out_bready,
	input         out_bvalid,
	input  [3:0]  out_bid,
	input  [1:0]  out_bresp
);

	assign in_arready = out_arready;
	assign out_arvalid = in_arvalid;
	assign out_arid = in_arid;
	assign out_araddr = in_araddr;
	assign out_arlen = in_arlen;
	assign out_arsize = in_arsize;
	assign out_arburst = in_arburst;
	// assign out_rready = in_rready;
	// assign in_rvalid = out_rvalid;
	// assign in_rid = out_rid;
	// assign in_rdata = out_rdata;
	// assign in_rresp = out_rresp;
	// assign in_rlast = out_rlast;
	assign in_awready = out_awready;
	assign out_awvalid = in_awvalid;
	assign out_awid = in_awid;
	assign out_awaddr = in_awaddr;
	assign out_awlen = in_awlen;
	assign out_awsize = in_awsize;
	assign out_awburst = in_awburst;
	assign in_wready = out_wready;
	assign out_wvalid = in_wvalid;
	assign out_wdata = in_wdata;
	assign out_wstrb = in_wstrb;
	assign out_wlast = in_wlast;
	// assign out_bready = in_bready;
	// assign in_bvalid = out_bvalid;
	// assign in_bid = out_bid;
	// assign in_bresp = out_bresp;


logic [31:0] wCnt;
logic wHas,wDone;
localparam rs = 263;
assign wDone = wHas & (wCnt[31:6] == '0);
always_ff @(posedge clock) begin
	if(reset | (out_bvalid & in_bready & wDone))wHas <= 0;
	else if(out_bvalid & wHas==0)wHas <= 1;

	if(reset | (out_bvalid & in_bready & wDone))wCnt[31:6] <= 'd0;
	else if(wHas)wCnt[31:6]<=(wCnt[31:6]=='d0)?'d0:(wCnt[31:6]-'d1);
	else wCnt <= wCnt + rs;
end
assign out_bready	= wDone?in_bready	:'b0;
assign in_bvalid	= wDone?out_bvalid	:'b0;
assign in_bid		= wDone?out_bid		:'b0;
assign in_bresp		= wDone?out_bresp	:'b0;

logic [31:0]	rRcnt;
logic [25:0]	rAcnt;
logic [2:0]		rIcnt,rOcnt;
logic [25:0]	rFcnt		[7:0];
logic [31:0]	rFifoData	[7:0];
logic [1:0]		rFifoResp	[7:0];
logic 			rFifoLast	[7:0];
logic [3:0]		rFifoId		[7:0];
logic rDone;
always_ff@(posedge clock)begin
	if(reset)begin
		rRcnt <= 'd0;
		rAcnt <= 'd0;
		rIcnt <= 'd0;
		rOcnt <= 'd0;
	end else begin
		if(out_rvalid)begin
			rFcnt[rIcnt] <= rRcnt[31:6];
			rFifoData[rIcnt] <= out_rdata;
			rFifoResp[rIcnt] <= out_rresp;
			rFifoLast[rIcnt] <= out_rlast;
			rFifoId	 [rIcnt] <= out_rid;
			rIcnt <= rIcnt + 'd1;
		end
		if(rFcnt[rOcnt]==rAcnt)begin
			rDone <= 1;
			if(rFifoLast[rOcnt])rOcnt <= rIcnt;
			else				rOcnt <= rOcnt +'d1;
		end else begin
			rDone <= 0;
		end
		if(rFcnt[rOcnt]==rAcnt & rFifoLast[rOcnt])begin
			rRcnt <= 'd0;
			rAcnt <= 'd0;
		end else begin
			rRcnt <= rRcnt+rs;
			rAcnt <= rAcnt+'d1;
		end
	end
end
	assign out_rready	= in_rready;

	assign in_rvalid	= rDone;
	assign in_rid		= rDone?rFifoId		[rOcnt-1'd1]:'d0;
	assign in_rdata		= rDone?rFifoData	[rOcnt-1'd1]:'d0;
	assign in_rresp		= rDone?rFifoResp	[rOcnt-1'd1]:'d0;
	assign in_rlast		= rDone?rFifoLast	[rOcnt-1'd1]:'b0;

endmodule
