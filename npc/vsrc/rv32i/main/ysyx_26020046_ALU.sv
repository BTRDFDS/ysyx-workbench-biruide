`include "ysyx_26020046_config.svh"
module ysyx_26020046_ALU(
	input  IdAl_t nIdAl,
	output upBk_t iAlId,
	output AlLs_t nAlLs,
	input  valcl_t vIdAl,
	output valcl_t vAlLs,
	input  LsAl_t iLsAl
	);
	logic enBfun;
	word_t result,in1,in2;
	IdAl_t oIdAl;

	always_comb oIdAl=nIdAl;

	always_comb vAlLs=vIdAl;

	always_comb begin
		nAlLs.oR2		=iLsAl.oR2;
		nAlLs.enS		=oIdAl.enS;
		nAlLs.enL		=oIdAl.enL;
		nAlLs.LSop		=oIdAl.LSop;
		nAlLs.cRd		=oIdAl.cRd;
		nAlLs.SRaddr	=oIdAl.SRaddr;
		nAlLs.SRop		=oIdAl.SRop;
		nAlLs.valid		=oIdAl.valid;
		iAlId.ready	=iLsAl.ready;
	end

	always_comb begin
		nAlLs.res='0;nAlLs.iCsr='0;nAlLs.addr='0;
		iAlId.enJfun='0;iAlId.addr='0;enBfun=0;
		result='0;in1='0;in2='0;
	 if(oIdAl.valid)begin
			// $fdisplay(logFile,"val cR1=%x cR2=%x oR1=%x oR2=%x SRaddr=%x oCsr=%x pc=%x",val.cR1,val.cR2,val.oR1,val.oR2,val.SRaddr,val.oCsr,val.pc);
		unique case(oIdAl.in1)
			IR1:in1=iLsAl.oR1;
			PC_:in1=oIdAl.pc;
			default:begin in1='0;`ifndef RV32I_STA $fatal("unknown in1==0x%x",oIdAl.in1);`endif end
		endcase
		unique case(oIdAl.in2)
			IR2:in2=iLsAl.oR2;
			IMM:in2=oIdAl.imm;
			default:begin in2='0;`ifndef RV32I_STA $fatal("unknown in2==0x%x",oIdAl.in2);`endif end
		endcase
		unique case(oIdAl.cal)
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
			default:begin result='0;`ifndef RV32I_STA $fatal("unknown cal==0x%x",oIdAl.cal);`endif end
		endcase
		
		unique case(oIdAl.cIrd)
			CAL_:nAlLs.res=result;
			IMM_:nAlLs.res=oIdAl.imm;
			CCSR:nAlLs.res=iLsAl.oCsr;
			SNPC:nAlLs.res=oIdAl.pc+4;
			NCHO:nAlLs.res='0;
			default:begin nAlLs.res='0;`ifndef RV32I_STA $error("unknown cho==0x%x",oIdAl.cIrd);$stop;`endif end
		endcase
		unique case(oIdAl.cCsr)
			WACSR:nAlLs.iCsr=iLsAl.oR1;
			RACSR:nAlLs.iCsr=iLsAl.oR1|iLsAl.oCsr;
			JUMP_:nAlLs.iCsr=oIdAl.pc;
			NCSR_:nAlLs.iCsr='0;
			default:begin nAlLs.iCsr='0;`ifndef RV32I_STA $error("unknown csr==0x%x",oIdAl.cCsr);$stop;`endif end
		endcase
		unique case(oIdAl.bfu)
			BEQ_:enBfun=(iLsAl.oR1==iLsAl.oR2);
			BNE_:enBfun=(iLsAl.oR1!=iLsAl.oR2);
			BLT_:enBfun=(   $signed(iLsAl.oR1) <  $signed(iLsAl.oR2));
			BGE_:enBfun=(   $signed(iLsAl.oR1)>=  $signed(iLsAl.oR2));
			BLTU:enBfun=( $unsigned(iLsAl.oR1) <$unsigned(iLsAl.oR2));
			BGEU:enBfun=( $unsigned(iLsAl.oR1)>=$unsigned(iLsAl.oR2));
			NBFU:enBfun='0;
			default:begin enBfun='0;`ifndef RV32I_STA $fatal("unknown bfu==0x%x",oIdAl.bfu);`endif end
			endcase
		unique case(oIdAl.adr)
			R1I:nAlLs.addr=iLsAl.oR1+oIdAl.imm;
			PCI:nAlLs.addr=oIdAl.pc +oIdAl.imm;
			ECJ:nAlLs.addr=iLsAl.oCsr;
			ERE:nAlLs.addr=iLsAl.oCsr;
			NAD:nAlLs.addr='0;
			default:begin nAlLs.addr='0;`ifndef RV32I_STA $fatal("unknown adr==0x%x",oIdAl.adr);`endif end
		endcase
		iAlId.enJfun=oIdAl.enJcod|enBfun;
		iAlId.addr=nAlLs.addr;
	end end
	endmodule
