module ysyx_26020046_rv32iCasezSta(clk,reset,code,pc,pmem_read,pmem_write,addr,oR2,mask,stop,eb);
	
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
	parameter OP_I_J	= 7'b1100111;//jalr	  +
	parameter OP_I_A	= 7'b0010011;//i运算	 运算器
	parameter OP_I_L	= 7'b0000011;//l系列	 +
	parameter OP_U_I	= 7'b0110111;//lui	   无
	parameter OP_U_P	= 7'b0010111;//auipc	 +
	parameter OP_S__	= 7'b0100011;//s系列	 +
	parameter OP_B__	= 7'b1100011;//b比较系列 比较
	parameter OP_J__	= 7'b1101111;//jal	   +
	parameter OP_R__ 	= 7'b0110011;//r运算	 运算器
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
	typedef struct packed {
		word_t		im;
		in1_t		in1;
		in2_t		in2;
		logic enJcod;

		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	csr;
		ALUopCho_t	cho;
	} opALU_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;//NM插在中间，必要时可以去掉
	typedef struct packed {
		logic enS,enL,enJfun;
		LSUop_t op;
	} opLSU_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;
	typedef struct packed {
		logic [11:0] addr;
		CSRop_t op;
	} opCSR_t;
	
	typedef struct packed {
		opALU_t ALU;//ALU
		opLSU_t LSU;//LSU
		opCSR_t CSR;//CSR
	} op_t;

	input logic clk,reset;
	// input word_t code;
	input code_t code;
	output word_t pc,oR2,addr;
	input word_t pmem_read;
	output logic pmem_write,stop,eb;
	output logic[3:0] mask;

	word_t oR1,data,iRd,iCsr,oCsr;
	reg_t cRd,cR1,cR2;
	op_t op;
	logic enJfun;
	

	ysyx_26020046_rv32iIDC IDC(.*);
	ysyx_26020046_rv32iALU ALU(.*);
	ysyx_26020046_rv32iLSU LSU(.*);
	ysyx_26020046_rv32iGPR GPR(.*);
	ysyx_26020046_rv32iCSR CSR(.*);

	`ifdef RV32I_DEBUG
		initial begin
			logFile = $fopen("rv32iDebugLog.txt");
			$write("\033[1;35m SV_DEBUG \033[0m");
		end
		always @(posedge clk) begin
			$fdisplay(logFile,"IF:pc=%x code=%x reset=%x cR1=%x cR2=%x cRd=%x",pc,code,reset,cR1,cR2,cRd);
			// $fdisplay(logFile,"ID:fun7=%x r2=%x r1=%x fun3=%x rd=%x op=%x",code.fun7,code.r2,code.r1,code.fun3,code.rd,code.op);
			$fdisplay(logFile,"ID:oR1=%x in1=%x oR2=%x in2=%x im=%x oCsr=%x",oR1,op.ALU.in1,oR2,op.ALU.in2,op.ALU.im,oCsr);
			$fdisplay(logFile,"AL:cal=%x bfu=%x adr=%x cho=%x csr=%x",op.ALU.cal,op.ALU.bfu,op.ALU.adr,op.ALU.cho,op.ALU.csr);
			$fdisplay(logFile,"AL:data=%x addr=%x iRd=%x iCsr=%x enJ=%x",data,addr,iRd,iCsr,enJfun);
			$fdisplay(logFile,"LS:op=%x enS=%x enL=%x",op.LSU.op,op.LSU.enS,op.LSU.enL);
			$fdisplay(logFile,"SR:op=%x addr=%x",op.CSR.op,op.CSR.addr);
		end
	`endif
endmodule
module ysyx_26020046_rv32iIDC(code,reset,cRd,cR1,cR2,op,stop,eb);
	
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
	parameter OP_I_J	= 7'b1100111;//jalr	  +
	parameter OP_I_A	= 7'b0010011;//i运算	 运算器
	parameter OP_I_L	= 7'b0000011;//l系列	 +
	parameter OP_U_I	= 7'b0110111;//lui	   无
	parameter OP_U_P	= 7'b0010111;//auipc	 +
	parameter OP_S__	= 7'b0100011;//s系列	 +
	parameter OP_B__	= 7'b1100011;//b比较系列 比较
	parameter OP_J__	= 7'b1101111;//jal	   +
	parameter OP_R__ 	= 7'b0110011;//r运算	 运算器
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
	typedef struct packed {
		word_t		im;
		in1_t		in1;
		in2_t		in2;
		logic enJcod;

		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	csr;
		ALUopCho_t	cho;
	} opALU_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;//NM插在中间，必要时可以去掉
	typedef struct packed {
		logic enS,enL,enJfun;
		LSUop_t op;
	} opLSU_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;
	typedef struct packed {
		logic [11:0] addr;
		CSRop_t op;
	} opCSR_t;
	
	typedef struct packed {
		opALU_t ALU;//ALU
		opLSU_t LSU;//LSU
		opCSR_t CSR;//CSR
	} op_t;

	// import "DPI-C" function void stop=1'b1;eb=1'biput bit eb);
	input code_t code;
	input logic reset;
	output reg_t cRd,cR1,cR2;
	output op_t op;
	output logic stop,eb;
	
	always_comb begin : ID
		op.ALU.in1=IR1;op.ALU.in2=IR2;
		op.ALU.adr=NAD;op.ALU.cal=NCAL;op.ALU.bfu=NBFU;
		op.ALU.csr=NACSR;op.ALU.cho=NCHO;
		op.LSU.op=NM;op.LSU.enS=0;op.LSU.enL=0;
		op.CSR.op=NCSR_;op.CSR.addr='0;
		{cR1,cR2,cRd,op.ALU.enJcod,op.ALU.im}='0;
		stop=1'b1;eb=1'b0;

		if(~reset) begin
			unique case(code.op)//选ALU imm
				OP_U_I	:op.ALU.im={code[31:12],12'b0 };
				OP_U_P	:op.ALU.im={code[31:12],12'b0 };
				OP_S__	:op.ALU.im={{20{code[31]}},code[31:25], code[11:7] };
				OP_I_A	:op.ALU.im={{20{code[31]}},code[31:20] };
				OP_I_J	:op.ALU.im={{20{code[31]}},code[31:20] };
				OP_I_L	:op.ALU.im={{20{code[31]}},code[31:20] };
				OP_B__	:op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
				OP_J__	:op.ALU.im={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
				default	:op.ALU.im='0;
			endcase
			unique case(code.op)//选ALU in1 只有auipc会用到它
				OP_U_P	:op.ALU.in1=PC_;
				default	:op.ALU.in1=IR1;
			endcase
			unique case(code.op)//选ALU in2 只有auipc和立即数计算系列
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

			// unique case(code.op)//选ALU cal
			// 	OP_U_P	:op.ALU.cal=ADD_;
			// 	OP_I_A	:begin unique case(code.fun3)
			// 			3'b001:begin unique case(code.fun7)
			// 					7'b0000000:op.ALU.cal=SLL_;
			// 					default:begin stop=1'b1;eb=1'b0;end
			// 				endcase end
			// 			3'b101:begin unique case(code.fun7)
			// 					7'b0000000:op.ALU.cal=SRL_;
			// 					7'b0100000:op.ALU.cal=SRA_;
			// 					default:begin stop=1'b1;eb=1'b0;end
			// 				endcase end
			// 			default:op.ALU.cal=ALUopCal_t'(code.fun3);
			// 		endcase end
			// 	OP_R__	:begin unique case(code.fun7)
			// 			7'b0000000:op.ALU.cal=ALUopCal_t'(code.fun3);
			// 			7'b0100000:begin unique case(code.fun3)
			// 					3'b000:op.ALU.cal=SUB_;
			// 					3'b101:op.ALU.cal=SRA_;
			// 					default:begin stop=1'b1;eb=1'b0;end
			// 				endcase end
			// 			default:begin stop=1'b1;eb=1'b0;end
			// 		endcase end
			// 	default	:op.ALU.cal=NCAL;
			// endcase
			unique casez({code.fun7,code.fun3,code.op})
				{7'b???????,3'b???,OP_U_I}	:op.ALU.cal=ADD_;
				{7'b0000000,3'b001,OP_I_A}	:op.ALU.cal=SLL_;
				{7'b0000000,3'b101,OP_I_A}	:op.ALU.cal=SRL_;
				{7'b0100000,3'b101,OP_I_A}	:op.ALU.cal=SRA_;
				{7'b???????,3'b??0,OP_I_A}	:op.ALU.cal=ALUopCal_t'(code.fun3);
				{7'b???????,3'b?11,OP_I_A}	:op.ALU.cal=ALUopCal_t'(code.fun3);
				{7'b0000000,3'b???,OP_R__}	:op.ALU.cal=ALUopCal_t'(code.fun3);
				{7'b0000000,3'b000,OP_R__}	:op.ALU.cal=SUB_;
				{7'b0100000,3'b101,OP_R__}	:op.ALU.cal=SRA_;
				default						:op.ALU.cal=NCAL;
			endcase

			if(code.op==OP_B__)begin//b系列
				op.ALU.bfu=ALUopBfu_t'(code.fun3);
			end else op.ALU.bfu=NBFU;

			unique case(code.op)//选ALU cho addr
				OP_U_I	:begin op.ALU.cho=IMM_;end
				OP_U_P	:begin op.ALU.cho=CAL_;end
				OP_J__	:begin op.ALU.cho=SNPC;end
				OP_I_J	:begin op.ALU.cho=SNPC;end
				OP_I_L	:begin op.ALU.cho=DATA;end
				OP_I_A	:begin op.ALU.cho=CAL_;end
				OP_R__	:begin op.ALU.cho=CAL_;end
				OP_CSR	:begin op.ALU.cho=CCSR;end
				default	:begin op.ALU.cho=NCHO;end
			endcase
			unique case(code.op)//选ALU cho addr
				OP_J__	:begin op.ALU.adr=PCI;end
				OP_I_J	:begin op.ALU.adr=R1I;end
				OP_I_L	:begin op.ALU.adr=R1I;end
				OP_CSR	:begin op.ALU.adr=ECJ;end
				OP_B__	:begin op.ALU.adr=PCI;end
				OP_S__	:begin op.ALU.adr=R1I;end
				default	:begin op.ALU.adr=NAD;end
			endcase

			unique case(code.op)//选LSU op
				OP_I_L	:op.LSU.op=LSUop_t'(code.fun3);
				OP_S__	:op.LSU.op=LSUop_t'(code.fun3);
				default	:op.LSU.op=NM;
			endcase
			op.LSU.enL=(code.op==OP_I_L);
			op.LSU.enS=(code.op==OP_S__);

			// if(code.op==OP_CSR)begin unique case(code.fun3)//选CSR op addr
			// 	3'b000	:begin
			// 		op.ALU.csr=JUMP_;
			// 		unique case(code)
			// 			OP_SCR_MRET__	:begin op.CSR.op=MRET_;op.CSR.addr=CSR_ADDR_MEPC;		end
			// 			OP_SCR_ECALL_	:begin op.CSR.op=ECALL;op.CSR.addr=CSR_ADDR_MTVEC;		end
			// 			OP_SCR_EBREAK	:begin op.CSR.op=NCSR_;op.CSR.addr='0;stop=1'b1;eb=1'b1;end
			// 			default			:begin op.CSR.op=NCSR_;op.CSR.addr='0;stop=1'b1;eb=1'b0;end
			// 		endcase end
			// 	3'b001	:begin op.CSR.addr={code[31:20]};	op.CSR.op=WCCSR;					op.ALU.csr=WACSR;						end
			// 	3'b010	:begin op.CSR.addr={code[31:20]};	op.CSR.op=(code.r1=='0)?NCSR_:WCCSR;op.ALU.csr=(code.r1=='0)?NACSR:RACSR;	end
			// 	default	:begin op.CSR.addr='0;				op.CSR.op=NCSR_;					op.ALU.csr=NACSR;						end
			// endcase end else begin op.CSR.addr='0;			op.CSR.op=NCSR_;					op.ALU.csr=NACSR;						end

			if(code.op==OP_CSR)begin unique casez({code.fun7,code.r2,code.r1,code.fun3,code.rd})
				25'b0011000_00010_00000_000_00000	:begin op.ALU.csr=JUMP_;					op.CSR.addr=CSR_ADDR_MEPC;	op.CSR.op=MRET_;					end
				25'b0000000_00000_00000_000_00000	:begin op.ALU.csr=JUMP_;					op.CSR.addr=CSR_ADDR_MTVEC;	op.CSR.op=ECALL;					end
				25'b0000000_00001_00000_000_00000	:begin op.ALU.csr=JUMP_;					op.CSR.addr='0;				op.CSR.op=NCSR_;stop=1'b1;eb=1'b1;	end
				25'b???????_?????_?????_001_?????	:begin op.ALU.csr=WACSR;					op.CSR.addr={code[31:20]};	op.CSR.op=WCCSR;					end
				25'b???????_?????_?????_010_?????	:begin op.ALU.csr=(code.r1=='0)?NACSR:RACSR;op.CSR.addr={code[31:20]};	op.CSR.op=(code.r1=='0)?NCSR_:WCCSR;end
				default								:begin op.ALU.csr=NACSR;					op.CSR.addr='0;				op.CSR.op=NCSR_;stop=1'b1;eb=1'b0;	end
			endcase end else						 begin op.ALU.csr=NACSR;					op.CSR.addr='0;				op.CSR.op=NCSR_;					end

			unique case(code.op)//选cR1 这里7/10就反选
				OP_U_I	:cR1='0;
				OP_U_P	:cR1='0;
				OP_J__	:cR1='0;
				default	:cR1=code.r1;
			endcase
			unique case(code.op)//选cR2
				OP_S__	:cR2=code.r2;
				OP_R__	:cR2=code.r2;
				OP_B__	:cR2=code.r2;
				default	:cR2='0;
			endcase
			unique case(code.op)//选cRd 也是反选
				OP_B__	:cRd='0;
				OP_S__	:cRd='0;
				OP_CSR	:cRd=(code.fun3==3'b000)?'0:code.rd;
				default	:cRd=code.rd;
			endcase
		end
	end
endmodule
module ysyx_26020046_rv32iALU(oR1,oR2,pc,data,addr,iRd,enJfun,op,oCsr,iCsr);
	
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
	parameter OP_I_J	= 7'b1100111;//jalr	  +
	parameter OP_I_A	= 7'b0010011;//i运算	 运算器
	parameter OP_I_L	= 7'b0000011;//l系列	 +
	parameter OP_U_I	= 7'b0110111;//lui	   无
	parameter OP_U_P	= 7'b0010111;//auipc	 +
	parameter OP_S__	= 7'b0100011;//s系列	 +
	parameter OP_B__	= 7'b1100011;//b比较系列 比较
	parameter OP_J__	= 7'b1101111;//jal	   +
	parameter OP_R__ 	= 7'b0110011;//r运算	 运算器
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
	typedef struct packed {
		word_t		im;
		in1_t		in1;
		in2_t		in2;
		logic enJcod;

		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	csr;
		ALUopCho_t	cho;
	} opALU_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;//NM插在中间，必要时可以去掉
	typedef struct packed {
		logic enS,enL,enJfun;
		LSUop_t op;
	} opLSU_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;
	typedef struct packed {
		logic [11:0] addr;
		CSRop_t op;
	} opCSR_t;
	
	typedef struct packed {
		opALU_t ALU;//ALU
		opLSU_t LSU;//LSU
		opCSR_t CSR;//CSR
	} op_t;

	//
	input word_t oR1,oR2,pc,data;
	/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
	/* verilator lint_on UNUSEDSIGNAL */

	input word_t oCsr;
	output word_t addr,iRd,iCsr;
	output logic enJfun;
	logic enBfun;

	word_t result,in1,in2;

	always_comb begin : cal
		unique case(op.ALU.in1)
			IR1:in1=oR1;
			PC_:in1=pc;
			default:begin in1='0;end
		endcase
		unique case(op.ALU.in2)
			IR2:in2=oR2;
			IMM:in2=op.ALU.im;
			default:begin in2='0;end
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
			default:begin result='0;end
		endcase
	end
	always_comb begin : bfu
		unique case(op.ALU.bfu)
			BEQ_:enBfun=(oR1==oR2);
			BNE_:enBfun=(oR1!=oR2);
			BLT_:enBfun=(  $signed(oR1) <  $signed(oR2));
			BGE_:enBfun=(  $signed(oR1)>=  $signed(oR2));
			BLTU:enBfun=($unsigned(oR1) <$unsigned(oR2));
			BGEU:enBfun=($unsigned(oR1)>=$unsigned(oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;end
			endcase
	end
	always_comb begin : adr
		unique case(op.ALU.adr)
			R1I:addr=oR1+op.ALU.im;
			PCI:addr=pc+op.ALU.im;
			ECJ:addr=oCsr;
			ERE:addr=oCsr+4;
			NAD:addr='0;
			default:begin addr='0;end
		endcase
		enJfun=op.ALU.enJcod|enBfun;
	end

	always_comb begin : cho
		unique case(op.ALU.cho)
			CAL_:iRd=result;
			IMM_:iRd=op.ALU.im;
			DATA:iRd=data;
			CCSR:iRd=oCsr;
			SNPC:iRd=pc+4;
			NCHO:iRd='0;
			default:begin iRd='0;end
		endcase
	end
	always_comb begin : csr
		unique case(op.ALU.csr)
			WACSR:iCsr=oR1;
			RACSR:iCsr=oR1|oCsr;
			JUMP_:iCsr=pc;
			NCSR_:iCsr='0;
			default:begin iCsr='0;end
		endcase
	end
endmodule
module ysyx_26020046_rv32iLSU(clk,reset,addr,oR2,enJfun,op,data,pc,pmem_read,pmem_write,mask);
	
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
	parameter OP_I_J	= 7'b1100111;//jalr	  +
	parameter OP_I_A	= 7'b0010011;//i运算	 运算器
	parameter OP_I_L	= 7'b0000011;//l系列	 +
	parameter OP_U_I	= 7'b0110111;//lui	   无
	parameter OP_U_P	= 7'b0010111;//auipc	 +
	parameter OP_S__	= 7'b0100011;//s系列	 +
	parameter OP_B__	= 7'b1100011;//b比较系列 比较
	parameter OP_J__	= 7'b1101111;//jal	   +
	parameter OP_R__ 	= 7'b0110011;//r运算	 运算器
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
	typedef struct packed {
		word_t		im;
		in1_t		in1;
		in2_t		in2;
		logic enJcod;

		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	csr;
		ALUopCho_t	cho;
	} opALU_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;//NM插在中间，必要时可以去掉
	typedef struct packed {
		logic enS,enL,enJfun;
		LSUop_t op;
	} opLSU_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;
	typedef struct packed {
		logic [11:0] addr;
		CSRop_t op;
	} opCSR_t;
	
	typedef struct packed {
		opALU_t ALU;//ALU
		opLSU_t LSU;//LSU
		opCSR_t CSR;//CSR
	} op_t;

	input word_t addr,oR2,pmem_read;
	input logic clk,reset,enJfun;
	/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
	/* verilator lint_on UNUSEDSIGNAL */

	output word_t data,pc;
	output logic pmem_write;

	output logic[3:0] mask;
	word_t iRAM;

	always_comb begin : choose_mask
		if (op.LSU.enS) begin unique case(op.LSU.op)
			B_:mask=4'b0001;
			H_:mask=4'b0011;
			W_:mask=4'b1111;
			NM:mask=4'b0000;
			default:begin mask=4'b0000;end
		endcase end else mask=4'b0000;
	end
	always_comb begin : choose_date_input
		if(op.LSU.enL) begin unique case(op.LSU.op)
			B_:data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:data=iRAM;
			BU:data={{24{1'b0}},iRAM[ 7: 0]};
			HU:data={{16{1'b0}},iRAM[15: 0]};
			default:begin data=0;end
		endcase end else data='0;
	end

	always_ff @(posedge clk) begin : pc_write
	`ifdef RV32I_DEBUG
		if(enJfun) $fdisplay(logFile,"PC:%x => %x",pc,addr);
	`endif
		if(reset) pc<=PC_RESET;
		else if(enJfun) pc<=addr;
		else pc<=pc+4;
	end

	// import "DPI-C" function int pmem_read(input int unsigned addr);
	// import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
	always_comb begin
		if((op.LSU.enL)&clk)begin
			iRAM=pmem_read;
	`ifdef RV32I_DEBUG
			$fdisplay(logFile,"LS:RESD  [%x] => %x",addr,iRAM);
	`endif
		end else iRAM = '0;
	end
	always_ff@(posedge clk) begin:control_write
		if (op.LSU.enS) begin // 有写请求时
	`ifdef RV32I_DEBUG
			$fdisplay(logFile,"LS:write [%x] <(%b)= %x",addr,mask,oR2);
	`endif
			pmem_write=1'b1;
		end
	end
endmodule
module ysyx_26020046_rv32iGPR(iRd,clk,reset,cRd,cR1,cR2,oR1,oR2);
	
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
	parameter OP_I_J	= 7'b1100111;//jalr	  +
	parameter OP_I_A	= 7'b0010011;//i运算	 运算器
	parameter OP_I_L	= 7'b0000011;//l系列	 +
	parameter OP_U_I	= 7'b0110111;//lui	   无
	parameter OP_U_P	= 7'b0010111;//auipc	 +
	parameter OP_S__	= 7'b0100011;//s系列	 +
	parameter OP_B__	= 7'b1100011;//b比较系列 比较
	parameter OP_J__	= 7'b1101111;//jal	   +
	parameter OP_R__ 	= 7'b0110011;//r运算	 运算器
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
	typedef struct packed {
		word_t		im;
		in1_t		in1;
		in2_t		in2;
		logic enJcod;

		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	csr;
		ALUopCho_t	cho;
	} opALU_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;//NM插在中间，必要时可以去掉
	typedef struct packed {
		logic enS,enL,enJfun;
		LSUop_t op;
	} opLSU_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;
	typedef struct packed {
		logic [11:0] addr;
		CSRop_t op;
	} opCSR_t;
	
	typedef struct packed {
		opALU_t ALU;//ALU
		opLSU_t LSU;//LSU
		opCSR_t CSR;//CSR
	} op_t;

	input word_t iRd;
	input logic clk,reset;
	input reg_t cRd,cR1,cR2;
	output word_t oR1,oR2;

	word_t gpr [2**REG_NUMBER -1:1];

	always_ff@(posedge clk) begin:reg_write
		if(reset)begin
			for (int i = 1; i < 32; i++) gpr[i]<='0;
		end else begin
			if (cRd!=0) gpr[cRd] <= iRd;
    	end
	end

	`ifdef RV32I_DEBUG
	always@(posedge clk)begin
		if(cRd!=0)begin
		$fstrobe(logFile,"RG:[%d]%x <= %x",cRd,gpr[cRd],iRd);
		// $fstrobe(logFile,"RG:$0:%8x ra:%8x  sp:%8x  gp:%8x tp:%8x t0:%8x t1:%8x t2:%8x",      0,gpr[ 1],gpr[ 2],gpr[ 3],gpr[ 4],gpr[ 5],gpr[ 6],gpr[ 7]);
		// $fstrobe(logFile,"RG:s0:%8x s1:%8x  a0:%8x  a1:%8x a2:%8x a3:%8x a4:%8x a5:%8x",gpr[ 8],gpr[ 9],gpr[10],gpr[11],gpr[12],gpr[13],gpr[14],gpr[15]);
		// $fstrobe(logFile,"RG:a6:%8x a7:%8x  s2:%8x  s3:%8x s4:%8x s5:%8x s6:%8x s7:%8x",gpr[16],gpr[17],gpr[18],gpr[19],gpr[20],gpr[21],gpr[22],gpr[23]);
		// $fstrobe(logFile,"RG:s8:%8x s9:%8x s10:%8x s11:%8x t3:%8x t4:%8x t5:%8x t6:%8x",gpr[24],gpr[25],gpr[26],gpr[27],gpr[28],gpr[29],gpr[30],gpr[31]);
		end
		$fstrobe(logFile,"### posedge clk off ###\n");
	end
	`endif

	assign oR1=(cR1==0)?'0:gpr[cR1];
	assign oR2=(cR2==0)?'0:gpr[cR2];

	// export "DPI-C" function getReg;
	// function int getReg(input int addr);
	// 	return (addr == 0) ? pc : gpr[addr];
	// endfunction
endmodule
module ysyx_26020046_rv32iCSR(op,iCsr,oCsr,clk,reset);
	
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
	parameter OP_I_J	= 7'b1100111;//jalr	  +
	parameter OP_I_A	= 7'b0010011;//i运算	 运算器
	parameter OP_I_L	= 7'b0000011;//l系列	 +
	parameter OP_U_I	= 7'b0110111;//lui	   无
	parameter OP_U_P	= 7'b0010111;//auipc	 +
	parameter OP_S__	= 7'b0100011;//s系列	 +
	parameter OP_B__	= 7'b1100011;//b比较系列 比较
	parameter OP_J__	= 7'b1101111;//jal	   +
	parameter OP_R__ 	= 7'b0110011;//r运算	 运算器
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
	typedef struct packed {
		word_t		im;
		in1_t		in1;
		in2_t		in2;
		logic enJcod;

		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	csr;
		ALUopCho_t	cho;
	} opALU_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;//NM插在中间，必要时可以去掉
	typedef struct packed {
		logic enS,enL,enJfun;
		LSUop_t op;
	} opLSU_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;
	typedef struct packed {
		logic [11:0] addr;
		CSRop_t op;
	} opCSR_t;
	
	typedef struct packed {
		opALU_t ALU;//ALU
		opLSU_t LSU;//LSU
		opCSR_t CSR;//CSR
	} op_t;

	/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
	/* verilator lint_on UNUSEDSIGNAL */
	input word_t iCsr;
	input logic clk,reset;
	output word_t oCsr;

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
				if(op.CSR.op==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,iCsr,mcause,11);
				else if(op.CSR.op==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,iCsr,mcause,0);
				else if(op.CSR.op==WCCSR)begin unique case(op.CSR.addr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus	,iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh	,iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid	,iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid	,iCsr);
					default:begin end
				endcase end
			end
	`endif
			unique case(op.CSR.op)
				ECALL:begin mepc<=iCsr;mcause<=11;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;{mcycleh,mcycle}<={mcycleh,mcycle}+1;end
				WCCSR:begin unique case(op.CSR.addr)
					CSR_ADDR_MEPC		:mepc	<=iCsr;
					CSR_ADDR_MSTAUS		:mstatus<=iCsr;
					CSR_ADDR_MTVEC		:mtvec	<=iCsr;
					CSR_ADDR_MCAUSE		:mcause	<=iCsr;
					CSR_ADDR_MCYCLE		:mcycle	<=iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh<=iCsr;
					CSR_ADDR_MARCHID	:marchid<=iCsr;
					CSR_ADDR_MVENDORID	:mvendorid<=iCsr;
					default:begin  end
					endcase end
				NCSR_:{mcycleh,mcycle}<={mcycleh,mcycle}+1;
				default:begin end
				endcase
			end
		end

	always_comb begin:choose_csr
		unique case(op.CSR.addr)
			CSR_ADDR_MEPC		:oCsr=mepc;
			CSR_ADDR_MSTAUS		:oCsr=mstatus;
			CSR_ADDR_MTVEC		:oCsr=mtvec;
			CSR_ADDR_MCAUSE		:oCsr=mcause;
			CSR_ADDR_MCYCLE		:oCsr=mcycle;
			CSR_ADDR_MCYCLEH	:oCsr=mcycleh;
			CSR_ADDR_MARCHID	:oCsr=marchid;
			CSR_ADDR_MVENDORID	:oCsr=mvendorid;
			default				:oCsr=0;
		endcase
	end
endmodule
