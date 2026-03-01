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

	parameter OP_FUN3_I0_0	= 3'b001;
	parameter OP_FUN3_I1_0	= 3'b101;
	parameter OP_FUN3_R1_0	= 3'b000;
	parameter OP_FUN3_R1_1	= 3'b101;

	// parameter OP_FUN7_M		= 7'b0000001;

	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;

	typedef struct packed {
	    logic Add, Sub, Sll, Slt, Sltu, Xor, Srl, Sra, Or, And;
	} opRcod_t;
	typedef struct packed {
	    logic Jalr;
	    logic Addi, Slti, Sltiu, Xori, Ori, Andi, Slli, Srli, Srai;
	} opIcod_t;
	typedef struct packed {
	    logic Lui,Auipc,Jal,Bfun,Mfun;
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
	    logic opI,opU,opS,opB,opJ,opR,opN;
		logic Ebreak;
		word_t immI,immU,immS,immB,immJ;
	}opImm_t;

endpackage

module ysyx_26020046_rv32i(clk,reset,code,pc);
	import rv32iBasis::*;
	input logic clk,reset;
	input word_t code;
	output word_t pc;

	word_t oR1,oR2,imm,data,addr,iRd,cRd,cR1,cR2;
	logic enB,enJfun;
	opCode_t opCode;
	opBfun_t opBfun;
	opLfun_t opLfun;
	opSfun_t opSfun;

	ysyx_260020046_rv32iIDC IDC(.*);
	ysyx_260020046_rv32iALU ALU(.*);
	ysyx_260020046_rv32iLSU LSU(.*);
	ysyx_260020046_rv32iGPR GPR(.*);

endmodule

module ysyx_260020046_rv32iIDC(code,reset,enJfun,imm,cRd,cR1,cR2,opIcod,opRcod,opCode,opBfun,opLfun,opSfun);
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
	opImm_t opImm;
	logic [6:0] op;
	logic [1:0]choose;
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
	assign opCode.jal	=(op==OP_J__);
	assign opIcod.jalr	=(op==OP_I_J)&(fun3==3'b000);
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
	assign opImm.Ebreak	=(code==OP_EBREAK);


	assign opCode.Bfun	=(|opBfun);
	assign opCode.Mfun	=(|opSfun)|(opLfun);
	
	assign opImm.immI	={{20{code[31]}},code[31:20] };
	assign opImm.immS	={{20{code[31]}},code[31:25], code[11:7] };
	assign opImm.immB	={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
	assign opImm.immJ	={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
	assign opImm.immU	={code[31:12],12'b0 };

	assign opImm.opI	=(|opIcod)|(|opLfun);
	assign opImm.opR	=(|opRcod);
	assign opImm.opS	=(|opSfun);
	assign opImm.opB	=(|opBfun);
	assign opImm.opJ	=(opCode.Jal);
	assign opImm.opU	=(opCode.Lui)|(opCode.Auipc);

	always_comb begin : choose_imm
		unique case('1)
			opImm.opI:imm=opImm.immI;
			opImm.opU:imm=opImm.immU;
			opImm.opS:imm=opImm.immS;
			opImm.opB:imm=opImm.immB;
			opImm.opJ:imm=opImm.immJ;
			default	 :imm='0;
		endcase
	end


// `ifdef RV32I_DEBUG
// 	always_comb begin
// 		// $display("code=%x op=%x fun3=%x fun7=%x",code,op,fun3,fun7);
// 		// $display("opIj=%x opIa=%x opI_0=%x opI_1=%x",opIj,opIa,opI_0,opI_1);
// 		// $display("opIl=%x opUi=%x opUp=%x opS=%x",opIl,opUi,opUp,opS);
// 		// $display("opB=%x opJ=%x opR=%x opEb=%x",opB,opJ,opR,opEb);
// 		// $display("opNop=%x cR1=%x cR2=%x cRd=%x",opNop,cR1,cR2,cRd);
// 		// $display("alu func=%x op=%x bOp=%x usB=%x nR1=%x nR2=%x choose=%x",aluOp.func,aluOp.op,aluOp.bOp,aluOp.usB,aluOp.nR1,aluOp.nR2,aluOp.choose);
// 		// $display("lsu fun3=%x s=%x l=%x",lsuOp.fun3,lsuOp.s,lsuOp.l);
// 	end
// `endif

	// import "DPI-C" function void stop(input bit eb);
	// always_comb begin : check
	// 	if(opEb&(~reset)) stop(1);
	// 	else if(~(|{opIj,opIa,opI_0,opI_1,opIl,opUi,opUp,opS,opB,opJ,opR,opEb,opNop,reset})) stop(0);
	// end

endmodule
module ysyx_260020046_rv32iALU(oR1,oR2,pc,imm,data,addr,iRd,enB,opIcod,opRcod,opCode,opBfun);
	import rv32iBasis::*;
	input word_t oR1,oR2,pc,imm,imi,data;
	input opIcod_t opIcod;
	input opRcod_t opRcod;
	input opCode_t opCode;
	input opBfun_t opBfun;

	output word_t addr,iRd;
	output logic enB;

	word_t result;
	logic enBc;
	logic   signed [31:0] sra;
    logic unsigned [31:0] srl;

	// assign sra=   $signed(in1) >>> (in2[4:0]);
	// assign srl= $unsigned(in1) >>  (in2[4:0]);

	// assign in1=aluOp.nR1? pc:oR1;
	// assign in2=aluOp.nR2?imm:oR2;
	assign addr=in1+in2;

	always_comb begin : calculate
		unique case(opRcod)
			opIcod.Lui		:result=imm;
			opIcod.Auipc	:result=imm+pc;
			opCode.Jal		:result=imm+pc;
			opCode.Jalr		:result=imm+oR1;
			opCode.Bfun		:result=imm+pc;
			opCode.Mfun		:result=addr;
			opIcod.Addi		:result=imm+oR1;
			opIcod.Slti		:result=  $signed(oR1) <  $signed(imm)?1:0;
			opIcod.Sltiu	:result=$unsigned(oR1) <$unsigned(imm)?1:0;
			opIcod.Xori		:result=oR1^imm;
			opIcod.Ori		:result=oR1|imm;
			opIcod.Andi		:result=oR1&imm;
			opIcod.Slli		:result=oR1<<imm[4:0];
			opIcod.Srli		:result=$unsigned(oR1)>> imm[4:0];
			opIcod.Srai		:result=  $signed(oR1)>>>imm[4:0];
			opRcod.Add		:result=oR1+oR2;
			opRcod.Sub		:result=oR1-oR2;
			opRcod.Sll		:result=oR1<<oR2[4:0];
			opRcod.Slt		:result=  $signed(oR1) <  $signed(oR2)?1:0;
			opRcod.Sltu		:result=$unsigned(oR1) <$unsigned(oR2)?1:0;
			opRcod.Xor		:result=oR1^oR2;
			opRcod.Srl		:result=$unsigned(oR1)>> oR2[4:0];
			opRcod.Sra		:result=  $signed(oR1)>>>oR2[4:0];
			opRcod.Or		:result=oR1|oR2;
			opRcod.And		:result=oR1&oR2;
			default			:result='0;
		endcase
	end

	always_comb begin : bFun
		unique case('1)
			opBfun.Beq	:enBc=(oR1==oR2);
			opBfun.Bne	:enBc=(oR1!=oR2);
			opBfun.Blt	:enBc=(  $signed(oR1) <  $signed(oR2));
			opBfun.Bge	:enBc=(  $signed(oR1)>=  $signed(oR2));
			opBfun.Bltu	:enBc=($unsigned(oR1) <$unsigned(oR2));
			opBfun.Bgeu	:enBc=($unsigned(oR1)>=$unsigned(oR2));
			default		:enBc='0;
		endcase
	end



// 	always_comb begin : calculate
// 		// unique case(aluOp.func)
// 		// 	ALU_OP_ADD	: result=aluOp.op?in1-in2:addr;//addr 就是in1+in2，既可以理解为是add的r也可以是address
// 		// 	ALU_OP_SLL	: result=in1<<in2[4:0];
// 		// 	ALU_OP_SLT	: result=  $signed(in1) <  $signed(in2)?1:0;
// 		// 	ALU_OP_SLTU	: result=$unsigned(in1) <$unsigned(in2)?1:0;
// 		// 	ALU_OP_XOR	: result=in1^in2;
// 		// 	ALU_OP_SRL	: result=aluOp.op?sra:srl;
// 		// 	ALU_OP_OR	: result=in1|in2;
// 		// 	ALU_OP_AND	: result=in1&in2;
// 		// 	default		: result='0;
// 		// endcase
// `ifdef RV32I_DEBUG
// 		$display("in1=%x in2=%x oR1=%x oR2=%x pc=%x imm=%x imi=%x",in1,in2,oR1,oR2,pc,imm,imi);
// 		$display("result=%x addr=%x",result,addr);
// 		$display("sra=%x srl=%x",sra,srl);
// `endif
// 	end

	// always_comb begin : B
	// 	unique case(aluOp.bOp)
	// 		B_OP_BEQ	: enBc=(oR1==oR2);
	// 		B_OP_BNE	: enBc=(oR1!=oR2);
	// 		B_OP_BLT	: enBc=aluOp.op?($unsigned(oR1) <$unsigned(oR2)):($signed(oR1) <$signed(oR2));
	// 		B_OP_BGE	: enBc=aluOp.op?($unsigned(oR1)>=$unsigned(oR2)):($signed(oR1)>=$signed(oR2));
	// 		default		: enBc='0;
	// 	endcase
	// end
	// assign enB=enBc&aluOp.usB;

	// always_comb begin : choose
	// 	unique case(aluOp.choose)
	// 		CHOOSE_OP_CAL	: iRd=result;
	// 		CHOOSE_OP_IMM	: iRd=imi;
	// 		CHOOSE_OP_SNPC	: iRd=pc+4;
	// 		CHOOSE_OP_L		: iRd=data;
	// 		default			: iRd='0;
	// 	endcase
	// end

endmodule
module ysyx_260020046_rv32iLSU(clk,reset,addr,oR2,enB,enJfun,data,pc);

	import rv32iBasis::*;
	input word_t addr,oR2;
	input logic clk,reset,enB,enJfun;
	output word_t data,pc;

	logic[3:0]hot,hotB,hotH,mask;
	word_t ramAddr,iRAM,dataH,dataB;
//s处理
	assign ramAddr={addr[31:2],2'b0};

	always_comb begin:get_hotB
		unique case(addr[1:0])
			2'b00:hotB=4'b0001;
			2'b01:hotB=4'b0010;
			2'b10:hotB=4'b0100;
			2'b11:hotB=4'b1000;
			default:hotB=4'b00;
		endcase
	end
	assign hot =4'b1111;
	assign hotH=addr[1]?4'b1100:4'b0011;
	// assign mask=(lsuOp.fun3[1])?hot:(lsuOp.fun3[0]?hotH:hotB);

//l处理//TODO
	always_comb begin
		unique case(addr[1:0])
			2'b00:dataB={24'b0,iRAM[7:0]};
			2'b01:dataB={24'b0,iRAM[15:8]};
			2'b10:dataB={24'b0,iRAM[23:16]};
			2'b11:dataB={24'b0,iRAM[31:24]};
			default:dataB=0;
		endcase
	end
	always_comb begin
		unique case(addr[1])
			1'b0:dataH={16'b0,iRAM[15: 0]};
			1'b1:dataH={16'b0,iRAM[31:16]};
			default:dataH=0;
		endcase
	end
	always_comb begin:control_RAM_output
		unique case(lsuOp.fun3)
			3'b000 :data={{24{dataB[ 7]}},dataB[ 7: 0]};
			3'b001 :data={{16{dataH[15]}},dataH[15: 0]};
			3'b010 :data=iRAM;
			3'b100 :data=dataB;
			3'b101 :data=dataH;
			default:data=0;
		endcase
`ifdef RV32I_DEBUG
		$display("data=%x dataB=%x dataH=%x iRAM=%x",data,dataB,dataH,iRAM);
		$display("mask=%x hot=%x hotH=%x hotB=%x lsuOp.fun3=%x",mask,hot,hotH,hotB,lsuOp.fun3);
`endif
	end

	always_ff @(posedge clk) begin : pc_write
`ifdef RV32I_DEBUG
		$display("pc=%x addr=%x enj=%x,enb=%x",pc,addr,enJfun,enB);
`endif
		if(reset) pc<=PC_RESET;
		else if(enJfun|enB) pc<=addr;
		else pc<=pc+4;
	end

	import "DPI-C" function int pmem_read(input int addr);
	import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);
	assign iRAM = lsuOp.l&clk?pmem_read(ramAddr):0;
	always_ff@(posedge clk) begin:control_write
		if (lsuOp.s) begin // 有写请求时
			pmem_write(ramAddr, oR2, {4'b0,mask});
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
