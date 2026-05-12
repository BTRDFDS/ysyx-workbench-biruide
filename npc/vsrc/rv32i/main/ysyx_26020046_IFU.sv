`include "ysyx_26020046_config.svh"
module ysyx_26020046_IFU(
	input  AXI4rBak_t	rIfBak,
	output AXI4rCal_t	rIfCal,
	output IfId_t		nIfId,
	input  upBk_t		iIdIf,
	input logic clock,reset
	);

	IFUstatus_t ns,s;
	always_comb begin
		//FSM转移	
			unique case(s)//两段状态转移会有1周期延迟
				IFUfunc:ns=iIdIf.ready		?IFUcall:IFUfunc;
				IFUcall:ns=rIfBak.arready	?IFUback:IFUcall;
				IFUback:ns=rIfBak.rvalid	?IFUfunc:IFUback;
				default:ns=IFUcall;
			endcase
		//FSM组合信号
			rIfCal.araddr	=nIfId.pc;
			rIfCal.arvalid	=(s==IFUcall);
			rIfCal.rready	=(s==IFUback);
			nIfId.error=false;nIfId.cause=32'hFFFFFFFF;//防止某些意外发生
			if(s==IFUback)case(rIfBak.rresp)
				OKAY	:;
				// default	:begin `ifndef RV32I_STA $error("rIfBak.rresp=%s:",rIfBak.rresp.name());$stop();`endif end
				default	:begin nIfId.error=true;nIfId.cause=32'd0;end
			endcase
			nIfId.valid=(s==IFUfunc);
	end always_ff@(posedge clock)begin
		`ifdef RV32I_DEBUG if(~reset)begin
			$fdisplay(logFile,"IFU:s=%s,ns=%s ready=%b valid=%b",s.name(),ns.name(),iIdIf.ready,nIfId.valid);
			if(iIdIf.enJfun)$fdisplay(logFile,"PC:%x => %x",nIfId.pc,iIdIf.addr);
			$fdisplay(logFile,"nIfId:%s",sIfId(nIfId));
			end`endif
		//FSM状态转移
			if(reset)s<=IFUcall;else s<=ns;
		//FSM时序信号
			if(s==IFUback&ns==IFUfunc)nIfId.code<=rIfBak.rdata;
		//IFU PC切换
			if(reset) nIfId.pc<=PC_RESET;
			else if(nIfId.valid&iIdIf.ready)begin
				if(iIdIf.enJfun) nIfId.pc<=(iIdIf.addr&32'hFFFFFFFC);
				else nIfId.pc<=nIfId.pc+4;
			end
		end
    endmodule
