module ysyx_26020046_rv32iMixSta(clk,reset,code,pc,stop,eb,pmem_read,pmem_write,addr,mask,enW);
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

	parameter OP_CSR_ECALL_	= 32'h00000073;
	parameter OP_CSR_EBREAK	= 32'h00100073;
	parameter OP_CSR_MRET__	= 32'h30200073;

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

	typedef struct packed {
	    logic Lui,Auipc,Jal,Jalr;
	    logic Add, Sub, Sll, Slt, Sltu, Xor, Srl, Sra, Or, And;
	    logic Addi, Slti, Sltiu, Xori, Ori, Andi, Slli, Srli, Srai;
	    logic Beq, Bne, Blt, Bge, Bltu, Bgeu;
	    logic Lb, Lh, Lw, Lbu, Lhu;
	    logic Sb, Sh, Sw;
		logic Csrrw,Csrrs,Mret,Ecall,Ebreak;
	} instruct_t;

	typedef enum logic[2:0] {N,I,U,S,B,J} imCode_t;
	input code_t code;
	input logic reset;
	// output logic enJfun;
	// output word_t im;
	output reg_t cRd,cR1,cR2;
	output op_t op;
	output logic stop,eb;
	instruct_t ins;
	// imCode_t imm;
	// logic error;
	instruct_t ins;
	assign ins.Lui		=(code.op==OP_U_I);
	assign ins.Auipc	=(code.op==OP_U_P);
	assign ins.Jal		=(code.op==OP_J__);
	assign ins.Jalr		=(code.op==OP_I_J)&(code.fun3==3'b000);
	assign ins.Beq		=(code.op==OP_B__)&(code.fun3==3'b000);
	assign ins.Bne		=(code.op==OP_B__)&(code.fun3==3'b001);
	assign ins.Blt		=(code.op==OP_B__)&(code.fun3==3'b100);
	assign ins.Bge		=(code.op==OP_B__)&(code.fun3==3'b101);
	assign ins.Bltu		=(code.op==OP_B__)&(code.fun3==3'b110);
	assign ins.Bgeu		=(code.op==OP_B__)&(code.fun3==3'b111);
	assign ins.Lb		=(code.op==OP_I_L)&(code.fun3==3'b000);
	assign ins.Lh		=(code.op==OP_I_L)&(code.fun3==3'b001);
	assign ins.Lw		=(code.op==OP_I_L)&(code.fun3==3'b010);
	assign ins.Lbu		=(code.op==OP_I_L)&(code.fun3==3'b100);
	assign ins.Lhu		=(code.op==OP_I_L)&(code.fun3==3'b101);
	assign ins.Sb		=(code.op==OP_S__)&(code.fun3==3'b000);
	assign ins.Sh		=(code.op==OP_S__)&(code.fun3==3'b001);
	assign ins.Sw		=(code.op==OP_S__)&(code.fun3==3'b010);
	assign ins.Addi		=(code.op==OP_I_A)&(code.fun3==3'b000);
	assign ins.Slti		=(code.op==OP_I_A)&(code.fun3==3'b010);
	assign ins.Sltiu	=(code.op==OP_I_A)&(code.fun3==3'b011);
	assign ins.Xori		=(code.op==OP_I_A)&(code.fun3==3'b100);
	assign ins.Ori		=(code.op==OP_I_A)&(code.fun3==3'b110);
	assign ins.Andi		=(code.op==OP_I_A)&(code.fun3==3'b111);
	assign ins.Slli		=(code.op==OP_I_A)&(code.fun3==3'b001)&(code.fun7==7'b0000000);
	assign ins.Srli		=(code.op==OP_I_A)&(code.fun3==3'b101)&(code.fun7==7'b0000000);
	assign ins.Srai		=(code.op==OP_I_A)&(code.fun3==3'b101)&(code.fun7==7'b0100000);
	assign ins.Add		=(code.op==OP_R__)&(code.fun3==3'b000)&(code.fun7==7'b0000000);
	assign ins.Sub		=(code.op==OP_R__)&(code.fun3==3'b000)&(code.fun7==7'b0100000);
	assign ins.Sll		=(code.op==OP_R__)&(code.fun3==3'b001)&(code.fun7==7'b0000000);
	assign ins.Slt		=(code.op==OP_R__)&(code.fun3==3'b010)&(code.fun7==7'b0000000);
	assign ins.Sltu		=(code.op==OP_R__)&(code.fun3==3'b011)&(code.fun7==7'b0000000);
	assign ins.Xor		=(code.op==OP_R__)&(code.fun3==3'b100)&(code.fun7==7'b0000000);
	assign ins.Srl		=(code.op==OP_R__)&(code.fun3==3'b101)&(code.fun7==7'b0000000);
	assign ins.Sra		=(code.op==OP_R__)&(code.fun3==3'b101)&(code.fun7==7'b0100000);
	assign ins.Or		=(code.op==OP_R__)&(code.fun3==3'b110)&(code.fun7==7'b0000000);
	assign ins.And		=(code.op==OP_R__)&(code.fun3==3'b111)&(code.fun7==7'b0000000);
	assign ins.Ecall	=(code==OP_CSR_ECALL_);
	assign ins.Ebreak	=(code==OP_CSR_EBREAK);
	assign ins.Mret		=(code==OP_CSR_MRET__);
	assign ins.Csrrw	=(code.op==OP_CSR)&(code.fun3==3'b001);
	assign ins.Csrrs	=(code.op==OP_CSR)&(code.fun3==3'b010);
	always_comb begin : ID
		op.ALU.in1=IR1;op.ALU.in2=IR2;
		op.ALU.adr=NAD;op.ALU.cal=NCAL;op.ALU.bfu=NBFU;
		op.ALU.csr=NACSR;op.ALU.cho=NCHO;
		op.LSU.op=NM;op.LSU.enS=0;op.LSU.enL=0;
		op.CSR.op=NCSR_;op.CSR.addr='0;
		{cR1,cR2,cRd,op.ALU.enJcod,stop,eb,op.ALU.im}='0;
		if(~reset) begin
			unique case(1'b1)
				ins.Lui		:begin op.ALU.cho=IMM_;cRd=code.rd;op.ALU.im={code[31:12],12'b0 };end
				ins.Auipc	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.cal=ADD_;op.ALU.in1=PC_;op.ALU.in2=IMM;op.ALU.im={code[31:12],12'b0 }; end
				ins.Jal		:begin op.ALU.cho=SNPC;cRd=code.rd;op.ALU.adr=PCI;op.ALU.im={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };op.ALU.enJcod=1; end
				ins.Jalr	:begin op.ALU.cho=SNPC;cRd=code.rd;op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:20] }; op.ALU.enJcod=1;cR1=code.r1; end
				ins.Beq		:begin op.ALU.adr=PCI;op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 }; op.ALU.bfu=BEQ_;cR1=code.r1;cR2=code.r2; end
				ins.Bne		:begin op.ALU.adr=PCI;op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 }; op.ALU.bfu=BNE_;cR1=code.r1;cR2=code.r2; end
				ins.Blt		:begin op.ALU.adr=PCI;op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 }; op.ALU.bfu=BLT_;cR1=code.r1;cR2=code.r2; end
				ins.Bge		:begin op.ALU.adr=PCI;op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 }; op.ALU.bfu=BGE_;cR1=code.r1;cR2=code.r2; end
				ins.Bltu	:begin op.ALU.adr=PCI;op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 }; op.ALU.bfu=BLTU;cR1=code.r1;cR2=code.r2; end
				ins.Bgeu	:begin op.ALU.adr=PCI;op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 }; op.ALU.bfu=BGEU;cR1=code.r1;cR2=code.r2; end
				ins.Lb		:begin op.ALU.cho=DATA;cRd=code.rd;op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:20] };cR1=code.r1; op.LSU.enL=1;op.LSU.op=B_; end
				ins.Lh		:begin op.ALU.cho=DATA;cRd=code.rd;op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:20] };cR1=code.r1; op.LSU.enL=1;op.LSU.op=H_; end
				ins.Lw		:begin op.ALU.cho=DATA;cRd=code.rd;op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:20] };cR1=code.r1; op.LSU.enL=1;op.LSU.op=W_; end
				ins.Lbu		:begin op.ALU.cho=DATA;cRd=code.rd;op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:20] };cR1=code.r1; op.LSU.enL=1;op.LSU.op=BU; end
				ins.Lhu		:begin op.ALU.cho=DATA;cRd=code.rd;op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:20] };cR1=code.r1; op.LSU.enL=1;op.LSU.op=HU; end
				ins.Sb		:begin op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:25], code[11:7] };cR1=code.r1;cR2=code.r2; op.LSU.enS=1;op.LSU.op=B_; end
				ins.Sh		:begin op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:25], code[11:7] };cR1=code.r1;cR2=code.r2; op.LSU.enS=1;op.LSU.op=H_; end
				ins.Sw		:begin op.ALU.adr=R1I;op.ALU.im={{20{code[31]}},code[31:25], code[11:7] };cR1=code.r1;cR2=code.r2; op.LSU.enS=1;op.LSU.op=W_; end
				ins.Addi	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=ADD_; end
				ins.Slti	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=SLT_; end
				ins.Sltiu	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=SLTU; end
				ins.Xori	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=XOR_; end
				ins.Ori		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=OR__; end
				ins.Andi	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=AND_; end
				ins.Slli	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=SLL_; end
				ins.Srli	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=SRL_; end
				ins.Srai	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.im={{20{code[31]}},code[31:20] };op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1;op.ALU.cal=SRA_; end
				ins.Add		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=ADD_; end
				ins.Sub		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=SUB_; end
				ins.Sll		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=SLL_; end
				ins.Slt		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=SLT_; end
				ins.Sltu	:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=SLTU; end
				ins.Xor		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=XOR_; end
				ins.Srl		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=SRL_; end
				ins.Sra		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=SRA_; end
				ins.Or		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=OR__; end
				ins.And		:begin op.ALU.cho=CAL_;cRd=code.rd;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;op.ALU.cal=AND_; end
				ins.Ecall	:begin op.CSR.op=ECALL;op.ALU.adr=ECJ;op.ALU.enJcod=1;op.CSR.addr=CSR_ADDR_MTVEC;	end
				ins.Ebreak	:begin stop=1'b1;eb=1'b1; end
				ins.Mret	:begin op.CSR.op=MRET_;op.ALU.adr=ECJ;op.ALU.enJcod=1;op.CSR.addr=CSR_ADDR_MEPC;	end
				ins.Csrrw	:begin op.ALU.cho=CCSR;cRd=code.rd;op.CSR.addr={code[31:20]};cR1=code.r1;op.CSR.op=WCCSR;op.ALU.csr=WACSR; end
				ins.Csrrs	:begin op.ALU.cho=CCSR;cRd=code.rd;op.CSR.addr={code[31:20]};cR1=code.r1;op.ALU.csr=(code.r1=='0)?NACSR:RACSR;op.CSR.op =(code.r1=='0)?NCSR_:WCCSR;end
				default		:begin stop=1'b1;eb=1'b0; end
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
	always_comb begin : choose_mask
		if (op.LSU.enS) begin unique case(op.LSU.op)
			B_:mask=4'b0001;
			H_:mask=4'b0011;
			W_:mask=4'b1111;
			NM:mask=4'b0000;
			default:begin mask=4'b0000;end
		endcase end else mask=4'b0000;
	end

//l处理

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
