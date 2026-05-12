`include "ysyx_26020046_config.svh"
module ysyx_26020046_CLT(
	input  AXI4rCal_t rCtCal,
	input  AXI4wCal_t wCtCal,
	output AXI4rBak_t rCtBak,
	output AXI4wBak_t wCtBak,
	input clock,reset
	);
	// word_t mtime,mtimeh;
	word_t clint['h2fff:'h2ffe];
	CLTsatus_t s,ns;
	logic hasAddr,hasData;
	word_t araddr,awaddr,wdata;
	mask_t wstrb;
	always_comb unique case(s)
		CLTidle:unique case('1)
			rCtCal.arvalid:ns=CLTrbak;
			(wCtCal.awvalid|hasAddr)&(wCtCal.wvalid|hasData):ns=CLTwbak;
			default:ns=CLTidle;endcase
		CLTrbak:ns=(rCtCal.rready)?CLTidle:CLTrbak;
		CLTwbak:ns=(wCtCal.bready)?CLTidle:CLTwbak;
		default:ns=CLTidle;
	endcase always_ff@(posedge clock) if(reset)s<=CLTidle;else s<=ns;
	always_ff@(posedge clock)begin
		if(s==CLTidle&rCtCal.arvalid)araddr<=rCtCal.araddr;

		if(s==CLTidle&wCtCal.awvalid)awaddr<=wCtCal.awaddr;
		if(s==CLTidle&wCtCal.awvalid)hasAddr<=1;
		if(s==CLTwbak)hasAddr<=0;
		if(s==CLTidle&wCtCal.wvalid)wdata<=wCtCal.wdata;
		if(s==CLTidle&wCtCal.wvalid)wstrb<=wCtCal.wstrb;
		if(s==CLTidle&wCtCal.wvalid)hasData<=1;
		if(s==CLTwbak)hasData<=0;

		if(reset){clint['h2fff],clint['h2ffe]}<='0;
		else begin	{clint['h2fff],clint['h2ffe]}<={clint['h2fff],clint['h2ffe]}+1;
					if(s==CLTwbak)	clint[awaddr[31:2]]<=wdata;end
	end always_comb begin
		rCtBak.arready	=(s==CLTidle);
		rCtBak.rvalid	=(s==CLTrbak);
		rCtBak.rdata	=(s==CLTrbak)?clint[araddr[31:2]]:'0;
		rCtBak.rresp	=(araddr[1:0]=='0)?OKAY:EXOKAY;

		wCtBak.awready	=(s==CLTidle);
		wCtBak.wready	=(s==CLTwbak);
		wCtBak.bvalid	=(s==CLTwbak);
		wCtBak.bresp	=(awaddr[1:0]=='0&wstrb==4'b1111)?OKAY:EXOKAY;
	end
    endmodule
