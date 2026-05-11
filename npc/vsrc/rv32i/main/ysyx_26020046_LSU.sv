`include "ysyx_26020046_config.svh"
module ysyx_26020046_LSU(
	output AXI4rCal_t rLsCal,
	output AXI4wCal_t wLsCal,
	input  AXI4rBak_t rLsBak,
	input  AXI4wBak_t wLsBak,
	input  AlLs_t nAlLs,
	input RgLs_t  iRgLs,
	output LsRg_t nLsRg,
	output LsAl_t iLsAl,
	input valcl_t vAlLs,
	output valcl_t vLsRg,
	input  logic clock,reset
	);

	AlLs_t oAlLs;

	mask_t mask;
	word_t iRAM,data;
	logic hasAddr,hasData;
	LSUstatus_t s,ns;
	logic LsWbValid;

	always_comb oAlLs=nAlLs;
	always_comb begin
		vLsRg.cR1=vAlLs.cR1;
		vLsRg.cR2=vAlLs.cR2;
		vLsRg.SRaddr=vAlLs.SRaddr;
	end always_comb begin
		iLsAl.oR1=iRgLs.oR1;
		iLsAl.oR2=iRgLs.oR2;
		iLsAl.oCsr=iRgLs.oCsr;
	end

	always_comb unique case(s)
			LSUidle:ns=(oAlLs.enL|oAlLs.enS)	?LSUcall:LSUidle;
			LSUcall:unique case('1)
				oAlLs.enL:ns=(rLsBak.arready)									?LSUback:LSUcall;
				oAlLs.enS:ns=((hasAddr|wLsBak.awready)&(hasData|wLsBak.wready))	?LSUback:LSUcall;
				default:begin ns=LSUidle;`ifndef RV32I_STA if(~reset)begin $error("LSU call L=%b S=%b reset=%b",oAlLs.enL,oAlLs.enS,reset);$stop;end`endif end endcase
			LSUback:unique case('1)
				oAlLs.enL:ns=(rLsBak.rvalid)	?LSUsuce:LSUback;
				oAlLs.enS:ns=(wLsBak.bvalid)	?LSUsuce:LSUback;
				default:begin ns=LSUidle;`ifndef RV32I_STA if(~reset)begin $error("LSU back L=%b S=%b reset=%b",oAlLs.enL,oAlLs.enS,reset);$stop;end`endif end endcase
			LSUsuce:ns=(iLsAl.ready&LsWbValid)	?LSUidle:LSUsuce;
			default:ns=LSUidle;
	endcase always_ff@(posedge clock) if(reset)begin
			s<=LSUidle;
	end else begin `ifdef RV32I_DEBUG $fdisplay(logFile,"LSU:Rs=%s ns=%s",s.name(),ns.name());`endif
			s<=ns;
	end always_ff@(posedge clock) begin
			iRAM<=(s==LSUback&ns==LSUsuce)?rLsBak.rdata:'0;
			if(oAlLs.enS&s==LSUcall&wLsBak.awready)	hasAddr<=true;
			if(oAlLs.enS&s!=LSUcall)				hasAddr<=false;
			if(oAlLs.enS&s==LSUcall&wLsBak.wready)	hasData<=true;
			if(oAlLs.enS&s!=LSUcall)				hasData<=false;
	end always_comb begin
			rLsCal.araddr	=oAlLs.enL?oAlLs.addr:'0;
			rLsCal.arvalid	=oAlLs.enL&(s==LSUcall);
			rLsCal.rready	=oAlLs.enL&(s==LSUback);
			
			wLsCal.awaddr	=oAlLs.enS?oAlLs.addr:'0;
			wLsCal.awvalid	=oAlLs.enS&(s==LSUcall);
			wLsCal.wdata	=oAlLs.enS?oAlLs.oR2:'0;
			wLsCal.wstrb	=oAlLs.enS?mask:'0;
			wLsCal.wvalid	=oAlLs.enS&(s==LSUcall);
			wLsCal.bready	=oAlLs.enS&(s==LSUback);
			if(s==LSUback)case(rLsBak.rresp)
				OKAY:;
				default:begin `ifndef RV32I_STA $error("unknown rresp==0x%x",rLsBak.rresp);`endif end
			endcase
			if(s==LSUback)case(wLsBak.bresp)
				OKAY:;
				default:begin `ifndef RV32I_STA $error("unknown bresp==0x%x",wLsBak.bresp);`endif end
			endcase
			// if(s==LSUsuce)$stop;
	end
	always_comb begin
		nLsRg.iRd	=(oAlLs.enS|oAlLs.enL)?data:oAlLs.res;
		nLsRg.cRd	=oAlLs.cRd;
		nLsRg.iCsr	=oAlLs.iCsr;
		nLsRg.SRmesg=oAlLs.SRmesg;
		nLsRg.SRop	=oAlLs.SRop;
		LsWbValid	=(~((oAlLs.enL|oAlLs.enS)^(s==LSUsuce)))&oAlLs.valid;
		nLsRg.valid	=LsWbValid;
		nLsRg.valid	=LsWbValid;
		iLsAl.ready	=(~((oAlLs.enL|oAlLs.enS)^(s==LSUsuce)))&iRgLs.ready&iRgLs.ready;
	end
	always_comb begin
		`ifdef RV32I_DEBUG if(oAlLs.enL)$fdisplay(logFile,"LSU:enL=%b valid=%b iRAM=%x",oAlLs.enL,oAlLs.valid,iRAM);`endif
		if (oAlLs.enS&oAlLs.valid) begin unique case(oAlLs.LSop)
			B_:				mask=4'b0001;
			H_:				mask=4'b0011;
			W_:				mask=4'b1111;
			NM:				mask=4'b0000;
			default:begin 	mask=4'b0000;`ifndef RV32I_STA $fatal("unknown mask==0x%x",oAlLs.LSop);`endif end
		endcase end else 	mask=4'b0000;
		if(oAlLs.enL&oAlLs.valid) begin unique case(oAlLs.LSop)
			B_:				data={{24{iRAM[ 7]}},iRAM[ 7: 0]};
			H_:				data={{16{iRAM[15]}},iRAM[15: 0]};
			W_:				data=iRAM;
			BU:				data={{24{1'b0}},iRAM[ 7: 0]};
			HU:				data={{16{1'b0}},iRAM[15: 0]};
			default:begin 	data=0;`ifndef RV32I_STA $fatal("unknown date==0x%x",oAlLs.LSop);`endif end
		endcase end else 	data='0;
		`ifdef RV32I_DEBUG if(oAlLs.enL)$fstrobe(logFile,"LSU:enL=%b valid=%b data=%x iRAM=%x",oAlLs.enL,oAlLs.valid,data,iRAM);`endif
	end
	endmodule
