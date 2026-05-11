`include "ysyx_26020046_config.svh"
module ysyx_26020046(
	/*verilator lint_off UNUSED*/
		input	logic 		io_interrupt,

		input	logic		io_master_awready,
		output	logic		io_master_awvalid,
		output	logic[31:0]	io_master_awaddr,
		output	logic[3:0]	io_master_awid,
		output	logic[7:0]	io_master_awlen,
		output	logic[2:0]	io_master_awsize,
		output	logic[1:0]	io_master_awburst,
		input	logic		io_master_wready,
		output	logic		io_master_wvalid,
		output	logic[31:0]	io_master_wdata,
		output	logic[3:0]	io_master_wstrb,
		output	logic		io_master_wlast,
		output	logic		io_master_bready,
		input	logic		io_master_bvalid,
		input	logic[1:0]	io_master_bresp,
		input	logic[3:0]	io_master_bid,
		input	logic		io_master_arready,
		output	logic		io_master_arvalid,
		output	logic[31:0]	io_master_araddr,
		output	logic[3:0]	io_master_arid,
		output	logic[7:0]	io_master_arlen,
		output	logic[2:0]	io_master_arsize,
		output	logic[1:0]	io_master_arburst,
		output	logic		io_master_rready,
		input	logic		io_master_rvalid,
		input	logic[1:0]	io_master_rresp,
		input	logic[31:0]	io_master_rdata,
		input	logic		io_master_rlast,
		input	logic[3:0]	io_master_rid,
		
		output	logic		io_slave_awready,
		input	logic		io_slave_awvalid,
		input	logic[31:0]	io_slave_awaddr,
		input	logic[3:0]	io_slave_awid,
		input	logic[7:0]	io_slave_awlen,
		input	logic[2:0]	io_slave_awsize,
		input	logic[1:0]	io_slave_awburst,
		output	logic		io_slave_wready,
		input	logic		io_slave_wvalid,
		input	logic[31:0]	io_slave_wdata,
		input	logic[3:0]	io_slave_wstrb,
		input	logic		io_slave_wlast,
		input	logic		io_slave_bready,
		output	logic		io_slave_bvalid,
		output	logic[1:0]	io_slave_bresp,
		output	logic[3:0]	io_slave_bid,
		output	logic		io_slave_arready,
		input	logic		io_slave_arvalid,
		input	logic[31:0]	io_slave_araddr,
		input	logic[3:0]	io_slave_arid,
		input	logic[7:0]	io_slave_arlen,
		input	logic[2:0]	io_slave_arsize,
		input	logic[1:0]	io_slave_arburst,
		input	logic		io_slave_rready,
		output	logic		io_slave_rvalid,
		output	logic[1:0]	io_slave_rresp,
		output	logic[31:0]	io_slave_rdata,
		output	logic		io_slave_rlast,
		output	logic[3:0]	io_slave_rid,
		/*verilator lint_on UNUSED*/
	input logic clock,reset
	);

	always_comb begin
		wMeBak.awready		=io_master_awready;
		io_master_awvalid	=wMeCal.awvalid;
		io_master_awaddr	=wMeCal.awaddr;
		io_master_awid		='0;
		io_master_awlen		='0;
		io_master_awsize	='0;
		io_master_awburst	='0;
		wMeBak.wready		=io_master_wready;
		io_master_wvalid	=wMeCal.wvalid;
		io_master_wdata		=wMeCal.wdata;
		io_master_wstrb		=wMeCal.wstrb;
		io_master_wlast		='0;
		io_master_bready	=wMeCal.bready;
		wMeBak.bvalid		=io_master_bvalid;
		wMeBak.bresp		=resp_t'(io_master_bresp);
		// wMeBak.		=io_master_bid;
		rMeBak.arready		=io_master_arready;
		io_master_arvalid	=rMeCal.arvalid;
		io_master_araddr	=rMeCal.araddr;
		io_master_arid		='0;
		io_master_arlen		='0;
		io_master_arsize	='0;
		io_master_arburst	='0;
		io_master_rready	=rMeCal.rready;
		rMeBak.rvalid		=io_master_rvalid;
		rMeBak.rresp		=resp_t'(io_master_rresp);
		rMeBak.rdata		=io_master_rdata;
		// rMeBak.	=io_master_rlast;
		// rMeBak.	=io_master_rid;

		io_slave_awready	='0;
		io_slave_bvalid		='0;
		io_slave_bresp		='0;
		io_slave_bid		='0;
		io_slave_arready	='0;
		io_slave_rvalid		='0;
		io_slave_rresp		='0;
		io_slave_rdata		='0;
		io_slave_rlast		='0;
		io_slave_rid		='0;
	end

	// initial $display("%m");

	IfId_t nIfId;upBk_t iAlId;
	IdAl_t nIdAl;upBk_t iIdIf;valcl_t vIdAl;
	AlLs_t nAlLs;LsAl_t iLsAl;valcl_t vAlLs;
	LsRg_t nLsRg;RgLs_t iRgLs;valcl_t vLsRg;

	AXI4rCal_t rIfCal;AXI4rBak_t rIfBak;
	AXI4rCal_t rLsCal;AXI4rBak_t rLsBak;
	AXI4wCal_t wLsCal;AXI4wBak_t wLsBak;
	AXI4rCal_t rCtCal;AXI4rBak_t rCtBak;
	AXI4wCal_t wCtCal;AXI4wBak_t wCtBak;
	AXI4rCal_t rMeCal;AXI4rBak_t rMeBak;
	AXI4wCal_t wMeCal;AXI4wBak_t wMeBak;

	ysyx_26020046_CLT CLT(.*);
	ysyx_26020046_ARB ARB(.*);
	ysyx_26020046_IFU IFU(.*);
	ysyx_26020046_IDU IDU(.*);
	ysyx_26020046_ALU ALU(.*);
	ysyx_26020046_LSU LSU(.*);
	ysyx_26020046_REG REG(.*);

	// `ifndef RV32I_STA always_ff@(posedge clock)difftest<=iIdIf.ready&nIfId.valid;`endif
	`ifdef RV32I_DEBUG
		initial begin
			logFile = $fopen("log/rv32iDebugLog.txt");
			$write("\033[1;35m SV_DEBUG \033[0m");
			// $fstrobe
		end
		always @(posedge clock) begin if(~reset)begin
			// $fdisplay(logFile,"rMeCal:%s",sAXI4rCal(rMeCal));$fdisplay(logFile,"rMeBak:%s",sAXI4rBak(rMeBak));
			// $fdisplay(logFile,"wMeCal:%s",sAXI4wCal(wMeCal));$fdisplay(logFile,"wMeBak:%s",sAXI4wBak(wMeBak));
			// $fdisplay(logFile,"rIfCal:%s",sAXI4rCal(rIfCal));$fdisplay(logFile,"rIfBak:%s",sAXI4rBak(rIfBak));
			// $fdisplay(logFile,"rLsCal:%s",sAXI4rCal(rLsCal));$fdisplay(logFile,"rLsBak:%s",sAXI4rBak(rLsBak));
			// $fdisplay(logFile,"wLsCal:%s",sAXI4wCal(wLsCal));$fdisplay(logFile,"wLsBak:%s",sAXI4wBak(wLsBak));
			// $fdisplay(logFile,"nIfId:%s",sIfId(nIfId));$fdisplay(logFile,"iIdIf:%s",sUpBk(iIdIf));
			// $fdisplay(logFile,"nIdAl:%s",sIdAl(nIdAl));$fdisplay(logFile,"iAlId:%s",sUpBk(iAlId));$fdisplay(logFile,"vIdAl:%s",sValcal(vIdAl));
			// $fdisplay(logFile,"nAlLs:%s",sAlLs(nAlLs));$fdisplay(logFile,"iLsAl:%s",sLsAl(iLsAl));$fdisplay(logFile,"vAlLs:%s",sValcal(vAlLs));
			// $fdisplay(logFile,"nLsRg:%s",sLsRg(nLsRg));$fdisplay(logFile,"iRgLs:%s",sRgLs(iRgLs));$fdisplay(logFile,"vLsRg:%s",sValRg(vLsRg));
			// $fdisplay(logFile,"nRgCt:%s",sLsSr(nLsSr));$fdisplay(logFile,"iCtRg:%s",sSrLs(iSrLs));$fdisplay(logFile,"vRgCt:%s",sValSr(vLsSr));

			$fdisplay(logFile,"nIdAl:%s",sIdAl(nIdAl));$fdisplay(logFile,"iAlId:%s",sUpBk(iAlId));$fdisplay(logFile,"vIdAl:%s",sValcal(vIdAl));
			$fdisplay(logFile,"nAlLs:%s",sAlLs(nAlLs));$fdisplay(logFile,"iLsAl:%s",sLsAl(iLsAl));$fdisplay(logFile,"vAlLs:%s",sValcal(vAlLs));
			
			// $fstrobe(logFile,"rMeCal:%s",sAXI4rCal(rMeCal));$fstrobe(logFile,"rMeBak:%s",sAXI4rBak(rMeBak));
			// $fstrobe(logFile,"wMeCal:%s",sAXI4wCal(wMeCal));$fstrobe(logFile,"wMeBak:%s",sAXI4wBak(wMeBak));
			// $fstrobe(logFile,"rIfCal:%s",sAXI4rCal(rIfCal));$fstrobe(logFile,"rIfBak:%s",sAXI4rBak(rIfBak));
			// $fstrobe(logFile,"rLsCal:%s",sAXI4rCal(rLsCal));$fstrobe(logFile,"rLsBak:%s",sAXI4rBak(rLsBak));
			// $fstrobe(logFile,"wLsCal:%s",sAXI4wCal(wLsCal));$fstrobe(logFile,"wLsBak:%s",sAXI4wBak(wLsBak));
			// $fstrobe(logFile,"nIfId:%s",sIfId(nIfId));$fstrobe(logFile,"iIdIf:%s",sUpBk(iIdIf));
			// $fstrobe(logFile,"nIdAl:%s",sIdAl(nIdAl));$fstrobe(logFile,"iAlId:%s",sUpBk(iAlId));$fstrobe(logFile,"vIdAl:%s",sValcal(vIdAl));
			// $fstrobe(logFile,"nAlLs:%s",sAlLs(nAlLs));$fstrobe(logFile,"iLsAl:%s",sLsAl(iLsAl));$fstrobe(logFile,"vAlLs:%s",sValcal(vAlLs));
			// $fstrobe(logFile,"nLsRg:%s",sLsRg(nLsRg));$fstrobe(logFile,"iRgLs:%s",sRgLs(iRgLs));$fstrobe(logFile,"vLsRg:%s",sValRg(vLsRg));
			// $fstrobe(logFile,"nRgCt:%s",sLsSr(nLsSr));$fstrobe(logFile,"iCtRg:%s",sSrLs(iSrLs));$fstrobe(logFile,"vRgCt:%s",sValSr(vLsSr));
		end end
	`endif
	
	`ifndef RV32I_STA logic difftest;always_ff@(posedge clock)difftest<=iIdIf.ready&nIfId.valid;
		export "DPI-C" function getReg;export "DPI-C" function getPc;export "DPI-C" function chkDft;
		function int getReg(input int addr);return (addr == 0) ? '0 : REG.gpr[addr];endfunction
		function int getPc();return nIfId.pc;endfunction
		function bit chkDft();return difftest;endfunction
		`endif
    endmodule