import chisel3._
import chisel3.util._
import WidthConsts._

object IfuStatus extends ChiselEnum{val Back,Call,Func=Value}
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in = IO(new Bundle{
		val imme = Flipped(new ImmeBefore())
	})
	val out = IO(new Bundle{
		val pipe = new PipeIfId()
	})
	val axi4 = IO(new Axi4Master())
	//FSM
		val status = RegInit(IfuStatus.Call)
		val ready = in.imme.back =/= Back.Wait
		switch(status){
			is(IfuStatus.Call){when(axi4.arready){status := IfuStatus.Back}}
			is(IfuStatus.Back){when(axi4.rvalid)	{status := IfuStatus.Func}}
			is(IfuStatus.Func){when(ready)			{status := IfuStatus.Call}}
		}	
	//pc更新
		val pc = RegInit(PcInit)
		switch(in.imme.back){
			is(Back.Jump)	{pc := in.imme.addr}
			is(Back.Error)	{pc := in.imme.addr}
			is(Back.Ready)	{when(status === IfuStatus.Func){pc := pc + 4.U}}//TODO:有问题
		}
		out.pipe.pc	:= pc
	//输出指令
		val instr = RegInit(0.U(BitWidth.W))
		when(status === IfuStatus.Back & axi4.rvalid === true.B){instr := axi4.rdata}
		out.pipe.instr := instr
	//输出状态
		out.pipe.res	:= IfuRes.Null
		switch(status){
			is(IfuStatus.Back){when(axi4.rresp =/= 0.U){out.pipe.res := IfuRes.Fall}}
			is(IfuStatus.Func){out.pipe.res := IfuRes.Valid}
			is(IfuStatus.Call){when(pc(1,0) =/= 0.U){out.pipe.res := IfuRes.Un4b}}
		}
	//axi4输出信号
		axi4.araddr	:= pc
		axi4.arvalid	:= status === IfuStatus.Call
		axi4.rready	:= status === IfuStatus.Back
	//用不到的axi4
		axi4.awvalid	:= false.B
		axi4.wvalid	:= false.B
		axi4.bready	:= false.B
		axi4.awaddr	:= 0.U
		axi4.wdata	:= 0.U
		axi4.wstrb	:= 0.U
		
	if(Yosys == false){
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock		:= clock
		ifuChk.io.inst	:= (status === IfuStatus.Back && axi4.rvalid)
		ifuChk.io.stall	:= (status =/= IfuStatus.Func)
	}
}
class ysyx_26020046_IfuChk extends ExtModule{
	val io = IO(new Bundle{
		val inst	= Input(Bool())
		val stall	= Input(Bool())
	})
	val clock = IO(Input(Clock()))
	setInline("ysyx_26020046_IfuChk.sv",
	"""
	module ysyx_26020046_IfuChk(
		input logic io_inst,
		input logic io_stall,
		input logic clock
	);
	import "DPI-C" function void ifuInst();
	import "DPI-C" function void ifuStall();

	always_ff@(posedge clock)begin
		if(io_stall)ifuStall();
		if(io_inst)ifuInst();
	end
	endmodule
	"""
	)
}