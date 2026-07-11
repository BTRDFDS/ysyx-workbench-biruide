module ysyx_26020046_rv32iSta(clk,reset,code,pc,stop,eb,pmem_read,pmem_write,addr,mask,enW);
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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

	parameter OP_CSR	= 7'b1110011;//CSR系列
	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;
	

	parameter MSTATUS_RESET = 32'h1800;

	// parameter OP_FUN7_M		= 7'b0000001;

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
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NCCSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[3:0] {NCHO,CAL_,DATA,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[1:0] {IR1,PC_} in1_t;
	typedef enum logic[1:0] {IR2,IMM} in2_t;
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

	typedef enum logic[2:0] {N,I,U,S,B,J} imCode_t;
	input logic clk,reset;
	input word_t pmem_read;
	input code_t code;
	output word_t pc,pmem_write,addr;
	output logic stop,eb,enW;
	assign pmem_write=oR2;
	assign enW=op.LSU.enS;

	word_t oR1,oR2,data,iRd,iCsr,oCsr;
	reg_t cRd,cR1,cR2;
	op_t op;
	logic enJfun;
	output logic[3:0] mask;

	ysyx_26020046_rv32iIDC IDC(.*);
	ysyx_26020046_rv32iALU ALU(.*);
	ysyx_26020046_rv32iLSU LSU(.*);
	ysyx_26020046_rv32iGPR GPR(.*);
	ysyx_26020046_rv32iCSR CSR(.*);

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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

	parameter OP_CSR	= 7'b1110011;//CSR系列
	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;
	

	parameter MSTATUS_RESET = 32'h1800;

	// parameter OP_FUN7_M		= 7'b0000001;

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
	typedef enum logic[3:0] {NCHO,CAL_,DATA,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[1:0] {IR1,PC_} in1_t;
	typedef enum logic[1:0] {IR2,IMM} in2_t;
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

	typedef enum logic[2:0] {N,I,U,S,B,J} imCode_t;
	input code_t code;
	input logic reset;
	// output logic enJfun;
	// output word_t im;
	output reg_t cRd,cR1,cR2;
	output op_t op;
	output logic stop,eb;
	// imCode_t imm;
	// logic error;
	
	always_comb begin : ID
		// imm=N;
		op.ALU.in1=IR1;op.ALU.in2=IR2;
		op.ALU.adr=NAD;op.ALU.cal=NCAL;op.ALU.bfu=NBFU;
		op.ALU.csr=NACSR;op.ALU.cho=NCHO;
		op.LSU.op=NM;op.LSU.enS=0;op.LSU.enL=0;
		op.CSR.op=NCSR_;op.CSR.addr='0;
		{cR1,cR2,cRd,op.ALU.enJcod,stop,eb,op.ALU.im}='0;

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

			unique case(code.op)//选ALU cal
				OP_U_P	:op.ALU.cal=ADD_;
				OP_I_A	:begin unique case(code.fun3)
						3'b001:begin unique case(code.fun7)
								7'b0000000:op.ALU.cal=SLL_;
								default:begin op.ALU.cal=NCAL;stop=1'b1;eb=1'b0;end
							endcase end
						3'b101:begin unique case(code.fun7)
								7'b0000000:op.ALU.cal=SRL_;
								7'b0100000:op.ALU.cal=SRA_;
								default:begin op.ALU.cal=NCAL;stop=1'b1;eb=1'b0;end
							endcase end
						default:op.ALU.cal=ALUopCal_t'(code.fun3);
					endcase end
				OP_R__	:begin unique case(code.fun7)
						7'b0000000:op.ALU.cal=ALUopCal_t'(code.fun3);
						7'b0100000:begin unique case(code.fun3)
								3'b000:op.ALU.cal=SUB_;
								3'b101:op.ALU.cal=SRA_;
								default:begin op.ALU.cal=NCAL;stop=1'b1;eb=1'b0;end
							endcase end
						default:begin op.ALU.cal=NCAL;stop=1'b1;eb=1'b0;end
					endcase end
				default	:op.ALU.cal=NCAL;
			endcase
			if(code.op==OP_B__)begin//b系列
				op.ALU.bfu=ALUopBfu_t'(code.fun3);
			end else op.ALU.bfu=NBFU;
			// if(code.op==OP_CSR)begin unique case(code.fun3)
			// 		3'b001	:op.ALU.csr=WACSR;
			// 		3'b010	:op.ALU.csr=(code.r1=='0)?NACSR:RACSR;
			// 		default	:op.ALU.csr=NACSR;
			// endcase end else op.ALU.csr=NACSR;
			unique case(code.op)//选ALU cho addr
				OP_U_I	:{op.ALU.cho,op.ALU.adr}={IMM_,NAD};
				OP_U_P	:{op.ALU.cho,op.ALU.adr}={CAL_,NAD};
				OP_J__	:{op.ALU.cho,op.ALU.adr}={SNPC,PCI};
				OP_I_J	:{op.ALU.cho,op.ALU.adr}={SNPC,R1I};
				OP_I_L	:{op.ALU.cho,op.ALU.adr}={DATA,R1I};
				OP_I_A	:{op.ALU.cho,op.ALU.adr}={CAL_,NAD};
				OP_R__	:{op.ALU.cho,op.ALU.adr}={CAL_,NAD};
				OP_CSR	:{op.ALU.cho,op.ALU.adr}={CCSR,ECJ};
				default	:{op.ALU.cho,op.ALU.adr}={NCHO,NAD};
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
						OP_SCR_MRET__	:begin op.CSR.op=MRET_;op.CSR.addr=CSR_ADDR_MEPC;end
						OP_SCR_ECALL_	:begin op.CSR.op=ECALL;op.CSR.addr=CSR_ADDR_MTVEC;end
						OP_SCR_EBREAK	:begin op.CSR.op=NCSR_;op.CSR.addr='0;stop=1'b1;eb=1'b1;end
						default			:begin op.CSR.op=NCSR_;op.CSR.addr='0;stop=1'b1;eb=1'b0;end
					endcase end
				3'b001	:begin op.CSR.addr={code[31:20]};	op.CSR.op=WCCSR;op.ALU.csr=WACSR;end
				3'b010	:begin op.CSR.addr={code[31:20]};	op.CSR.op=(code.r1=='0)?NCSR_:WCCSR;op.ALU.csr=(code.r1=='0)?NACSR:RACSR;end
				default	:begin op.CSR.addr='0;				op.CSR.op=NCSR_;op.ALU.csr=NACSR;end
			endcase end else begin op.CSR.addr='0;op.CSR.op=NCSR_;op.ALU.csr=NACSR;end

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


			// unique case(code.op)//旧的冗余
			// 	OP_U_I:begin op.ALU.cho=IMM_; end//lui
			// 	OP_U_P:begin op.ALU.cho=CAL_; end//auipc
			// 	OP_J__:begin op.ALU.cho=SNPC;op.ALU.adr=PCI; op.ALU.enJcod=1; end//jal
			// 	OP_I_J:begin op.ALU.cho=SNPC;op.ALU.adr=R1I; op.ALU.enJcod=1; end//jalr
			// 	OP_B__:begin op.ALU.adr=PCI; op.ALU.bfu=ALUopBfu_t'(code.fun3); end//B系列判断指令
			// 	OP_I_L:begin op.ALU.cho=DATA;op.ALU.adr=R1I; op.LSU.op=LSUop_t'(code.fun3); end//l读取系列
			// 	OP_S__:begin op.ALU.adr=R1I; op.LSU.op=LSUop_t'(code.fun3); end//s写入系列
			// 	OP_I_A:begin op.ALU.cho=CAL_;end //立即数计算
			// 	OP_R__:begin op.ALU.cho=CAL_;end //寄存器计算
			// 	OP_CSR:begin//CSR指令
			// 		op.ALU.enJcod=(code.fun3==3'b000);
			// 		unique case(code.fun3)
			// 			3'b000:begin op.ALU.adr=ECJ;end
			// 			3'b001:begin op.CSR.addr={code[31:20]};op.CSR.op=WCCSR;op.ALU.csr=WACSR; end
			// 			3'b010:begin op.CSR.addr={code[31:20]};op.ALU.cho=CCSR;
			// 				op.ALU.csr=(code.r1=='0)?NACSR:RACSR;
			// 				op.CSR.op =(code.r1=='0)?NCSR_:WCCSR;
			// 				end
			// 			default:begin stop=1'b1;eb=1'b0;end
			// 		endcase
			// 	end
			// 	default:begin stop=1'b1;eb=1'b0;end
			// endcase
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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

	parameter OP_CSR	= 7'b1110011;//CSR系列
	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;
	

	parameter MSTATUS_RESET = 32'h1800;

	// parameter OP_FUN7_M		= 7'b0000001;

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
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NCCSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[3:0] {NCHO,CAL_,DATA,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[1:0] {IR1,PC_} in1_t;
	typedef enum logic[1:0] {IR2,IMM} in2_t;
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

	typedef enum logic[2:0] {N,I,U,S,B,J} imCode_t;
	input word_t oR1,oR2,pc,data;
/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
/* verilator lint_on UNUSEDSIGNAL */

	input word_t oCsr;
	output word_t addr,iRd,iCsr;
	output logic enJfun;
	logic enBfun;

	word_t result,in1,in2;

	// ysyx_26020046_MuxKeyWithDefault #(2,1,DATA_WIDTH) Muxin1 (.out(in1),.key(op.ALU.in1),.default_out('0),.lut({
	// 	{IR1,oR1},
	// 	{PC_,pc}
	// }));
	// ysyx_26020046_MuxKeyWithDefault #(2,1,DATA_WIDTH) Muxin2 (.out(in2),.key(op.ALU.in2),.default_out('0),.lut({
	// 	{IR2,oR2},
	// 	{IMM,op.ALU.im}
	// }));
	// ysyx_26020046_MuxKeyWithDefault #(10,4,DATA_WIDTH) MuxCal (.out(result),.key(op.ALU.cal),.default_out('0),.lut({
	// 	{ADD_,in1+in2},
	// 	{SLL_,in1<<in2[4:0]},
	// 	{SLT_,  $signed(in1) <  $signed(in2)?32'b1:32'b0},
	// 	{SLTU,$unsigned(in1) <$unsigned(in2)?32'b1:32'b0},
	// 	{XOR_,in1^in2},
	// 	{SRL_,$unsigned(in1)>> in2[4:0]},
	// 	{OR__,in1|in2},
	// 	{AND_,in1&in2},
	// 	{SUB_,in1-in2},
	// 	{SRA_,  $signed(in1)>>>in2[4:0]}
	// }));
	// ysyx_26020046_MuxKeyWithDefault #(6,3,1) MuxBfun(.out(enBfun),.key(op.ALU.bfu),.default_out('0),.lut({
	// 	{BEQ_,(oR1==oR2)},
	// 	{BNE_,(oR1!=oR2)},
	// 	{BLT_,(  $signed(oR1) <  $signed(oR2))},
	// 	{BGE_,(  $signed(oR1)>=  $signed(oR2))},
	// 	{BLTU,($unsigned(oR1) <$unsigned(oR2))},
	// 	{BGEU,($unsigned(oR1)>=$unsigned(oR2))}
	// }));
	// ysyx_26020046_MuxKeyWithDefault #(4,3,DATA_WIDTH) MuxAdr(.out(addr),.key(op.ALU.adr),.default_out('0),.lut({
	//     {R1I,oR1+op.ALU.im},
	//     {PCI,pc+op.ALU.im},
	//     {ECJ,oCsr},
	//     {ERE,oCsr+4}
	// }));
	// assign enJfun=op.ALU.enJcod|enBfun;
	// ysyx_26020046_MuxKeyWithDefault #(5,3,DATA_WIDTH) MuxCho(.out(iRd),.key(op.ALU.cho),.default_out('0),.lut({
	// 	{CAL_,result},
	// 	{IMM_,op.ALU.im},
	// 	{DATA,data},
	// 	{CCSR,oCsr},
	// 	{SNPC,pc+4}
	// }));
	// ysyx_26020046_MuxKeyWithDefault #(3,2,DATA_WIDTH) MuxCsr(.out(iCsr),.key(op.ALU.csr),.default_out('0),.lut({
	// 	{WACSR,oR1},
	// 	{RACSR,oR1|oCsr},
	// 	{JUMP_,pc}
	// }));
	
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
module ysyx_26020046_rv32iLSU(clk,reset,addr,oR2,enJfun,op,data,pc,mask,pmem_read);
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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

	parameter OP_CSR	= 7'b1110011;//CSR系列
	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;
	

	parameter MSTATUS_RESET = 32'h1800;

	// parameter OP_FUN7_M		= 7'b0000001;

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
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NCCSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[3:0] {NCHO,CAL_,DATA,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[1:0] {IR1,PC_} in1_t;
	typedef enum logic[1:0] {IR2,IMM} in2_t;
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

	typedef enum logic[2:0] {N,I,U,S,B,J} imCode_t;
	input word_t addr,oR2,pmem_read;
	input logic clk,reset,enJfun;

/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
/* verilator lint_on UNUSEDSIGNAL */


	output word_t data,pc;
	// output logic LSUsuccess;

	output logic[3:0] mask;
	word_t iRAM;
//s处理
	
	// always_comb begin : choose_mask
	// 	if (op.LSU.enS) begin unique case(op.LSU.op)
	// 		B_:mask=4'b0001;
	// 		H_:mask=4'b0011;
	// 		W_:mask=4'b1111;
	// 		NM:mask=4'b0000;
	// 		default:begin mask=4'b0000;end
	// 	endcase end else mask=4'b0000;
	// end
	ysyx_26020046_MuxKeyWithDefault #(3,3,4) Muxmask(.out(mask),.key(op.LSU.op),.default_out('0),.lut({
	{B_,4'b0001},
	{H_,4'b0011},
	{W_,4'b1111}
	}));

//l处理
	
	// always_comb begin : choose_date_input
	// 	if(op.LSU.enL) begin unique case(op.LSU.op)
	// 		B_:data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
	// 		H_:data={{16{iRAM[15]}},iRAM[15: 0]};
	// 		W_:data=iRAM;
	// 		BU:data={{24{1'b0}},iRAM[ 7: 0]};
	// 		HU:data={{16{1'b0}},iRAM[15: 0]};
	// 		default:begin data=0;end
	// 	endcase end else data='0;
	// end
	ysyx_26020046_MuxKeyWithDefault #(5,3,DATA_WIDTH) Muxdata(.out(data),.key(op.LSU.op),.default_out('0),.lut({
		{B_,{24{iRAM[ 7]}},iRAM[ 7: 0]},
		{H_,{16{iRAM[15]}},iRAM[15: 0]},
		{W_,iRAM},
		{BU,{24{1'b0}},iRAM[ 7: 0]},
		{HU,{16{1'b0}},iRAM[15: 0]}
	}));

	always_ff @(posedge clk) begin : pc_write
		if(reset) pc<=PC_RESET;
		else if(enJfun) pc<=addr;
		else pc<=pc+4;
	end

	// import "DPI-C" function int pmem_read(input int addr);
	// import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);
	assign iRAM = (op.LSU.enL)&clk?pmem_read:0;
	// always_ff@(posedge clk) begin:control_write
	// 	if (op.LSU.enS) begin // 有写请求时
	// 		pmem_write(addr, oR2, {4'b0,mask});
	// 	end
	// end

endmodule
module ysyx_26020046_rv32iGPR(pc,iRd,clk,reset,cRd,cR1,cR2,oR1,oR2);
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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

	parameter OP_CSR	= 7'b1110011;//CSR系列
	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;
	

	parameter MSTATUS_RESET = 32'h1800;

	// parameter OP_FUN7_M		= 7'b0000001;

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
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NCCSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[3:0] {NCHO,CAL_,DATA,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[1:0] {IR1,PC_} in1_t;
	typedef enum logic[1:0] {IR2,IMM} in2_t;
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

	typedef enum logic[2:0] {N,I,U,S,B,J} imCode_t;
	input word_t pc,iRd;
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

	assign oR1=(cR1==0)?'0:gpr[cR1];
	assign oR2=(cR2==0)?'0:gpr[cR2];

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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

	parameter OP_CSR	= 7'b1110011;//CSR系列
	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;
	

	parameter MSTATUS_RESET = 32'h1800;

	// parameter OP_FUN7_M		= 7'b0000001;

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
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NCCSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[3:0] {NCHO,CAL_,DATA,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[1:0] {IR1,PC_} in1_t;
	typedef enum logic[1:0] {IR2,IMM} in2_t;
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

	typedef enum logic[2:0] {N,I,U,S,B,J} imCode_t;

/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
/* verilator lint_on UNUSEDSIGNAL */

	// input word_t pc;
	// input opCsrr_t opCsrr;opCsrr,pc,
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
			// $display("reset");
		end else begin
			unique case(op.CSR.op)
				ECALL:begin mepc<=iCsr;mcause<=11;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;end
				WCCSR:begin unique case(op.CSR.addr)
					CSR_ADDR_MEPC		:mepc	<=iCsr;
					CSR_ADDR_MSTAUS		:mstatus<=iCsr;
					CSR_ADDR_MTVEC		:mtvec	<=iCsr;
					CSR_ADDR_MCAUSE		:mcause	<=iCsr;
					CSR_ADDR_MCYCLE		:mcycle	<=iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh<=iCsr;
					CSR_ADDR_MARCHID	:marchid<=iCsr;
					CSR_ADDR_MVENDORID	:mvendorid<=iCsr;
					default:;
					endcase end
				NCSR_:;
				default:;
				endcase
			end
		end


	ysyx_26020046_MuxKeyWithDefault #(8,12,DATA_WIDTH) MuxOcsr(.out(oCsr),.key(op.CSR.addr),.default_out('0),.lut({
		{CSR_ADDR_MEPC		,mepc},
		{CSR_ADDR_MSTAUS	,mstatus},
		{CSR_ADDR_MTVEC		,mtvec},
		{CSR_ADDR_MCAUSE	,mcause},
		{CSR_ADDR_MCYCLE	,mcycle},
		{CSR_ADDR_MCYCLEH	,mcycleh},
		{CSR_ADDR_MARCHID	,marchid},
		{CSR_ADDR_MVENDORID	,mvendorid}
	}));
	// always_comb begin:choose_csr
	// 	unique case(op.CSR.addr)
	// 		CSR_ADDR_MEPC		:oCsr=mepc;
	// 		CSR_ADDR_MSTAUS		:oCsr=mstatus;
	// 		CSR_ADDR_MTVEC		:oCsr=mtvec;
	// 		CSR_ADDR_MCAUSE		:oCsr=mcause;
	// 		CSR_ADDR_MCYCLE		:oCsr=mcycle;
	// 		CSR_ADDR_MCYCLEH	:oCsr=mcycleh;
	// 		CSR_ADDR_MARCHID	:oCsr=marchid;
	// 		CSR_ADDR_MVENDORID	:oCsr=mvendorid;
	// 		default				:oCsr=0;
	// 	endcase
	// end
				
endmodule
