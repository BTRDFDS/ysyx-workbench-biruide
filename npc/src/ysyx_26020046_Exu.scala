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
	val pipeReset	= reset.asBool||(out.imme.back===Back.Error)||(out.imme.back===Back.Jump)
	val pipeValid	= Reg(Bool())			;pipeValid	:= Mux(pipeReset,false.B		,in.pipe.valid	)
	val pipeFenceI	= Reg(Bool())			;pipeFenceI	:= Mux(pipeReset,false.B		,in.pipe.fenceI	)
	val pipeEnJcod	= Reg(Bool())			;pipeEnJcod	:= Mux(pipeReset,false.B		,in.pipe.enJcod	)
	val pipeRdAddr	= Reg(UInt(RegWidth.W))	;pipeRdAddr	:= Mux(pipeReset,0.U(RegWidth.W),in.pipe.rdAddr	)
	val pipeResult	= Reg(UInt(BitWidth.W))	;pipeResult	:= Mux(pipeReset,0.U(RegWidth.W),in.pipe.result	)
	val pipePc		= Reg(UInt(BitWidth.W))	;pipePc		:= Mux(pipeReset,0.U(RegWidth.W),in.pipe.pc		)
	val pipeCsrAddr	= Reg(UInt(BitWidth.W))	;pipeCsrAddr:= Mux(pipeReset,0.U(RegWidth.W),in.pipe.csrAddr)
	val pipeCsrMesg	= Reg(UInt(BitWidth.W))	;pipeCsrMesg:= Mux(pipeReset,0.U(RegWidth.W),in.pipe.csrMesg)
	val pipeR1		= Reg(UInt(BitWidth.W))	;pipeR1		:= Mux(pipeReset,0.U(RegWidth.W),in.pipe.r1		)
	val pipeR2		= Reg(UInt(BitWidth.W))	;pipeR2		:= Mux(pipeReset,0.U(RegWidth.W),in.pipe.r2		)
	val pipeLsuOp	= Reg(LsuOp())			;pipeLsuOp	:= Mux(pipeReset,LsuOp.Null		,in.pipe.lsuOp	)
	val pipeLsuAddr	= Reg(LsuAddr())		;pipeLsuAddr:= Mux(pipeReset,LsuAddr.B		,in.pipe.lsuAddr)
	val pipeCsrOp	= Reg(CsrOp())			;pipeCsrOp	:= Mux(pipeReset,CsrOp.Null		,in.pipe.csrOp	)
	val pipeAlu		= Reg(ExuAlu())			;pipeAlu	:= Mux(pipeReset,ExuAlu.Null	,in.pipe.alu	)
	val pipeBfu		= Reg(ExuBfu())			;pipeBfu	:= Mux(pipeReset,ExuBfu.Null	,in.pipe.bfu	)
	val pipeCsr		= Reg(ExuCsr())			;pipeCsr	:= Mux(pipeReset,ExuCsr.Null	,in.pipe.csr	)
	val pipeRes		= Reg(ExuRes())			;pipeRes	:= Mux(pipeReset,ExuRes.Alu		,in.pipe.res	)
	val pipeIn1		= Reg(ExuIn1())			;pipeIn1	:= Mux(pipeReset,ExuIn1.R1		,in.pipe.in1	)
	val pipeIn2		= Reg(ExuIn2())			;pipeIn2	:= Mux(pipeReset,ExuIn2.R2		,in.pipe.in2	)
	
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
		val rdResult = WireInit(0.U(BitWidth.W))
		switch(pipeRes){
			is(ExuRes.Alu)	{rdResult := result}
			is(ExuRes.Null)	{rdResult := 0.U}
			is(ExuRes.Snpc)	{rdResult := pipePc+4.U}
			is(ExuRes.Csr)	{rdResult := pipeResult}//给rd的
		}
		out.pipe.result := rdResult
		when(pipeRdAddr =/= 0.U){
			when(out.imme.r1Addr === pipeRdAddr){out.imme.r1Out := rdResult}
			when(out.imme.r2Addr === pipeRdAddr){out.imme.r2Out := rdResult}
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