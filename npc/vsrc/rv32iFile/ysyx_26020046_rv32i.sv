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

	parameter OP_EBREAK	= 32'h00100073;

	parameter OP_SCR	= 7'b1110011;//错误处理系列
	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;

	// parameter OP_FUN7_M		= 7'b0000001;

	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;

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
		logic Ebreak;	
	} opIner_t;
	typedef struct packed {
		logic Csrrw,Csrrs;
	} opCsrr_t;

endpackage

module ysyx_26020046_rv32i(clk,reset,code,pc);
	import rv32iBasis::*;
	input logic clk,reset;
	input word_t code;
	output word_t pc;

	word_t oR1,oR2,imm,data,addr,iRd,iCsr,oCsr;
	reg_t cRd,cR1,cR2;
	logic enBfun,enJfun,enCsr;
	opCode_t opCode;
	opIcod_t opIcod;
	opRcod_t opRcod;
	opBfun_t opBfun;
	opLfun_t opLfun;
	opSfun_t opSfun;
	opCsrr_t opCsrr;
	logic [11:0] csrAddr;

	ysyx_260020046_rv32iIDC IDC(.*);
	ysyx_260020046_rv32iALU ALU(.*);
	ysyx_260020046_rv32iLSU LSU(.*);
	ysyx_260020046_rv32iGPR GPR(.*);
	ysyx_260020046_rv32iCSR CSR(.*);

`ifdef RV32I_DEBUG
	always @(posedge clk) begin
		$display("pc=0x%x code=0x%x reset=%x",pc,code,reset);
		$display("oR1=0x%x oR2=0x%x imm=0x%x data=0x%x addr=0x%x iRd=0x%x",oR1,oR2,imm,data,addr,iRd);
		$display("cRd=0x%x cR1=0x%x cR2=0x%x",cRd,cR1,cR2);
		$display("enBfun=%x enJfun=%x",enBfun,enJfun);
		$display("opCode=%d opIcod=%d opRcod=%d opBfun=%d opLfun=%d opSfun=%d",opCode,opIcod,opRcod,opBfun,opLfun,opSfun);
	end
`endif



endmodule

module ysyx_260020046_rv32iIDC(code,reset,enJfun,imm,cRd,cR1,cR2,opIcod,opRcod,opCode,opBfun,opLfun,opSfun,csrAddr,opCsrr);
	import rv32iBasis::*;
	input word_t code;
	input logic reset;
	output logic enJfun;
	output word_t imm;
	output reg_t cRd,cR1,cR2;
	output opIcod_t opIcod;
	output opRcod_t opRcod;
	output opCode_t opCode;
	output opBfun_t opBfun;
	output opLfun_t opLfun;
	output opSfun_t opSfun;
	output opCsrr_t opCsrr;
	output logic [11:0] csrAddr;
	opImmr_t opImmr;
	opIner_t opIner;
	logic [6:0] op;
	logic [2:0] fun3;
	logic [6:0] fun7;
	reg_t r1,r2,rd;

	assign fun7	=code[31:25];
	assign r2	=code[24:20];
	assign r1	=code[19:15];
	assign fun3	=code[14:12];
	assign rd	=code[11: 7];
	assign op	=code[ 6: 0];

	assign opCode.Lui	=(op==OP_U_I);
	assign opCode.Auipc	=(op==OP_U_P);
	assign opCode.Jal	=(op==OP_J__);
	assign opCode.Jalr	=(op==OP_I_J)&(fun3==3'b000);
	assign opBfun.Beq	=(op==OP_B__)&(fun3==3'b000);
	assign opBfun.Bne	=(op==OP_B__)&(fun3==3'b001);
	assign opBfun.Blt	=(op==OP_B__)&(fun3==3'b100);
	assign opBfun.Bge	=(op==OP_B__)&(fun3==3'b101);
	assign opBfun.Bltu	=(op==OP_B__)&(fun3==3'b110);
	assign opBfun.Bgeu	=(op==OP_B__)&(fun3==3'b111);
	assign opLfun.Lb	=(op==OP_I_L)&(fun3==3'b000);
	assign opLfun.Lh	=(op==OP_I_L)&(fun3==3'b001);
	assign opLfun.Lw	=(op==OP_I_L)&(fun3==3'b010);
	assign opLfun.Lbu	=(op==OP_I_L)&(fun3==3'b100);
	assign opLfun.Lhu	=(op==OP_I_L)&(fun3==3'b101);
	assign opSfun.Sb	=(op==OP_S__)&(fun3==3'b000);
	assign opSfun.Sh	=(op==OP_S__)&(fun3==3'b001);
	assign opSfun.Sw	=(op==OP_S__)&(fun3==3'b010);
	assign opIcod.Addi	=(op==OP_I_A)&(fun3==3'b000);
	assign opIcod.Slti	=(op==OP_I_A)&(fun3==3'b010);
	assign opIcod.Sltiu	=(op==OP_I_A)&(fun3==3'b011);
	assign opIcod.Xori	=(op==OP_I_A)&(fun3==3'b100);
	assign opIcod.Ori	=(op==OP_I_A)&(fun3==3'b110);
	assign opIcod.Andi	=(op==OP_I_A)&(fun3==3'b111);
	assign opIcod.Slli	=(op==OP_I_A)&(fun3==3'b001)&(fun7==7'b0000000);
	assign opIcod.Srli	=(op==OP_I_A)&(fun3==3'b101)&(fun7==7'b0000000);
	assign opIcod.Srai	=(op==OP_I_A)&(fun3==3'b101)&(fun7==7'b0100000);
	assign opRcod.Add	=(op==OP_R__)&(fun3==3'b000)&(fun7==7'b0000000);
	assign opRcod.Sub	=(op==OP_R__)&(fun3==3'b000)&(fun7==7'b0100000);
	assign opRcod.Sll	=(op==OP_R__)&(fun3==3'b001)&(fun7==7'b0000000);
	assign opRcod.Slt	=(op==OP_R__)&(fun3==3'b010)&(fun7==7'b0000000);
	assign opRcod.Sltu	=(op==OP_R__)&(fun3==3'b011)&(fun7==7'b0000000);
	assign opRcod.Xor	=(op==OP_R__)&(fun3==3'b100)&(fun7==7'b0000000);
	assign opRcod.Srl	=(op==OP_R__)&(fun3==3'b101)&(fun7==7'b0000000);
	assign opRcod.Sra	=(op==OP_R__)&(fun3==3'b101)&(fun7==7'b0100000);
	assign opRcod.Or	=(op==OP_R__)&(fun3==3'b110)&(fun7==7'b0000000);
	assign opRcod.And	=(op==OP_R__)&(fun3==3'b111)&(fun7==7'b0000000);
	assign opIner.Ebreak=(code==OP_EBREAK);
	assign opCsrr.Csrrw=(op==OP_SCR)&(fun3==3'b001);
	assign opCsrr.Csrrs=(op==OP_SCR)&(fun3==3'b010);

	assign opCode.Bfun	=(|opBfun);
	assign opCode.Mfun	=(|opSfun)|(|opLfun);
	
	assign opImmr.immI	={{20{code[31]}},code[31:20] };
	assign opImmr.immS	={{20{code[31]}},code[31:25], code[11:7] };
	assign opImmr.immB	={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
	assign opImmr.immJ	={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
	assign opImmr.immU	={code[31:12],12'b0 };

	assign csrAddr=code[31:20];

	assign opIner.opI	=(|opIcod)|(|opLfun)|(opCode.Jalr);
	assign opIner.opR	=(|opRcod);
	assign opIner.opS	=(|opSfun);
	assign opIner.opB	=(|opBfun);
	assign opIner.opJ	=(opCode.Jal);
	assign opIner.opU	=(opCode.Lui)|(opCode.Auipc);

	always_comb begin : choose_imm
		unique case('1)
			opIner.opI:imm=opImmr.immI;
			opIner.opU:imm=opImmr.immU;
			opIner.opS:imm=opImmr.immS;
			opIner.opB:imm=opImmr.immB;
			opIner.opJ:imm=opImmr.immJ;
			default   :imm='0;
		endcase
	end

	assign enJfun=(opCode.Jal)|(opCode.Jalr);
	assign cR1=r1;
	assign cR2=r2;
	assign cRd=(opIner.opB|opIner.opS)?'0:rd;

	import "DPI-C" function void stop(input bit eb);
	always_comb begin : check_ebreak_or_stop
		if(opIner.Ebreak&(~reset)) stop(1);
		else if((~((|opIner)|(|opCsrr)))&(~reset)) stop(0);
	end

endmodule
module ysyx_260020046_rv32iALU(oR1,oR2,pc,imm,data,addr,iRd,enBfun,opIcod,opRcod,opCode,opBfun,opLfun,opCsrr,oCsr,iCsr,enCsr);
	import rv32iBasis::*;
	input word_t oR1,oR2,pc,imm,data;
	input opIcod_t opIcod;
	input opRcod_t opRcod;
	input opCode_t opCode;
	input opBfun_t opBfun;
	input opLfun_t opLfun;
	input opCsrr_t opCsrr;
	input word_t oCsr;
	output word_t addr,iRd,iCsr;
	output logic enBfun,enCsr;

	word_t result;
	logic choRes,choDat,choNpc,choImm,choCsr;
	assign choRes=(|opRcod)|(|opIcod)|(opCode.Auipc);
	assign choDat=(|opLfun);
	assign choImm=(opCode.Lui);
	assign choNpc=(opCode.Jal)|(opCode.Jalr);
	assign choCsr=(|opCsrr);

	always_comb begin : calculate
		unique case('1)
			opCode.Lui	:result=imm;
			opCode.Auipc:result=imm+pc;
			opCode.Jal	:result=imm+pc;
			opCode.Jalr	:result=imm+oR1;
			opCode.Bfun	:result=imm+pc;
			opCode.Mfun	:result=imm+oR1;
			opIcod.Addi	:result=imm+oR1;
			opIcod.Slti	:result=  $signed(oR1) <  $signed(imm)?1:0;
			opIcod.Sltiu:result=$unsigned(oR1) <$unsigned(imm)?1:0;
			opIcod.Xori	:result=oR1^imm;
			opIcod.Ori	:result=oR1|imm;
			opIcod.Andi	:result=oR1&imm;
			opIcod.Slli	:result=oR1<<imm[4:0];
			opIcod.Srli	:result=$unsigned(oR1)>> imm[4:0];
			opIcod.Srai	:result=  $signed(oR1)>>>imm[4:0];
			opRcod.Add	:result=oR1+oR2;
			opRcod.Sub	:result=oR1-oR2;
			opRcod.Sll	:result=oR1<<oR2[4:0];
			opRcod.Slt	:result=  $signed(oR1) <  $signed(oR2)?1:0;
			opRcod.Sltu	:result=$unsigned(oR1) <$unsigned(oR2)?1:0;
			opRcod.Xor	:result=oR1^oR2;
			opRcod.Srl	:result=$unsigned(oR1)>> oR2[4:0];
			opRcod.Sra	:result=  $signed(oR1)>>>oR2[4:0];
			opRcod.Or	:result=oR1|oR2;
			opRcod.And	:result=oR1&oR2;
			opCsrr.Csrrs:result=oCsr|oR1;
			opCsrr.Csrrw:result=oR1;
			default		:result='0;
		endcase
	
	`ifdef RV32I_DEBUG
		$display("pc=%x oR1=%x oR2=%x imm=%x",pc,oR1,oR2,imm);
		$strobe("result=%x data=%x",result,data);
	`endif
	end

	always_comb begin : bFun
		unique case('1)
			opBfun.Beq	:enBfun=(oR1==oR2);
			opBfun.Bne	:enBfun=(oR1!=oR2);
			opBfun.Blt	:enBfun=(  $signed(oR1) <  $signed(oR2));
			opBfun.Bge	:enBfun=(  $signed(oR1)>=  $signed(oR2));
			opBfun.Bltu	:enBfun=($unsigned(oR1) <$unsigned(oR2));
			opBfun.Bgeu	:enBfun=($unsigned(oR1)>=$unsigned(oR2));
			default		:enBfun='0;
		endcase
	end

	assign iCsr=(|opCsrr)?result:0;
	assign enCsr=(|opCsrr);

	assign addr=(opCode.Mfun|opCode.Jal|opCode.Jalr|opCode.Bfun)?result:0;
	always_comb begin :choose
		unique case('1)
			choRes	:iRd=result;
			choDat	:iRd=data;
			choImm	:iRd=imm;
			choNpc	:iRd=pc+4;
			choCsr	:iRd=oCsr;
			default	:iRd='0;
		endcase
	end

endmodule
module ysyx_260020046_rv32iLSU(clk,reset,addr,oR2,enBfun,enJfun,opLfun,opSfun,data,pc);

	import rv32iBasis::*;
	input word_t addr,oR2;
	input logic clk,reset,enBfun,enJfun;
	input opLfun_t opLfun;
	input opSfun_t opSfun;
	output word_t data,pc;
	// output logic LSUsuccess;

	logic[3:0] mask;
	word_t iRAM;
//s处理
	always_comb begin : choose_mask
		unique case('1)
			opSfun.Sb	:mask=4'b0001;
			opSfun.Sh	:mask=4'b0011;
			opSfun.Sw	:mask=4'b1111;
			default		:mask=4'b0000;
		endcase
	end

//l处理

	always_comb begin : choose_date_input
		unique case('1)
			opLfun.Lb	:data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			opLfun.Lh	:data={{16{iRAM[15]}},iRAM[15: 0]};
			opLfun.Lw	:data=iRAM;
			opLfun.Lbu	:data={{24{1'b0}},iRAM[ 7: 0]};
			opLfun.Lhu	:data={{16{1'b0}},iRAM[15: 0]};
			default		:data=0;
		endcase
	end

	always_ff @(posedge clk) begin : pc_write
`ifdef RV32I_DEBUG
		$display("pc=%x addr=%x enj=%x,enb=%x",pc,addr,enJfun,enBfun);
`endif
		if(reset) pc<=PC_RESET;
		else if(enJfun|enBfun) pc<=addr;
		else pc<=pc+4;
	end

	import "DPI-C" function int pmem_read(input int addr);
	import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);
	assign iRAM = (|opLfun)&clk?pmem_read(addr):0;
	always_ff@(posedge clk) begin:control_write
		if (|opSfun) begin // 有写请求时
			pmem_write(addr, oR2, {4'b0,mask});
		end
	end

endmodule
module ysyx_260020046_rv32iGPR(pc,iRd,clk,reset,cRd,cR1,cR2,oR1,oR2);
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

module ysyx_260020046_rv32iCSR(csrAddr,iCsr,oCsr,clk,reset,enCsr);
	import rv32iBasis::*;
	input [11:0] csrAddr;
	word_t mepc,mstatus,mcause;
	input word_t iCsr;
	input logic clk,reset,enCsr;
	output word_t oCsr;

	always_ff@(posedge clk) begin:csr_write
		if(reset)begin
			mepc	<=PC_RESET;
			mstatus	<=32'h0;
			mcause	<=32'h0;
		end else if(enCsr)begin
			case(csrAddr)
				CSR_ADDR_MEPC	:mepc	<=iCsr;
				CSR_ADDR_MSTAUS	:mstatus	<=iCsr;
				CSR_ADDR_MCAUSE	:mcause	<=iCsr;
				default:;
			endcase
		end
	end

	always_comb begin:choose_csr
		unique case(csrAddr)
			CSR_ADDR_MEPC	:oCsr=mepc;
			CSR_ADDR_MSTAUS	:oCsr=mstatus;
			CSR_ADDR_MCAUSE	:oCsr=mcause;
			default			:oCsr=0;
		endcase
	end
				
endmodule
