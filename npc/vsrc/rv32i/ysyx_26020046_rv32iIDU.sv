// `define RV32I_DEBUG
	`define RV32I_STA

	parameter REG_NUMBER= 5;
	parameter DATA_WIDTH= 32;
	parameter false = 0;
	parameter true = 1;

	parameter OP_I_J	= 7'b1100111;//jalr
	parameter OP_I_A	= 7'b0010011;//i运算
	parameter OP_I_L	= 7'b0000011;//l系列
	parameter OP_U_I	= 7'b0110111;//lui
	parameter OP_U_P	= 7'b0010111;//auipc
	parameter OP_S__	= 7'b0100011;//s系列
	parameter OP_B__	= 7'b1100011;//b比较系列
	parameter OP_J__	= 7'b1101111;//jal
	parameter OP_R__ 	= 7'b0110011;//r运算
	parameter OP_CSR	= 7'b1110011;//CSR系列

	parameter OP_CSR_ECALL_	= 32'h00000073;
	parameter OP_CSR_EBREAK	= 32'h00100073;
	parameter OP_CSR_MRET__	= 32'h30200073;

	parameter CSR_ADDR_MSTAUS	= 12'h300;
	parameter CSR_ADDR_MTVEC	= 12'h305;
	parameter CSR_ADDR_MEPC		= 12'h341;
	parameter CSR_ADDR_MCAUSE	= 12'h342;
	parameter CSR_ADDR_MCYCLE	= 12'hb00;
	parameter CSR_ADDR_MCYCLEH	= 12'hb80;
	parameter CSR_ADDR_MVENDORID= 12'hf11;
	parameter CSR_ADDR_MARCHID	= 12'hf12;

	parameter PC_RESET	= 32'h80000000;
	parameter MSTATUS_RESET = 32'h1800;

	typedef logic [DATA_WIDTH-1:0] word_t;
	typedef logic [REG_NUMBER-1:0] reg_t;
	typedef logic [11:0] SRaddr_t;
	typedef logic [3:0] mask_t;

	typedef enum logic[3:0] {ADD_,SLL_,SLT_,SLTU,XOR_,SRL_,OR__,AND_,SUB_,SRA_,NCAL} ALUopCal_t;
	typedef enum logic[2:0] {BEQ_,BNE_,NBFU,BLT_='b100,BGE_,BLTU='b110,BGEU} ALUopBfu_t;
	typedef enum logic[1:0] {WACSR,RACSR,JUMP_,NACSR} ALUopCsr_t;
	typedef enum logic[2:0] {R1I,PCI,ECJ,ERE,NAD} ALUopADR_t;
	typedef enum logic[2:0] {NCHO,CAL_,IMM_,SNPC,CCSR} ALUopCho_t;
	typedef enum logic[0:0] {IR1,PC_} in1_t;
	typedef enum logic[0:0] {IR2,IMM} in2_t;
	typedef enum logic[2:0] {B_,H_,W_,NM,BU,HU} LSUop_t;
	typedef enum logic [1:0] {MRET_,ECALL,WCCSR,NCSR_} CSRop_t;

	typedef struct packed {
		logic [6:0] fun7;
		logic [4:0] r2;
		logic [4:0] r1;
		logic [2:0] fun3;
		logic [4:0] rd;
		logic [6:0] op;
	} code_t;

	typedef enum logic [1:0]{IFUback,IFUcall,IFUfunc} IFUstatus_t;
	typedef enum logic [1:0]{LSUback,LSUcall,LSUidle,LSUsuce} LSUstatus_t;
	typedef enum logic [1:0]{MEMidle,MEMfunc,MEMback,MEMwait} MEMstatus_t;
	typedef enum logic [1:0]{ARBidle,ARBifuR,ARBlsuR,ARBlsuW} ARBstatus_t;

	typedef enum logic [1:0]{OKAY,EXOKAY,SLVERR,DECERR} resp_t;//TODO 目前是只有OKAY有用
	`ifdef RV32I_DEBUG integer logFile;`endif
	`ifndef RV32I_STA
	import "DPI-C" function void stop(input bit eb);
	import "DPI-C" function int pmem_read(input int unsigned addr);
	import "DPI-C" function void pmem_write(input int unsigned addr, input int unsigned data, input byte mask);
	`endif

	typedef struct packed {logic valid;code_t code;word_t pc;} IfId_t;
	typedef struct packed {
		logic valid;

		in1_t		in1;
		in2_t		in2;
		logic 		enJcod;
		ALUopCal_t 	cal;
		ALUopBfu_t	bfu;
		ALUopADR_t	adr;
		ALUopCsr_t	cCsr;
		ALUopCho_t	cIrd;

		logic enS,enL;
		LSUop_t LSop;

		reg_t cRd;
		
		SRaddr_t SRaddr;
		CSRop_t SRop;

		word_t imm,pc;
	} IdAl_t;
	typedef struct packed {reg_t cR1,cR2;SRaddr_t SRaddr;}																		valcl_t;typedef struct packed {word_t addr;logic enJfun,ready;}																		upBk_t;
	typedef struct packed {logic valid,enS,enL;word_t addr,res,iCsr,oR2;LSUop_t LSop;SRaddr_t SRaddr;CSRop_t SRop;reg_t cRd;}	AlLs_t;
	typedef struct packed {logic ready;word_t oR1,oR2;word_t oCsr;}																LsAl_t;
	typedef struct packed {word_t iRd;reg_t cRd;logic valid;}																	LsRg_t;
	typedef struct packed {word_t iCsr;SRaddr_t SRaddr;CSRop_t SRop;logic valid;}												LsSr_t;
	typedef struct packed {logic ready;word_t oCsr;}																			SrLs_t;
	typedef struct packed {logic ready;word_t oR1,oR2;}																			RgLs_t;
	typedef struct packed {reg_t cR1,cR2;}																						valRg_t;
	typedef struct packed {SRaddr_t SRaddr;}																					valSr_t;
	interface AXI4_Lite_t();
		logic arready,arvalid;word_t araddr;
		logic rready,rvalid;word_t rdata;resp_t rresp;
		logic awready,awvalid;word_t awaddr;
		logic wvalid,wready;mask_t wstrb;word_t wdata;
		logic bvalid,bready;resp_t bresp;
		modport CPU(input  arready,rdata,rresp,rvalid,awready,wready,bresp,bvalid,output araddr,arvalid,rready,awaddr,awvalid,wdata,wstrb,wvalid,bready);
		modport MEM(output arready,rdata,rresp,rvalid,awready,wready,bresp,bvalid,input  araddr,arvalid,rready,awaddr,awvalid,wdata,wstrb,wvalid,bready);
		endinterface
	typedef struct packed {logic arvalid,rready;word_t araddr;}AXI4rCal_t;
	typedef struct packed {logic awvalid,wvalid,bready;word_t awaddr,wdata;mask_t wstrb;}AXI4wCal_t;
	typedef struct packed {logic arready;word_t rdata;resp_t rresp;logic rvalid;}AXI4rBak_t;
	typedef struct packed {logic awready,wready,bvalid;resp_t bresp;}AXI4wBak_t;
module ysyx_26020046_rv32iIDU(
	input  IfId_t  nIfId,
	output upBk_t  iIdIf,
	output valcl_t vIdAl,
	output IdAl_t  nIdAl,
	input  upBk_t  iAlId
	);
	IfId_t oIfId;

	always_comb oIfId=nIfId;

	always_comb begin
		nIdAl.valid	=oIfId.valid;
		nIdAl.pc	=oIfId.pc;
		iIdIf.addr	=iAlId.addr;
		iIdIf.enJfun=iAlId.enJfun;
		iIdIf.ready	=iAlId.ready;
	end
	always_comb begin : ID
		nIdAl.in1=IR1;nIdAl.in2=IR2;
		nIdAl.adr=NAD;nIdAl.cal=NCAL;nIdAl.bfu=NBFU;
		nIdAl.cCsr=NACSR;nIdAl.cIrd=NCHO;
		nIdAl.LSop=NM;nIdAl.enS=0;nIdAl.enL=0;
		nIdAl.SRop=NCSR_;nIdAl.SRaddr='0;
		{vIdAl.cR1,vIdAl.cR2,nIdAl.cRd,nIdAl.enJcod,nIdAl.imm}='0;
		vIdAl.SRaddr='0;

		if(oIfId.valid) begin
			`ifdef RV32I_DEBUG $fdisplay(logFile,"IDU:op=%x fun3=%x fun7=%x r1=%x r2=%x rd=%x",oIfId.code.op,oIfId.code.fun3,oIfId.code.fun7,oIfId.code.r1,oIfId.code.r2,oIfId.code.rd);`endif
			unique case(oIfId.code.op)
				OP_U_I	:nIdAl.imm={oIfId.code[31:12],12'b0 };
				OP_U_P	:nIdAl.imm={oIfId.code[31:12],12'b0 };
				OP_S__	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:25],oIfId.code[11:7] };
				OP_I_A	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
				OP_I_J	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
				OP_I_L	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
				OP_B__	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[7],oIfId.code[30:25],oIfId.code[11:8], 1'b0 };
				OP_J__	:nIdAl.imm={{12{oIfId.code[31]}},oIfId.code[19:12],oIfId.code[20],oIfId.code[30:21], 1'b0 };
				default	:nIdAl.imm='0;
			endcase
			unique case(oIfId.code.op)
				OP_U_P	:nIdAl.in1=PC_;
				default	:nIdAl.in1=IR1;
			endcase
			unique case(oIfId.code.op)
				OP_U_P	:nIdAl.in2=IMM;
				OP_I_A	:nIdAl.in2=IMM;
				default	:nIdAl.in2=IR2;
			endcase
			unique case(oIfId.code.op)
				OP_J__	:nIdAl.enJcod=1;
				OP_I_J	:nIdAl.enJcod=1;
				OP_CSR	:nIdAl.enJcod=(oIfId.code.fun3==3'b000);
				default	:nIdAl.enJcod=0;
			endcase

			unique case(oIfId.code.op)//选ALU cal
				OP_U_P	:nIdAl.cal=ADD_;
				OP_I_A	:begin unique case(oIfId.code.fun3)
						3'b001:begin unique case(oIfId.code.fun7)
								7'b0000000:nIdAl.cal=SLL_;
								default:begin `ifndef RV32I_STA $fatal("slli fun7(%x)!=0",oIfId.code.fun7);stop(0);`endif end
							endcase end
						3'b101:begin unique case(oIfId.code.fun7)
								7'b0000000:nIdAl.cal=SRL_;
								7'b0100000:nIdAl.cal=SRA_;
								default:begin `ifndef RV32I_STA $fatal("srai/srli fun7(%x)!=0/20",oIfId.code.fun7);stop(0);`endif end
							endcase end
						default:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
					endcase end
				OP_R__	:begin unique case(oIfId.code.fun7)
						7'b0000000:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
						7'b0100000:begin unique case(oIfId.code.fun3)
								3'b000:nIdAl.cal=SUB_;
								3'b101:nIdAl.cal=SRA_;
								default:begin `ifndef RV32I_STA $fatal("R fun7==20 fun3(%x)!=1/5",oIfId.code.fun3);stop(0);`endif end
							endcase end
						default:begin `ifndef RV32I_STA $fatal("R fun7(%x)!=0/20",oIfId.code.fun7);stop(0);`endif end
					endcase end
				default	:nIdAl.cal=NCAL;
			endcase

			if(oIfId.code.op==OP_B__)begin//b系列
				nIdAl.bfu=ALUopBfu_t'(oIfId.code.fun3);
			end else nIdAl.bfu=NBFU;

			unique case(oIfId.code.op)//选ALU cho
				OP_U_I	:nIdAl.cIrd=IMM_;
				OP_U_P	:nIdAl.cIrd=CAL_;
				OP_J__	:nIdAl.cIrd=SNPC;
				OP_I_J	:nIdAl.cIrd=SNPC;
				OP_I_A	:nIdAl.cIrd=CAL_;
				OP_R__	:nIdAl.cIrd=CAL_;
				OP_CSR	:nIdAl.cIrd=CCSR;
				default	:nIdAl.cIrd=NCHO;
			endcase
			unique case(oIfId.code.op)//选ALU addr
				OP_J__	:nIdAl.adr=PCI;
				OP_I_J	:nIdAl.adr=R1I;
				OP_I_L	:nIdAl.adr=R1I;
				OP_CSR	:nIdAl.adr=ECJ;
				OP_B__	:nIdAl.adr=PCI;
				OP_S__	:nIdAl.adr=R1I;
				default	:nIdAl.adr=NAD;
			endcase

			unique case(oIfId.code.op)//选LSU op
				OP_I_L	:nIdAl.LSop=LSUop_t'(oIfId.code.fun3);
				OP_S__	:nIdAl.LSop=LSUop_t'(oIfId.code.fun3);
				default	:nIdAl.LSop=NM;
			endcase
			nIdAl.enL=(oIfId.code.op==OP_I_L);
			nIdAl.enS=(oIfId.code.op==OP_S__);

			if(oIfId.code.op==OP_CSR)begin unique case(oIfId.code.fun3)
				3'b000	:nIdAl.cCsr=JUMP_;
				3'b001	:nIdAl.cCsr=WACSR;						
				3'b010	:nIdAl.cCsr=(oIfId.code.r1=='0)?NACSR:RACSR;
				default	:nIdAl.cCsr=NACSR;						
			endcase  unique case(oIfId.code.fun3)
				3'b000	:begin unique case(oIfId.code)
						OP_CSR_MRET__	:begin nIdAl.SRaddr=CSR_ADDR_MEPC;		end
						OP_CSR_ECALL_	:begin nIdAl.SRaddr=CSR_ADDR_MTVEC;	end
						OP_CSR_EBREAK	:begin nIdAl.SRaddr='0;`ifndef RV32I_STA stop(1);`endif end
						default			:begin nIdAl.SRaddr='0;`ifndef RV32I_STA stop(0);`endif end endcase end
				3'b001					:begin nIdAl.SRaddr={oIfId.code[31:20]};end
				3'b010					:begin nIdAl.SRaddr={oIfId.code[31:20]};end
				default					:begin nIdAl.SRaddr='0;				end
			endcase  unique case(oIfId.code.fun3)
				3'b000	:begin unique case(oIfId.code)
						OP_CSR_MRET__	:nIdAl.SRop=MRET_;
						OP_CSR_ECALL_	:nIdAl.SRop=ECALL;
						OP_CSR_EBREAK	:nIdAl.SRop=NCSR_;
						default			:nIdAl.SRop=NCSR_;endcase end
				3'b001					:nIdAl.SRop=WCCSR;
				3'b010					:nIdAl.SRop=(oIfId.code.r1=='0)?NCSR_:WCCSR;
				default					:nIdAl.SRop=NCSR_;
			endcase end else begin nIdAl.cCsr=NACSR;nIdAl.SRaddr='0;nIdAl.SRop=NCSR_;end
			vIdAl.SRaddr=nIdAl.SRaddr;

			unique case(oIfId.code.op)//选cR1 这里7/10就反选
				OP_U_I	:vIdAl.cR1='0;
				OP_U_P	:vIdAl.cR1='0;
				OP_J__	:vIdAl.cR1='0;
				default	:vIdAl.cR1=oIfId.code.r1;
			endcase
			// $fdisplay(logFile,"cR1=%x opR1=%b code=%b",val.cR1,oIfId.code.r1,oIfId.code);
			unique case(oIfId.code.op)//选cR2
				OP_S__	:vIdAl.cR2=oIfId.code.r2;
				OP_R__	:vIdAl.cR2=oIfId.code.r2;
				OP_B__	:vIdAl.cR2=oIfId.code.r2;
				default	:vIdAl.cR2='0;
			endcase
			unique case(oIfId.code.op)//选cRd 也是反选
				OP_B__	:nIdAl.cRd='0;
				OP_S__	:nIdAl.cRd='0;
				OP_CSR	:nIdAl.cRd=(oIfId.code.fun3==3'b000)?'0:oIfId.code.rd;
				default	:nIdAl.cRd=oIfId.code.rd;
			endcase
		end
	end
	endmodule
