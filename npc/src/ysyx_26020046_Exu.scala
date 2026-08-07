import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Exu(val Yosys:Boolean=false) extends Module {
	val in = IO(new Bundle {
		val imme = Flipped(new ImmeAfter())
		val pipe = Flipped(new PipeIdEx())
	})
	val out = IO(new Bundle {
		val imme = new ImmeAfter()
		val pipe = new PipeExLs()
	})
	val pipeReady	= out.imme.back===Back.Ready
	val pipeReset	= reset.asBool||(in.imme.back===Back.Error)
	val pipeValid	= PipeReg(pipeReset,false.B			,pipeReady,in.pipe.valid	)
	val pipeFenceI	= PipeReg(pipeReset,false.B			,pipeReady,in.pipe.fenceI	)
	val pipeEnJcod	= PipeReg(pipeReset,false.B			,pipeReady,in.pipe.enJcod	)
	val pipeRdAddr	= PipeReg(pipeReset,0.U(RegWidth.W)	,pipeReady,in.pipe.rdAddr	)
	val pipeResult	= PipeReg(pipeReset,0.U(BitWidth.W)	,pipeReady,in.pipe.result	)
	val pipePc		= PipeReg(pipeReset,0.U(BitWidth.W)	,pipeReady,in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(pipeReset,0.U(BitWidth.W)	,pipeReady,in.pipe.csrAddr	)
	val pipeCsrMesg	= PipeReg(pipeReset,0.U(BitWidth.W)	,pipeReady,in.pipe.csrMesg	)
	val pipeR1		= PipeReg(pipeReset,0.U(BitWidth.W)	,pipeReady,in.pipe.r1		)
	val pipeR2		= PipeReg(pipeReset,0.U(BitWidth.W)	,pipeReady,in.pipe.r2		)
	val pipeLsuOp	= PipeReg(pipeReset,LsuOp.Null		,pipeReady,in.pipe.lsuOp	)
	val pipeLsuAddr	= PipeReg(pipeReset,LsuAddr.B		,pipeReady,in.pipe.lsuAddr	)
	val pipeCsrOp	= PipeReg(pipeReset,CsrOp.Null		,pipeReady,in.pipe.csrOp	)
	val pipeAlu		= PipeReg(pipeReset,ExuAlu.Null		,pipeReady,in.pipe.alu		)
	val pipeBfu		= PipeReg(pipeReset,ExuBfu.Null		,pipeReady,in.pipe.bfu		)
	val pipeCsr		= PipeReg(pipeReset,ExuCsr.Null		,pipeReady,in.pipe.csr		)
	val pipeRes		= PipeReg(pipeReset,ExuRes.Alu		,pipeReady,in.pipe.res		)
	val pipeIn1		= PipeReg(pipeReset,ExuIn1.R1		,pipeReady,in.pipe.in1		)
	val pipeIn2		= PipeReg(pipeReset,ExuIn2.R2		,pipeReady,in.pipe.in2		)
	
	out.pipe.lsuAddr:= pipeLsuAddr
	out.pipe.lsuOp	:= pipeLsuOp
	out.pipe.fenceI	:= pipeFenceI
	out.pipe.r2		:= pipeR2
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= pipeCsrOp
	out.pipe.csrAddr:= pipeCsrAddr
	out.pipe.valid	:= pipeValid
	out.pipe.rdAddr	:= pipeRdAddr
	out.pipe.result := 0.U
	out.pipe.csrMesg:= pipeCsrMesg
	
	out.imme.back	:= in.imme.back
	out.imme.addr	:= 0.U
	out.imme.r1Out	:= in.imme.r1Out
	out.imme.r2Out	:= in.imme.r2Out
	out.imme.valid	:= in.imme.valid
	out.imme.csrOut	:= in.imme.csrOut
	in.imme.r1Addr	:= out.imme.r1Addr
	in.imme.r2Addr	:= out.imme.r2Addr
	in.imme.csrAddr	:= out.imme.csrAddr

	when(pipeValid){
		val input1 = Mux(pipeIn1 === ExuIn1.R1, pipeR1, pipePc)
		val input2 = Mux(pipeIn2 === ExuIn2.R2, pipeR2, pipeResult)
		val result = WireInit(0.U(BitWidth.W))
		switch(pipeAlu){
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
			is(ExuAlu.Csr)	{result := pipeResult}//给addr的
			is(ExuAlu.Imm)	{result := pipeResult}
			is(ExuAlu.Jalr)	{result := Cat((pipeR1 + pipeResult)(31,1), 0.U(1.W))}
		}
		val enBfun = WireInit(false.B)
		switch(pipeBfu){
			is(ExuBfu.Beq)	{enBfun := pipeR1 === pipeR2}
			is(ExuBfu.Bne)	{enBfun := pipeR1 =/= pipeR2}
			is(ExuBfu.Blt)	{enBfun := pipeR1.asSInt < pipeR2.asSInt}
			is(ExuBfu.Bge)	{enBfun := pipeR1.asSInt >= pipeR2.asSInt}
			is(ExuBfu.Bltu)	{enBfun := pipeR1 < pipeR2}
			is(ExuBfu.Bgeu)	{enBfun := pipeR1 >= pipeR2}
		}
		switch(pipeCsr){
			is(ExuCsr.Read)	{out.pipe.csrMesg := pipeR1 | pipeCsrMesg}
			is(ExuCsr.Write){out.pipe.csrMesg := pipeR1}
		}
		when(in.imme.back === Back.Error){
			out.imme.back	:= Back.Error
			out.imme.addr	:= in.imme.addr
		}.otherwise{
			when(pipeEnJcod || enBfun){
				out.imme.addr := result
				out.imme.back := Back.Jump
			}.otherwise{out.imme.back := in.imme.back}
		}
		switch(pipeRes){
			is(ExuRes.Alu)	{out.pipe.result := result}
			is(ExuRes.Null)	{out.pipe.result := 0.U}
			is(ExuRes.Snpc)	{out.pipe.result := pipePc+4.U}
			is(ExuRes.Csr)	{out.pipe.result := pipeResult}//给rd的
		}
		when(pipeRdAddr =/= 0.U){
			when(out.imme.r1Addr === pipeRdAddr){out.imme.r1Out := out.pipe.result}
			when(out.imme.r2Addr === pipeRdAddr){out.imme.r2Out := out.pipe.result}
			when(out.imme.r1Addr === pipeRdAddr || out.imme.r2Addr === pipeRdAddr){
				out.imme.valid := pipeLsuOp === LsuOp.Null//Write理论上也可以
			}
		}
	}
	if(Yosys == false){
		val exuChk = Module(new ysyx_26020046_ExuChk)
		exuChk.clock := clock
		exuChk.done := out.pipe.valid && in.imme.back =/= Back.Wait && ~(
			pipeAlu === ExuAlu.Null &&
			pipeBfu === ExuBfu.Null &&
			pipeCsr === ExuCsr.Null)
	}
}
class ysyx_26020046_ExuChk extends ExtModule{
	val done	= IO(Input(Bool()))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_ExuChk.sv",
	"""
	module ysyx_26020046_ExuChk(
		input logic done,
		input logic clock
	);
	import "DPI-C" function void exuDone();
	always_ff@(posedge clock)begin
		if(done)	exuDone();
	end
	endmodule
	"""
	)
}