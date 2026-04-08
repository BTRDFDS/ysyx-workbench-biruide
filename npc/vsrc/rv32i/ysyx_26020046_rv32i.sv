package rv32iBasis;
	// `define RV32I_DEBUG
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
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
	

	parameter MSTATUS_RESET = 32'h1800;

	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;
	typedef enum logic[3:0] {ADD_,SLL_,SLT_,SLTU,XOR_,SRL_,OR__,AND_,SUB_,SRA_,NCAL} ALUopCal_t;
	typedef enum logic[2:0] {BEQ_,BNE_,NBFU,BLT_='b100,BGE_,BLTU='b110,BGEU} ALUopBfu_t;
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NACSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[2:0] {NCHO,CAL_,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[0:0] {IR1,PC_} in1_t;
	typedef enum logic[0:0] {IR2,IMM} in2_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;

	typedef enum logic [1:0] {IDLE,WAIT} ifuStatus_t;


	typedef struct packed {
		logic [6:0] fun7;
		logic [4:0] r2;
		logic [4:0] r1;
		logic [2:0] fun3;
		logic [4:0] rd;
		logic [6:0] op;
	} code_t;

	`ifdef RV32I_DEBUG
		integer logFile;
	`endif
	
	import "DPI-C" function void stop(input bit eb);
	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
	endpackage
interface IfId_t();
	import rv32iBasis::*;
	code_t code;
	modport IFU(output code);
	modport IDU(input  code);
	modport IN_(input  code);
	modport OUT(output code);
	endinterface
interface IdAl_t();
	import rv32iBasis::*;
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
	
	logic [11:0] SRaddr;
	CSRop_t SRop;

	word_t oR1,oR2,oCsr,imm,pc;

	modport IDU(output in1,in2,oR1,oR2,oCsr,imm,pc,enJcod,cal,bfu,adr,cCsr,cIrd,enL,enS,LSop,SRaddr,SRop,cRd);
	modport ALU(input  in1,in2,oR1,oR2,oCsr,imm,pc,enJcod,cal,bfu,adr,cCsr,cIrd);
	modport IN_(input  in1,in2,oR1,oR2,oCsr,imm,pc,enJcod,cal,bfu,adr,cCsr,cIrd,enL,enS,LSop,SRaddr,SRop,cRd);
	modport OUT(output in1,in2,oR1,oR2,oCsr,imm,pc,enJcod,cal,bfu,adr,cCsr,cIrd,enL,enS,LSop,SRaddr,SRop,cRd);
	endinterface
interface AlLs_t();
	import rv32iBasis::*;
	logic enS,enL;
	LSUop_t LSop;
	word_t addr,res,iCsr,oR2;
	logic [11:0] SRaddr;
	CSRop_t SRop;

	reg_t cRd;
	modport ALU(output addr,res,iCsr,oR2);
	modport LSU(input  enS,enL,LSop,res,addr,oR2);
	modport IN_(input  enS,enL,LSop,res,addr,oR2,cRd,iCsr,SRaddr,SRop);
	modport OUT(output enS,enL,LSop,res,addr,oR2,cRd,iCsr,SRaddr,SRop);
	endinterface
interface AlIf_t();
	import rv32iBasis::*;
	word_t addr;
	logic enJfun;
	modport ALU(output addr,enJfun);
	modport IFU(input  addr,enJfun);
	modport IN_(input  addr,enJfun);
	endinterface
interface LsWb_t();
	import rv32iBasis::*;
	reg_t cRd;
	logic [11:0] SRaddr;
	CSRop_t SRop;
	word_t iRd,iCsr;
	modport LSU(output iRd);
	modport GPR(input  iRd,cRd);
	modport CSR(input  iCsr,SRaddr,SRop);
	modport IN_(input  iRd,cRd,iCsr,SRaddr,SRop);
	modport OUT(output iRd,cRd,iCsr,SRaddr,SRop);
	endinterface
interface val_t();
	import rv32iBasis::*;
	reg_t cR1,cR2;
	logic [11:0] SRaddr;
	word_t oR1,oR2,oCsr,pc;
	modport IDU(input oR1,oR2,pc,oCsr,output cR1,cR2,SRaddr);
	modport GPR(input cR1,cR2,output oR1,oR2,input pc);//PC用于getReg的调试
	modport CSR(input SRaddr ,output oCsr);
	modport IFU(output pc);
	endinterface;
interface SimpleBus_t();
	import rv32iBasis::*;
	word_t addr,rdata;
	modport IFU(input rdata,output addr);
	modport MEM(output rdata,input addr);
	endinterface
module ysyx_26020046_rv32i(
	input logic clk,
	input logic reset
	);
	import rv32iBasis::*;

	IfId_t nIfId();
	IfId_t oIfId();
	IdAl_t nIdAl();
	IdAl_t oIdAl();
	AlLs_t nAlLs();
	AlLs_t oAlLs();
	AlIf_t iAlIf();
	LsWb_t nLsWb();
	LsWb_t oLsWb();
	val_t val();
	SimpleBus_t sbIf();

	ysyx_26020046_rv32iMEM MEM(.*);
	ysyx_26020046_rv32iWater Water(.*);
	ysyx_26020046_rv32iIFU IFU(.*);
	ysyx_26020046_rv32iIDU IDU(.*);
	ysyx_26020046_rv32iALU ALU(.*);
	ysyx_26020046_rv32iLSU LSU(.*);
	ysyx_26020046_rv32iGPR GPR(.*);
	ysyx_26020046_rv32iCSR CSR(.*);

	`ifdef RV32I_DEBUG
		initial begin
			logFile = $fopen("log/rv32iDebugLog.txt");
			$write("\033[1;35m SV_DEBUG \033[0m");
		end
		always @(posedge clk) begin
			if(reset)$fdisplay(logFile,"!!!reset!!!");
			else begin
				$fdisplay(logFile,"nIfId code=%x",nIfId.code);
				$fdisplay(logFile,"oIfId code=%x",oIfId.code);
				$fdisplay(logFile,"val cR1=%x cR2=%x oR1=%x oR2=%x SRaddr=%x oCsr=%x pc=%x",val.cR1,val.cR2,val.oR1,val.oR2,val.SRaddr,val.oCsr,val.pc);
				$fdisplay(logFile,"nIdAl in1=%s in2=%s oR1=%x oR2=%x oCsr=%x imm=%x pc=%x enJcod=%b cal=%s adr=%s cCsr=%s cIrd=%s enL=%b enS=%b LSop=%s SRaddr=%x SRop=%s cRd=%x",nIdAl.in1.name(),nIdAl.in2.name(),nIdAl.oR1,nIdAl.oR2,nIdAl.oCsr,nIdAl.imm,nIdAl.pc,nIdAl.enJcod,nIdAl.cal.name(),nIdAl.adr.name(),nIdAl.cCsr.name(),nIdAl.cIrd.name(),nIdAl.enL,nIdAl.enS,nIdAl.LSop.name(),nIdAl.SRaddr,nIdAl.SRop.name(),nIdAl.cRd);
				$fdisplay(logFile,"oIdAl in1=%s in2=%s oR1=%x oR2=%x oCsr=%x imm=%x pc=%x enJcod=%b cal=%s adr=%s cCsr=%s cIrd=%s enL=%b enS=%b LSop=%s SRaddr=%x SRop=%s cRd=%x",oIdAl.in1.name(),oIdAl.in2.name(),oIdAl.oR1,oIdAl.oR2,oIdAl.oCsr,oIdAl.imm,oIdAl.pc,oIdAl.enJcod,oIdAl.cal.name(),oIdAl.adr.name(),oIdAl.cCsr.name(),oIdAl.cIrd.name(),oIdAl.enL,oIdAl.enS,oIdAl.LSop.name(),oIdAl.SRaddr,oIdAl.SRop.name(),oIdAl.cRd);
				$fdisplay(logFile,"nAlLs enS=%b enL=%b LSop=%s res=%x addr=%x oR2=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nAlLs.enS,nAlLs.enL,nAlLs.LSop.name(),nAlLs.res,nAlLs.addr,nAlLs.oR2,nAlLs.cRd,nAlLs.iCsr,nAlLs.SRaddr,nAlLs.SRop.name());
				$fdisplay(logFile,"oAlLs enS=%b enL=%b LSop=%s res=%x addr=%x oR2=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",oAlLs.enS,oAlLs.enL,oAlLs.LSop.name(),oAlLs.res,oAlLs.addr,oAlLs.oR2,oAlLs.cRd,oAlLs.iCsr,oAlLs.SRaddr,oAlLs.SRop.name());
				$fdisplay(logFile,"iAlIf addr=%x enJfun=%b",iAlIf.addr,iAlIf.enJfun);
				$fdisplay(logFile,"nLsWb iRd=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nLsWb.iRd,nLsWb.cRd,nLsWb.iCsr,nLsWb.SRaddr,nLsWb.SRop.name());
				$fdisplay(logFile,"oLsWb iRd=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",oLsWb.iRd,oLsWb.cRd,oLsWb.iCsr,oLsWb.SRaddr,oLsWb.SRop.name());
			end
			$fstrobe(logFile,"");
		end
	`endif
	endmodule
module ysyx_26020046_rv32iMEM(
	SimpleBus_t.MEM sbIf
	);
	import rv32iBasis::*;
	// always_ff@(posedge op.clk) begin
	// 	sbIf.rdata<=pmem_read(sbIf.addr);
	// end
	assign sbIf.rdata = pmem_read(sbIf.addr);
	endmodule
module ysyx_26020046_rv32iWater(
	IfId_t.IN_ nIfId,
	IfId_t.OUT oIfId,
	IdAl_t.IN_ nIdAl,
	IdAl_t.OUT oIdAl,
	AlLs_t.IN_ nAlLs,
	AlLs_t.OUT oAlLs,
	// AlIf_t.IN_ iAlIf,
	LsWb_t.IN_ nLsWb,
	LsWb_t.OUT oLsWb
	);
	always_comb begin
		oIfId.code=nIfId.code;
	end
	always_comb begin
		oIdAl.in1	=nIdAl.in1;
		oIdAl.in2	=nIdAl.in2;
		oIdAl.oR1	=nIdAl.oR1;
		oIdAl.oR2	=nIdAl.oR2;
		oIdAl.oCsr	=nIdAl.oCsr;
		oIdAl.imm	=nIdAl.imm;
		oIdAl.pc	=nIdAl.pc;
		oIdAl.enJcod=nIdAl.enJcod;
		oIdAl.adr	=nIdAl.adr;
		oIdAl.cal	=nIdAl.cal;
		oIdAl.bfu	=nIdAl.bfu;
		oIdAl.cCsr	=nIdAl.cCsr;
		oIdAl.cIrd	=nIdAl.cIrd;
		oIdAl.enL	=nIdAl.enL;
		oIdAl.enS	=nIdAl.enS;
		oIdAl.LSop	=nIdAl.LSop;
		oIdAl.SRaddr=nIdAl.SRaddr;
		oIdAl.SRop	=nIdAl.SRop;
		oIdAl.cRd	=nIdAl.cRd;
	end
	always_comb begin
		oAlLs.enS	=oIdAl.enS;
		oAlLs.enL	=oIdAl.enL;
		oAlLs.LSop	=oIdAl.LSop;
		oAlLs.res	=nAlLs.res;
		oAlLs.addr	=nAlLs.addr;
		oAlLs.oR2	=nAlLs.oR2;
		oAlLs.cRd	=oIdAl.cRd;
		oAlLs.iCsr	=nAlLs.iCsr;
		oAlLs.SRaddr=oIdAl.SRaddr;
		oAlLs.SRop	=oIdAl.SRop;
	end
	always_comb begin
		oLsWb.iRd	=nLsWb.iRd;
		oLsWb.cRd	=oAlLs.cRd;
		oLsWb.iCsr	=oAlLs.iCsr;
		oLsWb.SRaddr=oAlLs.SRaddr;
		oLsWb.SRop	=oAlLs.SRop;
	end
	endmodule
module ysyx_26020046_rv32iIFU(
	SimpleBus_t.IFU sbIf,
	IfId_t.IFU nIfId,
	AlIf_t.IFU iAlIf,
	val_t.IFU val,
	input logic clk,reset
	);
	import rv32iBasis::*;

	assign sbIf.addr=val.pc;
	assign nIfId.code=sbIf.rdata;

	always_ff @(posedge clk) begin : pc
	`ifdef RV32I_DEBUG
		if(iAlIf.enJfun) $fdisplay(logFile,"PC:%x => %x",val.pc,iAlIf.addr);
	`endif
		if(reset) val.pc<=PC_RESET;
		else if(iAlIf.enJfun) val.pc<=(iAlIf.addr&32'hFFFFFFFC);
		else val.pc<=val.pc+4;
	end	
	endmodule
module ysyx_26020046_rv32iIDU(
	IfId_t.IDU oIfId,
	IdAl_t.IDU nIdAl,
	val_t.IDU val
	);
	import rv32iBasis::*;
	assign nIdAl.oR1	=val.oR1;
	assign nIdAl.oR2	=val.oR2;
	assign nIdAl.oCsr	=val.oCsr;
	assign nIdAl.pc		=val.pc;
	always_comb begin : ID
		nIdAl.in1=IR1;nIdAl.in2=IR2;
		nIdAl.adr=NAD;nIdAl.cal=NCAL;nIdAl.bfu=NBFU;
		nIdAl.cCsr=NACSR;nIdAl.cIrd=NCHO;
		nIdAl.LSop=NM;nIdAl.enS=0;nIdAl.enL=0;
		nIdAl.SRop=NCSR_;nIdAl.SRaddr='0;
		{val.cR1,val.cR2,nIdAl.cRd,nIdAl.enJcod,nIdAl.imm}='0;

		// if(~op.reset) begin
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
								default:begin $fatal("slli fun7(%x)!=0",oIfId.code.fun7);stop(0);end
							endcase end
						3'b101:begin unique case(oIfId.code.fun7)
								7'b0000000:nIdAl.cal=SRL_;
								7'b0100000:nIdAl.cal=SRA_;
								default:begin $fatal("srai/srli fun7(%x)!=0/20",oIfId.code.fun7);stop(0);end
							endcase end
						default:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
					endcase end
				OP_R__	:begin unique case(oIfId.code.fun7)
						7'b0000000:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
						7'b0100000:begin unique case(oIfId.code.fun3)
								3'b000:nIdAl.cal=SUB_;
								3'b101:nIdAl.cal=SRA_;
								default:begin $fatal("R fun7==20 fun3(%x)!=1/5",oIfId.code.fun3);stop(0);end
							endcase end
						default:begin $fatal("R fun7(%x)!=0/20",oIfId.code.fun7);stop(0);end
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
						OP_CSR_EBREAK	:begin nIdAl.SRaddr='0;stop(1);		end
						default			:begin nIdAl.SRaddr='0;stop(0);		end endcase end
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
			val.SRaddr=nIdAl.SRaddr;

			unique case(oIfId.code.op)//选cR1 这里7/10就反选
				OP_U_I	:val.cR1='0;
				OP_U_P	:val.cR1='0;
				OP_J__	:val.cR1='0;
				default	:val.cR1=oIfId.code.r1;
			endcase
			unique case(oIfId.code.op)//选cR2
				OP_S__	:val.cR2=oIfId.code.r2;
				OP_R__	:val.cR2=oIfId.code.r2;
				OP_B__	:val.cR2=oIfId.code.r2;
				default	:val.cR2='0;
			endcase
			unique case(oIfId.code.op)//选cRd 也是反选
				OP_B__	:nIdAl.cRd='0;
				OP_S__	:nIdAl.cRd='0;
				OP_CSR	:nIdAl.cRd=(oIfId.code.fun3==3'b000)?'0:oIfId.code.rd;
				default	:nIdAl.cRd=oIfId.code.rd;
			endcase
		end
	// end
	endmodule
module ysyx_26020046_rv32iALU(
	IdAl_t oIdAl,
	AlLs_t nAlLs,
	AlIf_t iAlIf
	);
	import rv32iBasis::*;
	logic enBfun;
	word_t result,in1,in2;

	assign nAlLs.oR2=oIdAl.oR2;
	always_comb begin : cal
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
	end
	always_comb begin : bfu
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
	end
	always_comb begin : adr
		unique case(oIdAl.adr)
			R1I:nAlLs.addr=oIdAl.oR1+oIdAl.imm;
			PCI:nAlLs.addr=oIdAl.pc +oIdAl.imm;
			ECJ:nAlLs.addr=oIdAl.oCsr;
			ERE:nAlLs.addr=oIdAl.oCsr;
			NAD:nAlLs.addr='0;
			default:begin nAlLs.addr='0;$fatal("unknown adr==0x%x",oIdAl.adr);end
		endcase
		iAlIf.enJfun=oIdAl.enJcod|enBfun;
		iAlIf.addr=nAlLs.addr;
	end
	endmodule
module ysyx_26020046_rv32iLSU(
	AlLs_t.LSU oAlLs,
	LsWb_t.LSU nLsWb,
	input clk
	);
	import rv32iBasis::*;

	logic[3:0] mask;
	word_t iRAM,data;

	assign nLsWb.iRd=(oAlLs.enS|oAlLs.enL)?data:oAlLs.res;
	always_comb begin : choose_mask
		if (oAlLs.enS) begin unique case(oAlLs.LSop)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;$fatal("unknown mask==0x%x",oAlLs.LSop);end
		endcase end else 	mask=4'b0000;
	end
	always_comb begin : choose_date_input
		if(oAlLs.enL) begin unique case(oAlLs.LSop)
			B_:				data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				data=iRAM;
			BU:				data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	data=0;$fatal("unknown date==0x%x",oAlLs.LSop);end
		endcase end else 	data='0;
	end
	always_comb begin :write
		if((oAlLs.enL)&clk)begin
			iRAM=pmem_read(oAlLs.addr);
			`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:RESD  [%x] => %x",oAlLs.addr,iRAM);`endif
		end else iRAM = '0;
	end
	always_ff@(posedge clk) begin:control_write
		if (oAlLs.enS) begin // 有写请求时
			`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:write [%x] <(%b)= %x",oAlLs.addr,mask,oAlLs.oR2);`endif
			pmem_write(oAlLs.addr,oAlLs.oR2, {4'b0,mask});
		end
	end
	endmodule
module ysyx_26020046_rv32iGPR(
	LsWb_t.GPR oLsWb,
	val_t.GPR val,
	input clk,reset
	);
	import rv32iBasis::*;

	word_t gpr [2**REG_NUMBER -1:1];

	always_ff@(posedge clk) begin:reg_write
		if(reset)begin
			for (int i = 1; i < 32; i++) gpr[i]<='0;
		end else begin
			`ifdef RV32I_DEBUG if(oLsWb.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",oLsWb.cRd,gpr[oLsWb.cRd],oLsWb.iRd);`endif
			if (oLsWb.cRd!=0) gpr[oLsWb.cRd] <= oLsWb.iRd;
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
	LsWb_t.CSR oLsWb,
	output val_t val,
	input clk,reset
	);
	import rv32iBasis::*;

	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

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
				if(oLsWb.SRop==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,oLsWb.iCsr,mcause,11);
				else if(oLsWb.SRop==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,oLsWb.iCsr,mcause,0);
				else if(oLsWb.SRop==WCCSR)begin unique case(oLsWb.SRaddr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				oLsWb.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		oLsWb.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			oLsWb.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			oLsWb.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			oLsWb.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		oLsWb.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		oLsWb.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	oLsWb.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",oLsWb.SRaddr); end
				endcase end
			end
	`endif
			{mcycleh,mcycle}<={mcycleh,mcycle}+1;
			unique case(oLsWb.SRop)
				ECALL:begin mepc<=oLsWb.iCsr;mcause<=11;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;end
				WCCSR:begin unique case(oLsWb.SRaddr)
					CSR_ADDR_MEPC		:mepc		<=oLsWb.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=oLsWb.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=oLsWb.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=oLsWb.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=oLsWb.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=oLsWb.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=oLsWb.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=oLsWb.iCsr;
					default:begin $fatal("unknown csrAddr==0x%x",oLsWb.SRaddr); end
					endcase end
				NCSR_:;
				default:begin $fatal("unknown op.SRop==0x%x",oLsWb.SRop); end
				endcase
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
