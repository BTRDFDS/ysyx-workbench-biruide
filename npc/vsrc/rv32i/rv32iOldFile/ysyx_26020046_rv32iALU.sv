module ysyx_26020046_rv32iALU(oR1,oR2,pc,imm,data,addr,iRd,enBfun,opIcod,opRcod,opCode,opBfun,opLfun,opCsrr,oCsr,iCsr,enCsr);

	parameter DATA_WIDTH= 32;

	typedef logic [DATA_WIDTH-1:0] word_t;

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
		logic Csrrw,Csrrs;
	} opCsrr_t;

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