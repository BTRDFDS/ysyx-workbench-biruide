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
	typedef struct packed {
		logic [6:0] fun7;
		logic [4:0] r2;
		logic [4:0] r1;
		logic [2:0] fun3;
		logic [4:0] rd;
		logic [6:0] op;		
	} code_t;
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
		in1_t		in1;
		in2_t		in2;
		logic enJcod;

		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	csr;
		ALUopCho_t	cho;
	} opALU_t;
	typedef struct packed {
		logic enS,enL;
		LSUop_t op;
	} opLSU_t;
	typedef struct packed {
		logic [11:0] addr;
		CSRop_t op;
	} opCSR_t;

	typedef struct packed {
		reg_t cRd,cR1,cR2;
	} opGPR_t;
	
	typedef struct packed {
		opALU_t ALU;
		opLSU_t LSU;
		opCSR_t CSR;
		opGPR_t GPR;
	} op_t;


	typedef struct packed {
		word_t addr,iRd,iCsr,data;
		logic enJfun;
	} res_t;
	typedef struct packed {
		word_t oR1,oR2,data,oCsr,imm,pc;
	} val_t;

	`ifdef RV32I_DEBUG
		integer logFile;
	`endif
endpackage
module ysyx_26020046_rv32i(clk,reset,code,pc);
	import rv32iBasis::*;
	input logic clk,reset;
	input code_t code;
	output word_t pc;

	op_t op;
	res_t res;
	val_t val;

	assign pc =val.pc; 

	ysyx_26020046_rv32iIDC IDC(.*);
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
				$fdisplay(logFile,"\npc=%x code=%x",pc,code);
				$fdisplay(logFile,"opAL:{[%s %s %s] b:%s adr:%s}[r:%s sr:%s]",op.ALU.in1.name(),op.ALU.in2.name(),op.ALU.cal.name(),op.ALU.bfu.name(),op.ALU.adr.name(),op.ALU.cho.name(),op.ALU.csr.name());
				$fdisplay(logFile,"op:LS[%s S%bL%b] SR[%s %x] R12d[%x %x %x]",op.LSU.op.name(),op.LSU.enS,op.LSU.enL,op.CSR.op.name(),op.CSR.addr,op.GPR.cR1,op.GPR.cR2,op.GPR.cRd);
				$fdisplay(logFile,"val:oR1=%x oR2=%x imm=%x oCsr=%x data=%x",val.oR1,val.oR2,val.imm,val.oCsr,val.data);
				$fdisplay(logFile,"res:addr=%x data=%x iRd=%x iCsr=%x enJ=%b",res.addr,res.data,res.iRd,res.iCsr,res.enJfun);
				
			end
		end
	`endif
endmodule
module ysyx_26020046_rv32iIDC(
	input code_t code,
	input logic reset,
	output op_t op,
	/* verilator lint_off UNDRIVEN */
	output val_t val
	/* verilator lint_on UNDRIVEN */
	);
	import rv32iBasis::*;
	import "DPI-C" function void stop(input bit eb);
	
	always_comb begin : ID
		op.ALU.in1=IR1;op.ALU.in2=IR2;
		op.ALU.adr=NAD;op.ALU.cal=NCAL;op.ALU.bfu=NBFU;
		op.ALU.csr=NACSR;op.ALU.cho=NCHO;
		op.LSU.op=NM;op.LSU.enS=0;op.LSU.enL=0;
		op.CSR.op=NCSR_;op.CSR.addr='0;
		{op.GPR,op.ALU.enJcod,val.imm}='0;

		if(~reset) begin
			unique case(code.op)
				OP_U_I	:val.imm={code[31:12],12'b0 };
				OP_U_P	:val.imm={code[31:12],12'b0 };
				OP_S__	:val.imm={{20{code[31]}},code[31:25], code[11:7] };
				OP_I_A	:val.imm={{20{code[31]}},code[31:20] };
				OP_I_J	:val.imm={{20{code[31]}},code[31:20] };
				OP_I_L	:val.imm={{20{code[31]}},code[31:20] };
				OP_B__	:val.imm={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
				OP_J__	:val.imm={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
				default	:val.imm='0;
			endcase
			unique case(code.op)
				OP_U_P	:op.ALU.in1=PC_;
				default	:op.ALU.in1=IR1;
			endcase
			unique case(code.op)
				OP_U_P	:op.ALU.in2=IMM;
				OP_I_A	:op.ALU.in2=IMM;
				default	:op.ALU.in2=IR2;
			endcase
			unique case(code.op)
				OP_J__	:op.ALU.enJcod=1;
				OP_I_J	:op.ALU.enJcod=1;
				OP_CSR	:op.ALU.enJcod=(code.fun3==3'b000);
				default	:op.ALU.enJcod=0;
			endcase

			unique case(code.op)//选ALU cal
				OP_U_P	:op.ALU.cal=ADD_;
				OP_I_A	:begin unique case(code.fun3)
						3'b001:begin unique case(code.fun7)
								7'b0000000:op.ALU.cal=SLL_;
								default:begin $fatal("slli fun7(%x)!=0",code.fun7);stop(0);end
							endcase end
						3'b101:begin unique case(code.fun7)
								7'b0000000:op.ALU.cal=SRL_;
								7'b0100000:op.ALU.cal=SRA_;
								default:begin $fatal("srai/srli fun7(%x)!=0/20",code.fun7);stop(0);end
							endcase end
						default:op.ALU.cal=ALUopCal_t'(code.fun3);
					endcase end
				OP_R__	:begin unique case(code.fun7)
						7'b0000000:op.ALU.cal=ALUopCal_t'(code.fun3);
						7'b0100000:begin unique case(code.fun3)
								3'b000:op.ALU.cal=SUB_;
								3'b101:op.ALU.cal=SRA_;
								default:begin $fatal("R fun7==20 fun3(%x)!=1/5",code.fun3);stop(0);end
							endcase end
						default:begin $fatal("R fun7(%x)!=0/20",code.fun7);stop(0);end
					endcase end
				default	:op.ALU.cal=NCAL;
			endcase

			if(code.op==OP_B__)begin//b系列
				op.ALU.bfu=ALUopBfu_t'(code.fun3);
			end else op.ALU.bfu=NBFU;

			unique case(code.op)//选ALU cho
				OP_U_I	:op.ALU.cho=IMM_;
				OP_U_P	:op.ALU.cho=CAL_;
				OP_J__	:op.ALU.cho=SNPC;
				OP_I_J	:op.ALU.cho=SNPC;
				OP_I_L	:op.ALU.cho=DATA;
				OP_I_A	:op.ALU.cho=CAL_;
				OP_R__	:op.ALU.cho=CAL_;
				OP_CSR	:op.ALU.cho=CCSR;
				default	:op.ALU.cho=NCHO;
			endcase
			unique case(code.op)//选ALU addr
				OP_J__	:op.ALU.adr=PCI;
				OP_I_J	:op.ALU.adr=R1I;
				OP_I_L	:op.ALU.adr=R1I;
				OP_CSR	:op.ALU.adr=ECJ;
				OP_B__	:op.ALU.adr=PCI;
				OP_S__	:op.ALU.adr=R1I;
				default	:op.ALU.adr=NAD;
			endcase

			unique case(code.op)//选LSU op
				OP_I_L	:op.LSU.op=LSUop_t'(code.fun3);
				OP_S__	:op.LSU.op=LSUop_t'(code.fun3);
				default	:op.LSU.op=NM;
			endcase
			op.LSU.enL=(code.op==OP_I_L);
			op.LSU.enS=(code.op==OP_S__);

			if(code.op==OP_CSR)begin unique case(code.fun3)//选CSR op addr
				3'b000	:begin unique case(code)
						OP_SCR_MRET__	:begin 								op.CSR.addr=CSR_ADDR_MEPC;	op.CSR.op=MRET_;					end
						OP_SCR_ECALL_	:begin 								op.CSR.addr=CSR_ADDR_MTVEC;	op.CSR.op=ECALL;					end
						OP_SCR_EBREAK	:begin 								op.CSR.addr='0;stop(1);		op.CSR.op=NCSR_;					end
						default			:begin 								op.CSR.addr='0;stop(0);		op.CSR.op=NCSR_;					end
					endcase 		op.ALU.csr=JUMP_;																						end
				3'b001	:begin 		op.ALU.csr=WACSR;						op.CSR.addr={code[31:20]};	op.CSR.op=WCCSR;					end
				3'b010	:begin 		op.ALU.csr=(code.r1=='0)?NACSR:RACSR;	op.CSR.addr={code[31:20]};	op.CSR.op=(code.r1=='0)?NCSR_:WCCSR;end
				default	:begin 		op.ALU.csr=NACSR;						op.CSR.addr='0;				op.CSR.op=NCSR_;					end
			endcase end else begin 	op.ALU.csr=NACSR;						op.CSR.addr='0;				op.CSR.op=NCSR_;					end

			unique case(code.op)//选cR1 这里7/10就反选
				OP_U_I	:op.GPR.cR1='0;
				OP_U_P	:op.GPR.cR1='0;
				OP_J__	:op.GPR.cR1='0;
				default	:op.GPR.cR1=code.r1;
			endcase
			unique case(code.op)//选cR2
				OP_S__	:op.GPR.cR2=code.r2;
				OP_R__	:op.GPR.cR2=code.r2;
				OP_B__	:op.GPR.cR2=code.r2;
				default	:op.GPR.cR2='0;
			endcase
			unique case(code.op)//选cRd 也是反选
				OP_B__	:op.GPR.cRd='0;
				OP_S__	:op.GPR.cRd='0;
				OP_CSR	:op.GPR.cRd=(code.fun3==3'b000)?'0:code.rd;
				default	:op.GPR.cRd=code.rd;
			endcase
		end
	end
endmodule
module ysyx_26020046_rv32iALU(
	input val_t val,
	/* verilator lint_off UNUSEDSIGNAL */
	input op_t op,
	/* verilator lint_on UNUSEDSIGNAL */
	output res_t res
	);
	import rv32iBasis::*;
	logic enBfun;
	word_t result,in1,in2;

	assign res.data=val.oR2;

	always_comb begin : cal
		unique case(op.ALU.in1)
			IR1:in1=val.oR1;
			PC_:in1=val.pc;
			default:begin in1='0;$fatal("unknown in1==0x%x",op.ALU.in1);end
		endcase
		unique case(op.ALU.in2)
			IR2:in2=val.oR2;
			IMM:in2=val.imm;
			default:begin in2='0;$fatal("unknown in2==0x%x",op.ALU.in2);end
		endcase

		unique case(op.ALU.cal)
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
			default:begin result='0;$fatal("unknown cal==0x%x",op.ALU.cal);end
		endcase
	end
	always_comb begin : bfu
		unique case(op.ALU.bfu)
			BEQ_:enBfun=(val.oR1==val.oR2);
			BNE_:enBfun=(val.oR1!=val.oR2);
			BLT_:enBfun=(  $signed(val.oR1) <  $signed(val.oR2));
			BGE_:enBfun=(  $signed(val.oR1)>=  $signed(val.oR2));
			BLTU:enBfun=($unsigned(val.oR1) <$unsigned(val.oR2));
			BGEU:enBfun=($unsigned(val.oR1)>=$unsigned(val.oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;$fatal("unknown bfu==0x%x",op.ALU.bfu);end
			endcase
	end
	always_comb begin : adr
		unique case(op.ALU.adr)
			R1I:res.addr=val.oR1+val.imm;
			PCI:res.addr=val.pc +val.imm;
			ECJ:res.addr=val.oCsr;
			ERE:res.addr=val.oCsr+4;
			NAD:res.addr='0;
			default:begin res.addr='0;$fatal("unknown adr==0x%x",op.ALU.adr);end
		endcase
		res.enJfun=op.ALU.enJcod|enBfun;
	end

	always_comb begin : cho
		unique case(op.ALU.cho)
			CAL_:res.iRd=result;
			IMM_:res.iRd=val.imm;
			DATA:res.iRd=val.data;
			CCSR:res.iRd=val.oCsr;
			SNPC:res.iRd=val.pc+4;
			NCHO:res.iRd='0;
			default:begin res.iRd='0;$fatal("unknown cho==0x%x",op.ALU.cho);end
		endcase
	end
	always_comb begin : csr
		unique case(op.ALU.csr)
			WACSR:res.iCsr=val.oR1;
			RACSR:res.iCsr=val.oR1|val.oCsr;
			JUMP_:res.iCsr=val.pc;
			NCSR_:res.iCsr='0;
			default:begin res.iCsr='0;$fatal("unknown csr==0x%x",op.ALU.csr);end
		endcase
	end
endmodule
module ysyx_26020046_rv32iLSU(
	input logic clk,
	input logic reset,
	/* verilator lint_off UNUSEDSIGNAL */
	input res_t res,
	input op_t op,
	/* verilator lint_on UNUSEDSIGNAL */
	/* verilator lint_off UNDRIVEN */
	output val_t val
	/* verilator lint_on UNDRIVEN */
	);
	import rv32iBasis::*;

	logic[3:0] mask;
	/* verilator lint_off UNOPTFLAT */
	word_t iRAM;
	/* verilator lint_on UNOPTFLAT */
	word_t pc;

	always_comb begin : choose_mask
		if (op.LSU.enS) begin unique case(op.LSU.op)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;$fatal("unknown mask==0x%x",op.LSU.op);end
		endcase end else 	mask=4'b0000;
	end
	always_comb begin : choose_date_input
		if(op.LSU.enL) begin unique case(op.LSU.op)
			B_:				val.data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				val.data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				val.data=iRAM;
			BU:				val.data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				val.data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	val.data=0;$fatal("unknown date==0x%x",op.LSU.op);end
		endcase end else 	val.data='0;
	end
	assign val.pc=pc;
	always_ff @(posedge clk) begin : pc_write
	`ifdef RV32I_DEBUG
		if(res.enJfun) $fdisplay(logFile,"PC:%x => %x",pc,res.addr);
	`endif
		if(reset) pc<=PC_RESET;
		else if(res.enJfun) pc<=(res.addr&32'hFFFFFFFC);
		else pc<=pc+4;
	end

	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
	always_comb begin
		if((op.LSU.enL)&clk)begin
			iRAM=pmem_read(res.addr);
	`ifdef RV32I_DEBUG
			$fdisplay(logFile,"LS:RESD  [%x] => %x",res.addr,iRAM);
	`endif
		end else iRAM = '0;
	end
	always_ff@(posedge clk) begin:control_write
		if (op.LSU.enS) begin // 有写请求时
	`ifdef RV32I_DEBUG
			$fdisplay(logFile,"LS:write [%x] <(%b)= %x",res.addr,mask,res.data);
	`endif
			pmem_write(res.addr,res.data, {4'b0,mask});
		end
	end
endmodule
module ysyx_26020046_rv32iGPR(
	input word_t pc,
	input logic clk,
	input logic reset,
	/* verilator lint_off UNUSEDSIGNAL */
	input op_t op,
	input res_t res,
	/* verilator lint_on UNUSEDSIGNAL */
	/* verilator lint_off UNDRIVEN */
	output val_t val
	/* verilator lint_on UNDRIVEN */
	);
	import rv32iBasis::*;

	word_t gpr [2**REG_NUMBER -1:1];

	always_ff@(posedge clk) begin:reg_write
		if(reset)begin
			for (int i = 1; i < 32; i++) gpr[i]<='0;
		end else begin
			if (op.GPR.cRd!=0) gpr[op.GPR.cRd] <= res.iRd;
    	end
	end

	`ifdef RV32I_DEBUG
	always@(posedge clk)begin
		if(op.GPR.cRd!=0)$fstrobe(logFile,"RG:[%d]%x <= %x",op.GPR.cRd,gpr[op.GPR.cRd],res.iRd);
	end
	`endif

	assign val.oR1=(op.GPR.cR1==0)?'0:gpr[op.GPR.cR1];
	assign val.oR2=(op.GPR.cR2==0)?'0:gpr[op.GPR.cR2];

	export "DPI-C" function getReg;
	function int getReg(input int addr);
		return (addr == 0) ? pc : gpr[addr];
	endfunction
endmodule
module ysyx_26020046_rv32iCSR(
	input logic clk,
	input logic reset,
	/* verilator lint_off UNUSEDSIGNAL */
	input op_t op,
	input res_t res,
	/* verilator lint_on UNUSEDSIGNAL */
	/* verilator lint_off UNDRIVEN */
	output val_t val
	/* verilator lint_on UNDRIVEN */
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
				if(op.CSR.op==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,res.iCsr,mcause,11);
				else if(op.CSR.op==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,res.iCsr,mcause,0);
				else if(op.CSR.op==WCCSR)begin unique case(op.CSR.addr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				res.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		res.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			res.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			res.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			res.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		res.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		res.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	res.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",op.CSR.addr); end
				endcase end
			end
	`endif
			unique case(op.CSR.op)
				ECALL:begin mepc<=res.iCsr;mcause<=11;{mcycleh,mcycle}<={mcycleh,mcycle}+1;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;{mcycleh,mcycle}<={mcycleh,mcycle}+1;end
				WCCSR:begin unique case(op.CSR.addr)
					CSR_ADDR_MEPC		:mepc		<=res.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=res.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=res.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=res.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=res.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=res.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=res.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=res.iCsr;
					default:begin $fatal("unknown csrAddr==0x%x",op.CSR.addr); end
					endcase end
				NCSR_:{mcycleh,mcycle}<={mcycleh,mcycle}+1;
				default:begin $fatal("unknown op.CSR.op==0x%x",op.CSR.op); end
				endcase
			end
		end

	always_comb begin:choose_csr
		unique case(op.CSR.addr)
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
