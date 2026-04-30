`define RV32I_DEBUG
	// `define RV32I_STA

	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter false = 0;
	parameter true = 1;

	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;

	parameter PC_RESET	= 32'h80000000;
	parameter MSTATUS_RESET = 32'h1800;

	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;
	typedef logic [11:0] SRaddr_t;
	typedef logic [3:0] mask_t;

	typedef enum logic[3:0] {ADD_,SLL_,SLT_,SLTU,XOR_,SRL_,OR__,AND_,SUB_,SRA_,NCAL} ALUopCal_t;
	typedef enum logic[2:0] {BEQ_,BNE_,NBFU,BLT_='b100,BGE_,BLTU='b110,BGEU} ALUopBfu_t;
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NACSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[2:0] {NCHO,CAL_,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[0:0] {IR1,PC_} in1_t;
	typedef enum logic[0:0] {IR2,IMM} in2_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;

	typedef struct packed {
		logic [6:0] fun7;
		logic [4:0] r2;
		logic [4:0] r1;
		logic [2:0] fun3;
		logic [4:0] rd;
		logic [6:0] op;
	} code_t;

	typedef enum logic [1:0]{IFUback,IFUcall,IFUfunc}			IFUstatus_t;
	typedef enum logic [1:0]{LSUback,LSUcall,LSUidle,LSUsuce}	LSUstatus_t;
	typedef enum logic [1:0]{MEMidle,MEMfunc,MEMback,MEMwait}	MEMstatus_t;
	typedef enum logic [1:0]{ARBidle,ARBifuR,ARBlsuR,ARBlsuW}	ARBstatus_t;
	typedef enum logic [1:0]{CLTidle,CLTrbak,CLTwbak}			CLTsatus_t;

	typedef enum logic [1:0]{OKAY,EXOKAY,SLVERR,DECERR} resp_t;//TODO 目前是只有OKAY有用
	`ifdef RV32I_DEBUG integer logFile;`endif
	`ifndef RV32I_STA
	import "DPI-C" function void stop(input bit eb);
	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
	`endif

	typedef struct packed {logic valid;code_t code;word_t pc;} IfId_t;
	typedef struct packed {
		logic valid;

		in1_t		in1;
		in2_t		in2;
		logic 		enJcod;
		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	cCsr;
		ALUopCho_t	cIrd;

		logic enS,enL;
		LSUop_t LSop;

		reg_t cRd;
		
		SRaddr_t SRaddr;
		CSRop_t SRop;

		word_t imm,pc;
	} IdAl_t;
	typedef struct packed {reg_t cR1,cR2;SRaddr_t SRaddr;}																		valcl_t;
	typedef struct packed {word_t addr;logic enJfun,ready;}																		upBk_t;
	typedef struct packed {logic valid,enS,enL;word_t addr,res,iCsr,oR2;LSUop_t LSop;SRaddr_t SRaddr;CSRop_t SRop;reg_t cRd;}	AlLs_t;
	typedef struct packed {logic ready;word_t oR1,oR2;word_t oCsr;}																LsAl_t;
	typedef struct packed {word_t iRd;reg_t cRd;logic valid;}																	LsRg_t;
	typedef struct packed {word_t iCsr;SRaddr_t SRaddr;CSRop_t SRop;logic valid;}												LsSr_t;
	typedef struct packed {logic ready;word_t oCsr;}																			SrLs_t;
	typedef struct packed {logic ready;word_t oR1,oR2;}																			RgLs_t;
	typedef struct packed {reg_t cR1,cR2;}																						valRg_t;
	typedef struct packed {SRaddr_t SRaddr;}																					valSr_t;
	typedef struct packed {logic arvalid,rready;word_t araddr;}																	AXI4rCal_t;
	typedef struct packed {logic awvalid,wvalid,bready;word_t awaddr,wdata;mask_t wstrb;}										AXI4wCal_t;
	typedef struct packed {logic arready;word_t rdata;resp_t rresp;logic rvalid;}												AXI4rBak_t;
	typedef struct packed {logic awready,wready,bvalid;resp_t bresp;}															AXI4wBak_t;

	`ifndef RV32I_STA
	function string sIfId(IfId_t i);return $sformatf("valid=%b,code=%x,pc=%x",i.valid,i.code,i.pc);endfunction
	function string sIdAl(IdAl_t i);return $sformatf("valid=%b in1=%s in2=%s enJ=%b cal=%s bfu=%s adr=%s csr=%s iRd=%s enS=%b enL=%b LSop=%s cRd=%x SRaddr=%x SRop=%s imm=%x pc=%x",i.valid,i.in1.name(),i.in2.name(),i.enJcod,i.cal.name(),i.bfu.name(),i.adr.name(),i.cCsr.name(),i.cIrd.name(),i.enS,i.enL,i.LSop.name(),i.cRd,i.SRaddr,i.SRop.name(),i.imm,i.pc);endfunction
	function string sValcal(valcl_t i);return $sformatf("cR1=%x cR2=%x SRaddr=%x",i.cR1,i.cR2,i.SRaddr);endfunction
	function string sUpBk(upBk_t i);return $sformatf("addr=%x enJ=%b ready=%b",i.addr,i.enJfun,i.ready);endfunction
	function string sAlLs(AlLs_t i);return $sformatf("valid=%b enS=%b enL=%b addr=%x res=%x iCsr=%x oR2=%x LSop=%x SRaddr=%x SRop=%s cRd=%x",i.valid,i.enS,i.enL,i.addr,i.res,i.iCsr,i.oR2,i.LSop,i.SRaddr,i.SRop.name(),i.cRd);endfunction
	function string sLsAl(LsAl_t i);return $sformatf("ready=%b oR1=%x oR2=%x oCsr=%x",i.ready,i.oR1,i.oR2,i.oCsr);endfunction
	function string sLsRg(LsRg_t i);return $sformatf("valid=%b iRd=%x cRd=%x",i.valid,i.iRd,i.cRd);endfunction
	function string sLsSr(LsSr_t i);return $sformatf("valid=%b iCsr=%x SRaddr=%x SRop=%s",i.valid,i.iCsr,i.SRaddr,i.SRop.name());endfunction
	function string sSrLs(SrLs_t i);return $sformatf("ready=%b oCsr=%x",i.ready,i.oCsr);endfunction
	function string sRgLs(RgLs_t i);return $sformatf("ready=%b oR1=%x oR2=%x",i.ready,i.oR1,i.oR2);endfunction
	function string sValRg(valRg_t i);return $sformatf("cR1=%x cR2=%x",i.cR1,i.cR2);endfunction
	function string sValSr(valSr_t i);return $sformatf("SRaddr=%x",i.SRaddr);endfunction
	function string sAXI4rCal(AXI4rCal_t i);return $sformatf("arvalid=%b rready=%b araddr=%x",i.arvalid,i.rready,i.araddr);endfunction
	function string sAXI4wCal(AXI4wCal_t i);return $sformatf("awvalid=%b wvalid=%b bready=%b awaddr=%x wdata=%x wstrb=%b",i.awvalid,i.wvalid,i.bready,i.awaddr,i.wdata,i.wstrb);endfunction
	function string sAXI4rBak(AXI4rBak_t i);return $sformatf("arready=%b rdata=%x rresp=%s rvalid=%b rready=%b",i.arready,i.rdata,i.rresp.name(),i.rvalid,i.arready);endfunction
	function string sAXI4wBak(AXI4wBak_t i);return $sformatf("awready=%b wready=%b bvalid=%b bresp=%s",i.awready,i.wready,i.bvalid,i.bresp.name());endfunction
	`endif

module ysyx_26020046_rv32i(
	`ifdef RV32I_STA
		output AXI4rCal_t rMeCal,
		output AXI4wCal_t wMeCal,
		input  AXI4rBak_t rMeBak,
		input  AXI4wBak_t wMeBak,
	`else
		output logic difftest,
	`endif
	input logic clk,reset
	);

	IfId_t nIfId;upBk_t iAlId;
	IdAl_t nIdAl;upBk_t iIdIf;valcl_t vIdAl;
	AlLs_t nAlLs;LsAl_t iLsAl;valcl_t vAlLs;
	LsRg_t nLsRg;RgLs_t iRgLs;valRg_t vLsRg;
	LsSr_t nLsSr;SrLs_t iSrLs;valSr_t vLsSr;

	AXI4rCal_t rIfCal;AXI4rBak_t rIfBak;
	AXI4rCal_t rLsCal;AXI4rBak_t rLsBak;
	AXI4wCal_t wLsCal;AXI4wBak_t wLsBak;
	AXI4rCal_t rCtCal;AXI4rBak_t rCtBak;
	AXI4wCal_t wCtCal;AXI4wBak_t wCtBak;

	`ifndef RV32I_STA
		AXI4rCal_t rMeCal;AXI4rBak_t rMeBak;
		AXI4wCal_t wMeCal;AXI4wBak_t wMeBak;
		ysyx_26020046_rv32iMEM MEM(.*);
		AXI4wCal_t wUaCal;AXI4wBak_t wUaBak;
		ysyx_26020046_rv32iUAR UAR(.*);
	`endif
	ysyx_26020046_rv32iCLT CLT(.*);
	ysyx_26020046_rv32iARB ARB(.*);
	ysyx_26020046_rv32iIFU IFU(.*);
	ysyx_26020046_rv32iIDU IDU(.*);
	ysyx_26020046_rv32iALU ALU(.*);
	ysyx_26020046_rv32iLSU LSU(.*);
	ysyx_26020046_rv32iGPR GPR(.*);
	ysyx_26020046_rv32iCSR CSR(.*);

	`ifndef RV32I_STA always_ff@(posedge clk)difftest<=iIdIf.ready&nIfId.valid;`endif
	`ifdef RV32I_DEBUG
		initial begin
			logFile = $fopen("log/rv32iDebugLog.txt");
			$write("\033[1;35m SV_DEBUG \033[0m");
			// $fstrobe
		end
		always @(posedge clk) begin if(~reset)begin
			$fdisplay(logFile,"rMeCal:%s",sAXI4rCal(rMeCal));$fdisplay(logFile,"rMeBak:%s",sAXI4rBak(rMeBak));
			$fdisplay(logFile,"wMeCal:%s",sAXI4wCal(wMeCal));$fdisplay(logFile,"wMeBak:%s",sAXI4wBak(wMeBak));
			$fdisplay(logFile,"rIfCal:%s",sAXI4rCal(rIfCal));$fdisplay(logFile,"rIfBak:%s",sAXI4rBak(rIfBak));
			$fdisplay(logFile,"rLsCal:%s",sAXI4rCal(rLsCal));$fdisplay(logFile,"rLsBak:%s",sAXI4rBak(rLsBak));
			$fdisplay(logFile,"wLsCal:%s",sAXI4wCal(wLsCal));$fdisplay(logFile,"wLsBak:%s",sAXI4wBak(wLsBak));
			$fdisplay(logFile,"nIfId:%s",sIfId(nIfId));$fdisplay(logFile,"iIdIf:%s",sUpBk(iIdIf));
			$fdisplay(logFile,"nIdAl:%s",sIdAl(nIdAl));$fdisplay(logFile,"iAlId:%s",sUpBk(iAlId));$fdisplay(logFile,"vIdAl:%s",sValcal(vIdAl));
			$fdisplay(logFile,"nAlLs:%s",sAlLs(nAlLs));$fdisplay(logFile,"iLsAl:%s",sLsAl(iLsAl));$fdisplay(logFile,"vAlLs:%s",sValcal(vAlLs));
			$fdisplay(logFile,"nLsRg:%s",sLsRg(nLsRg));$fdisplay(logFile,"iRgLs:%s",sRgLs(iRgLs));$fdisplay(logFile,"vLsRg:%s",sValRg(vLsRg));
			$fdisplay(logFile,"nRgCt:%s",sLsSr(nLsSr));$fdisplay(logFile,"iCtRg:%s",sSrLs(iSrLs));$fdisplay(logFile,"vRgCt:%s",sValSr(vLsSr));
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
	
	`ifndef RV32I_STA
	export "DPI-C" function getReg;
	function int getReg(input int addr);
		return (addr == 0) ? '0 : GPR.gpr[addr];
	endfunction
	export "DPI-C" function getPc;
	function int getPc();
		return nIfId.pc;
	endfunction `endif
	endmodule
module ysyx_26020046_rv32iUAR(
	input  AXI4wCal_t wUaCal,
	output AXI4wBak_t wUaBak,
	input clk,reset
	);
	MEMstatus_t Ws,nWs;
	word_t awaddr,wdata;
	mask_t wstrb;
	logic hasAddr,hasData;
	always_comb unique case(Ws)
			MEMidle:nWs=(wUaCal.awvalid|hasAddr)&(wUaCal.wvalid|hasData)?MEMfunc:MEMidle;
			MEMfunc:nWs=MEMback;
			MEMback:nWs=(wUaCal.bready)?MEMidle:MEMback;
			default:nWs=MEMidle;
	endcase always_ff@(posedge clk) if(reset)begin
			Ws	<=MEMidle;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"%m:Ws=%s,nWs=%s",Ws.name(),nWs.name());`endif
			Ws	<=nWs;
	end always_ff @(posedge clk) begin
		if(wUaBak.awready&wUaCal.awvalid)	awaddr	<=wUaCal.awaddr;
		if(wUaBak.awready&wUaCal.awvalid)	hasAddr<=1'b1;
		if(Ws==MEMback)						hasAddr<=1'b0;
		if(wUaBak.wready &wUaCal.wvalid)	wdata	<=wUaCal.wdata;
		if(wUaBak.wready &wUaCal.wvalid)	wstrb	<=wUaCal.wstrb;
		if(wUaBak.wready &wUaCal.wvalid)	hasData<=1'b1;
		if(Ws==MEMback)						hasData<=1'b0;
		if(Ws==MEMfunc)`ifdef RV32I_DEBUG $fdisplay(logFile,"%m:write [%x] <(%b)= %x",awaddr,wstrb,wdata);`endif	
		if(Ws==MEMfunc)$write("%s",wdata[7:0]);
	end always_comb begin
		wUaBak.awready	=(Ws==MEMidle&!hasAddr);
		wUaBak.wready	=(Ws==MEMidle&!hasData);
		wUaBak.bresp	=(awaddr=='h10000000&wstrb==4'b1111)?OKAY:(wdata=='0?EXOKAY:EXOKAY);
		wUaBak.bvalid	=(Ws==MEMback);
	end
	endmodule
module ysyx_26020046_rv32iCLT(
	input  AXI4rCal_t rCtCal,
	input  AXI4wCal_t wCtCal,
	output AXI4rBak_t rCtBak,
	output AXI4wBak_t wCtBak,
	input clk,reset
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
	endcase always_ff@(posedge clk) if(reset)s<=CLTidle;else s<=ns;
	always_ff@(posedge clk)begin
		if(s==CLTidle&rCtCal.arvalid)araddr<=rCtCal.araddr;

		if(s==CLTidle&wCtCal.awvalid)awaddr<=wCtCal.awaddr;
		if(s==CLTidle&wCtCal.awvalid)hasAddr<=true;
		if(s==CLTwbak)hasAddr<=false;
		if(s==CLTidle&wCtCal.wvalid)wdata<=wCtCal.wdata;
		if(s==CLTidle&wCtCal.wvalid)wstrb<=wCtCal.wstrb;
		if(s==CLTidle&wCtCal.wvalid)hasData<=true;
		if(s==CLTwbak)hasData<=false;

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
`ifndef RV32I_STA module ysyx_26020046_rv32iMEM(
	input  AXI4rCal_t rMeCal,
	input  AXI4wCal_t wMeCal,
	output AXI4rBak_t rMeBak,
	output AXI4wBak_t wMeBak,
	input clk,reset
	);
	MEMstatus_t Rs,nRs,Ws,nWs;
	word_t rCnt,wCnt;//cnt会加3，这是因为会经过三段状态转移有三周期延迟
	parameter rMax = 10;
	parameter wMax = 10;
	word_t araddr,awaddr,wdata;
	mask_t wstrb;
	logic hasAddr,hasData;
	always_comb unique case(Rs)
			MEMidle:nRs=(rMeCal.arvalid)?MEMwait:MEMidle;
			MEMwait:nRs=(rCnt+3<rMax )	?MEMwait:MEMfunc;
			MEMfunc:nRs=MEMback;
			MEMback:nRs=(rMeCal.rready )?MEMidle:MEMback;
			default:nRs=MEMidle;
	endcase	always_ff@(posedge clk) if(reset)begin
			Rs	<=MEMidle;
			rCnt<=0;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"%m:Rs=%s,nRs=%s rCnt=%d",Rs.name(),nRs.name(),rCnt);`endif
			Rs	<=nRs;
			rCnt<=(Rs==MEMwait)?rCnt+1:0;
	end always_ff@(posedge clk)begin
		if(rMeBak.arready&rMeCal.arvalid)araddr<=rMeCal.araddr;
		if(Rs==MEMfunc)rMeBak.rdata<=pmem_read(araddr);
		`ifdef RV32I_DEBUG if(Rs==MEMfunc)$fdisplay(logFile,"%m:read [%x]==%x",araddr,rMeBak.rdata);`endif
	end always_comb begin
		rMeBak.arready=(Rs==MEMidle);
		rMeBak.rresp=OKAY;
		rMeBak.rvalid=(Rs==MEMback);
	end

	always_comb unique case(Ws)
			MEMidle:nWs=(wMeCal.awvalid|hasAddr)&(wMeCal.wvalid|hasData)?MEMwait:MEMidle;
			MEMwait:nWs=(wCnt+3<wMax)?MEMwait:MEMfunc;
			MEMfunc:nWs=MEMback;
			MEMback:nWs=(wMeCal.bready)?MEMidle:MEMback;
			default:nWs=MEMidle;
	endcase always_ff@(posedge clk) if(reset)begin
			Ws	<=MEMidle;
			wCnt<=0;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"%m:Ws=%s,nWs=%s wCnt=%d",Ws.name(),nWs.name(),wCnt);`endif
			Ws	<=nWs;
			wCnt<=(Ws==MEMwait)?wCnt+1:0;
	end always_ff @(posedge clk) begin
		if(wMeBak.awready&wMeCal.awvalid)	awaddr	<=wMeCal.awaddr;
		if(wMeBak.awready&wMeCal.awvalid)	hasAddr<=1'b1;
		if(Ws==MEMback)						hasAddr<=1'b0;
		if(wMeBak.wready &wMeCal.wvalid)	wdata	<=wMeCal.wdata;
		if(wMeBak.wready &wMeCal.wvalid)	wstrb	<=wMeCal.wstrb;
		if(wMeBak.wready &wMeCal.wvalid)	hasData<=1'b1;
		if(Ws==MEMback)						hasData<=1'b0;
		if(Ws==MEMfunc)`ifdef RV32I_DEBUG $fdisplay(logFile,"%m:write [%x] <(%b)= %x",awaddr,wstrb,wdata);`endif	
		if(Ws==MEMfunc)pmem_write(awaddr,wdata,{4'b0,wstrb});
	end always_comb begin
		wMeBak.awready	=(Ws==MEMidle&!hasAddr);
		wMeBak.wready	=(Ws==MEMidle&!hasData);
		wMeBak.bresp	=OKAY;
		wMeBak.bvalid	=(Ws==MEMback);
	end
	endmodule`endif
module ysyx_26020046_rv32iARB(
	input  AXI4rCal_t rIfCal,
	output AXI4rBak_t rIfBak,
	input  AXI4rCal_t rLsCal,output AXI4rBak_t rLsBak,
	input  AXI4wCal_t wLsCal,output AXI4wBak_t wLsBak,
	input  AXI4rBak_t rMeBak,input  AXI4wBak_t wMeBak,
	output AXI4rCal_t rMeCal,output AXI4wCal_t wMeCal,
	input  AXI4wBak_t wUaBak,output AXI4wCal_t wUaCal,
	input  AXI4rBak_t rCtBak,input  AXI4wBak_t wCtBak,
	output AXI4rCal_t rCtCal,output AXI4wCal_t wCtCal,
	input clk,reset
	);
	ARBstatus_t s,ns;
	// /*verilator lint_off UNUSEDSIGNAL */word_t addr;/*verilator lint_on UNUSEDSIGNAL */
	logic [31:16] addr;
	logic backvalid;
	always_comb	unique case(s)//TODO 现在默认是LSU不会同时读写
			ARBidle: if(rLsCal.arvalid)ns=ARBlsuR;
				else if(wLsCal.awvalid)ns=ARBlsuW;
				else if(wLsCal.wvalid )ns=ARBlsuW;
				else if(rIfCal.arvalid)ns=ARBifuR;
				else ns=ARBidle;
			ARBlsuR:ns=(rLsCal.rready&backvalid)?ARBidle:ARBlsuR;
			ARBlsuW:ns=(wLsCal.bready&backvalid)?ARBidle:ARBlsuW;
			ARBifuR:ns=(rIfCal.rready&backvalid)?ARBidle:ARBifuR;
			default:ns=ARBidle;
	endcase always_ff@(posedge clk)if(reset)begin
			s<=ARBidle;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"ARB:s=%s,ns=%s",s.name(),ns.name());`endif
			s<=ns;
	end always_ff@(posedge clk)begin
		if(s==ARBidle&ns==ARBlsuR)	addr<=rLsCal.araddr[31:16];
		if(s==ARBidle&ns==ARBlsuW)	addr<=wLsCal.awaddr[31:16];
		if(s==ARBidle&ns==ARBifuR)	addr<=rIfCal.araddr[31:16];
		if(ns==ARBidle)				addr<='0;
	end always_comb begin
		//默认折叠
			rMeCal.araddr	='0;
			rMeCal.arvalid	=false;
			rMeCal.rready	=false;
			wMeCal.awaddr	='0;
			wMeCal.awvalid	=false;
			wMeCal.wdata	='0;
			wMeCal.wstrb	='0;
			wMeCal.wvalid	=false;
			wMeCal.bready	=false;
			
			rCtCal.araddr	='0;
			rCtCal.arvalid	=false;
			rCtCal.rready	=false;
			wCtCal.awaddr	='0;
			wCtCal.awvalid	=false;
			wCtCal.wdata	='0;
			wCtCal.wstrb	='0;
			wCtCal.wvalid	=false;
			wCtCal.bready	=false;

			rLsBak.arready	=false;
			rLsBak.rdata	='0;
			rLsBak.rresp	=OKAY;
			rLsBak.rvalid	=false;
			wLsBak.awready	=false;
			wLsBak.wready	=false;
			wLsBak.bresp	=OKAY;
			wLsBak.bvalid	=false;

			rIfBak.arready	=false;
			rIfBak.rdata	='0;
			rIfBak.rresp	=OKAY;
			rIfBak.rvalid	=false;
		// $fdisplay(logFile,"ARB:s=%s,ns=%s ifr %xx:%x",s.name(),ns.name(),rIfCal.araddr[31:24],8'h80);
		unique case(s)
			ARBidle:;
			ARBlsuR:unique case('1)
				// addr[31:24]== 8'h10  :begin rMeCal=rLsCal;rLsBak=rMeBak;end//目前还不允许读UART
				addr[31:24]== 8'h80  :begin rMeCal=rLsCal;rLsBak=rMeBak;backvalid=rMeBak.rvalid;end
				addr[31:16]==16'h0200:begin rCtCal=rLsCal;rLsBak=rCtBak;backvalid=rCtBak.rvalid;end
				default:begin rLsBak.arready=true;rLsBak.rdata='0;rLsBak.rresp=EXOKAY;rLsBak.rvalid=true;end endcase
			ARBlsuW:unique case('1)
				addr[31:24]== 8'h80  :begin wMeCal=wLsCal;wLsBak=wMeBak;backvalid=wMeBak.bvalid;end
				addr[31:24]== 8'h10  :begin wUaCal=wLsCal;wLsBak=wUaBak;backvalid=wUaBak.bvalid;end
				addr[31:16]==16'h0200:begin wCtCal=wLsCal;wLsBak=wCtBak;backvalid=wCtBak.bvalid;end
				default:begin wLsBak.awready=true;wLsBak.wready=true;wLsBak.bresp=EXOKAY;wLsBak.bvalid=true;end endcase
			ARBifuR: if(addr[31:24]==8'h80)begin rMeCal=rIfCal;rIfBak=rMeBak;backvalid=rMeBak.rvalid;end
				else begin rIfBak.arready=true;rIfBak.rdata='0;rIfBak.rresp=EXOKAY;rIfBak.rvalid=true;end
	endcase end
	endmodule
module ysyx_26020046_rv32iIFU(
	input  AXI4rBak_t	rIfBak,
	output AXI4rCal_t	rIfCal,
	output IfId_t		nIfId,
	input  upBk_t		iIdIf,
	input logic clk,reset
	);

	IFUstatus_t ns,s;
	always_comb	unique case(s)//两段状态转移会有1周期延迟
			IFUfunc:ns=iIdIf.ready		?IFUcall:IFUfunc;
			IFUcall:ns=rIfBak.arready	?IFUback:IFUcall;
			IFUback:ns=rIfBak.rvalid	?IFUfunc:IFUback;
			default:ns=IFUcall;
	endcase always_ff@(posedge clk)if(reset)begin
			s<=IFUcall;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"IFU:s=%s,ns=%s ready=%b",s.name(),ns.name(),iIdIf.ready);`endif
			s<=ns;
	end always_comb begin : out
		rIfCal.araddr=nIfId.pc;
		rIfCal.arvalid=(s==IFUcall);

		rIfCal.rready=(s==IFUback);
	end
	always_ff@(posedge clk)begin
		if(s==IFUback&ns==IFUfunc)nIfId.code<=rIfBak.rdata;
	end
	always_comb begin : in
		// nIfId.code=sbIf.rdata;
		if(s==IFUback)case(rIfBak.rresp)
			OKAY	:;
			default	:begin `ifndef RV32I_STA $error("rIfBak.rresp=%s:",rIfBak.rresp.name());$stop();`endif end
		endcase

		nIfId.valid=(s==IFUfunc);
	end
	always_ff @(posedge clk) begin : pc
		`ifdef RV32I_DEBUG if(iIdIf.enJfun) $fdisplay(logFile,"PC:%x => %x",nIfId.pc,iIdIf.addr);`endif
		if(reset) nIfId.pc<=PC_RESET;
		else if(nIfId.valid&iIdIf.ready)begin
			if(iIdIf.enJfun) nIfId.pc<=(iIdIf.addr&32'hFFFFFFFC);
			else nIfId.pc<=nIfId.pc+4;
		end
	end
	endmodule
module ysyx_26020046_rv32iIDU(
	input  IfId_t  nIfId,
	output upBk_t  iIdIf,
	output valcl_t vIdAl,
	output IdAl_t  nIdAl,
	input  upBk_t  iAlId
	);
	//OP宏定义
		parameter OP_I_J	= 7'b1100111;//jalr
		parameter OP_I_A	= 7'b0010011;//i运算
		parameter OP_I_L	= 7'b0000011;//l系列
		parameter OP_U_I	= 7'b0110111;//lui
		parameter OP_U_P	= 7'b0010111;//auipc
		parameter OP_S__	= 7'b0100011;//s系列
		parameter OP_B__	= 7'b1100011;//b比较系列
		parameter OP_J__	= 7'b1101111;//jal
		parameter OP_R__ 	= 7'b0110011;//r运算
		parameter OP_CSR	= 7'b1110011;//CSR系列

		parameter OP_CSR_ECALL_	= 32'h00000073;
		parameter OP_CSR_EBREAK	= 32'h00100073;
		parameter OP_CSR_MRET__	= 32'h30200073;
	IfId_t oIfId;

	always_comb oIfId=nIfId;

	always_comb begin
		nIdAl.valid	=oIfId.valid;
		nIdAl.pc	=oIfId.pc;
		iIdIf.addr	=iAlId.addr;
		iIdIf.enJfun=iAlId.enJfun;
		iIdIf.ready	=iAlId.ready;
	end
	always_comb begin : ID
		nIdAl.in1=IR1;nIdAl.in2=IR2;
		nIdAl.adr=NAD;nIdAl.cal=NCAL;nIdAl.bfu=NBFU;
		nIdAl.cCsr=NACSR;nIdAl.cIrd=NCHO;
		nIdAl.LSop=NM;nIdAl.enS=0;nIdAl.enL=0;
		nIdAl.SRop=NCSR_;nIdAl.SRaddr='0;
		{vIdAl.cR1,vIdAl.cR2,nIdAl.cRd,nIdAl.enJcod,nIdAl.imm}='0;
		vIdAl.SRaddr='0;

		if(oIfId.valid) begin
			`ifdef RV32I_DEBUG $fdisplay(logFile,"IDU:op=%x fun3=%x fun7=%x r1=%x r2=%x rd=%x",oIfId.code.op,oIfId.code.fun3,oIfId.code.fun7,oIfId.code.r1,oIfId.code.r2,oIfId.code.rd);`endif
			unique case(oIfId.code.op)
				OP_U_I	:nIdAl.imm={oIfId.code[31:12],12'b0 };
				OP_U_P	:nIdAl.imm={oIfId.code[31:12],12'b0 };
				OP_S__	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:25],oIfId.code[11:7] };
				OP_I_A	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
				OP_I_J	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
				OP_I_L	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
				OP_B__	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[7],oIfId.code[30:25],oIfId.code[11:8], 1'b0 };
				OP_J__	:nIdAl.imm={{12{oIfId.code[31]}},oIfId.code[19:12],oIfId.code[20],oIfId.code[30:21], 1'b0 };
				default	:nIdAl.imm='0;
			endcase
			unique case(oIfId.code.op)
				OP_U_P	:nIdAl.in1=PC_;
				default	:nIdAl.in1=IR1;
			endcase
			unique case(oIfId.code.op)
				OP_U_P	:nIdAl.in2=IMM;
				OP_I_A	:nIdAl.in2=IMM;
				default	:nIdAl.in2=IR2;
			endcase
			unique case(oIfId.code.op)
				OP_J__	:nIdAl.enJcod=1;
				OP_I_J	:nIdAl.enJcod=1;
				OP_CSR	:nIdAl.enJcod=(oIfId.code.fun3==3'b000);
				default	:nIdAl.enJcod=0;
			endcase

			unique case(oIfId.code.op)//选ALU cal
				OP_U_P	:nIdAl.cal=ADD_;
				OP_I_A	:begin unique case(oIfId.code.fun3)
						3'b001:begin unique case(oIfId.code.fun7)
								7'b0000000:nIdAl.cal=SLL_;
								default:begin `ifndef RV32I_STA $fatal("slli fun7(%x)!=0",oIfId.code.fun7);stop(0);`endif end
							endcase end
						3'b101:begin unique case(oIfId.code.fun7)
								7'b0000000:nIdAl.cal=SRL_;
								7'b0100000:nIdAl.cal=SRA_;
								default:begin `ifndef RV32I_STA $fatal("srai/srli fun7(%x)!=0/20",oIfId.code.fun7);stop(0);`endif end
							endcase end
						default:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
					endcase end
				OP_R__	:begin unique case(oIfId.code.fun7)
						7'b0000000:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
						7'b0100000:begin unique case(oIfId.code.fun3)
								3'b000:nIdAl.cal=SUB_;
								3'b101:nIdAl.cal=SRA_;
								default:begin `ifndef RV32I_STA $fatal("R fun7==20 fun3(%x)!=1/5",oIfId.code.fun3);stop(0);`endif end
							endcase end
						default:begin `ifndef RV32I_STA $fatal("R fun7(%x)!=0/20",oIfId.code.fun7);stop(0);`endif end
					endcase end
				default	:nIdAl.cal=NCAL;
			endcase

			if(oIfId.code.op==OP_B__)begin//b系列
				nIdAl.bfu=ALUopBfu_t'(oIfId.code.fun3);
			end else nIdAl.bfu=NBFU;

			unique case(oIfId.code.op)//选ALU cho
				OP_U_I	:nIdAl.cIrd=IMM_;
				OP_U_P	:nIdAl.cIrd=CAL_;
				OP_J__	:nIdAl.cIrd=SNPC;
				OP_I_J	:nIdAl.cIrd=SNPC;
				OP_I_A	:nIdAl.cIrd=CAL_;
				OP_R__	:nIdAl.cIrd=CAL_;
				OP_CSR	:nIdAl.cIrd=CCSR;
				default	:nIdAl.cIrd=NCHO;
			endcase
			unique case(oIfId.code.op)//选ALU addr
				OP_J__	:nIdAl.adr=PCI;
				OP_I_J	:nIdAl.adr=R1I;
				OP_I_L	:nIdAl.adr=R1I;
				OP_CSR	:nIdAl.adr=ECJ;
				OP_B__	:nIdAl.adr=PCI;
				OP_S__	:nIdAl.adr=R1I;
				default	:nIdAl.adr=NAD;
			endcase

			unique case(oIfId.code.op)//选LSU op
				OP_I_L	:nIdAl.LSop=LSUop_t'(oIfId.code.fun3);
				OP_S__	:nIdAl.LSop=LSUop_t'(oIfId.code.fun3);
				default	:nIdAl.LSop=NM;
			endcase
			nIdAl.enL=(oIfId.code.op==OP_I_L);
			nIdAl.enS=(oIfId.code.op==OP_S__);

			if(oIfId.code.op==OP_CSR)begin unique case(oIfId.code.fun3)
				3'b000	:nIdAl.cCsr=JUMP_;
				3'b001	:nIdAl.cCsr=WACSR;						
				3'b010	:nIdAl.cCsr=(oIfId.code.r1=='0)?NACSR:RACSR;
				default	:nIdAl.cCsr=NACSR;						
			endcase  unique case(oIfId.code.fun3)
				3'b000	:begin unique case(oIfId.code)
						OP_CSR_MRET__	:begin nIdAl.SRaddr=CSR_ADDR_MEPC;		end
						OP_CSR_ECALL_	:begin nIdAl.SRaddr=CSR_ADDR_MTVEC;	end
						OP_CSR_EBREAK	:begin nIdAl.SRaddr='0;`ifndef RV32I_STA stop(1);`endif end
						default			:begin nIdAl.SRaddr='0;`ifndef RV32I_STA stop(0);`endif end endcase end
				3'b001					:begin nIdAl.SRaddr={oIfId.code[31:20]};end
				3'b010					:begin nIdAl.SRaddr={oIfId.code[31:20]};end
				default					:begin nIdAl.SRaddr='0;				end
			endcase  unique case(oIfId.code.fun3)
				3'b000	:begin unique case(oIfId.code)
						OP_CSR_MRET__	:nIdAl.SRop=MRET_;
						OP_CSR_ECALL_	:nIdAl.SRop=ECALL;
						OP_CSR_EBREAK	:nIdAl.SRop=NCSR_;
						default			:nIdAl.SRop=NCSR_;endcase end
				3'b001					:nIdAl.SRop=WCCSR;
				3'b010					:nIdAl.SRop=(oIfId.code.r1=='0)?NCSR_:WCCSR;
				default					:nIdAl.SRop=NCSR_;
			endcase end else begin nIdAl.cCsr=NACSR;nIdAl.SRaddr='0;nIdAl.SRop=NCSR_;end
			vIdAl.SRaddr=nIdAl.SRaddr;

			unique case(oIfId.code.op)//选cR1 这里7/10就反选
				OP_U_I	:vIdAl.cR1='0;
				OP_U_P	:vIdAl.cR1='0;
				OP_J__	:vIdAl.cR1='0;
				default	:vIdAl.cR1=oIfId.code.r1;
			endcase
			// $fdisplay(logFile,"cR1=%x opR1=%b code=%b",val.cR1,oIfId.code.r1,oIfId.code);
			unique case(oIfId.code.op)//选cR2
				OP_S__	:vIdAl.cR2=oIfId.code.r2;
				OP_R__	:vIdAl.cR2=oIfId.code.r2;
				OP_B__	:vIdAl.cR2=oIfId.code.r2;
				default	:vIdAl.cR2='0;
			endcase
			unique case(oIfId.code.op)//选cRd 也是反选
				OP_B__	:nIdAl.cRd='0;
				OP_S__	:nIdAl.cRd='0;
				OP_CSR	:nIdAl.cRd=(oIfId.code.fun3==3'b000)?'0:oIfId.code.rd;
				default	:nIdAl.cRd=oIfId.code.rd;
			endcase
		end
	end
	endmodule
module ysyx_26020046_rv32iALU(
	input  IdAl_t nIdAl,
	output upBk_t iAlId,
	output AlLs_t nAlLs,
	input  valcl_t vIdAl,
	output valcl_t vAlLs,
	input  LsAl_t iLsAl
	);
	logic enBfun;
	word_t result,in1,in2;
	IdAl_t oIdAl;

	always_comb oIdAl=nIdAl;

	always_comb vAlLs=vIdAl;

	always_comb begin
		nAlLs.oR2		=iLsAl.oR2;
		nAlLs.enS		=oIdAl.enS;
		nAlLs.enL		=oIdAl.enL;
		nAlLs.LSop		=oIdAl.LSop;
		nAlLs.cRd		=oIdAl.cRd;
		nAlLs.SRaddr	=oIdAl.SRaddr;
		nAlLs.SRop		=oIdAl.SRop;
		nAlLs.valid		=oIdAl.valid;
		iAlId.ready	=iLsAl.ready;
	end

	always_comb begin
		nAlLs.res='0;nAlLs.iCsr='0;nAlLs.addr='0;
		iAlId.enJfun='0;iAlId.addr='0;enBfun=0;
		result='0;in1='0;in2='0;
	 if(oIdAl.valid)begin
			// $fdisplay(logFile,"val cR1=%x cR2=%x oR1=%x oR2=%x SRaddr=%x oCsr=%x pc=%x",val.cR1,val.cR2,val.oR1,val.oR2,val.SRaddr,val.oCsr,val.pc);
		unique case(oIdAl.in1)
			IR1:in1=iLsAl.oR1;
			PC_:in1=oIdAl.pc;
			default:begin in1='0;`ifndef RV32I_STA $fatal("unknown in1==0x%x",oIdAl.in1);`endif end
		endcase
		unique case(oIdAl.in2)
			IR2:in2=iLsAl.oR2;
			IMM:in2=oIdAl.imm;
			default:begin in2='0;`ifndef RV32I_STA $fatal("unknown in2==0x%x",oIdAl.in2);`endif end
		endcase
		unique case(oIdAl.cal)
			ADD_:result=in1+in2;
			SLL_:result=in1<<in2[4:0];
			SLT_:result=  $signed(in1) <  $signed(in2)?1:0;
			SLTU:result=$unsigned(in1) <$unsigned(in2)?1:0;
			XOR_:result=in1^in2;
			SRL_:result=$unsigned(in1)>> in2[4:0];
			OR__:result=in1|in2;
			AND_:result=in1&in2;
			SUB_:result=in1-in2;
			SRA_:result=  $signed(in1)>>>in2[4:0];
			NCAL:result='0;
			default:begin result='0;`ifndef RV32I_STA $fatal("unknown cal==0x%x",oIdAl.cal);`endif end
		endcase
		
		unique case(oIdAl.cIrd)
			CAL_:nAlLs.res=result;
			IMM_:nAlLs.res=oIdAl.imm;
			CCSR:nAlLs.res=iLsAl.oCsr;
			SNPC:nAlLs.res=oIdAl.pc+4;
			NCHO:nAlLs.res='0;
			default:begin nAlLs.res='0;`ifndef RV32I_STA $error("unknown cho==0x%x",oIdAl.cIrd);$stop;`endif end
		endcase
		unique case(oIdAl.cCsr)
			WACSR:nAlLs.iCsr=iLsAl.oR1;
			RACSR:nAlLs.iCsr=iLsAl.oR1|iLsAl.oCsr;
			JUMP_:nAlLs.iCsr=oIdAl.pc;
			NCSR_:nAlLs.iCsr='0;
			default:begin nAlLs.iCsr='0;`ifndef RV32I_STA $error("unknown csr==0x%x",oIdAl.cCsr);$stop;`endif end
		endcase
		unique case(oIdAl.bfu)
			BEQ_:enBfun=(iLsAl.oR1==iLsAl.oR2);
			BNE_:enBfun=(iLsAl.oR1!=iLsAl.oR2);
			BLT_:enBfun=(   $signed(iLsAl.oR1) <  $signed(iLsAl.oR2));
			BGE_:enBfun=(   $signed(iLsAl.oR1)>=  $signed(iLsAl.oR2));
			BLTU:enBfun=( $unsigned(iLsAl.oR1) <$unsigned(iLsAl.oR2));
			BGEU:enBfun=( $unsigned(iLsAl.oR1)>=$unsigned(iLsAl.oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;`ifndef RV32I_STA $fatal("unknown bfu==0x%x",oIdAl.bfu);`endif end
			endcase
		unique case(oIdAl.adr)
			R1I:nAlLs.addr=iLsAl.oR1+oIdAl.imm;
			PCI:nAlLs.addr=oIdAl.pc +oIdAl.imm;
			ECJ:nAlLs.addr=iLsAl.oCsr;
			ERE:nAlLs.addr=iLsAl.oCsr;
			NAD:nAlLs.addr='0;
			default:begin nAlLs.addr='0;`ifndef RV32I_STA $fatal("unknown adr==0x%x",oIdAl.adr);`endif end
		endcase
		iAlId.enJfun=oIdAl.enJcod|enBfun;
		iAlId.addr=nAlLs.addr;
	end end
	endmodule
module ysyx_26020046_rv32iLSU(
	output AXI4rCal_t rLsCal,
	output AXI4wCal_t wLsCal,
	input  AXI4rBak_t rLsBak,
	input  AXI4wBak_t wLsBak,
	input  AlLs_t nAlLs,
	input RgLs_t  iRgLs,
	input SrLs_t iSrLs,
	output LsRg_t nLsRg,
	output LsSr_t nLsSr,
	output LsAl_t iLsAl,
	input valcl_t vAlLs,
	output valSr_t vLsSr,
	output valRg_t vLsRg,
	input  logic clk,reset
	);

	AlLs_t oAlLs;

	mask_t mask;
	word_t iRAM,data;
	logic hasAddr,hasData;
	LSUstatus_t s,ns;
	logic LsWbValid;

	always_comb oAlLs=nAlLs;
	always_comb begin
		vLsRg.cR1=vAlLs.cR1;
		vLsRg.cR2=vAlLs.cR2;
		vLsSr.SRaddr=vAlLs.SRaddr;
	end always_comb begin
		iLsAl.oR1=iRgLs.oR1;
		iLsAl.oR2=iRgLs.oR2;
		iLsAl.oCsr=iSrLs.oCsr;
	end

	always_comb unique case(s)
			LSUidle:ns=(oAlLs.enL|oAlLs.enS)	?LSUcall:LSUidle;
			LSUcall:unique case('1)
				oAlLs.enL:ns=(rLsBak.arready)	?LSUback:LSUcall;
				oAlLs.enS:ns=(hasAddr&hasData)	?LSUback:LSUcall;
				default:begin ns=LSUidle;`ifndef RV32I_STA if(~reset)begin $error("LSU call L=%b S=%b reset=%b",oAlLs.enL,oAlLs.enS,reset);$stop;end`endif end endcase
			LSUback:unique case('1)
				oAlLs.enL:ns=(rLsBak.rvalid)	?LSUsuce:LSUback;
				oAlLs.enS:ns=(wLsBak.bvalid)	?LSUsuce:LSUback;
				default:begin ns=LSUidle;`ifndef RV32I_STA if(~reset)begin $error("LSU back L=%b S=%b reset=%b",oAlLs.enL,oAlLs.enS,reset);$stop;end`endif end endcase
			LSUsuce:ns=(iLsAl.ready&LsWbValid)	?LSUidle:LSUsuce;
			default:ns=LSUidle;
	endcase always_ff@(posedge clk) if(reset)begin
			s<=LSUidle;
	end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"LSU:Rs=%s ns=%s",s.name(),ns.name());`endif
			s<=ns;
	end always_ff@(posedge clk) begin
			iRAM<=(s==LSUback&ns==LSUsuce)?rLsBak.rdata:'0;
			if(oAlLs.enS&s==LSUcall&wLsBak.awready)	hasAddr<=true;
			if(oAlLs.enS&s!=LSUcall)				hasAddr<=false;
			if(oAlLs.enS&s==LSUcall&wLsBak.wready)	hasData<=true;
			if(oAlLs.enS&s!=LSUcall)				hasData<=false;
	end always_comb begin
			rLsCal.araddr	=oAlLs.enL?oAlLs.addr:'0;
			rLsCal.arvalid	=oAlLs.enL&(s==LSUcall);
			rLsCal.rready	=oAlLs.enL&(s==LSUback);
			
			wLsCal.awaddr	=oAlLs.enS?oAlLs.addr:'0;
			wLsCal.awvalid	=oAlLs.enS&(s==LSUcall);
			wLsCal.wdata	=oAlLs.enS?oAlLs.oR2:'0;
			wLsCal.wstrb	=oAlLs.enS?mask:'0;
			wLsCal.wvalid	=oAlLs.enS&(s==LSUcall);
			wLsCal.bready	=oAlLs.enS&(s==LSUback);
			if(s==LSUback)case(rLsBak.rresp)
				OKAY:;
				default:begin `ifndef RV32I_STA $fatal("unknown rresp==0x%x",rLsBak.rresp);`endif end
			endcase
			if(s==LSUback)case(wLsBak.bresp)
				OKAY:;
				default:begin `ifndef RV32I_STA $fatal("unknown bresp==0x%x",wLsBak.bresp);`endif end
			endcase
	end
	always_comb begin
		nLsRg.iRd	=(oAlLs.enS|oAlLs.enL)?data:oAlLs.res;
		nLsRg.cRd	=oAlLs.cRd;
		nLsSr.iCsr	=oAlLs.iCsr;
		nLsSr.SRaddr=oAlLs.SRaddr;
		nLsSr.SRop	=oAlLs.SRop;
		LsWbValid	=(~((oAlLs.enL|oAlLs.enS)^(s==LSUsuce)))&oAlLs.valid;
		nLsSr.valid	=LsWbValid;
		nLsRg.valid	=LsWbValid;
		iLsAl.ready	=(~((oAlLs.enL|oAlLs.enS)^(s==LSUsuce)))&iRgLs.ready&iSrLs.ready;
	end
	always_comb begin
		`ifdef RV32I_DEBUG if(oAlLs.enL)$fdisplay(logFile,"LSU:enL=%b valid=%b iRAM=%x",oAlLs.enL,oAlLs.valid,iRAM);`endif
		if (oAlLs.enS&oAlLs.valid) begin unique case(oAlLs.LSop)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;`ifndef RV32I_STA $fatal("unknown mask==0x%x",oAlLs.LSop);`endif end
		endcase end else 	mask=4'b0000;
		if(oAlLs.enL&oAlLs.valid) begin unique case(oAlLs.LSop)
			B_:				data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				data=iRAM;
			BU:				data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	data=0;`ifndef RV32I_STA $fatal("unknown date==0x%x",oAlLs.LSop);`endif end
		endcase end else 	data='0;
		`ifdef RV32I_DEBUG if(oAlLs.enL)$fstrobe(logFile,"LSU:enL=%b valid=%b data=%x iRAM=%x",oAlLs.enL,oAlLs.valid,data,iRAM);`endif
	end
	endmodule
module ysyx_26020046_rv32iGPR(
	input  LsRg_t nLsRg,
	input  valRg_t vLsRg,
	output RgLs_t iRgLs,
	input  clk
	);

	LsRg_t oLsRg;

	always_comb oLsRg=nLsRg;

	word_t gpr [2**REG_NUMBER -1:1];

	assign iRgLs.ready=1;
	always_ff@(posedge clk) if(oLsRg.valid)begin
			`ifdef RV32I_DEBUG if(oLsRg.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",oLsRg.cRd,gpr[oLsRg.cRd],oLsRg.iRd);`endif
			if (oLsRg.cRd!=0) gpr[oLsRg.cRd] <= oLsRg.iRd;
    	end
	assign iRgLs.oR1=(vLsRg.cR1==0)?'0:gpr[vLsRg.cR1];
	assign iRgLs.oR2=(vLsRg.cR2==0)?'0:gpr[vLsRg.cR2];

	endmodule
module ysyx_26020046_rv32iCSR(
	input  LsSr_t nLsSr,
	input  valSr_t vLsSr,
	output SrLs_t  iSrLs,
	input  clk,reset
	);

	LsSr_t oLsSr;

	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

	always_comb oLsSr=nLsSr; 

	assign iSrLs.ready=1;
	always_ff@(posedge clk) begin:csr_write
		if(reset)begin
			mepc		<=PC_RESET;
			mstatus		<=MSTATUS_RESET;
			mtvec		<=PC_RESET;
			mcause		<='0;
			mcycle		<='0;
			mcycleh		<='0;
			marchid		<=32'h018D08CE;
			mvendorid	<=32'h79737978;
		end else begin
				// if(mcycle>='d1000)$stop;//特殊调试，用于观测死循环
	`ifdef RV32I_DEBUG
			if(~reset)begin
				$fstrobe(logFile,"mcycle = %d\n",mcycle);
				if(mcycle>='d10000000)$stop;//特殊调试，用于观测死循环
				if(oLsSr.SRop==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,oLsSr.iCsr,mcause,11);
				else if(oLsSr.SRop==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,oLsSr.iCsr,mcause,0);
				else if(oLsSr.SRop==WCCSR)begin unique case(oLsSr.SRaddr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				oLsSr.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		oLsSr.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			oLsSr.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			oLsSr.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			oLsSr.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		oLsSr.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		oLsSr.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	oLsSr.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",oLsSr.SRaddr); end
				endcase end
			end
	`endif
			{mcycleh,mcycle}<={mcycleh,mcycle}+1;
			if(oLsSr.valid) begin unique case(oLsSr.SRop)
				ECALL:begin mepc<=oLsSr.iCsr;mcause<=11;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;end
				WCCSR:begin unique case(oLsSr.SRaddr)
					CSR_ADDR_MEPC		:mepc		<=oLsSr.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=oLsSr.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=oLsSr.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=oLsSr.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=oLsSr.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=oLsSr.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=oLsSr.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=oLsSr.iCsr;
					default:begin `ifndef RV32I_STA $fatal("unknown csrAddr==0x%x",oLsSr.SRaddr);`endif end
					endcase end
				NCSR_:;
				default:begin `ifndef RV32I_STA $fatal("unknown op.SRop==0x%x",oLsSr.SRop);`endif end
			endcase end
			end
		end

	always_comb begin:choose_csr
		unique case(vLsSr.SRaddr)
			CSR_ADDR_MEPC		:iSrLs.oCsr=mepc;
			CSR_ADDR_MSTAUS		:iSrLs.oCsr=mstatus;
			CSR_ADDR_MTVEC		:iSrLs.oCsr=mtvec;
			CSR_ADDR_MCAUSE		:iSrLs.oCsr=mcause;
			CSR_ADDR_MCYCLE		:iSrLs.oCsr=mcycle;
			CSR_ADDR_MCYCLEH	:iSrLs.oCsr=mcycleh;
			CSR_ADDR_MARCHID	:iSrLs.oCsr=marchid;
			CSR_ADDR_MVENDORID	:iSrLs.oCsr=mvendorid;
			default				:iSrLs.oCsr='0;
		endcase
	end
	endmodule
