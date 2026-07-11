`include "ysyx_26020046_config.svh"
module ysyx_26020046_CSR(
	input  LsSr_t nLsSr,
	input  valSr_t vLsSr,
	output SrLs_t  iSrLs,
	input  clock,reset
	);

	LsSr_t oLsSr;

	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

	always_comb oLsSr=nLsSr; 

	assign iSrLs.ready=1;
	always_ff@(posedge clock) begin:csr_write
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
				// if(mcycle>='d20)$stop;//特殊调试，用于观测死循环
	`ifdef RV32I_DEBUG
			$fdisplay(logFile,"nRgCt:%s",sLsSr(nLsSr));$fdisplay(logFile,"iCtRg:%s",sSrLs(iSrLs));$fdisplay(logFile,"vRgCt:%s",sValSr(vLsSr));
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
			$fstrobe(logFile,"mcycle = %d\n",mcycle);
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
