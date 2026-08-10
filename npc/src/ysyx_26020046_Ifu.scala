import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeBefore())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())
	//pc更新
		val hasChange= RegInit(true.B);dontTouch(hasChange)
		val pc		= RegInit(PcInit(31,2))
		// val state	= RegInit(MemStatus.Call)
		// val error	= RegInit(false.B)//特指地址错误
		// val res		= RegInit(IfuRes.Null)
		// val instr = RegInit(0.U(BitWidth.W))


		when(in.imme.error || in.imme.jump)		{pc := in.imme.addr(31,2)}
		.elsewhen(in.imme.ready && ich.ready && ~hasChange)	{pc := pc + 1.U}

		when(in.imme.error || in.imme.jump || (in.imme.ready && ~hasChange)){hasChange := true.B}
		.elsewhen(out.pipe.res === IfuRes.Valid)							{hasChange := false.B}

		ich.valid	:= true.B
		ich.addr	:= pc

		out.pipe.instr	:= ich.data
		out.pipe.pc		:= pc
		when(in.imme.addr(1,0)=/=0.U(2.W))	{out.pipe.res := IfuRes.Un4b}
		.elsewhen(ich.ready&& hasChange)	{out.pipe.res := Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
		.otherwise							{out.pipe.res := IfuRes.Null}






		// switch(state){
		// 	is(MemStatus.Call){when((ich.ready & (in.imme.back === Back.Ready || in.imme.back === Back.Wait)) || error)
		// 															{state := MemStatus.Back}}
		// 	is(MemStatus.Back){when(in.imme.back =/= Back.Wait)		{state := MemStatus.Call}}
		// }
		// when(state === MemStatus.Call){
		// 	ich.valid	:= ~error
		// 	when(ich.ready){instr := ich.data}

		// 	when(error)						{res := IfuRes.Un4b}
		// 	.elsewhen(ich.ready &&(in.imme.back === Back.Ready || in.imme.back === Back.Wait))
		// 									{res :=Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
		// 	.otherwise						{res := IfuRes.Null}
		// }.otherwise{
		// 	ich.valid := false.B
		// 	when(in.imme.back =/= Back.Wait){res := IfuRes.Null}
		// }
		// switch(in.imme.back){
		// 	is(Back.Jump)	{pc := in.imme.addr(31,2)}
		// 	is(Back.Error)	{pc := in.imme.addr(31,2)}
		// 	is(Back.Ready)	{when(state===MemStatus.Back)(pc := pc + 1.U)}
		// }
		// when(in.imme.back === Back.Error || in.imme.back === Back.Jump){
		// 	error := in.imme.addr(1,0) =/= 0.U
		// }


	if(Yosys == false){
		val ifuPc	= Mux(out.pipe.res === IfuRes.Valid,Cat(out.pipe.pc,0.U(2.W)),0.U(32.W));dontTouch(ifuPc)
		val ifuInst	= Mux(out.pipe.res === IfuRes.Valid,out.pipe.instr,0.U(BitWidth.W));dontTouch(ifuInst)
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= ich.ready
		ifuChk.stall	:= out.pipe.res === IfuRes.Null
		ifuChk.unable	:= false.B
		ifuChk.jAb		:= false.B
		ifuChk.jAC		:= false.B
		// ifuChk.unable	:= ich.ready && (in.imme.back === Back.Jump || in.imme.back === Back.Error)
		// ifuChk.jAb		:= in.imme.back === Back.Jump && state === MemStatus.Back
		// ifuChk.jAC		:= (state === MemStatus.Call && ich.ready) =/= (state === MemStatus.Call && ich.ready & (in.imme.back === Back.Ready || in.imme.back === Back.Wait))
	}
}
class ysyx_26020046_IfuChk extends ExtModule{
	val inst	= IO(Input(Bool()))
	val stall	= IO(Input(Bool()))
	val jAb		= IO(Input(Bool()))
	val jAC		= IO(Input(Bool()))
	val unable	= IO(Input(Bool()))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_IfuChk.sv",
	"""
	module ysyx_26020046_IfuChk(
		input logic inst,
		input logic stall,
		input logic jAb	,
		input logic jAC,
		input logic unable,
		input logic clock
	);
	import "DPI-C" function void ifuInst();
	import "DPI-C" function void ifuStall();
	import "DPI-C" function void ifuJaB();
	import "DPI-C" function void ifuJaC();
	import "DPI-C" function void ifuUnable();

	always_ff@(posedge clock)begin
		if(stall)	ifuStall();
		// if(inst)	ifuInst();
		if(jAb)		ifuJaB();
		if(jAC)		ifuJaC();
		if(unable)	ifuUnable();
	end
	always_ff@(posedge inst)	ifuInst();
	endmodule
	"""
	)
}