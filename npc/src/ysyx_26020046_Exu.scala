import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Exu extends Module {
	val in = IO(new Bundle {
		val imme = Flipped(new ImmeAfter())
		val pipe = Flipped(new PipeIdEx())
	})
	val out = IO(new Bundle {
		val imme = new ImmeAfter()
		val pipe = new PipeExLs()
	})
	
	out.pipe.lsuAddr:= in.pipe.lsuAddr
	out.pipe.lsuOp	:= in.pipe.lsuOp
	out.pipe.r2		:= in.pipe.r2
	out.pipe.pc		:= in.pipe.pc
	out.pipe.csrOp	:= in.pipe.csrOp
	out.pipe.csrAddr:= in.pipe.csrAddr
	out.pipe.valid	:= in.pipe.valid
	out.pipe.rdAddr	:= in.pipe.rdAddr
	out.pipe.result := 0.U
	out.pipe.csrMesg:= in.pipe.csrMesg
	
	out.imme.back	:= in.imme.back
	out.imme.addr	:= 0.U
	out.imme.r1Out	:= in.imme.r1Out
	out.imme.r2Out	:= in.imme.r2Out
	out.imme.csrOut	:= in.imme.csrOut
	in.imme.r1Addr	:= out.imme.r1Addr
	in.imme.r2Addr	:= out.imme.r2Addr
	in.imme.csrAddr	:= out.imme.csrAddr

	when(in.pipe.valid){
		val input1 = Mux(in.pipe.In1 === ExuIn1.R1, in.pipe.r1, in.pipe.pc)
		val input2 = Mux(in.pipe.In2 === ExuIn2.R2, in.pipe.r2, in.pipe.result)
		val result = WireInit(0.U(BitWidth.W))
		switch(in.pipe.alu){
			is(ExuAlu.Add)	{result := input1 + input2}
			is(ExuAlu.Sll)	{result := input1 << input2(4,0)}
			is(ExuAlu.Slt)	{result := input1.asSInt < input2.asSInt}
			is(ExuAlu.Sltu)	{result := input1 < input2}
			is(ExuAlu.Xor)	{result := input1 ^ input2}
			is(ExuAlu.Srl)	{result := input1 >> input2(4,0)}
			is(ExuAlu.Or)	{result := input1 | input2}
			is(ExuAlu.And)	{result := input1 & input2}
			is(ExuAlu.Sub)	{result := input1 - input2}
			is(ExuAlu.Sra)	{result := (input1.asSInt >> input2(4,0)).asUInt}
			is(ExuAlu.Csr)	{result := in.pipe.result}//给addr的
			is(ExuAlu.Imm)	{result := in.pipe.result}
			is(ExuAlu.Jalr)	{result := Cat((in.pipe.r1 + in.pipe.result)(31,1), 0.U(1.W))}
		}
		val enBfun = WireInit(false.B)
		switch(in.pipe.bfu){
			is(ExuBfu.Beq)	{enBfun := in.pipe.r1 === in.pipe.r2}
			is(ExuBfu.Bne)	{enBfun := in.pipe.r1 =/= in.pipe.r2}
			is(ExuBfu.Blt)	{enBfun := in.pipe.r1.asSInt < in.pipe.r2.asSInt}
			is(ExuBfu.Bge)	{enBfun := in.pipe.r1.asSInt >= in.pipe.r2.asSInt}
			is(ExuBfu.Bltu)	{enBfun := in.pipe.r1 < in.pipe.r2}
			is(ExuBfu.Bgeu)	{enBfun := in.pipe.r1 >= in.pipe.r2}
		}
		switch(in.pipe.csr){
			is(ExuCsr.Read)	{out.pipe.csrMesg := in.pipe.r1 | in.pipe.csrMesg}
			is(ExuCsr.Write){out.pipe.csrMesg := in.pipe.r1}
		}
		switch(in.pipe.res){
			is(ExuRes.Alu)	{out.pipe.result := result}
			is(ExuRes.Null)	{out.pipe.result := 0.U}
			is(ExuRes.Snpc)	{out.pipe.result := in.pipe.pc+4.U}
			is(ExuRes.Csr)	{out.pipe.result := in.pipe.result}//给rd的
		}
		when(in.imme.back === Back.Error){
			out.imme.back	:= Back.Error
			out.imme.addr	:= in.imme.addr
		}.otherwise{
			when(in.pipe.enJcod || enBfun){
				out.imme.addr := result
				out.imme.back := Back.Jump
			}.otherwise{out.imme.back := in.imme.back}
		}
	}

	val exuChk = Module(new ysyx_26020046_ExuChk)
	exuChk.clock := clock
	exuChk.io.done := out.pipe.valid && in.imme.back === Back.Ready && ~(
		in.pipe.alu === ExuAlu.Null &&
		in.pipe.bfu === ExuBfu.Null &&
		in.pipe.csr === ExuCsr.Null &&
		in.pipe.res === ExuRes.Null)
}
class ysyx_26020046_ExuChk extends ExtModule{
	val io = IO(new Bundle{
		val done	= Input(Bool())
	})
	val clock = IO(Input(Clock()))
	setInline("ysyx_26020046_ExuChk.sv",
	"""
	module ysyx_26020046_ExuChk(
		input logic io_done,
		input logic clock
	);
	import "DPI-C" function void exuDone();
	always_ff@(posedge clock) if(io_done)exuDone();
	endmodule
	"""
	)
}