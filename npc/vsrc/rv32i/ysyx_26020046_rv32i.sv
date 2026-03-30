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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

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
	typedef enum logic[2:0] {NCHO,CAL_,DATA,IMM_,SNPC,CCSR} ALUopCho_t;
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

	`ifdef RV32I_DEBUG
		integer logFile;
	`endif
	
	import "DPI-C" function void stop(input bit eb);
	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
endpackage
interface ifdu_t();
	import rv32iBasis::*;
	code_t code;
	modport IFU(output code);
	modport IDU(input  code);
endinterface
interface op_t(input logic clk,reset);
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

	reg_t cRd,cR1,cR2;
	
	logic [11:0] SRaddr;
	CSRop_t SRop;

	modport IFU(input  clk,reset);
	modport IDU(output in1,in2,enJcod,cal,bfu,adr,cCsr,cIrd,enL,enS,LSop,SRaddr,SRop,cRd,cR1,cR2);
	modport ALU(input  in1,in2,enJcod,cal,bfu,adr,cCsr,cIrd);
	modport LSU(input  clk,enL,enS,LSop);
	modport CSR(input  clk,reset,SRaddr,SRop);
	modport GPR(input  clk,reset,cR1,cR2,cRd);
endinterface
interface val_t();
	import rv32iBasis::*;
	word_t oR1,oR2,data,oCsr,imm,pc;
	modport ALU(input oR1,oR2,data,imm,pc,oCsr);
	modport GPR(output oR1,oR2,input pc);
	modport CSR(output oCsr);
	modport IFU(output pc);
	modport LSU(output data,input oR2);
	modport IDU(output imm);
endinterface;
interface res_t();
	import rv32iBasis::*;
	word_t addr,iRd,iCsr;
	logic enJfun;
	modport ALU(output addr,iRd,iCsr,enJfun);
	modport GPR(input iRd);
	modport CSR(input iCsr);
	modport IFU(input addr,enJfun);
	modport LSU(input addr);
endinterface;
module ysyx_26020046_rv32i(
	input logic clk,
	input logic reset
	);
	import rv32iBasis::*;

	ifdu_t ifdu();
	op_t op(.*);
	res_t res();
	val_t val();

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
				$fdisplay(logFile,"\nIF:pc=%x code=%x",val.pc,code);
				$fdisplay(logFile,"opAL:{[%s %s %s] b:%s adr:%s}[r:%s sr:%s]",op.in1.name(),op.in2.name(),op.cal.name(),op.bfu.name(),op.adr.name(),op.cIrd.name(),op.cCsr.name());
				$fdisplay(logFile,"op:LS[%s S%bL%b] SR[%s %x] R12d[%x %x %x]",op.LSop.name(),op.enS,op.enL,op.SRop.name(),op.SRaddr,op.cR1,op.cR2,op.cRd);
				$fdisplay(logFile,"val:oR1=%x oR2=%x imm=%x oCsr=%x data=%x",val.oR1,val.oR2,val.imm,val.oCsr,val.data);
				$fdisplay(logFile,"res:addr=%x iRd=%x iCsr=%x enJ=%b",res.addr,res.iRd,res.iCsr,res.enJfun);
				
			end
		end
	`endif
endmodule
module ysyx_26020046_rv32iIFU(
	ifdu_t.IFU ifdu,
	val_t.IFU val,
	res_t.IFU res,
	op_t.IFU op
	);
	import rv32iBasis::*;
	assign ifdu.code=pmem_read(val.pc);
	always_ff @(posedge op.clk) begin : pc_write
	`ifdef RV32I_DEBUG
		if(res.enJfun) $fdisplay(logFile,"PC:%x => %x",val.pc,res.addr);
	`endif
		if(op.reset) val.pc<=PC_RESET;
		else if(res.enJfun) val.pc<=(res.addr&32'hFFFFFFFC);
		else val.pc<=val.pc+4;
	end	
endmodule
module ysyx_26020046_rv32iIDU(
	ifdu_t.IDU ifdu,
	val_t.IDU val,
	op_t.IDU op
	);
	import rv32iBasis::*;
	always_comb begin : ID
		op.in1=IR1;op.in2=IR2;
		op.adr=NAD;op.cal=NCAL;op.bfu=NBFU;
		op.cCsr=NACSR;op.cIrd=NCHO;
		op.LSop=NM;op.enS=0;op.enL=0;
		op.SRop=NCSR_;op.SRaddr='0;
		{op.cR1,op.cR2,op.cRd,op.enJcod,val.imm}='0;

		// if(~op.reset) begin
			unique case(ifdu.code.op)
				OP_U_I	:val.imm={ifdu.code[31:12],12'b0 };
				OP_U_P	:val.imm={ifdu.code[31:12],12'b0 };
				OP_S__	:val.imm={{20{ifdu.code[31]}},ifdu.code[31:25],ifdu.code[11:7] };
				OP_I_A	:val.imm={{20{ifdu.code[31]}},ifdu.code[31:20]};
				OP_I_J	:val.imm={{20{ifdu.code[31]}},ifdu.code[31:20]};
				OP_I_L	:val.imm={{20{ifdu.code[31]}},ifdu.code[31:20]};
				OP_B__	:val.imm={{20{ifdu.code[31]}},ifdu.code[7],ifdu.code[30:25],ifdu.code[11:8], 1'b0 };
				OP_J__	:val.imm={{12{ifdu.code[31]}},ifdu.code[19:12],ifdu.code[20],ifdu.code[30:21], 1'b0 };
				default	:val.imm='0;
			endcase
			unique case(ifdu.code.op)
				OP_U_P	:op.in1=PC_;
				default	:op.in1=IR1;
			endcase
			unique case(ifdu.code.op)
				OP_U_P	:op.in2=IMM;
				OP_I_A	:op.in2=IMM;
				default	:op.in2=IR2;
			endcase
			unique case(ifdu.code.op)
				OP_J__	:op.enJcod=1;
				OP_I_J	:op.enJcod=1;
				OP_CSR	:op.enJcod=(ifdu.code.fun3==3'b000);
				default	:op.enJcod=0;
			endcase

			unique case(ifdu.code.op)//选ALU cal
				OP_U_P	:op.cal=ADD_;
				OP_I_A	:begin unique case(ifdu.code.fun3)
						3'b001:begin unique case(ifdu.code.fun7)
								7'b0000000:op.cal=SLL_;
								default:begin $fatal("slli fun7(%x)!=0",ifdu.code.fun7);stop(0);end
							endcase end
						3'b101:begin unique case(ifdu.code.fun7)
								7'b0000000:op.cal=SRL_;
								7'b0100000:op.cal=SRA_;
								default:begin $fatal("srai/srli fun7(%x)!=0/20",ifdu.code.fun7);stop(0);end
							endcase end
						default:op.cal=ALUopCal_t'(ifdu.code.fun3);
					endcase end
				OP_R__	:begin unique case(ifdu.code.fun7)
						7'b0000000:op.cal=ALUopCal_t'(ifdu.code.fun3);
						7'b0100000:begin unique case(ifdu.code.fun3)
								3'b000:op.cal=SUB_;
								3'b101:op.cal=SRA_;
								default:begin $fatal("R fun7==20 fun3(%x)!=1/5",ifdu.code.fun3);stop(0);end
							endcase end
						default:begin $fatal("R fun7(%x)!=0/20",ifdu.code.fun7);stop(0);end
					endcase end
				default	:op.cal=NCAL;
			endcase

			if(ifdu.code.op==OP_B__)begin//b系列
				op.bfu=ALUopBfu_t'(ifdu.code.fun3);
			end else op.bfu=NBFU;

			unique case(ifdu.code.op)//选ALU cho
				OP_U_I	:op.cIrd=IMM_;
				OP_U_P	:op.cIrd=CAL_;
				OP_J__	:op.cIrd=SNPC;
				OP_I_J	:op.cIrd=SNPC;
				OP_I_L	:op.cIrd=DATA;
				OP_I_A	:op.cIrd=CAL_;
				OP_R__	:op.cIrd=CAL_;
				OP_CSR	:op.cIrd=CCSR;
				default	:op.cIrd=NCHO;
			endcase
			unique case(ifdu.code.op)//选ALU addr
				OP_J__	:op.adr=PCI;
				OP_I_J	:op.adr=R1I;
				OP_I_L	:op.adr=R1I;
				OP_CSR	:op.adr=ECJ;
				OP_B__	:op.adr=PCI;
				OP_S__	:op.adr=R1I;
				default	:op.adr=NAD;
			endcase

			unique case(ifdu.code.op)//选LSU op
				OP_I_L	:op.LSop=LSUop_t'(ifdu.code.fun3);
				OP_S__	:op.LSop=LSUop_t'(ifdu.code.fun3);
				default	:op.LSop=NM;
			endcase
			op.enL=(ifdu.code.op==OP_I_L);
			op.enS=(ifdu.code.op==OP_S__);

			if(ifdu.code.op==OP_CSR)begin unique case(ifdu.code.fun3)//选CSR op addr
				3'b000	:begin unique case(ifdu.code)
						OP_SCR_MRET__	:begin 								op.SRaddr=CSR_ADDR_MEPC;		op.SRop=MRET_;							end
						OP_SCR_ECALL_	:begin 								op.SRaddr=CSR_ADDR_MTVEC;		op.SRop=ECALL;							end
						OP_SCR_EBREAK	:begin 								op.SRaddr='0;stop(1);			op.SRop=NCSR_;							end
						default			:begin 								op.SRaddr='0;stop(0);			op.SRop=NCSR_;							end
					endcase 		op.cCsr=JUMP_;																									end
				3'b001	:begin 		op.cCsr=WACSR;							op.SRaddr={ifdu.code[31:20]};	op.SRop=WCCSR;							end
				3'b010	:begin 		op.cCsr=(ifdu.code.r1=='0)?NACSR:RACSR;	op.SRaddr={ifdu.code[31:20]};	op.SRop=(ifdu.code.r1=='0)?NCSR_:WCCSR;	end
				default	:begin 		op.cCsr=NACSR;							op.SRaddr='0;					op.SRop=NCSR_;							end
			endcase end else begin 	op.cCsr=NACSR;							op.SRaddr='0;					op.SRop=NCSR_;							end

			unique case(ifdu.code.op)//选cR1 这里7/10就反选
				OP_U_I	:op.cR1='0;
				OP_U_P	:op.cR1='0;
				OP_J__	:op.cR1='0;
				default	:op.cR1=ifdu.code.r1;
			endcase
			unique case(ifdu.code.op)//选cR2
				OP_S__	:op.cR2=ifdu.code.r2;
				OP_R__	:op.cR2=ifdu.code.r2;
				OP_B__	:op.cR2=ifdu.code.r2;
				default	:op.cR2='0;
			endcase
			unique case(ifdu.code.op)//选cRd 也是反选
				OP_B__	:op.cRd='0;
				OP_S__	:op.cRd='0;
				OP_CSR	:op.cRd=(ifdu.code.fun3==3'b000)?'0:ifdu.code.rd;
				default	:op.cRd=ifdu.code.rd;
			endcase
		end
	// end
endmodule
module ysyx_26020046_rv32iALU(
	op_t.ALU op,
	val_t.ALU val,
	res_t.ALU res
	);
	import rv32iBasis::*;
	logic enBfun;
	word_t result,in1,in2;

	always_comb begin : cal
		unique case(op.in1)
			IR1:in1=val.oR1;
			PC_:in1=val.pc;
			default:begin in1='0;$fatal("unknown in1==0x%x",op.in1);end
		endcase
		unique case(op.in2)
			IR2:in2=val.oR2;
			IMM:in2=val.imm;
			default:begin in2='0;$fatal("unknown in2==0x%x",op.in2);end
		endcase
		unique case(op.cal)
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
			default:begin result='0;$fatal("unknown cal==0x%x",op.cal);end
		endcase
		
		unique case(op.cIrd)
			CAL_:res.iRd=result;
			IMM_:res.iRd=val.imm;
			DATA:res.iRd=val.data;
			CCSR:res.iRd=val.oCsr;
			SNPC:res.iRd=val.pc+4;
			NCHO:res.iRd='0;
			default:begin res.iRd='0;$fatal("unknown cho==0x%x",op.cIrd);end
		endcase
		unique case(op.cCsr)
			WACSR:res.iCsr=val.oR1;
			RACSR:res.iCsr=val.oR1|val.oCsr;
			JUMP_:res.iCsr=val.pc;
			NCSR_:res.iCsr='0;
			default:begin res.iCsr='0;$fatal("unknown csr==0x%x",op.cCsr);end
		endcase
	end
	always_comb begin : bfu
		unique case(op.bfu)
			BEQ_:enBfun=(val.oR1==val.oR2);
			BNE_:enBfun=(val.oR1!=val.oR2);
			BLT_:enBfun=(  $signed(val.oR1) <  $signed(val.oR2));
			BGE_:enBfun=(  $signed(val.oR1)>=  $signed(val.oR2));
			BLTU:enBfun=($unsigned(val.oR1) <$unsigned(val.oR2));
			BGEU:enBfun=($unsigned(val.oR1)>=$unsigned(val.oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;$fatal("unknown bfu==0x%x",op.bfu);end
			endcase
	end
	always_comb begin : adr
		unique case(op.adr)
			R1I:res.addr=val.oR1+val.imm;
			PCI:res.addr=val.pc +val.imm;
			ECJ:res.addr=val.oCsr;
			ERE:res.addr=val.oCsr+4;
			NAD:res.addr='0;
			default:begin res.addr='0;$fatal("unknown adr==0x%x",op.adr);end
		endcase
		res.enJfun=op.enJcod|enBfun;
	end
endmodule
module ysyx_26020046_rv32iLSU(
	op_t.LSU op,
	res_t.LSU res,
	val_t.LSU val
	);
	import rv32iBasis::*;

	logic[3:0] mask;
	word_t iRAM;

	always_comb begin : choose_mask
		if (op.enS) begin unique case(op.LSop)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;$fatal("unknown mask==0x%x",op.LSop);end
		endcase end else 	mask=4'b0000;
	end
	always_comb begin : choose_date_input
		if(op.enL) begin unique case(op.LSop)
			B_:				val.data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				val.data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				val.data=iRAM;
			BU:				val.data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				val.data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	val.data=0;$fatal("unknown date==0x%x",op.LSop);end
		endcase end else 	val.data='0;
	end
	always_comb begin :write
		if((op.enL)&op.clk)begin
			iRAM=pmem_read(res.addr);
			`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:RESD  [%x] => %x",res.addr,iRAM);`endif
		end else iRAM = '0;
	end
	always_ff@(posedge op.clk) begin:control_write
		if (op.enS) begin // 有写请求时
			`ifdef RV32I_DEBUG $fdisplay(logFile,"LS:write [%x] <(%b)= %x",res.addr,mask,val.oR2);`endif
			pmem_write(res.addr,val.oR2, {4'b0,mask});
		end
	end
endmodule
module ysyx_26020046_rv32iGPR(
	op_t.GPR op,
	res_t.GPR res,
	val_t.GPR val
	);
	import rv32iBasis::*;

	word_t gpr [2**REG_NUMBER -1:1];

	always_ff@(posedge op.clk) begin:reg_write
		if(op.reset)begin
			for (int i = 1; i < 32; i++) gpr[i]<='0;
		end else begin
			`ifdef RV32I_DEBUG if(op.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",op.cRd,gpr[op.cRd],res.iRd);`endif
			if (op.cRd!=0) gpr[op.cRd] <= res.iRd;
    	end
	end
	assign val.oR1=(op.cR1==0)?'0:gpr[op.cR1];
	assign val.oR2=(op.cR2==0)?'0:gpr[op.cR2];

	export "DPI-C" function getReg;
	function int getReg(input int addr);
		return (addr == 0) ? val.pc : gpr[addr];
	endfunction
endmodule
module ysyx_26020046_rv32iCSR(
	input op_t op,
	input res_t res,
	output val_t val
	);
	import rv32iBasis::*;

	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

	always_ff@(posedge op.clk) begin:csr_write
		if(op.reset)begin
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
			if(~op.reset)begin
				if(op.SRop==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,res.iCsr,mcause,11);
				else if(op.SRop==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,res.iCsr,mcause,0);
				else if(op.SRop==WCCSR)begin unique case(op.SRaddr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				res.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		res.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			res.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			res.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			res.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		res.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		res.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	res.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",op.SRaddr); end
				endcase end
			end
	`endif
			unique case(op.SRop)
				ECALL:begin mepc<=res.iCsr;mcause<=11;{mcycleh,mcycle}<={mcycleh,mcycle}+1;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;{mcycleh,mcycle}<={mcycleh,mcycle}+1;end
				WCCSR:begin unique case(op.SRaddr)
					CSR_ADDR_MEPC		:mepc		<=res.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=res.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=res.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=res.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=res.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=res.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=res.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=res.iCsr;
					default:begin $fatal("unknown csrAddr==0x%x",op.SRaddr); end
					endcase end
				NCSR_:{mcycleh,mcycle}<={mcycleh,mcycle}+1;
				default:begin $fatal("unknown op.SRop==0x%x",op.SRop); end
				endcase
			end
		end

	always_comb begin:choose_csr
		unique case(op.SRaddr)
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
