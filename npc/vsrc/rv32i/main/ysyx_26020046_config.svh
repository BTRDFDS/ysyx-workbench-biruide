`ifndef _YSYX_26020046_CONFIG_ `define _YSYX_26020046_CONFIG_
    `define RV32I_DEBUG
	// `define RV32I_STA

	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;

	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;

	parameter PC_RESET	= 32'h20000000;
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
	typedef enum logic [1:0] {MRET_,ERROR,WCCSR,NCSR_} CSRop_t;

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
	`endif

	typedef struct packed {reg_t cR1,cR2;SRaddr_t SRaddr;}	valcl_t;
	typedef struct packed {word_t addr;logic enJfun,ready;}	upBk_t;
	typedef struct packed {logic valid;code_t code;word_t pc;logic error;word_t cause;} IfId_t;
	typedef struct packed {
		logic valid;
		word_t imm,pc;in1_t in1;in2_t in2;logic enJcod;
		ALUopCal_t cal;ALUopBfu_t bfu;ALUopADR_t adr;ALUopCsr_t cCsr;ALUopCho_t cIrd;
		logic enS,enL;LSUop_t LSop;
		reg_t cRd;
		word_t SRmesg;CSRop_t SRop;
	} IdAl_t;
	typedef struct packed {logic valid,enS,enL;word_t addr,res,iCsr,oR2;LSUop_t LSop;word_t SRmesg;CSRop_t SRop;reg_t cRd;word_t cause;}	AlLs_t;
	typedef struct packed {logic ready;word_t oR1,oR2;word_t oCsr;word_t cause;}															LsAl_t;
	typedef struct packed {word_t iRd;reg_t cRd;logic valid;word_t iCsr;word_t SRmesg;CSRop_t SRop;word_t cause;}							LsRg_t;
	typedef struct packed {logic ready;word_t oR1,oR2,oCsr;}																				RgLs_t;
	typedef struct packed {logic arvalid,rready;word_t araddr;}																				AXI4rCal_t;
	typedef struct packed {logic awvalid,wvalid,bready;word_t awaddr,wdata;mask_t wstrb;}													AXI4wCal_t;
	typedef struct packed {logic arready;word_t rdata;resp_t rresp;logic rvalid;}															AXI4rBak_t;
	typedef struct packed {logic awready,wready,bvalid;resp_t bresp;}																		AXI4wBak_t;

	`ifndef RV32I_STA
	function string sIfId(IfId_t i);return $sformatf("valid=%b,code=%x,pc=%x",i.valid,i.code,i.pc);endfunction
	function string sIdAl(IdAl_t i);return $sformatf("valid=%b in1=%s in2=%s enJ=%b cal=%s bfu=%s adr=%s csr=%s iRd=%s enS=%b enL=%b LSop=%s cRd=%x SRaddr=%x SRop=%s imm=%x pc=%x",i.valid,i.in1.name(),i.in2.name(),i.enJcod,i.cal.name(),i.bfu.name(),i.adr.name(),i.cCsr.name(),i.cIrd.name(),i.enS,i.enL,i.LSop.name(),i.cRd,i.SRmesg,i.SRop.name(),i.imm,i.pc);endfunction
	function string sValcal(valcl_t i);return $sformatf("cR1=%x cR2=%x SRaddr=%x",i.cR1,i.cR2,i.SRaddr);endfunction
	function string sUpBk(upBk_t i);return $sformatf("addr=%x enJ=%b ready=%b",i.addr,i.enJfun,i.ready);endfunction
	function string sAlLs(AlLs_t i);return $sformatf("valid=%b enS=%b enL=%b addr=%x res=%x iCsr=%x oR2=%x LSop=%x SRaddr=%x SRop=%s cRd=%x",i.valid,i.enS,i.enL,i.addr,i.res,i.iCsr,i.oR2,i.LSop,i.SRmesg,i.SRop.name(),i.cRd);endfunction
	function string sLsAl(LsAl_t i);return $sformatf("ready=%b oR1=%x oR2=%x oCsr=%x",i.ready,i.oR1,i.oR2,i.oCsr);endfunction
	function string sLsRg(LsRg_t i);return $sformatf("valid=%b iRd=%x cRd=%x",i.valid,i.iRd,i.cRd);endfunction
	// function string sLsSr(LsSr_t i);return $sformatf("valid=%b iCsr=%x SRaddr=%x SRop=%s",i.valid,i.iCsr,i.SRmesg,i.SRop.name());endfunction
	// function string sSrLs(SrLs_t i);return $sformatf("ready=%b oCsr=%x",i.ready,i.oCsr);endfunction
	function string sRgLs(RgLs_t i);return $sformatf("ready=%b oR1=%x oR2=%x",i.ready,i.oR1,i.oR2);endfunction
	// function string sValRg(valRg_t i);return $sformatf("cR1=%x cR2=%x",i.cR1,i.cR2);endfunction
	// function string sValSr(valSr_t i);return $sformatf("SRaddr=%x",i.SRaddr);endfunction
	function string sAXI4rCal(AXI4rCal_t i);return $sformatf("arvalid=%b rready=%b araddr=%x",i.arvalid,i.rready,i.araddr);endfunction
	function string sAXI4wCal(AXI4wCal_t i);return $sformatf("awvalid=%b wvalid=%b bready=%b awaddr=%x wdata=%x wstrb=%b",i.awvalid,i.wvalid,i.bready,i.awaddr,i.wdata,i.wstrb);endfunction
	function string sAXI4rBak(AXI4rBak_t i);return $sformatf("arready=%b rdata=%x rresp=%s rvalid=%b rready=%b",i.arready,i.rdata,i.rresp.name(),i.rvalid,i.arready);endfunction
	function string sAXI4wBak(AXI4wBak_t i);return $sformatf("awready=%b wready=%b bvalid=%b bresp=%s",i.awready,i.wready,i.bvalid,i.bresp.name());endfunction
	`endif
`endif