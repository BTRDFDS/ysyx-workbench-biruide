import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeBefore())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())
	//pc更新
		val pc		= RegInit(PcInit(31,2))
		val state	= RegInit(MemStatus.Call)
		val error	= RegInit(false.B)//特指地址错误
		val res		= RegInit(IfuRes.Null)
		when(state === MemStatus.Back){
			switch(in.imme.back){
				is(Back.Jump)	{pc := in.imme.addr(31,2)	}
				is(Back.Error)	{pc := in.imme.addr(31,2)	}
				is(Back.Ready)	{pc := pc + 1.U				}
			}
			when(in.imme.back === Back.Error || in.imme.back === Back.Jump){error := in.imme.addr(1,0) =/= 0.U}
		}.otherwise{
			switch(in.imme.back){
				is(Back.Jump)	{pc := in.imme.addr(31,2)	}
				is(Back.Error)	{pc := in.imme.addr(31,2)	}
			}
			when(in.imme.back === Back.Error || in.imme.back === Back.Jump){error := in.imme.addr(1,0) =/= 0.U}
		}
		out.pipe.pc	:= Cat(pc,0.U(2.W))
	//状态机
		switch(state){
			is(MemStatus.Call){when(ich.ready || error)		{state := MemStatus.Back}}
			is(MemStatus.Back){when(in.imme.back =/= Back.Wait)	{state := MemStatus.Call}}
		}
	//发出
		ich.addr	:= pc
		ich.valid:= state === MemStatus.Call && ~error
	//接收
		val instr = RegInit(0.U(BitWidth.W))
		when(state === MemStatus.Call && ich.ready){instr := ich.data}
		out.pipe.instr	:= instr
		when(state === MemStatus.Call){
			when(ich.ready){	res := Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
			.otherwise{			res := Mux(error,		IfuRes.Un4b,IfuRes.Null)}
		}.elsewhen(in.imme.back =/= Back.Wait){res := IfuRes.Null}
		out.pipe.res := res
	if(Yosys == false){
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= state === MemStatus.Call && ich.ready
		ifuChk.stall	:= state === MemStatus.Call
		ifuChk.forward	:= in.imme.back === Back.Jump && in.imme.addr < Cat(pc,0.U(2.W))
		ifuChk.backward	:= in.imme.back === Back.Jump && in.imme.addr > Cat(pc,0.U(2.W))
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