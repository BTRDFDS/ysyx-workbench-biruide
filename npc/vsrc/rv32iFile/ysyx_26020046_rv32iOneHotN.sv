package rv32iBasis;
// `define RV32I_DEBUG
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

	parameter OP_ECALL	= 32'h00000073;
	parameter OP_EBREAK	= 32'h00100073;
	parameter OP_MRET	= 32'h30200073;

	parameter OP_SCR	= 7'b1110011;//CSR系列
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

	typedef struct packed {
	    logic Add, Sub, Sll, Slt, Sltu, Xor, Srl, Sra, Or, And;
	} opRcod_t;
	typedef struct packed {
	    logic Addi, Slti, Sltiu, Xori, Ori, Andi, Slli, Srli, Srai;
	} opIcod_t;
	typedef struct packed {
	    logic Lui,Auipc,Jal,Jalr,Bfun,Mfun;
	} opCode_t;

	typedef struct packed {
	    logic Beq, Bne, Blt, Bge, Bltu, Bgeu;
	} opBfun_t;
	typedef struct packed {
	    logic Lb, Lh, Lw, Lbu, Lhu;
	} opLfun_t;
	typedef struct packed {
	    logic Sb, Sh, Sw;
	} opSfun_t;
	typedef struct packed {
		word_t immI,immU,immS,immB,immJ;
	}opImmr_t;
	typedef struct packed {
	    logic opI,opU,opS,opB,opJ,opR;
	} opIner_t;
	typedef struct packed {
		logic Csrrw,Csrrs,Mret,Ecall,Ebreak;
	} opCsrr_t;
	typedef struct packed {
		opIcod_t Icod;
		opRcod_t Rcod;
		opCode_t Code;
		opBfun_t Bfun;
		opLfun_t Lfun;
		opSfun_t Sfun;
		opCsrr_t Csrr;
		opIner_t Iner;
	} op_t;

endpackage

module ysyx_26020046_rv32iOneHotN(clk,reset,code,pc);
	import rv32iBasis::*;
	input logic clk,reset;
	// input word_t code;
	input code_t code;
	output word_t pc;

	word_t oR1,oR2,imm,data,addr,iRd,iCsr,oCsr;
	reg_t cRd,cR1,cR2;
	logic enBfun,enJfun,enCsr,enMret,enEcall;
	// opCode_t opCode;
	// opIcod_t opIcod;
	// opRcod_t opRcod;
	// opBfun_t opBfun;
	// opLfun_t opLfun;
	// opSfun_t opSfun;
	// opCsrr_t opCsrr;
	op_t op;
	logic [11:0] csrAddr;

	ysyx_26020046_rv32iIDC IDC(.*);
	ysyx_26020046_rv32iALU ALU(.*);
	ysyx_26020046_rv32iLSU LSU(.*);
	ysyx_26020046_rv32iGPR GPR(.*);
	ysyx_26020046_rv32iCSR CSR(.*);

`ifdef RV32I_DEBUG
	always @(posedge clk) begin
		$display("pc=0x%x code=0x%x reset=%x op=%x fun7=%x",pc,code,reset,code.op,code.fun7);
		$display("oR1=0x%x oR2=0x%x imm=0x%x data=0x%x addr=0x%x iRd=0x%x",oR1,oR2,imm,data,addr,iRd);
		$display("cRd=0x%x cR1=0x%x cR2=0x%x",cRd,cR1,cR2);
		$display("enBfun=%x enJfun=%x",enBfun,enJfun);
		$display("opCode=%d opIcod=%d opRcod=%d opBfun=%d opLfun=%d opSfun=%d onIner=%d",op.Code,op.Icod,op.Rcod,op.Bfun,op.Lfun,op.Sfun,op.Iner);
	end
`endif



endmodule

module ysyx_26020046_rv32iIDC(clk,code,reset,enJfun,enMret,enEcall,imm,cRd,cR1,cR2,op,enCsr,csrAddr);
	import rv32iBasis::*;
	// input word_t code;
	input code_t code;
	input logic clk,reset;
	output logic enJfun,enMret,enEcall,enCsr;
	output word_t imm;
	output reg_t cRd,cR1,cR2;
	// output opIcod_t opIcod;
	// output opRcod_t opRcod;
	// output opCode_t opCode;
	// output opBfun_t opBfun;
	// output opLfun_t opLfun;
	// output opSfun_t opSfun;
	// output opCsrr_t opCsrr;
	output op_t op;
	output logic [11:0] csrAddr;
	opImmr_t opImmr;
	// opIner_t opIner;
	// logic [6:0] op;
	// logic [2:0] fun3;
	// logic [6:0] fun7;
	// reg_t r1,r2,rd;

	// assign fun7	=code[31:25];
	// assign r2	=code[24:20];
	// assign r1	=code[19:15];
	// assign fun3	=code[14:12];
	// assign rd	=code[11: 7];
	// assign op	=code[ 6: 0];

	assign op.Code.Lui	=(code.op==OP_U_I);
	assign op.Code.Auipc=(code.op==OP_U_P);
	assign op.Code.Jal	=(code.op==OP_J__);
	assign op.Code.Jalr	=(code.op==OP_I_J)&(code.fun3==3'b000);
	assign op.Bfun.Beq	=(code.op==OP_B__)&(code.fun3==3'b000);
	assign op.Bfun.Bne	=(code.op==OP_B__)&(code.fun3==3'b001);
	assign op.Bfun.Blt	=(code.op==OP_B__)&(code.fun3==3'b100);
	assign op.Bfun.Bge	=(code.op==OP_B__)&(code.fun3==3'b101);
	assign op.Bfun.Bltu	=(code.op==OP_B__)&(code.fun3==3'b110);
	assign op.Bfun.Bgeu	=(code.op==OP_B__)&(code.fun3==3'b111);
	assign op.Lfun.Lb	=(code.op==OP_I_L)&(code.fun3==3'b000);
	assign op.Lfun.Lh	=(code.op==OP_I_L)&(code.fun3==3'b001);
	assign op.Lfun.Lw	=(code.op==OP_I_L)&(code.fun3==3'b010);
	assign op.Lfun.Lbu	=(code.op==OP_I_L)&(code.fun3==3'b100);
	assign op.Lfun.Lhu	=(code.op==OP_I_L)&(code.fun3==3'b101);
	assign op.Sfun.Sb	=(code.op==OP_S__)&(code.fun3==3'b000);
	assign op.Sfun.Sh	=(code.op==OP_S__)&(code.fun3==3'b001);
	assign op.Sfun.Sw	=(code.op==OP_S__)&(code.fun3==3'b010);
	assign op.Icod.Addi	=(code.op==OP_I_A)&(code.fun3==3'b000);
	assign op.Icod.Slti	=(code.op==OP_I_A)&(code.fun3==3'b010);
	assign op.Icod.Sltiu=(code.op==OP_I_A)&(code.fun3==3'b011);
	assign op.Icod.Xori	=(code.op==OP_I_A)&(code.fun3==3'b100);
	assign op.Icod.Ori	=(code.op==OP_I_A)&(code.fun3==3'b110);
	assign op.Icod.Andi	=(code.op==OP_I_A)&(code.fun3==3'b111);
	assign op.Icod.Slli	=(code.op==OP_I_A)&(code.fun3==3'b001)&(code.fun7==7'b0000000);
	assign op.Icod.Srli	=(code.op==OP_I_A)&(code.fun3==3'b101)&(code.fun7==7'b0000000);
	assign op.Icod.Srai	=(code.op==OP_I_A)&(code.fun3==3'b101)&(code.fun7==7'b0100000);
	assign op.Rcod.Add	=(code.op==OP_R__)&(code.fun3==3'b000)&(code.fun7==7'b0000000);
	assign op.Rcod.Sub	=(code.op==OP_R__)&(code.fun3==3'b000)&(code.fun7==7'b0100000);
	assign op.Rcod.Sll	=(code.op==OP_R__)&(code.fun3==3'b001)&(code.fun7==7'b0000000);
	assign op.Rcod.Slt	=(code.op==OP_R__)&(code.fun3==3'b010)&(code.fun7==7'b0000000);
	assign op.Rcod.Sltu	=(code.op==OP_R__)&(code.fun3==3'b011)&(code.fun7==7'b0000000);
	assign op.Rcod.Xor	=(code.op==OP_R__)&(code.fun3==3'b100)&(code.fun7==7'b0000000);
	assign op.Rcod.Srl	=(code.op==OP_R__)&(code.fun3==3'b101)&(code.fun7==7'b0000000);
	assign op.Rcod.Sra	=(code.op==OP_R__)&(code.fun3==3'b101)&(code.fun7==7'b0100000);
	assign op.Rcod.Or	=(code.op==OP_R__)&(code.fun3==3'b110)&(code.fun7==7'b0000000);
	assign op.Rcod.And	=(code.op==OP_R__)&(code.fun3==3'b111)&(code.fun7==7'b0000000);
	
	assign op.Csrr.Ecall	=(code==OP_ECALL);
	assign op.Csrr.Ebreak	=(code==OP_EBREAK);
	assign op.Csrr.Mret		=(code==OP_MRET);
	assign op.Csrr.Csrrw	=(code.op==OP_SCR)&(code.fun3==3'b001);
	assign op.Csrr.Csrrs	=(code.op==OP_SCR)&(code.fun3==3'b010);

	assign op.Code.Bfun	=(|op.Bfun);
	assign op.Code.Mfun	=(|op.Sfun)|(|op.Lfun);
	
	assign opImmr.immI	={{20{code[31]}},code[31:20] };
	assign opImmr.immS	={{20{code[31]}},code[31:25], code[11:7] };
	assign opImmr.immB	={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
	assign opImmr.immJ	={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
	assign opImmr.immU	={code[31:12],12'b0 };

	// assign csrAddr	=code[31:20];
	assign enMret	=op.Csrr.Mret;
	assign enEcall	=op.Csrr.Ecall;
	assign enCsr	=op.Csrr.Csrrs?(cR1!='0):(|op.Csrr);
	always_comb begin
		unique case('1)
			op.Csrr.Ecall:csrAddr=CSR_ADDR_MTVEC;
			op.Csrr.Mret	:csrAddr=CSR_ADDR_MEPC;
			op.Csrr.Csrrw:csrAddr=code[31:20];
			op.Csrr.Csrrs:csrAddr=code[31:20];
			default		:csrAddr=12'b0;
		endcase
	end


	assign op.Iner.opI	=(|op.Icod)|(|op.Lfun)|(op.Code.Jalr);
	assign op.Iner.opR	=(|op.Rcod);
	assign op.Iner.opS	=(|op.Sfun);
	assign op.Iner.opB	=(|op.Bfun);
	assign op.Iner.opJ	=(op.Code.Jal);
	assign op.Iner.opU	=(op.Code.Lui)|(op.Code.Auipc);

	always_comb begin : choose_imm
		unique case('1)
			op.Iner.opI:imm=opImmr.immI;
			op.Iner.opU:imm=opImmr.immU;
			op.Iner.opS:imm=opImmr.immS;
			op.Iner.opB:imm=opImmr.immB;
			op.Iner.opJ:imm=opImmr.immJ;
			default   :imm='0;
		endcase
	end

	assign enJfun=(op.Code.Jal)|(op.Code.Jalr);
	assign cR1=code.r1;
	assign cR2=code.r2;
	assign cRd=(op.Iner.opB|op.Iner.opS)?'0:code.rd;

	import "DPI-C" function void stop(input bit eb);
	// always_comb begin : check_ebreak_or_stop
	always_ff @(posedge clk) begin
		if(~reset)begin
			if(op.Csrr.Ebreak) stop(1);
			else if(~((|op.Iner)|(|op.Csrr))) stop(0);
		end
	end

endmodule
module ysyx_26020046_rv32iALU(oR1,oR2,pc,imm,data,addr,iRd,enBfun,op,oCsr,iCsr);
	import rv32iBasis::*;
	//
	input word_t oR1,oR2,pc,imm,data;
	// input opIcod_t opIcod;
	// input opRcod_t opRcod;
	// input opCode_t opCode;
	// input opBfun_t opBfun;
	// input opLfun_t opLfun;
	// input opCsrr_t opCsrr;

/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
/* verilator lint_on UNUSEDSIGNAL */

	input word_t oCsr;
	output word_t addr,iRd,iCsr;
	output logic enBfun;

	word_t result;
	logic choRes,choDat,choNpc,choImm,choCsr;
	assign choRes=(op.Iner.opR)|(|op.Icod)|(op.Code.Auipc);
	assign choDat=(|op.Lfun);
	assign choImm=( op.Code.Lui);
	assign choNpc=( op.Code.Jal)|(op.Code.Jalr);
	assign choCsr=(|op.Csrr);

	always_comb begin : calculate
		unique case('1)
			// op.Code.Lui		:result=imm;
			op.Code.Auipc	:result=imm+pc;
			// op.Code.Jal		:result=imm+pc;
			// op.Code.Jalr	:result=imm+oR1;
			// op.Code.Bfun	:result=imm+pc;
			// op.Code.Mfun	:result=imm+oR1;
			op.Icod.Addi	:result=imm+oR1;
			op.Icod.Slti	:result=  $signed(oR1) <  $signed(imm)?1:0;
			op.Icod.Sltiu	:result=$unsigned(oR1) <$unsigned(imm)?1:0;
			op.Icod.Xori	:result=oR1^imm;
			op.Icod.Ori		:result=oR1|imm;
			op.Icod.Andi	:result=oR1&imm;
			op.Icod.Slli	:result=oR1<<imm[4:0];
			op.Icod.Srli	:result=$unsigned(oR1)>> imm[4:0];
			op.Icod.Srai	:result=  $signed(oR1)>>>imm[4:0];
			op.Rcod.Add		:result=oR1+oR2;
			op.Rcod.Sub		:result=oR1-oR2;
			op.Rcod.Sll		:result=oR1<<oR2[4:0];
			op.Rcod.Slt		:result=  $signed(oR1) <  $signed(oR2)?1:0;
			op.Rcod.Sltu	:result=$unsigned(oR1) <$unsigned(oR2)?1:0;
			op.Rcod.Xor		:result=oR1^oR2;
			op.Rcod.Srl		:result=$unsigned(oR1)>> oR2[4:0];
			op.Rcod.Sra		:result=  $signed(oR1)>>>oR2[4:0];
			op.Rcod.Or		:result=oR1|oR2;
			op.Rcod.And		:result=oR1&oR2;
			// op.Csrr.Mret	:result=oCsr+4;
			// op.Csrr.Ecall	:result=oCsr;
			default			:result='0;
		endcase
	
	`ifdef RV32I_DEBUG
		$display("pc=%x oR1=%x oR2=%x imm=%x",pc,oR1,oR2,imm);
		$strobe("result=%x data=%x",result,data);
	`endif
	end

	always_comb begin : bFun
		unique case('1)
			op.Bfun.Beq	:enBfun=(oR1==oR2);
			op.Bfun.Bne	:enBfun=(oR1!=oR2);
			op.Bfun.Blt	:enBfun=(  $signed(oR1) <  $signed(oR2));
			op.Bfun.Bge	:enBfun=(  $signed(oR1)>=  $signed(oR2));
			op.Bfun.Bltu:enBfun=($unsigned(oR1) <$unsigned(oR2));
			op.Bfun.Bgeu:enBfun=($unsigned(oR1)>=$unsigned(oR2));
			default		:enBfun='0;
		endcase
	end

	// assign iCsr=(|opCsrr)?result:0;
	always_comb begin : choose_csr_input
		unique case('1)
			op.Csrr.Ecall	:iCsr=pc;
			op.Csrr.Mret	:iCsr=pc;
			op.Csrr.Csrrw	:iCsr=oR1;
			op.Csrr.Csrrs	:iCsr=oCsr|oR1;
			default			:iCsr='0;
		endcase
	end

	// assign addr=(op.Code.Jal|op.Code.Jalr|op.Code.Bfun|op.Code.Mfun|op.Csrr.Mret|op.Csrr.Ecall)?result:0;

	always_comb begin
		unique case('1)
			op.Code.Jal		:addr=imm+pc;
			op.Code.Jalr	:addr=imm+oR1;
			op.Code.Bfun	:addr=imm+pc;
			op.Code.Mfun	:addr=imm+oR1;
			op.Csrr.Mret	:addr=oCsr+4;
			op.Csrr.Ecall	:addr=oCsr;
			default			:addr='0;
		endcase
	end

	always_comb begin :choose
		unique case('1)
			choRes	:iRd=result;
			choDat	:iRd=data;
			choImm	:iRd=imm;
			choNpc	:iRd=pc+4;
			choCsr	:iRd=oCsr;
			default	:iRd='0;
		endcase

`ifdef RV32I_DEBUG
		$display("res %x dat %x imm %x npc %x csr %x",choRes,choDat,choImm,choNpc,choCsr);
`endif
	end

endmodule
module ysyx_26020046_rv32iLSU(clk,reset,addr,oR2,enBfun,enJfun,op,data,pc,enMret,enEcall);

	import rv32iBasis::*;
	input word_t addr,oR2;
	input logic clk,reset,enBfun,enJfun,enMret,enEcall;
	// input opLfun_t opLfun;
	// input opSfun_t opSfun;

/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
/* verilator lint_on UNUSEDSIGNAL */


	output word_t data,pc;
	// output logic LSUsuccess;

	logic[3:0] mask;
	word_t iRAM;
//s处理
	always_comb begin : choose_mask
		unique case('1)
			op.Sfun.Sb	:mask=4'b0001;
			op.Sfun.Sh	:mask=4'b0011;
			op.Sfun.Sw	:mask=4'b1111;
			default		:mask=4'b0000;
		endcase
	end

//l处理

	always_comb begin : choose_date_input
		unique case('1)
			op.Lfun.Lb	:data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			op.Lfun.Lh	:data={{16{iRAM[15]}},iRAM[15: 0]};
			op.Lfun.Lw	:data=iRAM;
			op.Lfun.Lbu	:data={{24{1'b0}},iRAM[ 7: 0]};
			op.Lfun.Lhu	:data={{16{1'b0}},iRAM[15: 0]};
			default		:data=0;
		endcase
	end

	always_ff @(posedge clk) begin : pc_write
`ifdef RV32I_DEBUG
		$display("pc=%x addr=%x enj=%x,enb=%x",pc,addr,enJfun,enBfun,enMret,enEcall);
`endif
		if(reset) pc<=PC_RESET;
		else if(enJfun|enBfun|enMret|enEcall) pc<=addr;
		else pc<=pc+4;
	end

	import "DPI-C" function int pmem_read(input int addr);
	import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);
	assign iRAM = (|op.Lfun)&clk?pmem_read(addr):0;
	always_ff@(posedge clk) begin:control_write
		if (|op.Sfun) begin // 有写请求时
			pmem_write(addr, oR2, {4'b0,mask});
		end
	end

endmodule
module ysyx_26020046_rv32iGPR(pc,iRd,clk,reset,cRd,cR1,cR2,oR1,oR2);
	import rv32iBasis::*;
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

`ifdef RV32I_DEBUG
	always@(clk)begin
		$display("[%d] <= %x",cRd,iRd);
		$display(" $0:x%8x ra:x%8x  sp:x%8x  gp:x%8x tp:x%8x t0:x%8x t1:x%8x t2:x%8x",      0,gpr[ 1],gpr[ 2],gpr[ 3],gpr[ 4],gpr[ 5],gpr[ 6],gpr[ 7]);
		$display(" s0:x%8x s1:x%8x  a0:x%8x  a1:x%8x a2:x%8x a3:x%8x a4:x%8x a5:x%8x",gpr[ 8],gpr[ 9],gpr[10],gpr[11],gpr[12],gpr[13],gpr[14],gpr[15]);
		$display(" a6:x%8x a7:x%8x  s2:x%8x  s3:x%8x s4:x%8x s5:x%8x s6:x%8x s7:x%8x",gpr[16],gpr[17],gpr[18],gpr[19],gpr[20],gpr[21],gpr[22],gpr[23]);
		$display(" s8:x%8x s9:x%8x s10:x%8x s11:x%8x t3:x%8x t4:x%8x t5:x%8x t6:x%8x",gpr[24],gpr[25],gpr[26],gpr[27],gpr[28],gpr[29],gpr[30],gpr[31]);
		if(clk) $strobe("up off\n");
		else $strobe("down off\n");
	end
`endif

	assign oR1=(cR1==0)?'0:gpr[cR1];
	assign oR2=(cR2==0)?'0:gpr[cR2];

	export "DPI-C" function getReg;
	function int getReg(input int addr);
		return (addr == 0) ? pc : gpr[addr];
	endfunction

endmodule

module ysyx_26020046_rv32iCSR(csrAddr,iCsr,oCsr,clk,reset,enCsr,enMret,enEcall);
	import rv32iBasis::*;
	input [11:0] csrAddr;
	// input word_t pc;
	// input opCsrr_t opCsrr;opCsrr,pc,
	input word_t iCsr;
	input logic clk,reset,enCsr,enMret,enEcall;
	output word_t oCsr;

	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

	always_ff@(posedge clk) begin:csr_write
		if(reset)begin
			mepc		<=PC_RESET;
			mstatus		<=MSTATUS_RESET;
			mcause		<='0;
			mcycle		<='0;
			mcycleh		<='0;
			marchid		<=32'h018D08CE;
			mvendorid	<=32'h79737978;
			// $display("reset");
		end else if(enEcall)begin
			// $display("ecall mepc(%x)=%x mtvec=%x",mepc,iCsr,mtvec);
			mepc	<=iCsr;
			mcause	<=11;
		end else if(enMret)begin
			// $display("mret mepc=%x",mepc);
			mstatus	<=MSTATUS_RESET;
			mcause	<='0;
		end else if(enCsr)begin
			// $display("write %x %x <= %x @%x %d",mcycleh,mcycle,iCsr,pc,opCsrr);
			// $strobe ("write %x %x <= %x @%x %d",mcycleh,mcycle,iCsr,pc,opCsrr);
			case(csrAddr)
				CSR_ADDR_MEPC		:mepc	<=iCsr;
				CSR_ADDR_MSTAUS		:mstatus<=iCsr;
				CSR_ADDR_MTVEC		:mtvec	<=iCsr;
				CSR_ADDR_MCAUSE		:mcause	<=iCsr;
				CSR_ADDR_MCYCLE		:mcycle	<=iCsr;
				CSR_ADDR_MCYCLEH	:mcycleh<=iCsr;
				CSR_ADDR_MARCHID	:marchid<=iCsr;
				CSR_ADDR_MVENDORID	:mvendorid<=iCsr;
				default:;
			endcase
		end else begin
			// {mcycleh,mcycle}<={mcycleh,mcycle}+1;
			// $display("%x %x <= %x @%x %x",mcycleh,mcycle,{mcycleh,mcycle}+1,pc,enCsr);
			// $strobe("%x %x <= %x @%x %x",mcycleh,mcycle,{mcycleh,mcycle}+1,pc,enCsr);
			mcycle<=mcycle+1;
			mcycleh<=mcycleh+&{mcycle};
		end
	end

	always_comb begin:choose_csr
		unique case(csrAddr)
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
