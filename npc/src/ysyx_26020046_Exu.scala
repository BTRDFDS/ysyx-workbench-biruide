import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Exu(val Yosys:Boolean=false) extends Module {
	val in = IO(new Bundle {
		val imme = Flipped(new ImmeLsEx())
		val pipe = Flipped(new PipeIdEx())
	})
	val out = IO(new Bundle {
		val imme = new ImmeExId()
		val pipe = new PipeExLs()
	})
	val pipeReset	= reset.asBool||(out.imme.jump && in.imme.ready)//||in.imme.error error被包含在jump里面了
	val pipeValid	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.valid	)
	val pipeFenceI	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.fenceI	)
	val pipeEnJcod	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.enJcod	)
	val pipeRdAddr	= PipeReg(pipeReset,0.U(RegWidth.W)		,out.imme.ready,in.pipe.rdAddr	)
	val pipeResult	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.result	)
	val pipePc		= PipeReg(pipeReset,0.U((BitWidth-2).W)	,out.imme.ready,in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.csrAddr	)
	val pipeCsrMesg	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.csrMesg	)
	val pipeR1		= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.r1		)
	val pipeR2		= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.r2		)
	val pipeLsuOp	= PipeReg(pipeReset,LsuOp.Null			,out.imme.ready,in.pipe.lsuOp	)
	val pipeLsuAddr	= PipeReg(pipeReset,LsuAddr.B			,out.imme.ready,in.pipe.lsuAddr	)
	val pipeCsrOp	= PipeReg(pipeReset,CsrOp.Null			,out.imme.ready,in.pipe.csrOp	)
	val pipeAlu		= PipeReg(pipeReset,ExuAlu.Null			,out.imme.ready,in.pipe.alu		)
	val pipeBfu		= PipeReg(pipeReset,ExuBfu.Null			,out.imme.ready,in.pipe.bfu		)
	val pipeCsr		= PipeReg(pipeReset,ExuCsr.Null			,out.imme.ready,in.pipe.csr		)
	val pipeRes		= PipeReg(pipeReset,ExuRes.Alu			,out.imme.ready,in.pipe.res		)
	val pipeIn1		= PipeReg(pipeReset,ExuIn1.R1			,out.imme.ready,in.pipe.in1		)
	val pipeIn2		= PipeReg(pipeReset,ExuIn2.R2			,out.imme.ready,in.pipe.in2		)

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

	val enBfun = WireInit(false.B)
	val result = WireInit(0.U(BitWidth.W))
	when(pipeValid){
		val input1 = Mux(pipeIn1 === ExuIn1.R1, pipeR1, Cat(pipePc,0.U(2.W)))
		val input2 = Mux(pipeIn2 === ExuIn2.R2, pipeR2, pipeResult)
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
		switch(pipeRes){
			is(ExuRes.Alu)	{out.pipe.result := result}
			is(ExuRes.Null)	{out.pipe.result := 0.U}
			is(ExuRes.Snpc)	{out.pipe.result := Cat(pipePc+1.U,0.U(2.W))}
			is(ExuRes.Csr)	{out.pipe.result := pipeResult}//给rd的
		}
	}

	val shouldBe = Mux(pipeEnJcod || enBfun, result(31,2)=/=in.pipe.pc, pipePc+1.U=/=in.pipe.pc)
	val hasSend = RegInit(false.B)
	when(out.imme.ready){hasSend := false.B}
	.elsewhen(pipeValid&&(pipeEnJcod||pipeBfu=/=ExuBfu.Null)){hasSend := true.B}
	//BJR
	// out.imme.jbpu := ~in.imme.error && (pipeValid && (pipeBfu=/=ExuBfu.Null || pipeEnJcod))
	// out.imme.jump :=  in.imme.error || (pipeValid && (pipeBfu=/=ExuBfu.Null || pipeEnJcod)&& ~hasSend && shouldBe=/=in.pipe.pc)//shouldBe其实还需要out.imme.jbpu，但是这里未进行拆分因此可以直接这样子
	//BJ

	out.imme.jbpu := ~in.imme.error && (pipeValid && (pipeBfu=/=ExuBfu.Null || (pipeEnJcod && pipeAlu=/=ExuAlu.Jalr)))
	out.imme.jump :=  in.imme.error || (pipeValid && (pipeBfu=/=ExuBfu.Null || pipeEnJcod)&& ~hasSend && (shouldBe || pipeAlu===ExuAlu.Jalr))

	out.imme.ready	:= in.imme.ready || ~pipeValid
	out.imme.addr	:= Mux(in.imme.error,in.imme.addr,Mux((pipeEnJcod || enBfun),result,Cat(pipePc+1.U,0.U(2.W))))
	out.imme.pc		:= Mux(in.imme.error,in.imme.pc	,pipePc)

	 in.imme.r1Addr	:= out.imme.r1Addr
	 in.imme.r2Addr	:= out.imme.r2Addr
	 in.imme.csrAddr:= out.imme.csrAddr
	out.imme.r1Out	:=  in.imme.r1Out
	out.imme.r2Out	:=  in.imme.r2Out
	out.imme.valid	:=  in.imme.valid
	out.imme.csrOut	:=  in.imme.csrOut
	when(pipeValid&&pipeRdAddr =/= 0.U){
		when(out.imme.r1Addr === pipeRdAddr){out.imme.r1Out := out.pipe.result}
		when(out.imme.r2Addr === pipeRdAddr){out.imme.r2Out := out.pipe.result}
		when(out.imme.r1Addr === pipeRdAddr || out.imme.r2Addr === pipeRdAddr){
			out.imme.valid := pipeLsuOp =/= LsuOp.Load//store理论上也可以
		}
	}

	if(Yosys == false){
		val exuPc = Mux(pipeValid,Cat(pipePc,0.U(2.W)),0.U(32.W));dontTouch(exuPc)
		val exuChk = Module(new ysyx_26020046_ExuChk)
		exuChk.clock:= clock
		exuChk.bnj	:= pipeValid&&pipeBfu=/=ExuBfu.Null&& ~enBfun && out.imme.ready
		exuChk.bij	:= pipeValid&&pipeBfu=/=ExuBfu.Null&&  enBfun && out.imme.ready
		exuChk.jum	:= pipeValid&&pipeBfu===ExuBfu.Null&& pipeEnJcod && out.imme.jump && pipeAlu=/=ExuAlu.Jalr
		exuChk.jlr	:= pipeValid&&pipeBfu===ExuBfu.Null&& pipeEnJcod && out.imme.jump && pipeAlu===ExuAlu.Jalr
		exuChk.addr := out.imme.addr
		exuChk.pc 	:= Cat(pipePc,0.U(2.W))
		exuChk.sext	:= pipeResult(31)
	}
}
class ysyx_26020046_ExuChk extends ExtModule{
	val bnj	= IO(Input(Bool()))
	val bij = IO(Input(Bool()))
	val jum = IO(Input(Bool()))
	val jlr = IO(Input(Bool()))
	val addr= IO(Input(UInt(32.W)))
	val pc	= IO(Input(UInt(32.W)))
	val sext= IO(Input(UInt( 1.W)))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_ExuChk.sv",
	"""
	module ysyx_26020046_ExuChk(
		input logic bnj,
		input logic bij,
		input logic jum,
		input logic jlr,
		input logic [31:0]addr,
		input logic [31:0]pc,
		input logic sext,
		input logic clock
	);
	import "DPI-C" function void exuBnTrace(int pc,byte state);
	import "DPI-C" function void exuBiTrace(int pc,byte state,int addr);
	always_ff@(posedge clock)begin
		if(bnj) exuBnTrace(pc,{5'b0,sext,2'b01});
		if(bij) exuBiTrace(pc,{5'b0,sext,2'b11},addr);
		if(jum) exuBiTrace(pc,{5'b0,1'b0,2'b10},addr);
		if(jlr) exuBiTrace(pc,{5'b0,1'b1,2'b10},addr);
	end
	endmodule
	"""
	)
}