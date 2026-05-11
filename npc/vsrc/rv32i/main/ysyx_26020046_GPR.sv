`include "ysyx_26020046_config.svh"
module ysyx_26020046_GPR(
	input  LsRg_t nLsRg,
	input  valRg_t vLsRg,
	output RgLs_t iRgLs,
	`ifdef RV32I_DEBUG input logic reset,`endif
	input  clock
	);

	LsRg_t oLsRg;
	word_t gpr [2**REG_NUMBER -1:1];

	always_comb begin
		oLsRg=nLsRg;
		iRgLs.ready=1;
		iRgLs.oR1=(vLsRg.cR1==0)?'0:gpr[vLsRg.cR1];
		iRgLs.oR2=(vLsRg.cR2==0)?'0:gpr[vLsRg.cR2];
	end always_ff@(posedge clock)begin
		`ifdef RV32I_DEBUG if(~reset)begin
			if(oLsRg.cRd!=0)$fdisplay(logFile,"RG:[%d]%x <= %x",oLsRg.cRd,gpr[oLsRg.cRd],oLsRg.iRd);
			$fdisplay(logFile,"nLsRg:%s",sLsRg(nLsRg));
			$fdisplay(logFile,"vLsRg:%s",sValRg(vLsRg));
			$fdisplay(logFile,"iRgLs:%s",sRgLs(iRgLs));
			end`endif
		if(oLsRg.valid)if (oLsRg.cRd!=0) gpr[oLsRg.cRd] <= oLsRg.iRd;
		end
	endmodule
