// `define RV32I_DEBUG

	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter false = 0;
	parameter true = 1;

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

	typedef enum logic [1:0]{CPUback,CPUcall,CPUfunc} CPUstatus_t;
	typedef enum logic [1:0]{MEMidle,MEMfunc,MEMback,MEMwait} MEMstatus_t;
	typedef enum logic [1:0]{ARBidle,ARBifuR,ARBlsuR,ARBlsuW} ARBstatus_t;

	typedef enum logic [1:0]{OKAY,EXOKAY,SLVERR,DECERR} resp_t;//TODO 目前是只有OKAY有用
	`ifdef RV32I_DEBUG
		integer logFile;
	`endif
	import "DPI-C" function void stop(input bit eb);
	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);

interface IfId_t();
	logic valid,ready;
	code_t code;
	word_t addr;
	logic enJfun;
	modport IFU(output code,valid,input  addr,enJfun,ready);
	modport IDU(input  code,valid,output addr,enJfun,ready);
	endinterface
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

	word_t oR1,oR2,oCsr,imm,pc;
} IdAl_t;
typedef struct packed {
	word_t addr;
	logic enJfun,ready;
} enJready_t;
typedef struct packed {
	logic valid;
	logic enS,enL;
	LSUop_t LSop;
	word_t addr,res,iCsr,oR2;
	SRaddr_t SRaddr;
	CSRop_t SRop;
	reg_t cRd;
} AlLs_t;
typedef struct packed {
	word_t iRd;
	reg_t cRd;
	logic valid;
} LsRg_t;
typedef struct packed {
	word_t iCsr;
	SRaddr_t SRaddr;
	CSRop_t SRop;
	logic valid;
} LsSr_t;
interface val_t();
	reg_t cR1,cR2;
	SRaddr_t SRaddr;
	word_t oR1,oR2,oCsr,pc;
	modport IDU(input oR1,oR2,pc,oCsr,output cR1,cR2,SRaddr);
	modport GPR(input cR1,cR2,output oR1,oR2,input pc);//PC用于getReg的调试
	modport CSR(input SRaddr ,output oCsr);
	modport IFU(output pc);
	endinterface
interface AXI4_Lite_t();
	logic arready,arvalid;
	word_t araddr;

	logic rready,rvalid;
	word_t rdata;
	resp_t rresp;

	logic awready,awvalid;
	word_t awaddr;

	logic wvalid,wready;
	mask_t wstrb;//mask
	word_t wdata;

	logic bvalid,bready;
	resp_t bresp;

	modport CPU(input  arready,rdata,rresp,rvalid,awready,wready,bresp,bvalid,output araddr,arvalid,rready,awaddr,awvalid,wdata,wstrb,wvalid,bready);
	modport MEM(output arready,rdata,rresp,rvalid,awready,wready,bresp,bvalid,input  araddr,arvalid,rready,awaddr,awvalid,wdata,wstrb,wvalid,bready);
	endinterface
module ysyx_26020046_rv32i(
	input logic clk,
	input logic reset,
	output logic difftest
	);

	IfId_t nIfId();
	IdAl_t nIdAl;
	AlLs_t nAlLs;
	LsRg_t nLsRg;
	LsSr_t nLsSr;
	val_t val();
	AXI4_Lite_t sbIf();
	AXI4_Lite_t sbLs();
	AXI4_Lite_t axi4();

	logic LsSrReady,LsRgReady,AlLsReady;//,IfIdReady;
	enJready_t IdAlReady;
	// ysyx_26020046_rv32iMEM ROM(.*,.axi4(sbIf));
	// ysyx_26020046_rv32iMEM RAM(.*,.axi4(sbLs));
	ysyx_26020046_rv32iMEM MEM(.*);
	ysyx_26020046_rv32iARB ARB(.*);
	ysyx_26020046_rv32iIFU IFU(.*);
	ysyx_26020046_rv32iIDU IDU(.*);
	ysyx_26020046_rv32iALU ALU(.*);
	ysyx_26020046_rv32iLSU LSU(.*);
	ysyx_26020046_rv32iGPR GPR(.*);
	ysyx_26020046_rv32iCSR CSR(.*);

	// assign difftest=nIfId.ready&nIfId.valid;
	always_ff@(posedge clk)difftest<=nIfId.ready&nIfId.valid;
	// always_ff@(negedge clk)difftest<=nIfId.ready&nIfId.valid;
	`ifdef RV32I_DEBUG
		initial begin
			logFile = $fopen("log/rv32iDebugLog.txt");
			$write("\033[1;35m SV_DEBUG \033[0m");
			// $fstrobe
		end
		always @(posedge clk) begin if(~reset)begin
			$fdisplay(logFile,"sbIf:araddr=%x arvalid=%b arready=%b rdata=%x rresp=%s rvalid=%b rready=%b",sbIf.araddr,sbIf.arvalid,sbIf.arready,sbIf.rdata,sbIf.rresp.name(),sbIf.rvalid,sbIf.rready);
			$fdisplay(logFile,"sbIf:awaddr=%x awvalid=%b awready=%b wdata=%x wstrb=%b wvalid=%b wready=%b",sbIf.awaddr,sbIf.awvalid,sbIf.awready,sbIf.wdata,sbIf.wstrb,sbIf.wvalid,sbIf.wready);
			$fdisplay(logFile,"sbIf:bresp=%s bvalid=%b bready=%b",sbIf.bresp.name(),sbIf.bvalid,sbIf.bready);
			$fdisplay(logFile,"sbLs:araddr=%x arvalid=%b arready=%b rdata=%x rresp=%s rvalid=%b rready=%b",sbLs.araddr,sbLs.arvalid,sbLs.arready,sbLs.rdata,sbLs.rresp.name(),sbLs.rvalid,sbLs.rready);
			$fdisplay(logFile,"sbLs:awaddr=%x awvalid=%b awready=%b wdata=%x wstrb=%b wvalid=%b wready=%b",sbLs.awaddr,sbLs.awvalid,sbLs.awready,sbLs.wdata,sbLs.wstrb,sbLs.wvalid,sbLs.wready);
			$fdisplay(logFile,"sbLs:bresp=%s bvalid=%b bready=%b",sbLs.bresp.name(),sbLs.bvalid,sbLs.bready);
			$fdisplay(logFile,"nIfId code=%x valid=%b ready=%b addr=%x enJfun=%b difftest=%b",nIfId.code,nIfId.valid,nIfId.ready,nIfId.addr,nIfId.enJfun,difftest);
			$fdisplay(logFile,"val cR1=%x cR2=%x oR1=%x oR2=%x SRaddr=%x oCsr=%x pc=%x",val.cR1,val.cR2,val.oR1,val.oR2,val.SRaddr,val.oCsr,val.pc);
			$fdisplay(logFile,"nIdAl oR1=%x oR2=%x oCsr=%x imm=%x pc=%x enJcod=%b vaild=%b ready=%b",nIdAl.oR1,nIdAl.oR2,nIdAl.oCsr,nIdAl.imm,nIdAl.pc,nIdAl.enJcod,nIdAl.valid,nIdAl.ready);
			$fdisplay(logFile,"nIdAl in1=%s in2=%s al=%s adr=%s cCsr=%s cIrd=%s addr=%x enJfun=%b",nIdAl.in1.name(),nIdAl.in2.name(),nIdAl.cal.name(),nIdAl.adr.name(),nIdAl.cCsr.name(),nIdAl.cIrd.name(),nIdAl.addr,nIdAl.enJfun);
			$fdisplay(logFile,"nIdAl enL=%b enS=%b LSop=%s SRaddr=%x SRop=%s cRd=%x",nIdAl.enL,nIdAl.enS,nIdAl.LSop.name(),nIdAl.SRaddr,nIdAl.SRop.name(),nIdAl.cRd);
			$fdisplay(logFile,"nAlLs enS=%b enL=%b LSop=%s res=%x addr=%x valid=%b ready=%b",nAlLs.enS,nAlLs.enL,nAlLs.LSop.name(),nAlLs.res,nAlLs.addr,nAlLs.valid,nAlLs.ready);
			$fdisplay(logFile,"nAlLs oR2=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nAlLs.oR2,nAlLs.cRd,nAlLs.iCsr,nAlLs.SRaddr,nAlLs.SRop.name());
			$fdisplay(logFile,"LsWb iRd=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s valid=%b ready=%b",LsWb.iRd,LsWb.cRd,LsWb.iCsr,LsWb.SRaddr,LsWb.SRop.name(),LsWb.valid,LsWb.ready);
		end end
	`endif
	endmodule
module ysyx_26020046_rv32iMEM(
	AXI4_Lite_t.MEM axi4,
	input clk,reset
	);
	MEMstatus_t Rs,nRs,Ws,nWs;
	word_t rCnt,wCnt;//cnt会加3，这是因为会经过三段状态转移有三周期延迟
	parameter rMax = 10;
	parameter wMax = 10;
	word_t araddr,awaddr,wdata;
	mask_t wstrb;
	logic hasAddr,hasData;
	always_comb case(Rs)
			MEMidle:nRs=(axi4.arvalid)?MEMwait:MEMidle;
			MEMwait:nRs=(rCnt+3<rMax )?MEMwait:MEMfunc;
			MEMfunc:nRs=MEMback;
			MEMback:nRs=(axi4.rready )?MEMidle:MEMback;
			default:nRs=MEMidle;
	endcase	always_ff@(posedge clk) if(reset)begin
			Rs	<=MEMidle;
			rCnt<=0;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"%m:Rs=%s,nRs=%s rCnt=%d",Rs.name(),nRs.name(),rCnt);`endif
			Rs	<=nRs;
			rCnt<=(Rs==MEMwait)?rCnt+1:0;
	end always_ff@(posedge clk)begin
		if(axi4.arready&axi4.arvalid)araddr<=axi4.araddr;
		if(Rs==MEMfunc)axi4.rdata<=pmem_read(araddr);
		`ifdef RV32I_DEBUG if(Rs==MEMfunc)$fdisplay(logFile,"%m:read [%x]==%x",araddr,axi4.rdata);`endif
	end always_comb begin
		axi4.arready=(Rs==MEMidle);
		axi4.rresp=OKAY;
		axi4.rvalid=(Rs==MEMback);
	end

	always_comb case(Ws)
			MEMidle:nWs=(axi4.awvalid|hasAddr)&(axi4.wvalid|hasData)?MEMwait:MEMidle;
			MEMwait:nWs=(wCnt+3<wMax)?MEMwait:MEMfunc;
			MEMfunc:nWs=MEMback;
			MEMback:nWs=(axi4.bready)?MEMidle:MEMback;
			default:nWs=MEMidle;
	endcase always_ff@(posedge clk) if(reset)begin
			Ws	<=MEMidle;
			wCnt<=0;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"%m:Ws=%s,nWs=%s wCnt=%d",Ws.name(),nWs.name(),wCnt);`endif
			Ws	<=nWs;
			wCnt<=(Ws==MEMwait)?wCnt+1:0;
	end always_ff @(posedge clk) begin
		if(axi4.awready&axi4.awvalid)awaddr	<=axi4.awaddr;
		if(axi4.awready&axi4.awvalid)hasAddr<=1'b1;
		if(Ws==MEMback				)hasAddr<=1'b0;
		if(axi4.wready &axi4.wvalid )wdata	<=axi4.wdata;
		if(axi4.wready &axi4.wvalid )wstrb	<=axi4.wstrb;
		if(axi4.wready &axi4.wvalid )hasData<=1'b1;
		if(Ws==MEMback				)hasData<=1'b0;
		if(Ws==MEMfunc)`ifdef RV32I_DEBUG $fdisplay(logFile,"%m:write [%x] <(%b)= %x",awaddr,wstrb,wdata);`endif	
		if(Ws==MEMfunc)pmem_write(awaddr,wdata,{4'b0,wstrb});
	end always_comb begin
		axi4.awready=(Ws==MEMidle&!hasAddr);
		axi4.wready	=(Ws==MEMidle&!hasData);
		axi4.bresp	=OKAY;
		axi4.bvalid	=(Ws==MEMback);
	end
	endmodule
module ysyx_26020046_rv32iARB(
	AXI4_Lite_t.MEM sbIf,
	AXI4_Lite_t.MEM sbLs,
	AXI4_Lite_t.CPU axi4,
	input clk,reset
	);
	ARBstatus_t s,ns;
	always_comb	unique case(s)//TODO 现在默认是LSU不会同时读写
			ARBidle: if(sbLs.arvalid&axi4.arready)ns=ARBlsuR;
				else if(sbLs.awvalid&axi4.awready)ns=ARBlsuW;
				else if(sbLs.wvalid &axi4.wready )ns=ARBlsuW;
				else if(sbIf.arvalid&axi4.arready)ns=ARBifuR;
				else ns=ARBidle;
			ARBlsuR:ns=(sbLs.rready&axi4.rvalid)?ARBidle:ARBlsuR;
			ARBlsuW:ns=(sbLs.bready&axi4.bvalid)?ARBidle:ARBlsuW;
			ARBifuR:ns=(sbIf.rready&axi4.rvalid)?ARBidle:ARBifuR;
			default:ns=ARBidle;
	endcase always_ff@(posedge clk)if(reset)begin
			s<=ARBidle;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"ARB:s=%s,ns=%s",s.name(),ns.name());`endif
			s<=ns;
		end always_comb begin
			axi4.araddr	='0;
			axi4.arvalid=false;
			axi4.rready	=false;
			axi4.awaddr	='0;
			axi4.awvalid=false;
			axi4.wdata	='0;
			axi4.wstrb	='0;
			axi4.wvalid	=false;
			axi4.bready	=false;
			
			sbLs.arready=false;
			sbLs.rdata	='0;
			sbLs.rresp	=OKAY;
			sbLs.rvalid	=false;
			sbLs.awready=false;
			sbLs.wready	=false;
			sbLs.bresp	=OKAY;
			sbLs.bvalid	=false;

			sbIf.arready=false;
			sbIf.rdata	='0;
			sbIf.rresp	=OKAY;
			sbIf.rvalid	=false;
			sbIf.awready=false;
			sbIf.wready	=false;
			sbIf.bresp	=OKAY;
			sbIf.bvalid	=false;
		unique case(s)
			ARBidle:;
			ARBlsuR:begin
				axi4.araddr	=sbLs.araddr;
				axi4.arvalid=sbLs.arvalid;
				sbLs.arready=axi4.arready;
				sbLs.rdata	=axi4.rdata;
				sbLs.rresp	=axi4.rresp;
				sbLs.rvalid	=axi4.rvalid;
				axi4.rready	=sbLs.rready;
				end
			ARBlsuW:begin
				axi4.awaddr	=sbLs.awaddr;
				axi4.awvalid=sbLs.awvalid;
				sbLs.awready=axi4.awready;
				axi4.wdata	=sbLs.wdata;
				axi4.wstrb	=sbLs.wstrb;
				axi4.wvalid	=sbLs.wvalid;
				sbLs.wready	=axi4.wready;
				sbLs.bresp	=axi4.bresp;
				sbLs.bvalid	=axi4.bvalid;
				axi4.bready	=sbLs.bready;
				end
			ARBifuR:begin
				axi4.araddr	=sbIf.araddr;
				axi4.arvalid=sbIf.arvalid;
				sbIf.arready=axi4.arready;
				sbIf.rdata	=axi4.rdata;
				sbIf.rresp	=axi4.rresp;
				sbIf.rvalid	=axi4.rvalid;
				axi4.rready	=sbIf.rready;
				end
	endcase end
	endmodule
module ysyx_26020046_rv32iIFU(
	AXI4_Lite_t.CPU sbIf,
	IfId_t.IFU nIfId,
	val_t.IFU val,
	input logic clk,reset
	);

	CPUstatus_t ns,s;
	always_comb	unique case(s)//两段状态转移会有1周期延迟
			CPUfunc:ns=nIfId.ready	?CPUcall:CPUfunc;
			CPUcall:ns=sbIf.arready	?CPUback:CPUcall;
			CPUback:ns=sbIf.rvalid	?CPUfunc:CPUback;
			default:ns=CPUcall;
	endcase always_ff@(posedge clk)if(reset)begin
			s<=CPUcall;
		end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"IFU:s=%s,ns=%s ready=%b",s.name(),ns.name(),nIfId.ready);`endif
			s<=ns;
	end always_comb begin : out
		sbIf.araddr=val.pc;
		sbIf.arvalid=(s==CPUcall);

		sbIf.rready=(s==CPUback);

		sbIf.awaddr='0;
		sbIf.awvalid=false;

		sbIf.wdata='0;
		sbIf.wstrb='0;
		sbIf.wvalid=false;

		sbIf.bready=false;
	end
	logic nuseTrue=1'b1|sbIf.awready|sbIf.wready|sbIf.bvalid|(|sbIf.bresp);
	always_ff@(posedge clk)begin
		if(s==CPUback&ns==CPUfunc)nIfId.code<=sbIf.rdata;
	end
	always_comb begin : in
		// nIfId.code=sbIf.rdata;
		case(sbIf.rresp)
			OKAY	:;
			default	:$stop("rresp");
		endcase

		nIfId.valid=(s==CPUfunc)&nuseTrue;//无关信号就都绑定到valid上
	end
	always_ff @(posedge clk) begin : pc
		`ifdef RV32I_DEBUG if(nIfId.enJfun) $fdisplay(logFile,"PC:%x => %x",val.pc,nIfId.addr);`endif
		if(reset) val.pc<=PC_RESET;
		else if(nIfId.valid&nIfId.ready)begin
			if(nIfId.enJfun) val.pc<=(nIfId.addr&32'hFFFFFFFC);
			else val.pc<=val.pc+4;
		end
	end	
	endmodule
module ysyx_26020046_rv32iIDU(
	IfId_t.IDU nIfId,
	output IdAl_t nIdAl,
	input enJready_t IdAlReady,
	val_t.IDU val
	);
	always_comb begin
		nIdAl.oR1	=val.oR1;
		nIdAl.oR2	=val.oR2;
		nIdAl.oCsr	=val.oCsr;
		nIdAl.pc	=val.pc;
		nIdAl.valid	=nIfId.valid;
		nIfId.addr	=IdAlReady.addr;
		nIfId.enJfun=IdAlReady.enJfun;
		nIfId.ready	=IdAlReady.ready;
	end
	always_comb begin : ID
		nIdAl.in1=IR1;nIdAl.in2=IR2;
		nIdAl.adr=NAD;nIdAl.cal=NCAL;nIdAl.bfu=NBFU;
		nIdAl.cCsr=NACSR;nIdAl.cIrd=NCHO;
		nIdAl.LSop=NM;nIdAl.enS=0;nIdAl.enL=0;
		nIdAl.SRop=NCSR_;nIdAl.SRaddr='0;
		{val.cR1,val.cR2,nIdAl.cRd,nIdAl.enJcod,nIdAl.imm}='0;

		if(nIfId.valid) begin
			`ifdef RV32I_DEBUG $fdisplay(logFile,"IDU:op=%x fun3=%x fun7=%x r1=%x r2=%x rd=%x",nIfId.code.op,nIfId.code.fun3,nIfId.code.fun7,nIfId.code.r1,nIfId.code.r2,nIfId.code.rd);`endif
			unique case(nIfId.code.op)
				OP_U_I	:nIdAl.imm={nIfId.code[31:12],12'b0 };
				OP_U_P	:nIdAl.imm={nIfId.code[31:12],12'b0 };
				OP_S__	:nIdAl.imm={{20{nIfId.code[31]}},nIfId.code[31:25],nIfId.code[11:7] };
				OP_I_A	:nIdAl.imm={{20{nIfId.code[31]}},nIfId.code[31:20]};
				OP_I_J	:nIdAl.imm={{20{nIfId.code[31]}},nIfId.code[31:20]};
				OP_I_L	:nIdAl.imm={{20{nIfId.code[31]}},nIfId.code[31:20]};
				OP_B__	:nIdAl.imm={{20{nIfId.code[31]}},nIfId.code[7],nIfId.code[30:25],nIfId.code[11:8], 1'b0 };
				OP_J__	:nIdAl.imm={{12{nIfId.code[31]}},nIfId.code[19:12],nIfId.code[20],nIfId.code[30:21], 1'b0 };
				default	:nIdAl.imm='0;
			endcase
			unique case(nIfId.code.op)
				OP_U_P	:nIdAl.in1=PC_;
				default	:nIdAl.in1=IR1;
			endcase
			unique case(nIfId.code.op)
				OP_U_P	:nIdAl.in2=IMM;
				OP_I_A	:nIdAl.in2=IMM;
				default	:nIdAl.in2=IR2;
			endcase
			unique case(nIfId.code.op)
				OP_J__	:nIdAl.enJcod=1;
				OP_I_J	:nIdAl.enJcod=1;
				OP_CSR	:nIdAl.enJcod=(nIfId.code.fun3==3'b000);
				default	:nIdAl.enJcod=0;
			endcase

			unique case(nIfId.code.op)//选ALU cal
				OP_U_P	:nIdAl.cal=ADD_;
				OP_I_A	:begin unique case(nIfId.code.fun3)
						3'b001:begin unique case(nIfId.code.fun7)
								7'b0000000:nIdAl.cal=SLL_;
								default:begin $fatal("slli fun7(%x)!=0",nIfId.code.fun7);stop(0);end
							endcase end
						3'b101:begin unique case(nIfId.code.fun7)
								7'b0000000:nIdAl.cal=SRL_;
								7'b0100000:nIdAl.cal=SRA_;
								default:begin $fatal("srai/srli fun7(%x)!=0/20",nIfId.code.fun7);stop(0);end
							endcase end
						default:nIdAl.cal=ALUopCal_t'(nIfId.code.fun3);
					endcase end
				OP_R__	:begin unique case(nIfId.code.fun7)
						7'b0000000:nIdAl.cal=ALUopCal_t'(nIfId.code.fun3);
						7'b0100000:begin unique case(nIfId.code.fun3)
								3'b000:nIdAl.cal=SUB_;
								3'b101:nIdAl.cal=SRA_;
								default:begin $fatal("R fun7==20 fun3(%x)!=1/5",nIfId.code.fun3);stop(0);end
							endcase end
						default:begin $fatal("R fun7(%x)!=0/20",nIfId.code.fun7);stop(0);end
					endcase end
				default	:nIdAl.cal=NCAL;
			endcase

			if(nIfId.code.op==OP_B__)begin//b系列
				nIdAl.bfu=ALUopBfu_t'(nIfId.code.fun3);
			end else nIdAl.bfu=NBFU;

			unique case(nIfId.code.op)//选ALU cho
				OP_U_I	:nIdAl.cIrd=IMM_;
				OP_U_P	:nIdAl.cIrd=CAL_;
				OP_J__	:nIdAl.cIrd=SNPC;
				OP_I_J	:nIdAl.cIrd=SNPC;
				OP_I_A	:nIdAl.cIrd=CAL_;
				OP_R__	:nIdAl.cIrd=CAL_;
				OP_CSR	:nIdAl.cIrd=CCSR;
				default	:nIdAl.cIrd=NCHO;
			endcase
			unique case(nIfId.code.op)//选ALU addr
				OP_J__	:nIdAl.adr=PCI;
				OP_I_J	:nIdAl.adr=R1I;
				OP_I_L	:nIdAl.adr=R1I;
				OP_CSR	:nIdAl.adr=ECJ;
				OP_B__	:nIdAl.adr=PCI;
				OP_S__	:nIdAl.adr=R1I;
				default	:nIdAl.adr=NAD;
			endcase

			unique case(nIfId.code.op)//选LSU op
				OP_I_L	:nIdAl.LSop=LSUop_t'(nIfId.code.fun3);
				OP_S__	:nIdAl.LSop=LSUop_t'(nIfId.code.fun3);
				default	:nIdAl.LSop=NM;
			endcase
			nIdAl.enL=(nIfId.code.op==OP_I_L);
			nIdAl.enS=(nIfId.code.op==OP_S__);

			if(nIfId.code.op==OP_CSR)begin unique case(nIfId.code.fun3)
				3'b000	:nIdAl.cCsr=JUMP_;
				3'b001	:nIdAl.cCsr=WACSR;						
				3'b010	:nIdAl.cCsr=(nIfId.code.r1=='0)?NACSR:RACSR;
				default	:nIdAl.cCsr=NACSR;						
			endcase  unique case(nIfId.code.fun3)
				3'b000	:begin unique case(nIfId.code)
						OP_CSR_MRET__	:begin nIdAl.SRaddr=CSR_ADDR_MEPC;		end
						OP_CSR_ECALL_	:begin nIdAl.SRaddr=CSR_ADDR_MTVEC;	end
						OP_CSR_EBREAK	:begin nIdAl.SRaddr='0;stop(1);		end
						default			:begin nIdAl.SRaddr='0;stop(0);		end endcase end
				3'b001					:begin nIdAl.SRaddr={nIfId.code[31:20]};end
				3'b010					:begin nIdAl.SRaddr={nIfId.code[31:20]};end
				default					:begin nIdAl.SRaddr='0;				end
			endcase  unique case(nIfId.code.fun3)
				3'b000	:begin unique case(nIfId.code)
						OP_CSR_MRET__	:nIdAl.SRop=MRET_;
						OP_CSR_ECALL_	:nIdAl.SRop=ECALL;
						OP_CSR_EBREAK	:nIdAl.SRop=NCSR_;
						default			:nIdAl.SRop=NCSR_;endcase end
				3'b001					:nIdAl.SRop=WCCSR;
				3'b010					:nIdAl.SRop=(nIfId.code.r1=='0)?NCSR_:WCCSR;
				default					:nIdAl.SRop=NCSR_;
			endcase end else begin nIdAl.cCsr=NACSR;nIdAl.SRaddr='0;nIdAl.SRop=NCSR_;end
			val.SRaddr=nIdAl.SRaddr;

			unique case(nIfId.code.op)//选cR1 这里7/10就反选
				OP_U_I	:val.cR1='0;
				OP_U_P	:val.cR1='0;
				OP_J__	:val.cR1='0;
				default	:val.cR1=nIfId.code.r1;
			endcase
			// $fdisplay(logFile,"cR1=%x opR1=%b code=%b",val.cR1,nIfId.code.r1,nIfId.code);
			unique case(nIfId.code.op)//选cR2
				OP_S__	:val.cR2=nIfId.code.r2;
				OP_R__	:val.cR2=nIfId.code.r2;
				OP_B__	:val.cR2=nIfId.code.r2;
				default	:val.cR2='0;
			endcase
			unique case(nIfId.code.op)//选cRd 也是反选
				OP_B__	:nIdAl.cRd='0;
				OP_S__	:nIdAl.cRd='0;
				OP_CSR	:nIdAl.cRd=(nIfId.code.fun3==3'b000)?'0:nIfId.code.rd;
				default	:nIdAl.cRd=nIfId.code.rd;
			endcase
		end
	end
	endmodule
module ysyx_26020046_rv32iALU(
	input  IdAl_t nIdAl,
	output enJready_t IdAlReady,
	output AlLs_t nAlLs,
	input  logic AlLsReady
	);
	logic enBfun;
	word_t result,in1,in2;
	IdAl_t oIdAl;

	always_comb oIdAl=nIdAl;

	always_comb begin
		nAlLs.oR2		=oIdAl.oR2;
		nAlLs.enS		=oIdAl.enS;
		nAlLs.enL		=oIdAl.enL;
		nAlLs.LSop		=oIdAl.LSop;
		nAlLs.cRd		=oIdAl.cRd;
		nAlLs.SRaddr	=oIdAl.SRaddr;
		nAlLs.SRop		=oIdAl.SRop;
		nAlLs.valid		=oIdAl.valid;
		IdAlReady.ready	=AlLsReady;
	end

	always_comb begin if(oIdAl.valid)begin
			// $fdisplay(logFile,"val cR1=%x cR2=%x oR1=%x oR2=%x SRaddr=%x oCsr=%x pc=%x",val.cR1,val.cR2,val.oR1,val.oR2,val.SRaddr,val.oCsr,val.pc);
		unique case(oIdAl.in1)
			IR1:in1=oIdAl.oR1;
			PC_:in1=oIdAl.pc;
			default:begin in1='0;$fatal("unknown in1==0x%x",oIdAl.in1);end
		endcase
		unique case(oIdAl.in2)
			IR2:in2=oIdAl.oR2;
			IMM:in2=oIdAl.imm;
			default:begin in2='0;$fatal("unknown in2==0x%x",oIdAl.in2);end
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
			default:begin result='0;$fatal("unknown cal==0x%x",oIdAl.cal);end
		endcase
		
		unique case(oIdAl.cIrd)
			CAL_:nAlLs.res=result;
			IMM_:nAlLs.res=oIdAl.imm;
			CCSR:nAlLs.res=oIdAl.oCsr;
			SNPC:nAlLs.res=oIdAl.pc+4;
			NCHO:nAlLs.res='0;
			default:begin nAlLs.res='0;$error("unknown cho==0x%x",oIdAl.cIrd);$stop;end
		endcase
		unique case(oIdAl.cCsr)
			WACSR:nAlLs.iCsr=oIdAl.oR1;
			RACSR:nAlLs.iCsr=oIdAl.oR1|oIdAl.oCsr;
			JUMP_:nAlLs.iCsr=oIdAl.pc;
			NCSR_:nAlLs.iCsr='0;
			default:begin nAlLs.iCsr='0;$error("unknown csr==0x%x",oIdAl.cCsr);$stop;end
		endcase
		unique case(oIdAl.bfu)
			BEQ_:enBfun=(oIdAl.oR1==oIdAl.oR2);
			BNE_:enBfun=(oIdAl.oR1!=oIdAl.oR2);
			BLT_:enBfun=(   $signed(oIdAl.oR1) <  $signed(oIdAl.oR2));
			BGE_:enBfun=(   $signed(oIdAl.oR1)>=  $signed(oIdAl.oR2));
			BLTU:enBfun=( $unsigned(oIdAl.oR1) <$unsigned(oIdAl.oR2));
			BGEU:enBfun=( $unsigned(oIdAl.oR1)>=$unsigned(oIdAl.oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;$fatal("unknown bfu==0x%x",oIdAl.bfu);end
			endcase
		unique case(oIdAl.adr)
			R1I:nAlLs.addr=oIdAl.oR1+oIdAl.imm;
			PCI:nAlLs.addr=oIdAl.pc +oIdAl.imm;
			ECJ:nAlLs.addr=oIdAl.oCsr;
			ERE:nAlLs.addr=oIdAl.oCsr;
			NAD:nAlLs.addr='0;
			default:begin nAlLs.addr='0;$fatal("unknown adr==0x%x",oIdAl.adr);end
		endcase
		IdAlReady.enJfun=oIdAl.enJcod|enBfun;
		IdAlReady.addr=nAlLs.addr;
	end end
	endmodule
module ysyx_26020046_rv32iLSU(
	AXI4_Lite_t sbLs,
	input  AlLs_t nAlLs,
	input  logic LsRgReady,LsSrReady,
	output LsRg_t nLsRg,
	output LsSr_t nLsSr,
	output logic AlLsReady,
	input  logic clk,reset
	);

	AlLs_t oAlLs;

	mask_t mask;
	word_t iRAM,data;
	logic hasAddr,hasData;
	CPUstatus_t Rs,nRs,Ws,nWs;
	logic Rfinish,Wfinish,LsWbValid;

	always_comb oAlLs=nAlLs;

	always_comb case(Rs)
			CPUfunc:nRs=(oAlLs.enL&(~Rfinish)	)?CPUcall:CPUfunc;
			CPUcall:nRs=(sbLs.arready			)?CPUback:CPUcall;
			CPUback:nRs=(sbLs.rvalid			)?CPUfunc:CPUback;
			default:nRs=CPUfunc;
	endcase always_ff@(posedge clk) if(reset)begin
			Rs<=CPUfunc;
	end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"LSU:Rs=%s nRs=%s",Rs.name(),nRs.name());`endif
			Rs<=nRs;
	end always_ff@(posedge clk) begin
			iRAM<=(Rs==CPUback&nRs==CPUfunc)?sbLs.rdata:'0;
			if(Rs==CPUback&nRs==CPUfunc)Rfinish<=true;
			if(AlLsReady&LsWbValid)		Rfinish<=false;
	end always_comb begin
			sbLs.araddr	=oAlLs.addr;
			sbLs.arvalid=(Rs==CPUcall);
			sbLs.rready	=(Rs==CPUback);
			case(sbLs.rresp)
				OKAY:;
				default:begin $fatal("unknown rresp==0x%x",sbLs.rresp);end
			endcase
	end

	always_comb case(Ws)
			CPUfunc:nWs=(oAlLs.enS&(~Wfinish)	)?CPUcall:CPUfunc;
			CPUcall:nWs=(hasAddr&hasData		)?CPUback:CPUcall;
			CPUback:nWs=(sbLs.bvalid			)?CPUfunc:CPUback;
			default:nWs=CPUfunc;
	endcase always_ff@(posedge clk) if(reset&(~oAlLs.valid))begin
			Ws<=CPUfunc;
	end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"LSU:Ws=%s nWs=%s",Ws.name(),nWs.name());`endif
			Ws<=nWs;
	end always_ff@(posedge clk) begin
			if(Ws==CPUcall&sbLs.awready)hasAddr<=true;
			if(Ws==CPUback|Ws==CPUfunc)	hasAddr<=false;
			if(Ws==CPUcall&sbLs.wready)	hasData<=true;
			if(Ws==CPUback|Ws==CPUfunc)	hasData<=false;
			if(Ws==CPUback&nWs==CPUfunc)Wfinish<=true;
			if(AlLsReady&LsWbValid)		Wfinish<=false;
	end always_comb begin
			sbLs.awaddr	=oAlLs.addr;
			sbLs.awvalid=(Ws==CPUcall);
			sbLs.wdata	=oAlLs.oR2;
			sbLs.wstrb	=mask;
			sbLs.wvalid	=(Ws==CPUcall);
			sbLs.bready	=(Ws==CPUback);
			case(sbLs.bresp)
				OKAY:;
				default:begin $fatal("unknown bresp==0x%x",sbLs.bresp);end
			endcase
	end
	always_comb begin
		nLsRg.iRd	=(oAlLs.enS|oAlLs.enL)?data:oAlLs.res;
		nLsRg.cRd	=oAlLs.cRd;
		nLsSr.iCsr	=oAlLs.iCsr;
		nLsSr.SRaddr=oAlLs.SRaddr;
		nLsSr.SRop	=oAlLs.SRop;
		LsWbValid	=(~(oAlLs.enL^Rfinish))&(~(oAlLs.enS^Wfinish))&oAlLs.valid;
		nLsSr.valid	=LsWbValid;
		nLsRg.valid	=LsWbValid;
		AlLsReady	=(~(oAlLs.enL^Rfinish))&(~(oAlLs.enS^Wfinish))&LsRgReady&LsSrReady;
	end
	always_comb begin
		`ifdef RV32I_DEBUG if(oAlLs.enL)$fdisplay(logFile,"LSU:enL=%b valid=%b iRAM=%x",oAlLs.enL,oAlLs.valid,iRAM);`endif
		if (oAlLs.enS&oAlLs.valid) begin unique case(oAlLs.LSop)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;$fatal("unknown mask==0x%x",oAlLs.LSop);end
		endcase end else 	mask=4'b0000;
		if(oAlLs.enL&oAlLs.valid) begin unique case(oAlLs.LSop)
			B_:				data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				data=iRAM;
			BU:				data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	data=0;$fatal("unknown date==0x%x",oAlLs.LSop);end
		endcase end else 	data='0;
		`ifdef RV32I_DEBUG if(oAlLs.enL)$fstrobe(logFile,"LSU:enL=%b valid=%b data=%x iRAM=%x",oAlLs.enL,oAlLs.valid,data,iRAM);`endif
	end
	endmodule
module ysyx_26020046_rv32iGPR(
	input  LsRg_t nLsRg,
	output logic LsRgReady,
	val_t. GPR val,
	input  clk,reset
	);

	LsRg_t oLsRg;

	always_comb oLsRg=nLsRg;

	word_t gpr [2**REG_NUMBER -1:1];

	assign LsRgReady=1;
	always_ff@(posedge clk) begin:reg_write
		if(reset)begin
			for (int i = 1; i < 32; i++) gpr[i]<='0;
		end else if(oLsRg.valid)begin
			`ifdef RV32I_DEBUG if(oLsRg.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",oLsRg.cRd,gpr[oLsRg.cRd],oLsRg.iRd);`endif
			if (oLsRg.cRd!=0) gpr[oLsRg.cRd] <= oLsRg.iRd;
    	end
	end
	assign val.oR1=(val.cR1==0)?'0:gpr[val.cR1];
	assign val.oR2=(val.cR2==0)?'0:gpr[val.cR2];

	export "DPI-C" function getReg;
	function int getReg(input int addr);
		return (addr == 0) ? val.pc : gpr[addr];
	endfunction
	endmodule
module ysyx_26020046_rv32iCSR(
	input  LsSr_t nLsSr,
	output logic LsSrReady,
	val_t.CSR val,
	input  clk,reset
	);

	LsSr_t oLsSr;

	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

	always_comb oLsSr=nLsSr; 

	assign LsSrReady=1;
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
					default:begin $fatal("unknown csrAddr==0x%x",oLsSr.SRaddr); end
					endcase end
				NCSR_:;
				default:begin $fatal("unknown op.SRop==0x%x",oLsSr.SRop); end
			endcase end
			end
		end

	always_comb begin:choose_csr
		unique case(val.SRaddr)
			CSR_ADDR_MEPC		:val.oCsr=mepc;
			CSR_ADDR_MSTAUS		:val.oCsr=mstatus;
			CSR_ADDR_MTVEC		:val.oCsr=mtvec;
			CSR_ADDR_MCAUSE		:val.oCsr=mcause;
			CSR_ADDR_MCYCLE		:val.oCsr=mcycle;
			CSR_ADDR_MCYCLEH	:val.oCsr=mcycleh;
			CSR_ADDR_MARCHID	:val.oCsr=marchid;
			CSR_ADDR_MVENDORID	:val.oCsr=mvendorid;
			default				:val.oCsr='0;
		endcase
	end
	endmodule
