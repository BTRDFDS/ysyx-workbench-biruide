package rv32iBasis;
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter PC_RESET	= 32'h80000000;
	parameter OP_I_J	= 7'b1100111;//jalr	  +
	parameter OP_I_A	= 7'b0010011;//i运算	 运算器
	parameter OP_I_L	= 7'b0000011;//l系列	 +
	parameter OP_U_I	= 7'b0110111;//lui	   无
	parameter OP_U_P	= 7'b0010111;//auipc	 +
	parameter OP_S		= 7'b0100011;//s系列	 +
	parameter OP_B		= 7'b1100011;//b比较系列 比较
	parameter OP_J		= 7'b1101111;//jal	   +
	parameter OP_R_0 	= 7'b0110011;//r运算	 运算器
	parameter OP_R_1	= 7'b0110011;//r运算	 运算器
	parameter OP_EBK	= 7'b1110011;
	parameter OP_NOP	= 7'b0001111;

	parameter OP_FUN7_I_0	= 7'b0000000;
	parameter OP_FUN7_I_1	= 7'b0100000;

	parameter OP_FUN3_I0_0	= 3'b000;
	parameter OP_FUN3_I1_0	= 3'b101;
	parameter OP_FUN3_R1_0	= 3'b000;
	parameter OP_FUN3_R1_1	= 3'b101;

	parameter OP_FUN7_M		= 7'b0000001;

	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;
	typedef enum [2:0] {ALU_OP_ADD,ALU_OP_SLL,ALU_OP_SLT,ALU_OP_SLTU,ALU_OP_XOR,ALU_OP_SRL,ALU_OP_OR,ALU_OP_AND} ALU_OP;
	typedef enum [1:0] {B_OP_BEQ,B_OP_BNE,B_OP_BLT,B_OP_BGE} B_OP;
	typedef enum [1:0] {CHOOSE_OP_CAL,CHOOSE_OP_IMM,CHOOSE_OP_SNPC,CHOOSE_OP_L} CHOOSE_OP;
	typedef struct packed {
		logic nR1,nR2;
		logic [1:0] choose;
		logic [1:0] bOp;
		logic op;//特殊情况：add=>sub,slt=>sltu,srl=>sra,blt=>bltu,bge=>bgeu
		logic [2:0] func;
	} aluOp_t;
endpackage

module ysyx_260020046_rv32I(clk,reset,code,pc);
	import rv32iBasis::*;
	input logic clk,reset;
	input word_t code;
	output word_t pc;

	aluOp_t aluOp;
	word_t oR1,oR2,imm,data,addr,iRd;
	logic enB,enJ;
	logic [2:0] fun3;
	reg_t cRd,cR1,cR2;

	ysyx_260020046_rv32iIDC IDC(.*);
	ysyx_260020046_rv32iALU ALU(.*);
	ysyx_260020046_rv32iLSU LSU(.*);
	ysyx_260020046_rv32iGPR GPR(.*);

endmodule

module ysyx_260020046_rv32iIDC(code,aluOp,enJ,fun3);
	import rv32iBasis::*;
	input word_t code;
	output aluOp_t aluOp;
	output logic enJ;
	output logic[2:0] fun3;
	word_t immI,immS,immB,immU,immJ;
	reg_t r1,r2,rd;
	logic [6:0] op;
	logic [2:0] aluOpFunc;
	logic [6:0] fun7;
	logic opIj,opIa,opIl,opI_0,opI_1,opUi,opUp,opS,opB,opJ,opR,opR_0,opR_1,opEb,opNop,opSltu;

	assign fun7=code[31:25];
	assign r2  =code[24:20];
	assign r1  =code[19:15];
	assign fun3=code[14:12];
	assign rd  =code[11: 7];
	assign op  =code[ 6: 0];

	assign immI={{20{code[31]}},code[31:20] };
	assign immS={{20{code[31]}},code[31:25], code[11:7] };
	assign immB={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
	assign immJ={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
	assign immU={code[31:12],12'b0 };

	assign opIj =(op==OP_I_J)|(fun3==OP_FUN3_I0_0);
	assign opIa =(op==OP_I_A)&(fun3!=OP_FUN3_I0_0 | fun3!=OP_FUN3_I1_0);
	assign opI_0=(op==OP_I_A)&(fun3==OP_FUN3_I0_0)&(fun7==OP_FUN7_I_0);
	assign opI_1=(op==OP_I_A)&(fun3==OP_FUN3_I1_0)&(fun7==OP_FUN7_I_0|fun7==OP_FUN7_I_1);
	assign opIl =(op==OP_I_L);
	assign opUi =(op==OP_U_I);
	assign opUp =(op==OP_U_P);
	assign opS  =(op==OP_S  );
	assign opB  =(op==OP_B  );
	assign opJ  =(op==OP_J  );
	assign opR_0=(op==OP_R_0)&(fun7==OP_FUN7_I_0)&(fun3!=OP_FUN3_R1_0 & fun3!=OP_FUN3_R1_1);
	assign opR_1=(op==OP_R_1)&(fun7==OP_FUN7_I_1)&(fun3==OP_FUN3_R1_0 | fun3==OP_FUN3_R1_1);
	assign opEb =(op==OP_EBK);
	assign opNop=(op==OP_NOP);

	assign enJ=opJ|opIj;

	assign opR=opR_0|opR_1;
	assign aluOp.func=(opIa|opR)?fun3:3'b0;
	assign aluOp.bOp={fun3[2],fun3[0]};

	import "DPI-C" function void stop(input bit eb);
	always_comb begin : check
		if(opEb) stop(1);
		else if(~(|{opIj,opIa,opIl,opUi,opUp,opS,opB,opJ,opR,opR,opNop})) stop(0);
	end

endmodule
module ysyx_260020046_rv32iALU(aluOp,oR1,oR2,pc,imm,data,addr,iRd,enB);
	import rv32iBasis::*;
	input aluOp_t aluOp;
	input word_t oR1,oR2,pc,imm,data;

	output word_t addr,iRd;
	output logic enB;

	word_t result,in1,in2;

	assign in1=aluOp.nR1 ? pc:oR1;
	assign in2=aluOp.nR2?imm:oR2;
	assign addr=in1+in2;

	always_comb begin : calculate
		case(aluOp.func)
			ALU_OP_ADD	: result=aluOp.op?in1-in2:addr;//addr 就是in1+in2，既可以理解为是add的r也可以是address
			ALU_OP_SLL	: result=in1<<in2;
			ALU_OP_SLT	: result=  $signed(in1) <  $signed(in2)?1:0;
			ALU_OP_SLTU	: result=$unsigned(in1) <$unsigned(in2)?1:0;
			ALU_OP_XOR	: result=in1^in2;
			ALU_OP_SRL	: result=aluOp.op?(in1>>>(in2&32'h1f)):in1>>(in2&32'h1f);
			ALU_OP_OR	: result=in1|in2;
			ALU_OP_AND	: result=in1&in2;
			default		: result='0;
		endcase
	end

	always_comb begin : B
		case(aluOp.bOp)
			B_OP_BEQ	: enB=(in1==in2);
			B_OP_BNE	: enB=(in1!=in2);
			B_OP_BLT	: enB=aluOp.op?($unsigned(in1) <$unsigned(in2)):($signed(in1) <$signed(in2));
			B_OP_BGE	: enB=aluOp.op?($unsigned(in1)>=$unsigned(in2)):($signed(in1)>=$signed(in2));
			default		: enB='0;
		endcase
	end


	always_comb begin : choose
		case(aluOp.choose)
			CHOOSE_OP_CAL	: iRd=result;
			CHOOSE_OP_IMM	: iRd=imm;
			CHOOSE_OP_SNPC	: iRd=pc+4;
			CHOOSE_OP_L		: iRd=data;
			default			: iRd='0;
		endcase
	end

endmodule
module ysyx_260020046_rv32iLSU(clk,reset,addr,oR2,enB,enJ,fun3,data,pc);

	import rv32iBasis::*;
	input word_t addr,oR2;
	input logic clk,reset,enB,enJ;
	input [2:0] fun3;
	output word_t data,pc;

	logic[3:0]hot;
	word_t ramAddr,iRAM;
//s处理
	assign ramAddr={addr[31:2],2'b0};

	always_comb begin:get_hot
		case(addr[1:0])
			2'b00:hot=4'b0001;
			2'b01:hot=4'b0010;
			2'b10:hot=4'b0100;
			2'b11:hot=4'b1000;
			default:hot=4'b00;
		endcase
	end

	assign wmask=w?4'b1111:hot;

//l处理//TODO
	always_comb begin:control_RAM_output
		case(fun3)
			3'b000 :data=iRAM;
			3'b001 :data={24'b0,iRAM[15:8]};
			3'b010 :data={24'b0,iRAM[23:16]};
			3'b100 :data={24'b0,iRAM[31:24]};
			3'b100 :data={24'b0,iRAM[31:24]};
			default:data=0;
		endcase
	end

	assign oRAM=(l&w)?iRAM:oRamB;

	always_ff @(posedge clk) begin : pc_write
		if(reset) pc<=PC_RESET;
		else if(enJ|enB) pc<=addr;
		else pc<=pc+4;
	end

	import "DPI-C" function int pmem_read(input int addr);
	import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);
	assign iRAM = l&inClk?pmem_read(ramAddr):0;
	always_ff@(posedge clk) begin:control_write
		if (s) begin // 有写请求时
			pmem_write(ramAddr, oR2, {4'b0,wmask});
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

	assign oR1=(cR1==0)?'0:gpr[cR1];
	assign oR2=(cR2==0)?'0:gpr[cR2];

	export "DPI-C" function getReg;
	function int getReg(input int addr);
		return (addr == 0) ? pc : gpr[addr];
	endfunction

endmodule