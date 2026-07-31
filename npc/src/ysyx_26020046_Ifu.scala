import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeBefore())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val loader	= IO(new LoaderBus(BitWidth))
	//pc更新
		val pc = RegInit(PcInit)
		val valid = RegInit(false.B)
		when(valid){
			switch(in.imme.back){
				is(Back.Jump)	{pc := in.imme.addr	}
				is(Back.Error)	{pc := in.imme.addr	}
				is(Back.Ready)	{pc := pc + 4.U		}
			}
		}
		out.pipe.pc	:= pc
	//发出
	when(in.imme.back =/= Back.Wait){
		loader.addr	:= pc
		loader.valid:= ~valid
	}.otherwire{
		loader.addr	:= 0.U
		loader.valid:=false.B
	}
	//接收
		val instr = RegInit(0.U(BitWidth.W))
		when(loader.ready){instr := loader.data}
		out.pipe.instr	:= instr
		out.pipe.res	:= IfuRes.Null
		when(valid && (in.imme.back === Back.Jump || in.imme.back === Back.Error) && in.imme.addr(1,0) =/= 0.U){out.pipe.res := IfuRes.Un4b}
		when(~valid && in.imme.back =/= Back.Wait){out.pipe.res := Mux(loader.error,IfuRes.Fall,IfuRes.Valid)}
	//valid
		when(in.imme.back =/= Back.Wait){valid := false.B}
		.elsewhen(loader.ready)			{valid := true.B }
	if(Yosys == false){
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= in.imme.back =/= Back.Wait && ~valid && loader.ready
		ifuChk.stall	:= in.imme.back =/= Back.Wait && ~valid
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