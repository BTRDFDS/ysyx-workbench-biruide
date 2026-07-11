// 移除SV package，改为Verilog-2005全局定义（核心解决import错误）
`define REG_ADDR_WIDTH 5   // 原REG_NUMBER易误解，重命名为寄存器地址位宽（5位=32个寄存器）
`define DATA_WIDTH     32
`define PC_RESET       32'h80000000
// 操作码宏定义
`define OP_I_J         7'b1100111
`define OP_I_A         7'b0010011
`define OP_I_L         7'b0000011
`define OP_U_I         7'b0110111
`define OP_U_P         7'b0010111
`define OP_S           7'b0100011
`define OP_B           7'b1100011
`define OP_J           7'b1101111
`define OP_R_0         7'b0110011
`define OP_R_1         7'b0110011
`define OP_EBK         7'b1110011
`define OP_NOP         7'b0001111
// FUN7/FUN3宏定义
`define OP_FUN7_I_0    7'b0000000
`define OP_FUN7_I_1    7'b0100000
`define OP_FUN3_I0_0   3'b001
`define OP_FUN3_I1_0   3'b101
`define OP_FUN3_R1_0   3'b000
`define OP_FUN3_R1_1   3'b101
// 枚举替换为参数（Verilog-2005无enum）
`define ALU_OP_ADD     3'b000
`define ALU_OP_SLL     3'b001
`define ALU_OP_SLT     3'b010
`define ALU_OP_SLTU    3'b011
`define ALU_OP_XOR     3'b100
`define ALU_OP_SRL     3'b101
`define ALU_OP_OR      3'b110
`define ALU_OP_AND     3'b111

`define B_OP_BEQ       2'b00
`define B_OP_BNE       2'b01
`define B_OP_BLT       2'b10
`define B_OP_BGE       2'b11

`define CHOOSE_OP_CAL  2'b00
`define CHOOSE_OP_IMM  2'b01
`define CHOOSE_OP_SNPC 2'b10
`define CHOOSE_OP_L    2'b11

// 自定义类型全局定义
typedef logic [`DATA_WIDTH-1:0] word_t;
typedef logic [`REG_ADDR_WIDTH-1:0] reg_t;

// aluOp_t 结构体定义
typedef struct packed {
    logic nR1,nR2;
    logic [1:0] choose;
    logic usB;
    logic [1:0] bOp;
    logic op;//特殊情况：add=>sub,slt=>sltu,srl=>sra,blt=>bltu,bge=>bgeu
    logic [2:0] func;
} aluOp_t;

// lsuOp_t 结构体定义
typedef struct packed {
    logic [2:0] fun3;
    logic s,l;
} lsuOp_t;

// import rv32iBasis::*;
module ysyx_26020046_rv32i_oldSta(clk,reset,code,pmem_read,pc,stop,eb,enW,pmem_write,ramAddr,mask);
	// import rv32iBasis::*;
	input logic clk,reset;
	input word_t code,pmem_read;
	output word_t pc,pmem_write,ramAddr;
	output stop,eb,enW;
	output [3:0]mask;

	aluOp_t aluOp;
	word_t oR1,oR2,imm,imi,data,addr,iRd;
	logic enB,enJ;
	lsuOp_t lsuOp;
	reg_t cRd,cR1,cR2;

	ysyx_260020046_rv32iIDC IDC(.*);
	ysyx_260020046_rv32iALU ALU(.*);
	ysyx_260020046_rv32iLSU LSU(.*);
	ysyx_260020046_rv32iGPR GPR(.*);

endmodule

module ysyx_260020046_rv32iIDC(code,reset,aluOp,enJ,lsuOp,imm,imi,cRd,cR1,cR2,stop,eb);
	// import rv32iBasis::*;
	input word_t code;
	input logic reset;
	output aluOp_t aluOp;
	output logic enJ,stop,eb;
	output lsuOp_t lsuOp;
	output word_t imm,imi;
	output reg_t cRd,cR1,cR2;
	word_t immI,immS,immB,immU,immJ,immC;
	logic [6:0] op;
	logic [1:0]choose;
	logic [2:0] fun3;
	logic [6:0] fun7;
	logic opIj,opIa,opIl,opI_0,opI_1,opUi,opUp,opS,opB,opJ,opR,opR_0,opR_1,opEb,opNop,opSrai,opBop;

	assign fun7=code[31:25];
	assign cR2  =code[24:20];
	assign cR1  =code[19:15];
	assign fun3=code[14:12];
	assign cRd  =(opB|opS)?'0:code[11: 7];
	assign op  =code[ 6: 0];

	assign immI={{20{code[31]}},code[31:20] };
	assign immS={{20{code[31]}},code[31:25], code[11:7] };
	assign immB={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
	assign immJ={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
	assign immU={code[31:12],12'b0 };

	assign choose[0]=opS|opJ;
	assign choose[1]=opB|opJ;

	always_comb begin
		unique case(choose)
			2'b00: immC=immI;
			2'b01: immC=immS;
			2'b10: immC=immB;
			2'b11: immC=immJ;
		endcase
	end

	assign imi=immU;
	assign imm=opUp?immU:immC;

	assign opIj =(op==`OP_I_J)&(fun3==3'b000);
	assign opIa =(op==`OP_I_A)&(fun3!=`OP_FUN3_I0_0 | fun3!=`OP_FUN3_I1_0);
	assign opI_0=(op==`OP_I_A)&(fun3==`OP_FUN3_I0_0)&(fun7==`OP_FUN7_I_0);
	assign opI_1=(op==`OP_I_A)&(fun3==`OP_FUN3_I1_0)&(fun7==`OP_FUN7_I_0|fun7==`OP_FUN7_I_1);
	assign opIl =(op==`OP_I_L);
	assign opUi =(op==`OP_U_I);
	assign opUp =(op==`OP_U_P);
	assign opS  =(op==`OP_S  )&(fun3==3'b000|fun3==3'b001|fun3==3'b010);
	assign opB  =(op==`OP_B  )&(fun3!=3'b010|fun3!=3'b011);
	assign opJ  =(op==`OP_J  );
	assign opR_0=(op==`OP_R_0)&(fun7==`OP_FUN7_I_0);
	assign opR_1=(op==`OP_R_1)&(fun7==`OP_FUN7_I_1)&(fun3==`OP_FUN3_R1_0 | fun3==`OP_FUN3_R1_1);
	assign opEb =(op==`OP_EBK);
	assign opNop=(op==`OP_NOP);

	assign opR=opR_0|opR_1;

	assign enJ=opJ|opIj;

	assign lsuOp.fun3=fun3;
	assign lsuOp.s=opS;
	assign lsuOp.l=opIl;

	assign opSrai=opI_1&fun7==`OP_FUN7_I_1;
	assign opBop =opB&fun3[1];

	assign aluOp.func=(opIa|opR)?fun3:3'b0;
	assign aluOp.bOp={fun3[2],fun3[0]};
	assign aluOp.usB=opB;
	assign aluOp.nR1=opJ|opUp|opB;
	assign aluOp.nR2=opS|opI_0|opI_1|opIj|opIl|opIa|opUp|opJ|opB;
	assign aluOp.choose[0]=opUi|opIl;
	assign aluOp.choose[1]=opJ|opIj|opIl;
	assign aluOp.op=opSrai|opBop|opR_1;

	always_comb begin : check
		if(opEb&(~reset))begin
			stop=1;
			eb=1;
		end else if(~(|{opIj,opIa,opI_0,opI_1,opIl,opUi,opUp,opS,opB,opJ,opR,opEb,opNop,reset}))begin
			stop=1;
			eb=0;
		end else begin
			stop=0;
			eb=0;
		end
	end

endmodule
module ysyx_260020046_rv32iALU(aluOp,oR1,oR2,pc,imm,imi,data,addr,iRd,enB);
	// import rv32iBasis::*;
	input aluOp_t aluOp;
	input word_t oR1,oR2,pc,imm,imi,data;

	output word_t addr,iRd;
	output logic enB;

	word_t result,in1,in2;
	logic enBc;
	logic   signed [31:0] sra;
    logic unsigned [31:0] srl;

	assign sra=   $signed(in1) >>> (in2[4:0]);
	assign srl= $unsigned(in1) >>  (in2[4:0]);

	assign in1=aluOp.nR1? pc:oR1;
	assign in2=aluOp.nR2?imm:oR2;
	assign addr=in1+in2;

	always_comb begin : calculate
		unique case(aluOp.func)
			`ALU_OP_ADD	: result=aluOp.op?in1-in2:addr;//addr 就是in1+in2，既可以理解为是add的r也可以是address
			`ALU_OP_SLL	: result=in1<<in2[4:0];
			`ALU_OP_SLT	: result=  $signed(in1) <  $signed(in2)?1:0;
			`ALU_OP_SLTU: result=$unsigned(in1) <$unsigned(in2)?1:0;
			`ALU_OP_XOR	: result=in1^in2;
			`ALU_OP_SRL	: result=aluOp.op?sra:srl;
			`ALU_OP_OR	: result=in1|in2;
			`ALU_OP_AND	: result=in1&in2;
			default		: result='0;
		endcase
	end

	always_comb begin : B
		unique case(aluOp.bOp)
			`B_OP_BEQ	: enBc=(oR1==oR2);
			`B_OP_BNE	: enBc=(oR1!=oR2);
			`B_OP_BLT	: enBc=aluOp.op?($unsigned(oR1) <$unsigned(oR2)):($signed(oR1) <$signed(oR2));
			`B_OP_BGE	: enBc=aluOp.op?($unsigned(oR1)>=$unsigned(oR2)):($signed(oR1)>=$signed(oR2));
			default		: enBc='0;
		endcase
	end
	assign enB=enBc&aluOp.usB;

	always_comb begin : choose
		unique case(aluOp.choose)
			`CHOOSE_OP_CAL	: iRd=result;
			`CHOOSE_OP_IMM	: iRd=imi;
			`CHOOSE_OP_SNPC	: iRd=pc+4;
			`CHOOSE_OP_L	: iRd=data;
			default			: iRd='0;
		endcase
	end

endmodule
module ysyx_260020046_rv32iLSU(clk,reset,addr,oR2,pmem_read,enB,enJ,lsuOp,data,pc,enW,pmem_write,ramAddr,mask);

	// import rv32iBasis::*;
	input word_t addr,oR2,pmem_read;
	input logic clk,reset,enB,enJ;
	input lsuOp_t lsuOp;
	output word_t data,pc,pmem_write,ramAddr;
	output reg enW;
	output logic[3:0]mask;

	logic[3:0]hot,hotB,hotH;
	word_t iRAM,dataH,dataB;
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
	assign mask=(lsuOp.fun3[1])?hot:(lsuOp.fun3[0]?hotH:hotB);

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
	end

	always_ff @(posedge clk) begin : pc_write
		if(reset) pc<=`PC_RESET;
		else if(enJ|enB) pc<=addr;
		else pc<=pc+4;
	end

	assign iRAM = lsuOp.l&clk?pmem_read:0;
	assign enW = lsuOp.s;
	assign pmem_write=oR2;

endmodule
module ysyx_260020046_rv32iGPR(iRd,clk,reset,cRd,cR1,cR2,oR1,oR2);
	// import rv32iBasis::*;
	input word_t iRd;
	input logic clk,reset;
	input reg_t cRd,cR1,cR2;
	output word_t oR1,oR2;

	word_t gpr [2**`REG_ADDR_WIDTH -1:1];

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
