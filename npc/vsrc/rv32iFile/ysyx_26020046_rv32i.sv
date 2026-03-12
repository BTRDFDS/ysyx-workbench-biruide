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

	parameter OP_SCR_ECALL_	= 32'h00000073;
	parameter OP_SCR_EBREAK	= 32'h00100073;
	parameter OP_SCR_MRET__	= 32'h30200073;

	parameter OP_SCR_	= 7'b1110011;//CSR系列
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
	typedef enum logic[2:0] {R1I,PCI,ECL,ERE,NAD} ALUopADR_t;
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
	// typedef struct packed {
	// 	// logic I,U,S,B,J;
	// 	imCode_t m;
	// 	word_t mr;
	// }opImmr_t;
endpackage

module ysyx_26020046_rv32i(clk,reset,code,pc);
	import rv32iBasis::*;
	input logic clk,reset;
	// input word_t code;
	input code_t code;
	output word_t pc;

	word_t oR1,oR2,data,addr,iRd,iCsr,oCsr;
	reg_t cRd,cR1,cR2;
	op_t op;
	logic enJfun;

	ysyx_26020046_rv32iIDC IDC(.*);
	ysyx_26020046_rv32iALU ALU(.*);
	ysyx_26020046_rv32iLSU LSU(.*);
	ysyx_26020046_rv32iGPR GPR(.*);
	ysyx_26020046_rv32iCSR CSR(.*);

`ifdef RV32I_DEBUG
	always @(posedge clk) begin
		$display("pc=%x code=%x reset=%x cR1=%x cR2=%x cRd=%x",pc,code,reset,cR1,cR2,cRd);
		$display("oR1=0x%x oR2=0x%x data=0x%x addr=0x%x iRd=0x%x",oR1,oR2,data,addr,iRd);
		$display("cRd=0x%x cR1=0x%x cR2=0x%x",cRd,cR1,cR2);
		$display("ALU:cal=%x bfu=%x adr=%x cho=%x csr=%x in1=%x in2=%x im=%x",op.ALU.cal,op.ALU.bfu,op.ALU.adr,op.ALU.cho,op.ALU.csr,op.ALU.in1,op.ALU.in2,op.ALU.im);
		$display("LSU:op=%x enS=%x enL=%x",op.LSU.op,op.LSU.enS,op.LSU.enL);
		$display("CSR:op=%x addr=%x",op.CSR.op,op.CSR.addr);
		$display("enJfun=%x",enJfun);
	end
`endif
	`ifdef RV32I_DEBUG
	`endif



endmodule

module ysyx_26020046_rv32iIDC(code,reset,cRd,cR1,cR2,op);
	import rv32iBasis::*;
	import "DPI-C" function void stop(input bit eb);
	input code_t code;
	input logic reset;
	// output logic enJfun;
	// output word_t im;
	output reg_t cRd,cR1,cR2;
	output op_t op;
	imCode_t imm;
	// logic error;
	
	always_comb begin : ID
		imm=N;
		op.ALU.in1=IR1;op.ALU.in2=IR2;
		op.ALU.adr=NAD;op.ALU.cal=NCAL;op.ALU.bfu=NBFU;
		op.ALU.csr=NCCSR;op.ALU.cho=NCHO;
		op.LSU.op=NM;op.LSU.enS=0;op.LSU.enL=0;
		op.CSR.op=NCSR_;op.CSR.addr='0;
		{cR1,cR2,cRd,op.ALU.enJcod,op.ALU.im}='0;


	`ifdef RV32I_DEBUG
		$display("#ID:code=%x code.fun7=%x code.r2=%x code.r1=%x code.fun3=%x code.rd=%x code.op=%x",code,code.fun7,code.r2,code.r1,code.fun3,code.rd,code.op);
	`endif

		if(~reset) begin
			unique case(code.op)
				OP_U_I:begin op.ALU.cho=IMM_;imm=U; end//lui
				OP_U_P:begin op.ALU.cal=ADD_;op.ALU.in1=PC_;op.ALU.in2=IMM;imm=U; op.ALU.cho=CAL_; end//auipc
				OP_J__:begin op.ALU.adr=PCI;imm=J; op.ALU.cho=SNPC;op.ALU.enJcod=1; end//jal
				OP_I_J:begin op.ALU.adr=R1I;imm=I; op.ALU.cho=SNPC;op.ALU.enJcod=1;cR1=code.r1; end//jalr
				OP_B__:begin op.ALU.adr=PCI;imm=B; op.ALU.bfu=ALUopBfu_t'(code.fun3);cR1=code.r1;cR2=code.r2; end//B系列判断指令
				OP_I_L:begin op.ALU.adr=R1I;imm=I; op.ALU.cho=DATA;cR1=code.r1; op.LSU.enL=1;op.LSU.op=LSUop_t'(code.fun3); end//l读取系列
				OP_S__:begin op.ALU.adr=R1I;imm=S;cR1=code.r1;cR2=code.r2; op.LSU.enS=1;op.LSU.op=LSUop_t'(code.fun3); end//s写入系列
				OP_I_A:begin op.ALU.cho=CAL_;imm=I;op.ALU.in1=IR1;op.ALU.in2=IMM;cR1=code.r1; //立即数计算
					unique case(code.fun3)
						3'b001:begin unique case(code.fun7)
								7'b0000000:op.ALU.cal=SLL_;
								default:begin $fatal("slli fun7(%x)!=0",code.fun7);stop(0);end
							endcase end
						3'b101:begin unique case(code.fun7)
								7'b0000000:op.ALU.cal=SRL_;
								7'b0100000:op.ALU.cal=SRA_;
								default:begin $fatal("srai/srli fun7(%x)!=0/20",code.fun7);stop(0);end
							endcase end
						default:op.ALU.cal=ALUopCal_t'(code.fun3);
					endcase
					end
				OP_R__:begin op.ALU.cho=CAL_;op.ALU.in1=IR1;op.ALU.in2=IR2;cR1=code.r1;cR2=code.r2;//寄存器计算
					unique case(code.fun7)
						7'b0000000:op.ALU.cal=ALUopCal_t'(code.fun3);
						7'b0100000:begin unique case(code.fun3)
								3'b000:op.ALU.cal=SUB_;
								3'b101:op.ALU.cal=SRA_;
								default:begin $fatal("R fun7==20 fun3(%x)!=1/5",code.fun3);stop(0);end
							endcase end
						default:begin $fatal("R fun7(%x)!=0/20",code.fun7);stop(0);end
					endcase
					end
				OP_SCR_:begin//CSR指令
					unique case(code.fun3)
						3'b000:begin unique case(code)
								OP_SCR_MRET__:begin op.CSR.op=MRET_;op.ALU.adr=ECL;op.ALU.enJcod=1;op.CSR.addr=CSR_ADDR_MEPC;	end
								OP_SCR_ECALL_:begin op.CSR.op=ECALL;op.ALU.adr=ECL;op.ALU.enJcod=1;op.CSR.addr=CSR_ADDR_MTVEC;	end
								OP_SCR_EBREAK:stop(1);
								default:begin $fatal("ECL unknown op==0x%x",code);stop(0);end
							endcase end
						3'b001:begin op.CSR.addr={code[31:20]};cR1=code.r1;op.CSR.op=WCCSR;
							op.ALU.cho=CCSR;op.ALU.csr=WACSR; end
						3'b010:begin op.CSR.addr={code[31:20]};cR1=code.r1;op.ALU.cho=CCSR;
							op.ALU.csr=(code.r1=='0)?NCCSR:RACSR;
							op.CSR.op =(code.r1=='0)?NCSR_:WCCSR;
							end
						default:begin $fatal("ECL unknown fun3==0x%x",code.fun3);stop(0);end
					endcase
				end
				default:begin $fatal("unknown op==0x%x",code.op);stop(0);end
			endcase
			unique case(imm)
				N:op.ALU.im='0;
				I:op.ALU.im={{20{code[31]}},code[31:20] };
				S:op.ALU.im={{20{code[31]}},code[31:25], code[11:7] };
				B:op.ALU.im={{20{code[31]}},code[7], code[30:25], code[11:8], 1'b0 };
				J:op.ALU.im={{12{code[31]}},code[19:12], code[20], code[30:21], 1'b0 };
				U:op.ALU.im={code[31:12],12'b0 };
				default:begin op.ALU.im='0;$fatal("unknown imm==0x%x",imm);stop(0);end
			endcase
			cRd=(op.ALU.cho	==NCHO)	?'0:code.rd;
		end
	end
endmodule
module ysyx_26020046_rv32iALU(oR1,oR2,pc,data,addr,iRd,enJfun,op,oCsr,iCsr);
	import rv32iBasis::*;
	//
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
			default:begin in1='0;$fatal("unknown in1==0x%x",op.ALU.in1);end
		endcase
		unique case(op.ALU.in2)
			IR2:in2=oR2;
			IMM:in2=op.ALU.im;
			default:begin in2='0;$fatal("unknown in2==0x%x",op.ALU.in2);end
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
			default:begin result='0;$fatal("unknown cal==0x%x",op.ALU.cal);end
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
			default:begin enBfun='0;$fatal("unknown bfu==0x%x",op.ALU.bfu);end
			endcase
	end
	always_comb begin : adr
		unique case(op.ALU.adr)
			R1I:addr=oR1+op.ALU.im;
			PCI:addr=pc+op.ALU.im;
			ECL:addr=oCsr;
			ERE:addr=oCsr+4;
			NAD:addr='0;
			default:begin addr='0;$fatal("unknown adr==0x%x",op.ALU.adr);end
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
			default:begin iRd='0;$fatal("unknown cho==0x%x",op.ALU.cho);end
		endcase
	end
	always_comb begin : csr
		unique case(op.ALU.csr)
			WACSR:iCsr=oR1;
			RACSR:iCsr=oR1|oCsr;
			JUMP_:iCsr=pc;
			NCSR_:iCsr='0;
			default:begin iCsr='0;$fatal("unknown csr==0x%x",op.ALU.csr);end
		endcase
	end
endmodule
module ysyx_26020046_rv32iLSU(clk,reset,addr,oR2,enJfun,op,data,pc);

	import rv32iBasis::*;
	input word_t addr,oR2;
	input logic clk,reset,enJfun;

/* verilator lint_off UNUSEDSIGNAL */
	input op_t op;
/* verilator lint_on UNUSEDSIGNAL */


	output word_t data,pc;
	// output logic LSUsuccess;

	logic[3:0] mask;
	word_t iRAM;
//s处理
	always_comb begin : choose_mask
		if (op.LSU.enS) begin unique case(op.LSU.op)
			B_:mask=4'b0001;
			H_:mask=4'b0011;
			W_:mask=4'b1111;
			NM:mask=4'b0000;
			default:begin mask=4'b0000;$fatal("unknown mask==0x%x",op.LSU.op);end
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
			default:begin data=0;$fatal("unknown date==0x%x",op.LSU.op);end
		endcase end else data='0;
	end

	always_ff @(posedge clk) begin : pc_write
`ifdef RV32I_DEBUG
		$display("pc=%x addr=%x enj=%x",pc,addr,enJfun);
`endif
		if(reset) pc<=PC_RESET;
		else if(enJfun) pc<=addr;
		else pc<=pc+4;
	end

	import "DPI-C" function int pmem_read(input int addr);
	import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);
	assign iRAM = (op.LSU.enL)&clk?pmem_read(addr):0;
	always_ff@(posedge clk) begin:control_write
		if (op.LSU.enS) begin // 有写请求时
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

module ysyx_26020046_rv32iCSR(op,iCsr,oCsr,clk,reset);
	import rv32iBasis::*;

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
					default:begin $display("unknown csrAddr==0x%x",op.CSR.addr); end
					endcase end
				NCSR_:;
				default:begin $display("unknown op.CSR.op==0x%x",op.CSR.op); end
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

	`ifdef RV32I_DEBUG
		$monitor("mepc=%x mstatus=%x mtvec=%x mcause=%x mcycle=%x mcycleh=%x marchid=%x mvendorid=%x",mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid);
	`endif
	end
				
endmodule
