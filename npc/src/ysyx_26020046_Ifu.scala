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
		val change	= RegInit(false.B)
		val res		= RegInit(IfuRes.Null)
		val instr = RegInit(0.U(BitWidth.W))

		ich.addr		:= pc
		out.pipe.instr	:= instr
		out.pipe.pc		:= pc
		out.pipe.res 	:= res
		switch(state){
			is(MemStatus.Call){when((ich.ready& ~change & (in.imme.back === Back.Ready || in.imme.back === Back.Wait)) || error)
																	{state := MemStatus.Back}}
			is(MemStatus.Back){when(in.imme.back =/= Back.Wait)		{state := MemStatus.Call}}
		}
		when(state === MemStatus.Call){
			ich.valid	:= ~error
			when(ich.ready & ~change){instr := ich.data}

			when(error)						{res := IfuRes.Un4b}
			.elsewhen(ich.ready && ~change &&(in.imme.back === Back.Ready || in.imme.back === Back.Wait))
											{res :=Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
			.otherwise						{res := IfuRes.Null}

			when(change&ich.ready){change := false.B}
		}.otherwise{
			ich.valid := false.B
			when(in.imme.back =/= Back.Wait){res := IfuRes.Null}
		}
		switch(in.imme.back){
			is(Back.Jump)	{pc := in.imme.addr(31,2)}
			is(Back.Error)	{pc := in.imme.addr(31,2)}
			is(Back.Ready)	{when(state===MemStatus.Back)(pc := pc + 1.U)}
		}
		when(in.imme.back === Back.Error || in.imme.back === Back.Jump){
			error := in.imme.addr(1,0) =/= 0.U
			when(state===MemStatus.Call){change := ~ich.ready}
		}


	if(Yosys == false){
		val ifuPc = Mux(res === IfuRes.Valid,Cat(pc,0.U(2.W)),0.U(32.W));dontTouch(ifuPc)
		val ifuInst = Mux(res === IfuRes.Valid,instr,0.U(BitWidth.W));dontTouch(ifuInst)
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= state === MemStatus.Call && ich.ready
		ifuChk.unable	:= state === MemStatus.Call && ich.ready && (change || in.imme.back === Back.Jump || in.imme.back === Back.Error)
		ifuChk.stall	:= state === MemStatus.Call
		ifuChk.jAb		:= in.imme.back === Back.Jump && state === MemStatus.Back
		// ifuChk.jAC		:= in.imme.back === Back.Jump && state === MemStatus.Call
		ifuChk.jAC		:= state === MemStatus.Call && (ich.ready& ~change & (in.imme.back === Back.Ready || in.imme.back === Back.Wait)) || error
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
		if(inst)	ifuInst();
		if(jAb)		ifuJaB();
		if(jAC)		ifuJaC();
		if(unable)	ifuUnable();
	end
	endmodule
	"""
	)
}