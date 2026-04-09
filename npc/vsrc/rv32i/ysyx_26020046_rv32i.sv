package rv32iBasis;
	`define RV32I_DEBUG
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

	typedef struct packed {
		logic [6:0] fun7;
		logic [4:0] r2;
		logic [4:0] r1;
		logic [2:0] fun3;
		logic [4:0] rd;
		logic [6:0] op;
	} code_t;

	typedef enum logic [0:0]{IFUidle,IFUwait} IFUstatus_t;

	`ifdef RV32I_DEBUG
		integer logFile;
	`endif

	typedef struct packed {
		reg_t cRd;
		word_t iRd;
	} LsRg_p;
	typedef struct packed {
		logic [11:0] SRaddr;
		CSRop_t SRop;
		word_t iCsr;
	} LsSr_p;
	typedef struct packed {
		LsRg_p Gpr;
		LsSr_p Csr;
	} LsWb_p;
	typedef struct packed {
	logic enS,enL;
	LSUop_t LSop;
	word_t addr,res,oR2;
	LsWb_p Wbu;
	} AlLs_p;
	typedef struct packed {
	in1_t		in1;
	in2_t		in2;
	logic 		enJcod;
	ALUopCal_t 	cal;
	ALUopBfu_t	bfu;
	ALUopADR_t	adr;
	ALUopCsr_t	cCsr;
	ALUopCho_t	cIrd;

	word_t oR1,oR2,oCsr,imm,pc;

	AlLs_p LS;
	} IdAl_p;
	
	import "DPI-C" function void stop(input bit eb);
	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
	endpackage
interface IfId_t();
	import rv32iBasis::*;
	logic valid,ready,enJfun;
	word_t addr;
	code_t code;
	modport IFU(output code,valid,input  ready,addr,enJfun);
	modport IDU(input  code,valid,output ready,addr,enJfun);
	endinterface
interface IdAl_t();
	import rv32iBasis::*;
	IdAl_p ob;
	logic enJfun;
	word_t addr;
	modport IDU(output ob,input  addr,enJfun);
	modport ALU(input  ob,output addr,enJfun);
	endinterface
interface AlLs_t();
	import rv32iBasis::*;
	AlLs_p ob;
	modport ALU(output ob);
	modport LSU(input  ob);
	endinterface
interface LsWb_t();
	import rv32iBasis::*;
	LsWb_p ob;
	LsRg_p obGpr;
	LsSr_p obCsr;
	assign obGpr=ob.Gpr;
	assign obCsr=ob.Csr;
	modport LSU(output ob);
	modport GPR(input  obGpr);
	modport CSR(input  obCsr);
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
	IdAl_t nIdAl();
	AlLs_t nAlLs();
	LsWb_t nLsWb();
	val_t val();
	SimpleBus_t sbIf();

	ysyx_26020046_rv32iMEM MEM(.*);
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
				$fdisplay(logFile,"nIfId code=%x valid=%b ready=%b",nIfId.code,nIfId.valid,nIfId.ready);
				$fdisplay(logFile,"nIfId code=%x valid=%b ready=%b",nIfId.code,nIfId.valid,nIfId.ready);
				$fdisplay(logFile,"val cR1=%x cR2=%x oR1=%x oR2=%x SRaddr=%x oCsr=%x pc=%x",val.cR1,val.cR2,val.oR1,val.oR2,val.SRaddr,val.oCsr,val.pc);
				$fdisplay(logFile,"nIdAl in1=%s in2=%s oR1=%x oR2=%x oCsr=%x imm=%x pc=%x enJcod=%b cal=%s adr=%s cCsr=%s cIrd=%s enL=%b enS=%b LSop=%s SRaddr=%x SRop=%s cRd=%x",nIdAl.ob.in1.name(),nIdAl.ob.in2.name(),nIdAl.ob.oR1,nIdAl.ob.oR2,nIdAl.ob.oCsr,nIdAl.ob.imm,nIdAl.ob.pc,nIdAl.ob.enJcod,nIdAl.ob.cal.name(),nIdAl.ob.adr.name(),nIdAl.ob.cCsr.name(),nIdAl.ob.cIrd.name(),nIdAl.ob.LS.enL,nIdAl.ob.LS.enS,nIdAl.ob.LS.LSop.name(),nIdAl.ob.LS.Wbu.Csr.SRaddr,nIdAl.ob.Wbu.Csr.SRop.name(),nIdAl.ob.Wbu.Gpr.cRd);
				$fdisplay(logFile,"nIdAl in1=%s in2=%s oR1=%x oR2=%x oCsr=%x imm=%x pc=%x enJcod=%b cal=%s adr=%s cCsr=%s cIrd=%s enL=%b enS=%b LSop=%s SRaddr=%x SRop=%s cRd=%x",nIdAl.ob.in1.name(),nIdAl.ob.in2.name(),nIdAl.ob.oR1,nIdAl.ob.oR2,nIdAl.ob.oCsr,nIdAl.ob.imm,nIdAl.ob.pc,nIdAl.ob.enJcod,nIdAl.ob.cal.name(),nIdAl.ob.adr.name(),nIdAl.ob.cCsr.name(),nIdAl.ob.cIrd.name(),nIdAl.ob.LS.enL,nIdAl.ob.LS.enS,nIdAl.ob.LS.LSop.name(),nIdAl.ob.LS.Wbu.Csr.SRaddr,nIdAl.ob.Wbu.Csr.SRop.name(),nIdAl.ob.Wbu.Gpr.cRd);
				$fdisplay(logFile,"nAlLs enS=%b enL=%b LSop=%s res=%x addr=%x oR2=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nAlLs.ob.enS,nAlLs.ob.enL,nAlLs.ob.LSop.name(),nAlLs.ob.res,nAlLs.ob.addr,nAlLs.ob.oR2,nAlLs.ob.cRd,nAlLs.ob.iCsr,nAlLs.ob.SRaddr,nAlLs.ob.SRop.name());
				$fdisplay(logFile,"nAlLs enS=%b enL=%b LSop=%s res=%x addr=%x oR2=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nAlLs.ob.enS,nAlLs.ob.enL,nAlLs.ob.LSop.name(),nAlLs.ob.res,nAlLs.ob.addr,nAlLs.ob.oR2,nAlLs.ob.cRd,nAlLs.ob.iCsr,nAlLs.ob.SRaddr,nAlLs.ob.SRop.name());
				$fdisplay(logFile,"nLsWb iRd=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nLsWb.obGpr.iRd,nLsWb.obGpr.cRd,nLsWb.obCsr.iCsr,nLsWb.obCsr.SRaddr,nLsWb.obCsr.SRop.name());
				$fdisplay(logFile,"nLsWb iRd=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nLsWb.obGpr.iRd,nLsWb.obGpr.cRd,nLsWb.obCsr.iCsr,nLsWb.obCsr.SRaddr,nLsWb.obCsr.SRop.name());
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
module ysyx_26020046_rv32iIFU(
	SimpleBus_t.IFU sbIf,
	IfId_t.IFU nIfId,
	val_t.IFU val,
	input logic clk,reset
	);
	import rv32iBasis::*;

	IFUstatus_t nStatus,oStatus;
	always_comb begin
		unique case(oStatus)
			IFUidle:nStatus=IFUwait;//TODO 先默认是有数据要发送
			IFUwait:nStatus=nIfId.ready?IFUidle:IFUwait;
		endcase
		nIfId.valid=(oStatus==IFUidle);
		// nIfId.valid=1;//TODO 完全单周期不启动状态机
		sbIf.addr=val.pc;
		nIfId.code=sbIf.rdata;
	end
	always_ff@(posedge clk)begin
		if(reset) oStatus<=IFUidle;
		else oStatus<=nStatus;
	end

	// assign sbIf.addr=val.pc;
	// assign nIfId.code=sbIf.rdata;

	always_ff @(posedge clk) begin : pc
		`ifdef RV32I_DEBUG if(nIfId.enJfun) $fdisplay(logFile,"PC:%x => %x",val.pc,nIfId.addr);`endif
		if(reset) val.pc<=PC_RESET;
		else if(oStatus==IFUidle)begin
			if(nIfId.enJfun) val.pc<=(nIfId.addr&32'hFFFFFFFC);
			else val.pc<=val.pc+4;
		end
	end	
	endmodule
module ysyx_26020046_rv32iIDU(
	IfId_t.IDU nIfId,
	IdAl_t.IDU nIdAl,
	val_t.IDU val
	);
	import rv32iBasis::*;
	assign nIfId.ready=1;
	assign nIdAl.ob.oR1	=val.oR1;
	assign nIdAl.ob.oR2	=val.oR2;
	assign nIdAl.ob.oCsr	=val.oCsr;
	assign nIdAl.ob.pc		=val.pc;
	always_comb begin : ID
		nIdAl.ob.in1=IR1;nIdAl.ob.in2=IR2;
		nIdAl.ob.adr=NAD;nIdAl.ob.cal=NCAL;nIdAl.ob.bfu=NBFU;
		nIdAl.ob.cCsr=NACSR;nIdAl.ob.cIrd=NCHO;
		nIdAl.ob.LSop=NM;nIdAl.ob.enS=0;nIdAl.ob.enL=0;
		nIdAl.ob.SRop=NCSR_;nIdAl.ob.SRaddr='0;
		{val.cR1,val.cR2,nIdAl.ob.cRd,nIdAl.ob.enJcod,nIdAl.ob.imm}='0;

		if(nIfId.valid) begin
			unique case(nIfId.code.op)
				OP_U_I	:nIdAl.ob.imm={nIfId.code[31:12],12'b0 };
				OP_U_P	:nIdAl.ob.imm={nIfId.code[31:12],12'b0 };
				OP_S__	:nIdAl.ob.imm={{20{nIfId.code[31]}},nIfId.code[31:25],nIfId.code[11:7] };
				OP_I_A	:nIdAl.ob.imm={{20{nIfId.code[31]}},nIfId.code[31:20]};
				OP_I_J	:nIdAl.ob.imm={{20{nIfId.code[31]}},nIfId.code[31:20]};
				OP_I_L	:nIdAl.ob.imm={{20{nIfId.code[31]}},nIfId.code[31:20]};
				OP_B__	:nIdAl.ob.imm={{20{nIfId.code[31]}},nIfId.code[7],nIfId.code[30:25],nIfId.code[11:8], 1'b0 };
				OP_J__	:nIdAl.ob.imm={{12{nIfId.code[31]}},nIfId.code[19:12],nIfId.code[20],nIfId.code[30:21], 1'b0 };
				default	:nIdAl.ob.imm='0;
			endcase
			unique case(nIfId.code.op)
				OP_U_P	:nIdAl.ob.in1=PC_;
				default	:nIdAl.ob.in1=IR1;
			endcase
			unique case(nIfId.code.op)
				OP_U_P	:nIdAl.ob.in2=IMM;
				OP_I_A	:nIdAl.ob.in2=IMM;
				default	:nIdAl.ob.in2=IR2;
			endcase
			unique case(nIfId.code.op)
				OP_J__	:nIdAl.ob.enJcod=1;
				OP_I_J	:nIdAl.ob.enJcod=1;
				OP_CSR	:nIdAl.ob.enJcod=(nIfId.code.fun3==3'b000);
				default	:nIdAl.ob.enJcod=0;
			endcase

			unique case(nIfId.code.op)//选ALU cal
				OP_U_P	:nIdAl.ob.cal=ADD_;
				OP_I_A	:begin unique case(nIfId.code.fun3)
						3'b001:begin unique case(nIfId.code.fun7)
								7'b0000000:nIdAl.ob.cal=SLL_;
								default:begin $fatal("slli fun7(%x)!=0",nIfId.code.fun7);stop(0);end
							endcase end
						3'b101:begin unique case(nIfId.code.fun7)
								7'b0000000:nIdAl.ob.cal=SRL_;
								7'b0100000:nIdAl.ob.cal=SRA_;
								default:begin $fatal("srai/srli fun7(%x)!=0/20",nIfId.code.fun7);stop(0);end
							endcase end
						default:nIdAl.ob.cal=ALUopCal_t'(nIfId.code.fun3);
					endcase end
				OP_R__	:begin unique case(nIfId.code.fun7)
						7'b0000000:nIdAl.ob.cal=ALUopCal_t'(nIfId.code.fun3);
						7'b0100000:begin unique case(nIfId.code.fun3)
								3'b000:nIdAl.ob.cal=SUB_;
								3'b101:nIdAl.ob.cal=SRA_;
								default:begin $fatal("R fun7==20 fun3(%x)!=1/5",nIfId.code.fun3);stop(0);end
							endcase end
						default:begin $fatal("R fun7(%x)!=0/20",nIfId.code.fun7);stop(0);end
					endcase end
				default	:nIdAl.ob.cal=NCAL;
			endcase

			if(nIfId.code.op==OP_B__)begin//b系列
				nIdAl.ob.bfu=ALUopBfu_t'(nIfId.code.fun3);
			end else nIdAl.ob.bfu=NBFU;

			unique case(nIfId.code.op)//选ALU cho
				OP_U_I	:nIdAl.ob.cIrd=IMM_;
				OP_U_P	:nIdAl.ob.cIrd=CAL_;
				OP_J__	:nIdAl.ob.cIrd=SNPC;
				OP_I_J	:nIdAl.ob.cIrd=SNPC;
				OP_I_A	:nIdAl.ob.cIrd=CAL_;
				OP_R__	:nIdAl.ob.cIrd=CAL_;
				OP_CSR	:nIdAl.ob.cIrd=CCSR;
				default	:nIdAl.ob.cIrd=NCHO;
			endcase
			unique case(nIfId.code.op)//选ALU addr
				OP_J__	:nIdAl.ob.adr=PCI;
				OP_I_J	:nIdAl.ob.adr=R1I;
				OP_I_L	:nIdAl.ob.adr=R1I;
				OP_CSR	:nIdAl.ob.adr=ECJ;
				OP_B__	:nIdAl.ob.adr=PCI;
				OP_S__	:nIdAl.ob.adr=R1I;
				default	:nIdAl.ob.adr=NAD;
			endcase

			unique case(nIfId.code.op)//选LSU op
				OP_I_L	:nIdAl.ob.LSop=LSUop_t'(nIfId.code.fun3);
				OP_S__	:nIdAl.ob.LSop=LSUop_t'(nIfId.code.fun3);
				default	:nIdAl.ob.LSop=NM;
			endcase
			nIdAl.ob.enL=(nIfId.code.op==OP_I_L);
			nIdAl.ob.enS=(nIfId.code.op==OP_S__);

			if(nIfId.code.op==OP_CSR)begin unique case(nIfId.code.fun3)
				3'b000	:nIdAl.ob.cCsr=JUMP_;
				3'b001	:nIdAl.ob.cCsr=WACSR;						
				3'b010	:nIdAl.ob.cCsr=(nIfId.code.r1=='0)?NACSR:RACSR;
				default	:nIdAl.ob.cCsr=NACSR;						
			endcase  unique case(nIfId.code.fun3)
				3'b000	:begin unique case(nIfId.code)
						OP_CSR_MRET__	:begin nIdAl.ob.SRaddr=CSR_ADDR_MEPC;		end
						OP_CSR_ECALL_	:begin nIdAl.ob.SRaddr=CSR_ADDR_MTVEC;	end
						OP_CSR_EBREAK	:begin nIdAl.ob.SRaddr='0;stop(1);		end
						default			:begin nIdAl.ob.SRaddr='0;stop(0);		end endcase end
				3'b001					:begin nIdAl.ob.SRaddr={nIfId.code[31:20]};end
				3'b010					:begin nIdAl.ob.SRaddr={nIfId.code[31:20]};end
				default					:begin nIdAl.ob.SRaddr='0;				end
			endcase  unique case(nIfId.code.fun3)
				3'b000	:begin unique case(nIfId.code)
						OP_CSR_MRET__	:nIdAl.ob.SRop=MRET_;
						OP_CSR_ECALL_	:nIdAl.ob.SRop=ECALL;
						OP_CSR_EBREAK	:nIdAl.ob.SRop=NCSR_;
						default			:nIdAl.ob.SRop=NCSR_;endcase end
				3'b001					:nIdAl.ob.SRop=WCCSR;
				3'b010					:nIdAl.ob.SRop=(nIfId.code.r1=='0)?NCSR_:WCCSR;
				default					:nIdAl.ob.SRop=NCSR_;
			endcase end else begin nIdAl.ob.cCsr=NACSR;nIdAl.ob.SRaddr='0;nIdAl.ob.SRop=NCSR_;end
			val.SRaddr=nIdAl.ob.SRaddr;

			unique case(nIfId.code.op)//选cR1 这里7/10就反选
				OP_U_I	:val.cR1='0;
				OP_U_P	:val.cR1='0;
				OP_J__	:val.cR1='0;
				default	:val.cR1=nIfId.code.r1;
			endcase
			unique case(nIfId.code.op)//选cR2
				OP_S__	:val.cR2=nIfId.code.r2;
				OP_R__	:val.cR2=nIfId.code.r2;
				OP_B__	:val.cR2=nIfId.code.r2;
				default	:val.cR2='0;
			endcase
			unique case(nIfId.code.op)//选cRd 也是反选
				OP_B__	:nIdAl.ob.cRd='0;
				OP_S__	:nIdAl.ob.cRd='0;
				OP_CSR	:nIdAl.ob.cRd=(nIfId.code.fun3==3'b000)?'0:nIfId.code.rd;
				default	:nIdAl.ob.cRd=nIfId.code.rd;
			endcase
		end
	end
	endmodule
module ysyx_26020046_rv32iALU(
	IdAl_t.ALU nIdAl,
	AlLs_t.ALU nAlLs
	);
	import rv32iBasis::*;
	logic enBfun;
	word_t result,in1,in2;

	always_comb begin
		nAlLs.ob.LS=nIdAl.ob.LS;
	end

	always_comb begin : cal
		unique case(nIdAl.ob.in1)
			IR1:in1=nIdAl.ob.oR1;
			PC_:in1=nIdAl.ob.pc;
			default:begin in1='0;$fatal("unknown in1==0x%x",nIdAl.ob.in1);end
		endcase
		unique case(nIdAl.ob.in2)
			IR2:in2=nIdAl.ob.oR2;
			IMM:in2=nIdAl.ob.imm;
			default:begin in2='0;$fatal("unknown in2==0x%x",nIdAl.ob.in2);end
		endcase
		unique case(nIdAl.ob.cal)
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
			default:begin result='0;$fatal("unknown cal==0x%x",nIdAl.ob.cal);end
		endcase
		
		unique case(nIdAl.ob.cIrd)
			CAL_:nAlLs.ob.res=result;
			IMM_:nAlLs.ob.res=nIdAl.ob.imm;
			CCSR:nAlLs.ob.res=nIdAl.ob.oCsr;
			SNPC:nAlLs.ob.res=nIdAl.ob.pc+4;
			NCHO:nAlLs.ob.res='0;
			default:begin nAlLs.ob.res='0;$error("unknown cho==0x%x",nIdAl.ob.cIrd);$stop;end
		endcase
		unique case(nIdAl.ob.cCsr)
			WACSR:nAlLs.ob.iCsr=nIdAl.ob.oR1;
			RACSR:nAlLs.ob.iCsr=nIdAl.ob.oR1|nIdAl.ob.oCsr;
			JUMP_:nAlLs.ob.iCsr=nIdAl.ob.pc;
			NCSR_:nAlLs.ob.iCsr='0;
			default:begin nAlLs.ob.iCsr='0;$error("unknown csr==0x%x",nIdAl.ob.cCsr);$stop;end
		endcase
	end
	always_comb begin : bfu
		unique case(nIdAl.ob.bfu)
			BEQ_:enBfun=(nIdAl.ob.oR1==nIdAl.ob.oR2);
			BNE_:enBfun=(nIdAl.ob.oR1!=nIdAl.ob.oR2);
			BLT_:enBfun=(   $signed(nIdAl.ob.oR1) <  $signed(nIdAl.ob.oR2));
			BGE_:enBfun=(   $signed(nIdAl.ob.oR1)>=  $signed(nIdAl.ob.oR2));
			BLTU:enBfun=( $unsigned(nIdAl.ob.oR1) <$unsigned(nIdAl.ob.oR2));
			BGEU:enBfun=( $unsigned(nIdAl.ob.oR1)>=$unsigned(nIdAl.ob.oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;$fatal("unknown bfu==0x%x",nIdAl.ob.bfu);end
			endcase
	end
	always_comb begin : adr
		unique case(nIdAl.ob.adr)
			R1I:nAlLs.ob.addr=nIdAl.ob.oR1+nIdAl.ob.imm;
			PCI:nAlLs.ob.addr=nIdAl.ob.pc +nIdAl.ob.imm;
			ECJ:nAlLs.ob.addr=nIdAl.ob.oCsr;
			ERE:nAlLs.ob.addr=nIdAl.ob.oCsr;
			NAD:nAlLs.ob.addr='0;
			default:begin nAlLs.ob.addr='0;$fatal("unknown adr==0x%x",nIdAl.ob.adr);end
		endcase
		nIdAl.enJfun=nIdAl.ob.enJcod|enBfun;
		nIdAl.addr=nAlLs.ob.addr;
	end
	endmodule
module ysyx_26020046_rv32iLSU(
	AlLs_t.LSU nAlLs,
	LsWb_t.LSU nLsWb,
	input clk
	);
	import rv32iBasis::*;

	logic[3:0] mask;
	word_t iRAM,data;

	always_comb begin
		nLsWb.ob.iRd=(nAlLs.ob.enS|nAlLs.ob.enL)?data:nAlLs.ob.res;
		nLsWb.ob.cRd	=nAlLs.ob.cRd;
		nLsWb.ob.iCsr	=nAlLs.ob.iCsr;
		nLsWb.ob.SRaddr	=nAlLs.ob.SRaddr;
		nLsWb.ob.SRop	=nAlLs.ob.SRop;
	end

	always_comb begin : choose_mask
		if (nAlLs.ob.enS) begin unique case(nAlLs.ob.LSop)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;$fatal("unknown mask==0x%x",nAlLs.ob.LSop);end
		endcase end else 	mask=4'b0000;
	end
	always_comb begin : choose_date_input
		if(nAlLs.ob.enL) begin unique case(nAlLs.ob.LSop)
			B_:				data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				data=iRAM;
			BU:				data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	data=0;$fatal("unknown date==0x%x",nAlLs.ob.LSop);end
		endcase end else 	data='0;
	end
	always_comb begin :write
		if((nAlLs.ob.enL)&clk)begin
			iRAM=pmem_read(nAlLs.ob.addr);
			`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:RESD  [%x] => %x",nAlLs.ob.addr,iRAM);`endif
		end else iRAM = '0;
	end
	always_ff@(posedge clk) begin:control_write
		if (nAlLs.ob.enS) begin // 有写请求时
			`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:write [%x] <(%b)= %x",nAlLs.ob.addr,mask,nAlLs.ob.oR2);`endif
			pmem_write(nAlLs.ob.addr,nAlLs.ob.oR2, {4'b0,mask});
		end
	end
	endmodule
module ysyx_26020046_rv32iGPR(
	LsWb_t.GPR nLsWb,
	val_t.GPR val,
	input clk,reset
	);
	import rv32iBasis::*;

	word_t gpr [2**REG_NUMBER -1:1];

	always_ff@(posedge clk) begin:reg_write
		if(reset)begin
			for (int i = 1; i < 32; i++) gpr[i]<='0;
		end else begin
			`ifdef RV32I_DEBUG if(nLsWb.obGpr.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",nLsWb.obGpr.cRd,gpr[nLsWb.obGpr.cRd],nLsWb.obGpr.iRd);`endif
			if (nLsWb.obGpr.cRd!=0) gpr[nLsWb.obGpr.cRd] <= nLsWb.obGpr.iRd;
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
	LsWb_t.CSR nLsWb,
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
				if(nLsWb.obCsr.SRop==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,nLsWb.obCsr.iCsr,mcause,11);
				else if(nLsWb.obCsr.SRop==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,nLsWb.obCsr.iCsr,mcause,0);
				else if(nLsWb.obCsr.SRop==WCCSR)begin unique case(nLsWb.obCsr.SRaddr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				nLsWb.obCsr.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		nLsWb.obCsr.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			nLsWb.obCsr.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			nLsWb.obCsr.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			nLsWb.obCsr.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		nLsWb.obCsr.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		nLsWb.obCsr.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	nLsWb.obCsr.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",nLsWb.obCsr.SRaddr); end
				endcase end
			end
	`endif
			{mcycleh,mcycle}<={mcycleh,mcycle}+1;
			unique case(nLsWb.obCsr.SRop)
				ECALL:begin mepc<=nLsWb.obCsr.iCsr;mcause<=11;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;end
				WCCSR:begin unique case(nLsWb.obCsr.SRaddr)
					CSR_ADDR_MEPC		:mepc		<=nLsWb.obCsr.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=nLsWb.obCsr.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=nLsWb.obCsr.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=nLsWb.obCsr.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=nLsWb.obCsr.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=nLsWb.obCsr.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=nLsWb.obCsr.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=nLsWb.obCsr.iCsr;
					default:begin $fatal("unknown csrAddr==0x%x",nLsWb.obCsr.SRaddr); end
					endcase end
				NCSR_:;
				default:begin $fatal("unknown op.SRop==0x%x",nLsWb.obCsr.SRop); end
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
