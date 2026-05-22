`include "ysyx_26020046_config.svh"
module ysyx_26020046_REG(
	input  LsRg_t nLsRg,
	input  valcl_t vLsRg,
	output RgLs_t iRgLs,
	input  logic clock,reset
	);

	LsRg_t oLsRg;
	word_t gpr [2**REG_NUMBER -1:1];
	word_t mepc,mstatus,mtvec,mcause,mcycle,mcycleh,marchid,mvendorid;

	always_comb begin
		oLsRg=nLsRg;
		iRgLs.ready=1;
		iRgLs.oR1=(vLsRg.cR1==0)?'0:gpr[vLsRg.cR1];
		iRgLs.oR2=(vLsRg.cR2==0)?'0:gpr[vLsRg.cR2];
	end always_ff@(posedge clock)begin
		`ifdef RV32I_DEBUG if(~reset)begin
			if(oLsRg.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",oLsRg.cRd,gpr[oLsRg.cRd],oLsRg.iRd);
			$fdisplay(logFile,"nLsRg:%s",sLsRg(nLsRg));
			// $fdisplay(logFile,"vLsRg:%s",sValRg(vLsRg));
			$fdisplay(logFile,"iRgLs:%s",sRgLs(iRgLs));
			end`endif
		if(oLsRg.valid&oLsRg.SRop!=ERROR)if (oLsRg.cRd!=0) gpr[oLsRg.cRd] <= oLsRg.iRd;
		end

	assign iRgLs.ready=1;
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
				if(mcycle>='d20000)$stop;//特殊调试，用于观测死循环
	`ifdef RV32I_DEBUG
			// $fdisplay(logFile,"nRgCt:%s",sLsSr(nLsRg));$fdisplay(logFile,"iCtRg:%s",sSrLs(iRgLs));$fdisplay(logFile,"vRgCt:%s",sValSr(vLsRg));
				if(mcycle>='d10000000)$stop;//特殊调试，用于观测死循环
				if(oLsRg.SRop==ERROR)$fdisplay(logFile,"SR:ecall mepc %x<=%x mcause %x<=%x",mepc,oLsRg.iCsr,mcause,11);
				else if(oLsRg.SRop==MRET_)$fdisplay(logFile,"SR:mret mstatus %x<=%x mcause %x<=%x",mstatus,oLsRg.iCsr,mcause,0);
				else if(oLsRg.SRop==WCCSR)begin unique case(oLsRg.SRmesg[11:0])
					CSR_ADDR_MEPC		:$fdisplay(logFile,"SR:mepc %x<=%x", mepc,				oLsRg.iCsr);
					CSR_ADDR_MSTAUS		:$fdisplay(logFile,"SR:mstatus %x<=%x", mstatus,		oLsRg.iCsr);
					CSR_ADDR_MTVEC		:$fdisplay(logFile,"SR:mtvec %x<=%x", mtvec,			oLsRg.iCsr);
					CSR_ADDR_MCAUSE		:$fdisplay(logFile,"SR:mcause %x<=%x", mcause,			oLsRg.iCsr);
					CSR_ADDR_MCYCLE		:$fdisplay(logFile,"SR:mcycle %x<=%x", mcycle,			oLsRg.iCsr);
					CSR_ADDR_MCYCLEH	:$fdisplay(logFile,"SR:mcycleh %x<=%x", mcycleh,		oLsRg.iCsr);
					CSR_ADDR_MARCHID	:$fdisplay(logFile,"SR:marchid %x<=%x", marchid,		oLsRg.iCsr);
					CSR_ADDR_MVENDORID	:$fdisplay(logFile,"SR:mvendorid %x<=%x", mvendorid,	oLsRg.iCsr);
					default:begin $fatal("unknown csrAddr==0x%x",oLsRg.SRmesg[11:0]); end
				endcase end
			$fstrobe(logFile,"mcycle = %d\n",mcycle);
	`endif
			{mcycleh,mcycle}<={mcycleh,mcycle}+1;
			if(oLsRg.valid) begin unique case(oLsRg.SRop)
				ERROR:begin mepc<=oLsRg.iCsr;mcause<=oLsRg.SRmesg;stop(1);end
				MRET_:begin mstatus<=MSTATUS_RESET;mcause<='0;end
				WCCSR:begin unique case(oLsRg.SRmesg[11:0])
					CSR_ADDR_MEPC		:mepc		<=oLsRg.iCsr;
					CSR_ADDR_MSTAUS		:mstatus	<=oLsRg.iCsr;
					CSR_ADDR_MTVEC		:mtvec		<=oLsRg.iCsr;
					CSR_ADDR_MCAUSE		:mcause		<=oLsRg.iCsr;
					CSR_ADDR_MCYCLE		:mcycle		<=oLsRg.iCsr;
					CSR_ADDR_MCYCLEH	:mcycleh	<=oLsRg.iCsr;
					CSR_ADDR_MARCHID	:marchid	<=oLsRg.iCsr;
					CSR_ADDR_MVENDORID	:mvendorid	<=oLsRg.iCsr;
					default:begin `ifndef RV32I_STA $fatal("unknown csrAddr==0x%x",oLsRg.SRmesg[11:0]);`endif end
					endcase end
				NCSR_:;
				default:begin `ifndef RV32I_STA $fatal("unknown op.SRop==0x%x",oLsRg.SRop);`endif end
			endcase end
			end
		end

	always_comb begin:choose_csr
		unique case(vLsRg.SRaddr)
			CSR_ADDR_MEPC		:iRgLs.oCsr=mepc;
			CSR_ADDR_MSTAUS		:iRgLs.oCsr=mstatus;
			CSR_ADDR_MTVEC		:iRgLs.oCsr=mtvec;
			CSR_ADDR_MCAUSE		:iRgLs.oCsr=mcause;
			CSR_ADDR_MCYCLE		:iRgLs.oCsr=mcycle;
			CSR_ADDR_MCYCLEH	:iRgLs.oCsr=mcycleh;
			CSR_ADDR_MARCHID	:iRgLs.oCsr=marchid;
			CSR_ADDR_MVENDORID	:iRgLs.oCsr=mvendorid;
			default				:iRgLs.oCsr='0;
		endcase
	end
	endmodule
