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
	
	import "DPI-C" function void stop(input bit eb);
	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
	endpackage
interface IfId_t();
	import rv32iBasis::*;
	logic valid,ready;
	code_t code;
	word_t addr;
	logic enJfun;
	modport IFU(output code,valid,input  ready,addr,enJfun);
	modport IDU(input  code,valid,output ready,addr,enJfun);
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

	word_t addr;
	logic enJfun;

	modport IDU(output in1,in2,oR1,oR2,oCsr,imm,pc,enJcod,cal,bfu,adr,cCsr,cIrd,enL,enS,LSop,SRaddr,SRop,cRd,input  addr,enJfun);
	modport ALU(input  in1,in2,oR1,oR2,oCsr,imm,pc,enJcod,cal,bfu,adr,cCsr,cIrd,enL,enS,LSop,SRaddr,SRop,cRd,output addr,enJfun);
	endinterface
interface AlLs_t();
	import rv32iBasis::*;
	logic enS,enL;
	LSUop_t LSop;
	word_t addr,res,iCsr,oR2;
	logic [11:0] SRaddr;
	CSRop_t SRop;

	reg_t cRd;
	modport ALU(output enS,enL,LSop,res,addr,oR2,cRd,iCsr,SRaddr,SRop);
	modport LSU(input  enS,enL,LSop,res,addr,oR2,cRd,iCsr,SRaddr,SRop);
	endinterface
interface LsWb_t();
	import rv32iBasis::*;
	reg_t cRd;
	logic [11:0] SRaddr;
	CSRop_t SRop;
	word_t iRd,iCsr;
	modport LSU(output iRd,cRd,iCsr,SRaddr,SRop);
	modport GPR(input  iRd,cRd);
	modport CSR(input  iCsr,SRaddr,SRop);
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
	word_t addr,rdata,wdata;
	logic ren,wen;
	logic[3:0] wmask;
	modport CPU(input  rdata,output addr,ren,wen,wdata,wmask);
	modport MEM(output rdata,input  addr,ren,wen,wdata,wmask);
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
	SimpleBus_t sbLs();

	ysyx_26020046_rv32iROM ROM(.*);
	ysyx_26020046_rv32iRAM RAM(.*);
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
				$fdisplay(logFile,"nIfId code=%x valid=%b ready=%b addr=%x enJfun=%b",nIfId.code,nIfId.valid,nIfId.ready,nIfId.addr,nIfId.enJfun);
				$fdisplay(logFile,"val cR1=%x cR2=%x oR1=%x oR2=%x SRaddr=%x oCsr=%x pc=%x",val.cR1,val.cR2,val.oR1,val.oR2,val.SRaddr,val.oCsr,val.pc);
				$fdisplay(logFile,"nIdAl in1=%s in2=%s oR1=%x oR2=%x oCsr=%x imm=%x pc=%x enJcod=%b cal=%s adr=%s cCsr=%s cIrd=%s enL=%b enS=%b LSop=%s SRaddr=%x SRop=%s cRd=%x addr=%x enJfun=%b",nIdAl.in1.name(),nIdAl.in2.name(),nIdAl.oR1,nIdAl.oR2,nIdAl.oCsr,nIdAl.imm,nIdAl.pc,nIdAl.enJcod,nIdAl.cal.name(),nIdAl.adr.name(),nIdAl.cCsr.name(),nIdAl.cIrd.name(),nIdAl.enL,nIdAl.enS,nIdAl.LSop.name(),nIdAl.SRaddr,nIdAl.SRop.name(),nIdAl.cRd,nIdAl.addr,nIdAl.enJfun);
				$fdisplay(logFile,"nAlLs enS=%b enL=%b LSop=%s res=%x addr=%x oR2=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nAlLs.enS,nAlLs.enL,nAlLs.LSop.name(),nAlLs.res,nAlLs.addr,nAlLs.oR2,nAlLs.cRd,nAlLs.iCsr,nAlLs.SRaddr,nAlLs.SRop.name());
				$fdisplay(logFile,"nLsWb iRd=%x cRd=%x iCsr=%x SRaddr=%x SRop=%s",nLsWb.iRd,nLsWb.cRd,nLsWb.iCsr,nLsWb.SRaddr,nLsWb.SRop.name());
			end
			$fstrobe(logFile,"");
		end
	`endif
	endmodule
module ysyx_26020046_rv32iROM(
	SimpleBus_t.MEM sbIf,
	input clk
	);
	import rv32iBasis::*;
	always_ff@(posedge clk) begin
		if(sbIf.ren)sbIf.rdata<=pmem_read(sbIf.addr);
		if(sbIf.wen)pmem_write(sbIf.addr,sbIf.wdata,{4'b0,sbIf.wmask});
	end
	endmodule
module ysyx_26020046_rv32iRAM(
	SimpleBus_t.MEM sbLs,
	input clk
	);
	import rv32iBasis::*;
	assign sbLs.rdata=sbLs.ren?pmem_read(sbLs.addr):'0;
	always_ff@(posedge clk) begin
		// if(sbLs.ren)sbLs.rdata<=pmem_read(sbLs.addr);
	// 		`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:RESD  [%x] => %x",nAlLs.addr,iRAM);`endif
		if(sbLs.wen)pmem_write(sbLs.addr,sbLs.wdata,{4'b0,sbLs.wmask});
	// 		`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:write [%x] <(%b)= %x",nAlLs.addr,mask,nAlLs.oR2);`endif
	end
	endmodule
module ysyx_26020046_rv32iIFU(
	SimpleBus_t.CPU sbIf,
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
		nIfId.code=sbIf.rdata;
		// nIfId.valid=1;//TODO 完全单周期不启动状态机
		sbIf.addr=val.pc;
		sbIf.ren=(oStatus==IFUwait);
		sbIf.wen=0;
		sbIf.wdata='0;
		sbIf.wmask='0;
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
	assign nIfId.ready	=1;
	assign nIfId.addr	=nIdAl.addr;
	assign nIfId.enJfun	=nIdAl.enJfun;
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

		if(nIfId.valid) begin
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
	IdAl_t.ALU nIdAl,
	AlLs_t.ALU nAlLs
	);
	import rv32iBasis::*;
	logic enBfun;
	word_t result,in1,in2;

	always_comb begin
		nAlLs.oR2=nIdAl.oR2;
		nAlLs.enS	=nIdAl.enS;
		nAlLs.enL	=nIdAl.enL;
		nAlLs.LSop	=nIdAl.LSop;
		nAlLs.cRd	=nIdAl.cRd;
		nAlLs.SRaddr=nIdAl.SRaddr;
		nAlLs.SRop	=nIdAl.SRop;
	end

	always_comb begin : cal
		unique case(nIdAl.in1)
			IR1:in1=nIdAl.oR1;
			PC_:in1=nIdAl.pc;
			default:begin in1='0;$fatal("unknown in1==0x%x",nIdAl.in1);end
		endcase
		unique case(nIdAl.in2)
			IR2:in2=nIdAl.oR2;
			IMM:in2=nIdAl.imm;
			default:begin in2='0;$fatal("unknown in2==0x%x",nIdAl.in2);end
		endcase
		unique case(nIdAl.cal)
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
			default:begin result='0;$fatal("unknown cal==0x%x",nIdAl.cal);end
		endcase
		
		unique case(nIdAl.cIrd)
			CAL_:nAlLs.res=result;
			IMM_:nAlLs.res=nIdAl.imm;
			CCSR:nAlLs.res=nIdAl.oCsr;
			SNPC:nAlLs.res=nIdAl.pc+4;
			NCHO:nAlLs.res='0;
			default:begin nAlLs.res='0;$error("unknown cho==0x%x",nIdAl.cIrd);$stop;end
		endcase
		unique case(nIdAl.cCsr)
			WACSR:nAlLs.iCsr=nIdAl.oR1;
			RACSR:nAlLs.iCsr=nIdAl.oR1|nIdAl.oCsr;
			JUMP_:nAlLs.iCsr=nIdAl.pc;
			NCSR_:nAlLs.iCsr='0;
			default:begin nAlLs.iCsr='0;$error("unknown csr==0x%x",nIdAl.cCsr);$stop;end
		endcase
	end
	always_comb begin : bfu
		unique case(nIdAl.bfu)
			BEQ_:enBfun=(nIdAl.oR1==nIdAl.oR2);
			BNE_:enBfun=(nIdAl.oR1!=nIdAl.oR2);
			BLT_:enBfun=(   $signed(nIdAl.oR1) <  $signed(nIdAl.oR2));
			BGE_:enBfun=(   $signed(nIdAl.oR1)>=  $signed(nIdAl.oR2));
			BLTU:enBfun=( $unsigned(nIdAl.oR1) <$unsigned(nIdAl.oR2));
			BGEU:enBfun=( $unsigned(nIdAl.oR1)>=$unsigned(nIdAl.oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;$fatal("unknown bfu==0x%x",nIdAl.bfu);end
			endcase
	end
	always_comb begin : adr
		unique case(nIdAl.adr)
			R1I:nAlLs.addr=nIdAl.oR1+nIdAl.imm;
			PCI:nAlLs.addr=nIdAl.pc +nIdAl.imm;
			ECJ:nAlLs.addr=nIdAl.oCsr;
			ERE:nAlLs.addr=nIdAl.oCsr;
			NAD:nAlLs.addr='0;
			default:begin nAlLs.addr='0;$fatal("unknown adr==0x%x",nIdAl.adr);end
		endcase
		nIdAl.enJfun=nIdAl.enJcod|enBfun;
		nIdAl.addr=nAlLs.addr;
	end
	endmodule
module ysyx_26020046_rv32iLSU(
	SimpleBus_t sbLs,
	AlLs_t.LSU nAlLs,
	LsWb_t.LSU nLsWb
	// input clk
	);
	import rv32iBasis::*;

	logic[3:0] mask;
	word_t iRAM,data;

	always_comb begin
		nLsWb.iRd=(nAlLs.enS|nAlLs.enL)?data:nAlLs.res;
		nLsWb.cRd	=nAlLs.cRd;
		nLsWb.iCsr	=nAlLs.iCsr;
		nLsWb.SRaddr=nAlLs.SRaddr;
		nLsWb.SRop	=nAlLs.SRop;
	end

	always_comb begin : choose_mask
		if (nAlLs.enS) begin unique case(nAlLs.LSop)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;$fatal("unknown mask==0x%x",nAlLs.LSop);end
		endcase end else 	mask=4'b0000;
	end
	always_comb begin : choose_date_input
		if(nAlLs.enL) begin unique case(nAlLs.LSop)
			B_:				data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				data=iRAM;
			BU:				data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	data=0;$fatal("unknown date==0x%x",nAlLs.LSop);end
		endcase end else 	data='0;
	end
	// always_comb begin :write
	// 	if((nAlLs.enL)&clk)begin
	// 		iRAM=pmem_read(nAlLs.addr);
	// 	end else iRAM = '0;
	// end
	// always_ff@(posedge clk) begin:control_write
	// 	if (nAlLs.enS) begin // 有写请求时
	// 		pmem_write(nAlLs.addr,nAlLs.oR2, {4'b0,mask});
	// 	end
	// end
	always_comb begin
		sbLs.addr=nAlLs.addr;
		sbLs.wdata=nAlLs.oR2;
		sbLs.wmask=mask;
		sbLs.ren=nAlLs.enL;
		sbLs.wen=nAlLs.enS;
		iRAM=sbLs.rdata;
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
			`ifdef RV32I_DEBUG if(nLsWb.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",nLsWb.cRd,gpr[nLsWb.cRd],nLsWb.iRd);`endif
			if (nLsWb.cRd!=0) gpr[nLsWb.cRd] <= nLsWb.iRd;
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
				if(nLsWb.SRop==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,nLsWb.iCsr,mcause,11);
				else if(nLsWb.SRop==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,nLsWb.iCsr,mcause,0);
				else if(nLsWb.SRop==WCCSR)begin unique case(nLsWb.SRaddr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				nLsWb.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		nLsWb.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			nLsWb.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			nLsWb.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			nLsWb.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		nLsWb.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		nLsWb.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	nLsWb.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",nLsWb.SRaddr); end
				endcase end
			end
	`endif
			{mcycleh,mcycle}<={mcycleh,mcycle}+1;
			unique case(nLsWb.SRop)
				ECALL:begin mepc<=nLsWb.iCsr;mcause<=11;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;end
				WCCSR:begin unique case(nLsWb.SRaddr)
					CSR_ADDR_MEPC		:mepc		<=nLsWb.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=nLsWb.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=nLsWb.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=nLsWb.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=nLsWb.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=nLsWb.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=nLsWb.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=nLsWb.iCsr;
					default:begin $fatal("unknown csrAddr==0x%x",nLsWb.SRaddr); end
					endcase end
				NCSR_:;
				default:begin $fatal("unknown op.SRop==0x%x",nLsWb.SRop); end
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
