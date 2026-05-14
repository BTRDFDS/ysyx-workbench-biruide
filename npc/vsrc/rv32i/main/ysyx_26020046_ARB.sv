`include "ysyx_26020046_config.svh"
module ysyx_26020046_ARB(
	input  AXI4rCal_t rIfCal,
	output AXI4rBak_t rIfBak,
	input  AXI4rCal_t rLsCal,output AXI4rBak_t rLsBak,
	input  AXI4wCal_t wLsCal,output AXI4wBak_t wLsBak,
	input  AXI4rBak_t rMeBak,input  AXI4wBak_t wMeBak,
	output AXI4rCal_t rMeCal,output AXI4wCal_t wMeCal,
	input  AXI4rBak_t rCtBak,input  AXI4wBak_t wCtBak,
	output AXI4rCal_t rCtCal,output AXI4wCal_t wCtCal,
	input clock,reset
	);
	ARBstatus_t s,ns;
	// /*verilator lint_off UNUSEDSIGNAL */word_t addr;/*verilator lint_on UNUSEDSIGNAL */
	logic [31:16] addr;
	logic backvalid;
	always_comb	unique case(s)//TODO 现在默认是LSU不会同时读写
			ARBidle: if(rLsCal.arvalid)ns=ARBlsuR;
				else if(wLsCal.awvalid)ns=ARBlsuW;
				else if(wLsCal.wvalid )ns=ARBlsuW;
				else if(rIfCal.arvalid)ns=ARBifuR;
				else ns=ARBidle;
			ARBlsuR:ns=(rLsCal.rready&backvalid)?ARBidle:ARBlsuR;
			ARBlsuW:ns=(wLsCal.bready&backvalid)?ARBidle:ARBlsuW;
			ARBifuR:ns=(rIfCal.rready&backvalid)?ARBidle:ARBifuR;
			default:ns=ARBidle;
	endcase always_ff@(posedge clock)begin
		//FSM时序输出
			if(s==ARBidle&ns==ARBlsuR)	addr<=rLsCal.araddr[31:16];
			if(s==ARBidle&ns==ARBlsuW)	addr<=wLsCal.awaddr[31:16];
			if(s==ARBidle&ns==ARBifuR)	addr<=rIfCal.araddr[31:16];
			if(ns==ARBidle)				addr<='0;
		`ifdef RV32I_DEBUG if(~reset)begin
			$fdisplay(logFile,"ARB:s=%s ns=%s addr=%x r=%x w=%x",s.name(),ns.name(),addr,rMeCal.araddr,wMeCal.awaddr);
			$fdisplay(logFile,"rMeCal:%s",sAXI4rCal(rMeCal));$fdisplay(logFile,"rMeBak:%s",sAXI4rBak(rMeBak));
			$fdisplay(logFile,"wMeCal:%s",sAXI4wCal(wMeCal));$fdisplay(logFile,"wMeBak:%s",sAXI4wBak(wMeBak));
			$fdisplay(logFile,"rIfCal:%s",sAXI4rCal(rIfCal));$fdisplay(logFile,"rIfBak:%s",sAXI4rBak(rIfBak));
			$fdisplay(logFile,"rLsCal:%s",sAXI4rCal(rLsCal));$fdisplay(logFile,"rLsBak:%s",sAXI4rBak(rLsBak));
			$fdisplay(logFile,"wLsCal:%s",sAXI4wCal(wLsCal));$fdisplay(logFile,"wLsBak:%s",sAXI4wBak(wLsBak));
			end`endif
		//FSM切换
			if(reset)s<=ARBidle;else s<=ns;
			if(~reset)if((s!=ARBidle)&(addr[31:16]!=16'h2000)&(addr[31:16]!=16'h0f00)&(addr[31:16]!=16'h0200))$stop();
	end always_comb begin
		//默认折叠
			backvalid='0;

			rMeCal.araddr	='0;
			rMeCal.arvalid	=0;
			rMeCal.rready	=0;
			wMeCal.awaddr	='0;
			wMeCal.awvalid	=0;
			wMeCal.wdata	='0;
			wMeCal.wstrb	='0;
			wMeCal.wvalid	=0;
			wMeCal.bready	=0;
			
			rCtCal.araddr	='0;
			rCtCal.arvalid	=0;
			rCtCal.rready	=0;
			wCtCal.awaddr	='0;
			wCtCal.awvalid	=0;
			wCtCal.wdata	='0;
			wCtCal.wstrb	='0;
			wCtCal.wvalid	=0;
			wCtCal.bready	=0;

			rLsBak.arready	=0;
			rLsBak.rdata	='0;
			rLsBak.rresp	=OKAY;
			rLsBak.rvalid	=0;
			wLsBak.awready	=0;
			wLsBak.wready	=0;
			wLsBak.bresp	=OKAY;
			wLsBak.bvalid	=0;

			rIfBak.arready	=0;
			rIfBak.rdata	='0;
			rIfBak.rresp	=OKAY;
			rIfBak.rvalid	=0;
		unique case(s)
			ARBidle:;
			ARBlsuR:if(addr[31:16]==16'h0200)	begin rCtCal=rLsCal;rLsBak=rCtBak;backvalid=rCtBak.rvalid;end
					else						begin rMeCal=rLsCal;rLsBak=rMeBak;backvalid=rMeBak.rvalid;end
			ARBlsuW:if(addr[31:16]==16'h0200)	begin wCtCal=wLsCal;wLsBak=wCtBak;backvalid=wCtBak.bvalid;end
					else						begin wMeCal=wLsCal;wLsBak=wMeBak;backvalid=wMeBak.bvalid;end
			ARBifuR:							begin rMeCal=rIfCal;rIfBak=rMeBak;backvalid=rMeBak.rvalid;end//TODO 未进行拦截，很危险
	endcase end
    endmodule
