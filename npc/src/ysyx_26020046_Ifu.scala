import chisel3._
import chisel3.util._
import WidthConsts._
object IfuStatus extends ChiselEnum{val Call,Back = Value}
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeBefore())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val loader	= IO(new LoaderBus(BitWidth))
	//pc更新
		val pc		= RegInit(PcInit)
		val state	= RegInit(IfuStatus.Call)
		val error	= RegInit(false.B)//特指地址错误
		val res		= RegInit(IfuRes.Null)
		when(state === IfuStatus.Back){
			switch(in.imme.back){
				is(Back.Jump)	{pc := in.imme.addr	}
				is(Back.Error)	{pc := in.imme.addr	}
				is(Back.Ready)	{pc := pc + 4.U		}
			}
			when(in.imme.back === Back.Error || in.imme.back === Back.Jump){error := in.imme.addr(1,0) =/= 0.U}
		}
		out.pipe.pc	:= pc
	//状态机
		switch(state){
			is(IfuStatus.Call){when(loader.ready || error)		{state := IfuStatus.Back}}
			is(IfuStatus.Back){when(in.imme.back =/= Back.Wait)	{state := IfuStatus.Call}}
		}
	//发出
		loader.addr	:= pc
		loader.valid:= state === IfuStatus.Call && ~error
	//接收
		val instr = RegInit(0.U(BitWidth.W))
		when(state === IfuStatus.Call && loader.ready){instr := loader.data}
		out.pipe.instr	:= instr
		when(state === IfuStatus.Call){
			when(loader.ready){	res := Mux(loader.error,IfuRes.Fall,IfuRes.Valid)}
			.otherwise{			res := Mux(error,		IfuRes.Un4b,IfuRes.Null)}
		}.elsewhen(in.imme.back =/= Back.Wait){res := IfuRes.Null}
		out.pipe.res := res
	if(Yosys == false){
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= state === IfuStatus.Call && loader.ready
		ifuChk.stall	:= state === IfuStatus.Call
		ifuChk.forward	:= in.imme.back === Back.Jump && in.imme.addr < pc
		ifuChk.backward	:= in.imme.back === Back.Jump && in.imme.addr > pc
		ifuChk.jump		:= in.imme.back === Back.Jump
	}
}
class ysyx_26020046_IfuChk extends ExtModule{
	val inst	= IO(Input(Bool()))
	val stall	= IO(Input(Bool()))
	val forward	= IO(Input(Bool()))
	val backward= IO(Input(Bool()))
	val jump	= IO(Input(Bool()))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_IfuChk.sv",
	"""
	module ysyx_26020046_IfuChk(
		input logic inst,
		input logic stall,
		input logic forward,
		input logic backward,
		input logic jump,
		input logic clock
	);
	import "DPI-C" function void ifuInst();
	import "DPI-C" function void ifuStall();
	import "DPI-C" function void ifuForward();
	import "DPI-C" function void ifuBackward();
	import "DPI-C" function void ifuJump();

	always_ff@(posedge clock)begin
		if(stall)	ifuStall();
		if(inst)	ifuInst();
		if(forward)	ifuForward();
		if(backward)ifuBackward();
		if(jump)	ifuJump();
	end
	endmodule
	"""
	)
}