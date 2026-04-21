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

module ysyx_26020046_rv32iCSR(
	input  LsSr_t nLsSr,
	input  valSr_t vLsSr,
	output SrLs_t  iSrLs,
	input  clk,reset
	);

	LsSr_t oLsSr;

	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

	always_comb oLsSr=nLsSr; 

	assign iSrLs.ready=1;
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
		end else begin
	`ifdef RV32I_DEBUG
			if(~reset)begin
				$fstrobe(logFile,"mcycle = %d\n",mcycle);
				if(mcycle>='d10000000)$stop;//特殊调试，用于观测死循环
				if(oLsSr.SRop==ECALL)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,oLsSr.iCsr,mcause,11);
				else if(oLsSr.SRop==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,oLsSr.iCsr,mcause,0);
				else if(oLsSr.SRop==WCCSR)begin unique case(oLsSr.SRaddr)
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				oLsSr.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		oLsSr.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			oLsSr.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			oLsSr.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			oLsSr.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		oLsSr.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		oLsSr.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	oLsSr.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",oLsSr.SRaddr); end
				endcase end
			end
	`endif
			{mcycleh,mcycle}<={mcycleh,mcycle}+1;
			if(oLsSr.valid) begin unique case(oLsSr.SRop)
				ECALL:begin mepc<=oLsSr.iCsr;mcause<=11;end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;end
				WCCSR:begin unique case(oLsSr.SRaddr)
					CSR_ADDR_MEPC		:mepc		<=oLsSr.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=oLsSr.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=oLsSr.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=oLsSr.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=oLsSr.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=oLsSr.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=oLsSr.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=oLsSr.iCsr;
					default:begin `ifndef RV32I_STA $fatal("unknown csrAddr==0x%x",oLsSr.SRaddr);`endif end
					endcase end
				NCSR_:;
				default:begin `ifndef RV32I_STA $fatal("unknown op.SRop==0x%x",oLsSr.SRop);`endif end
			endcase end
			end
		end

	always_comb begin:choose_csr
		unique case(vLsSr.SRaddr)
			CSR_ADDR_MEPC		:iSrLs.oCsr=mepc;
			CSR_ADDR_MSTAUS		:iSrLs.oCsr=mstatus;
			CSR_ADDR_MTVEC		:iSrLs.oCsr=mtvec;
			CSR_ADDR_MCAUSE		:iSrLs.oCsr=mcause;
			CSR_ADDR_MCYCLE		:iSrLs.oCsr=mcycle;
			CSR_ADDR_MCYCLEH	:iSrLs.oCsr=mcycleh;
			CSR_ADDR_MARCHID	:iSrLs.oCsr=marchid;
			CSR_ADDR_MVENDORID	:iSrLs.oCsr=mvendorid;
			default				:iSrLs.oCsr='0;
		endcase
	end
	endmodule
