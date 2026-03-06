module ysyx_26020046_rv32ioldALU(aluOp,oR1,oR2,pc,imm,imi,data,addr,iRd,enB);
	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;
	typedef enum logic [2:0] {ALU_OP_ADD,ALU_OP_SLL,ALU_OP_SLT,ALU_OP_SLTU,ALU_OP_XOR,ALU_OP_SRL,ALU_OP_OR,ALU_OP_AND} ALU_OP;
	typedef enum logic [1:0] {B_OP_BEQ,B_OP_BNE,B_OP_BLT,B_OP_BGE} B_OP;
	typedef enum logic [1:0] {CHOOSE_OP_CAL,CHOOSE_OP_IMM,CHOOSE_OP_SNPC,CHOOSE_OP_L} CHOOSE_OP;
	typedef struct packed {
		logic nR1,nR2;
		logic [1:0] choose;
		logic usB;
		logic [1:0] bOp;
		logic op;
		logic [2:0] func;
	} aluOp_t;
	typedef struct packed {
		logic [2:0] fun3;
		logic s,l;
	} lsuOp_t;
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
