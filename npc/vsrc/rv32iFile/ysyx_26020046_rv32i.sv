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
	parameter OP_S		= 7'b0100011;//s系列	 +
	parameter OP_B		= 7'b1100011;//b比较系列 比较
	parameter OP_J		= 7'b1101111;//jal	   +
	parameter OP_R_0 	= 7'b0110011;//r运算	 运算器
	parameter OP_R_1	= 7'b0110011;//r运算	 运算器
	parameter OP_EBK	= 7'b1110011;
	parameter OP_NOP	= 7'b0001111;

	parameter OP_FUN7_I_0	= 7'b0000000;
	parameter OP_FUN7_I_1	= 7'b0100000;

	parameter OP_FUN3_I0_0	= 3'b001;
	parameter OP_FUN3_I1_0	= 3'b101;
	parameter OP_FUN3_R1_0	= 3'b000;
	parameter OP_FUN3_R1_1	= 3'b101;

	// parameter OP_FUN7_M		= 7'b0000001;

	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;
	typedef enum [2:0] {ALU_OP_ADD,ALU_OP_SLL,ALU_OP_SLT,ALU_OP_SLTU,ALU_OP_XOR,ALU_OP_SRL,ALU_OP_OR,ALU_OP_AND} ALU_OP;
	typedef enum [1:0] {B_OP_BEQ,B_OP_BNE,B_OP_BLT,B_OP_BGE} B_OP;
	typedef enum [1:0] {CHOOSE_OP_CAL,CHOOSE_OP_IMM,CHOOSE_OP_SNPC,CHOOSE_OP_L} CHOOSE_OP;
	typedef struct packed {
		logic nR1,nR2;
		logic [1:0] choose;
		logic usB;
		logic [1:0] bOp;
		logic op;//特殊情况：add=>sub,slt=>sltu,srl=>sra,blt=>bltu,bge=>bgeu
		logic [2:0] func;
	} aluOp_t;
	typedef struct packed {
		logic [2:0] fun3;
		logic s,l;
	} lsuOp_t;
endpackage

module ysyx_26020046_rv32i(clk,reset,code,pc);
	import rv32iBasis::*;
	input logic clk,reset;
	input word_t code;
	output word_t pc;

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

module ysyx_260020046_rv32iIDC(code,reset,aluOp,enJ,lsuOp,imm,imi,cRd,cR1,cR2);
	import rv32iBasis::*;
	input word_t code;
	input logic reset;
	output aluOp_t aluOp;
	output logic enJ;
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
		case(choose)
			2'b00: immC=immI;
			2'b01: immC=immS;
			2'b10: immC=immB;
			2'b11: immC=immJ;
		endcase
	end

	assign imi=immU;
	assign imm=opUp?immU:immC;

	assign opIj =(op==OP_I_J)&(fun3==3'b000);
	assign opIa =(op==OP_I_A)&(fun3!=OP_FUN3_I0_0 | fun3!=OP_FUN3_I1_0);
	assign opI_0=(op==OP_I_A)&(fun3==OP_FUN3_I0_0)&(fun7==OP_FUN7_I_0);
	assign opI_1=(op==OP_I_A)&(fun3==OP_FUN3_I1_0)&(fun7==OP_FUN7_I_0|fun7==OP_FUN7_I_1);
	assign opIl =(op==OP_I_L);
	assign opUi =(op==OP_U_I);
	assign opUp =(op==OP_U_P);
	assign opS  =(op==OP_S  )&(fun3==3'b000|fun3==3'b001|fun3==3'b010);
	assign opB  =(op==OP_B  )&(fun3!=3'b010|fun3!=3'b011);
	assign opJ  =(op==OP_J  );
	assign opR_0=(op==OP_R_0)&(fun7==OP_FUN7_I_0);
	assign opR_1=(op==OP_R_1)&(fun7==OP_FUN7_I_1)&(fun3==OP_FUN3_R1_0 | fun3==OP_FUN3_R1_1);
	assign opEb =(op==OP_EBK);
	assign opNop=(op==OP_NOP);

	assign opR=opR_0|opR_1;

	assign enJ=opJ|opIj;

	assign lsuOp.fun3=fun3;
	assign lsuOp.s=opS;
	assign lsuOp.l=opIl;

	assign opSrai=opI_1&fun7==OP_FUN7_I_1;
	assign opBop =opB&fun3[1];

	assign aluOp.func=(opIa|opR)?fun3:3'b0;
	assign aluOp.bOp={fun3[2],fun3[0]};
	assign aluOp.usB=opB;
	assign aluOp.nR1=opJ|opUp|opB;
	assign aluOp.nR2=opS|opI_0|opI_1|opIj|opIl|opIa|opUp|opJ|opB;
	assign aluOp.choose[0]=opUi|opIl;
	assign aluOp.choose[1]=opJ|opIj|opIl;
	assign aluOp.op=opSrai|opBop|opR_1;

`ifdef RV32I_DEBUG
	always_comb begin
		$display("code=%x op=%x fun3=%x fun7=%x",code,op,fun3,fun7);
		$display("opIj=%x opIa=%x opI_0=%x opI_1=%x",opIj,opIa,opI_0,opI_1);
		$display("opIl=%x opUi=%x opUp=%x opS=%x",opIl,opUi,opUp,opS);
		$display("opB=%x opJ=%x opR=%x opEb=%x",opB,opJ,opR,opEb);
		$display("opNop=%x cR1=%x cR2=%x cRd=%x",opNop,cR1,cR2,cRd);
		$display("alu func=%x op=%x bOp=%x usB=%x nR1=%x nR2=%x choose=%x",aluOp.func,aluOp.op,aluOp.bOp,aluOp.usB,aluOp.nR1,aluOp.nR2,aluOp.choose);
		$display("lsu fun3=%x s=%x l=%x",lsuOp.fun3,lsuOp.s,lsuOp.l);
	end
`endif

	import "DPI-C" function void stop(input bit eb);
	always_comb begin : check
		if(opEb&(~reset)) stop(1);
		else if(~(|{opIj,opIa,opI_0,opI_1,opIl,opUi,opUp,opS,opB,opJ,opR,opEb,opNop,reset})) stop(0);
	end

endmodule
module ysyx_260020046_rv32iALU(aluOp,oR1,oR2,pc,imm,imi,data,addr,iRd,enB);
	import rv32iBasis::*;
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
		case(aluOp.func)
			ALU_OP_ADD	: result=aluOp.op?in1-in2:addr;//addr 就是in1+in2，既可以理解为是add的r也可以是address
			ALU_OP_SLL	: result=in1<<in2[4:0];
			ALU_OP_SLT	: result=  $signed(in1) <  $signed(in2)?1:0;
			ALU_OP_SLTU	: result=$unsigned(in1) <$unsigned(in2)?1:0;
			ALU_OP_XOR	: result=in1^in2;
			ALU_OP_SRL	: result=aluOp.op?sra:srl;
			ALU_OP_OR	: result=in1|in2;
			ALU_OP_AND	: result=in1&in2;
			default		: result='0;
		endcase
`ifdef RV32I_DEBUG
		$display("in1=%x in2=%x oR1=%x oR2=%x pc=%x imm=%x imi=%x",in1,in2,oR1,oR2,pc,imm,imi);
		$display("result=%x addr=%x",result,addr);
		$display("sra=%x srl=%x",sra,srl);
`endif
	end

	always_comb begin : B
		case(aluOp.bOp)
			B_OP_BEQ	: enBc=(oR1==oR2);
			B_OP_BNE	: enBc=(oR1!=oR2);
			B_OP_BLT	: enBc=aluOp.op?($unsigned(oR1) <$unsigned(oR2)):($signed(oR1) <$signed(oR2));
			B_OP_BGE	: enBc=aluOp.op?($unsigned(oR1)>=$unsigned(oR2)):($signed(oR1)>=$signed(oR2));
			default		: enBc='0;
		endcase
	end
	assign enB=enBc&aluOp.usB;

	always_comb begin : choose
		case(aluOp.choose)
			CHOOSE_OP_CAL	: iRd=result;
			CHOOSE_OP_IMM	: iRd=imi;
			CHOOSE_OP_SNPC	: iRd=pc+4;
			CHOOSE_OP_L		: iRd=data;
			default			: iRd='0;
		endcase
	end

endmodule
module ysyx_260020046_rv32iLSU(clk,reset,addr,oR2,enB,enJ,lsuOp,data,pc);

	import rv32iBasis::*;
	input word_t addr,oR2;
	input logic clk,reset,enB,enJ;
	input lsuOp_t lsuOp;
	output word_t data,pc;

	logic[3:0]hot,hotB,hotH,mask;
	word_t ramAddr,iRAM,dataH,dataB;
//s处理
	assign ramAddr={addr[31:2],2'b0};

	always_comb begin:get_hotB
		case(addr[1:0])
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
		case(addr[1:0])
			2'b00:dataB={24'b0,iRAM[7:0]};
			2'b01:dataB={24'b0,iRAM[15:8]};
			2'b10:dataB={24'b0,iRAM[23:16]};
			2'b11:dataB={24'b0,iRAM[31:24]};
			default:dataB=0;
		endcase
	end
	always_comb begin
		case(addr[1])
			1'b0:dataH={16'b0,iRAM[15: 0]};
			1'b1:dataH={16'b0,iRAM[31:16]};
			default:dataH=0;
		endcase
	end
	always_comb begin:control_RAM_output
		case(lsuOp.fun3)
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
		$display("pc=%x addr=%x enj=%x,enb=%x",pc,addr,enJ,enB);
`endif
		if(reset) pc<=PC_RESET;
		else if(enJ|enB) pc<=addr;
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
