import chisel3._
import chisel3.util._
import WidthConsts._

class exu(val Yosys:Boolean=false) extends Module {
	val in = IO(new Bundle {
		val imme = Flipped(new ImmeLsEx())
		val pipe = Flipped(new PipeIdEx())
	})
	val out = IO(new Bundle {
		val imme = new ImmeExId()
		val pipe = new PipeExLs()
	})
	val ich		= IO(new FecneBus())
	val pipeReset	= reset.asBool||(out.imme.reloca && in.imme.ready)//||in.imme.error error被包含在jump里面了
	val pipeValid	= PipeReg(in.pipe.valid		,out.imme.ready,false.B		,pipeReset)
	val pipeCsrOp	= PipeReg(in.pipe.csrOp		,out.imme.ready,CsrOp.Null	,pipeReset)
	val pipeFenceI	= PipeReg(in.pipe.fenceI	,out.imme.ready)
	val pipeJump	= PipeReg(in.pipe.jump		,out.imme.ready)
	val pipeUpdate	= PipeReg(in.pipe.update	,out.imme.ready)
	val pipeRdAddr	= PipeReg(in.pipe.rdAddr	,out.imme.ready)
	val pipeResult	= PipeReg(in.pipe.result	,out.imme.ready)
	val pipePc		= PipeReg(in.pipe.pc		,out.imme.ready)
	val pipeCsrAddr	= PipeReg(in.pipe.csrAddr	,out.imme.ready)
	val pipeCsrMesg	= PipeReg(in.pipe.csrMesg	,out.imme.ready)
	val pipeR1		= PipeReg(in.pipe.r1		,out.imme.ready)
	val pipeR2		= PipeReg(in.pipe.r2		,out.imme.ready)
	val pipeLsuOp	= PipeReg(in.pipe.lsuOp		,out.imme.ready,LsuOp.Null	,pipeReset)
	val pipeLsuAddr	= PipeReg(in.pipe.lsuAddr	,out.imme.ready)
	val pipeAlu		= PipeReg(in.pipe.alu		,out.imme.ready)
	val pipeBfu		= PipeReg(in.pipe.bfu		,out.imme.ready)
	val pipeCsr		= PipeReg(in.pipe.csr		,out.imme.ready)
	val pipeRes		= PipeReg(in.pipe.res		,out.imme.ready)
	val pipeIn1		= PipeReg(in.pipe.in1		,out.imme.ready)
	val pipeIn2		= PipeReg(in.pipe.in2		,out.imme.ready)

	out.pipe.lsuAddr:= pipeLsuAddr
	out.pipe.lsuOp	:= pipeLsuOp
	out.pipe.r2		:= pipeR2
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= pipeCsrOp
	out.pipe.csrAddr:= pipeCsrAddr
	out.pipe.valid	:= pipeValid
	out.pipe.rdAddr	:= pipeRdAddr
	// out.pipe.result := 0.U
	// out.pipe.csrMesg:= pipeCsrMesg

	val enBfun = WireInit(false.B)
	val result = WireInit(0.U(BitWidth.W))
	val input1 = Mux(pipeIn1 === ExuIn1.R1, pipeR1, Cat(pipePc,0.U(2.W)))
	val input2 = Mux(pipeIn2 === ExuIn2.R2, pipeR2, pipeResult)
	out.pipe.csrMesg := Mux1H(Seq(
		(pipeCsr === ExuCsr.Read)	->(pipeR1 | pipeCsrMesg),
		(pipeCsr === ExuCsr.Write)	->(pipeR1),
		(pipeCsr === ExuCsr.Null)	->(pipeCsrMesg)
	))
	result := Mux1H(Seq(
		(pipeAlu === ExuAlu.Add)	->(input1 + input2),
		(pipeAlu === ExuAlu.Sll)	->((input1 << input2(4,0))(31,0)),
		(pipeAlu === ExuAlu.Slt)	->(input1.asSInt < input2.asSInt),
		(pipeAlu === ExuAlu.Sltu)	->(input1 < input2),
		(pipeAlu === ExuAlu.Xor)	->(input1 ^ input2),
		(pipeAlu === ExuAlu.Srl)	->(input1 >> input2(4,0)),
		(pipeAlu === ExuAlu.Or)		->(input1 | input2),
		(pipeAlu === ExuAlu.And)	->(input1 & input2),
		(pipeAlu === ExuAlu.Sub)	->(input1 - input2),
		(pipeAlu === ExuAlu.Sra)	->((input1.asSInt >> input2(4,0)).asUInt)
	))
	enBfun := Mux1H(Seq(
		(pipeBfu === ExuBfu.Beq)	->(pipeR1 === pipeR2),
		(pipeBfu === ExuBfu.Bne)	->(pipeR1 =/= pipeR2),
		(pipeBfu === ExuBfu.Blt)	->(pipeR1.asSInt < pipeR2.asSInt),
		(pipeBfu === ExuBfu.Bge)	->(pipeR1.asSInt >= pipeR2.asSInt),
		(pipeBfu === ExuBfu.Bltu)	->(pipeR1 < pipeR2),
		(pipeBfu === ExuBfu.Bgeu)	->(pipeR1 >= pipeR2),
		(pipeBfu === ExuBfu.Null)	->(false.B)
	))
	out.pipe.result := Mux1H(Seq(
		(pipeRes === ExuRes.Alu)	->(result),
		(pipeRes === ExuRes.Null)	->(0.U),
		(pipeRes === ExuRes.Snpc)	->(Cat(pipePc+1.U,0.U(2.W))),
		(pipeRes === ExuRes.Imm)	->(pipeResult)
	))

	val shouldBe = Mux((pipeJump || enBfun),input1+pipeResult,Cat(pipePc+1.U,0.U(2.W)))
	val noSend = RegInit(true.B)
	when(out.imme.ready){noSend := true.B}
	.elsewhen(pipeValid&&(out.imme.reloca || pipeFenceI)){noSend := false.B}

	ich.fenceI	:= pipeValid&&noSend&&pipeFenceI
	out.imme.ready	:= in.imme.ready || ~pipeValid
	out.imme.reloca	:= in.imme.error || (pipeValid&&noSend&&(in.pipe.pc =/= shouldBe(31,2)||pipeFenceI))
	out.imme.addr	:= Mux(in.imme.error,in.imme.addr,shouldBe)
	out.imme.pc		:= pipePc
	val updateMaybe = Mux1H(Seq(
		(pipeUpdate === IfuUpdate.Jalr)		-> IfuUpdate.Jalr,
		(pipeUpdate === IfuUpdate.Jal)		-> IfuUpdate.Jal,
		(pipeUpdate === IfuUpdate.Branch)	-> Mux(enBfun,IfuUpdate.Branch,IfuUpdate.Null),
		(pipeUpdate === IfuUpdate.Null)		-> IfuUpdate.Null
	))
	out.imme.update	:= Mux(pipeValid&&noSend&&(~in.imme.error)&&(in.pipe.pc =/= shouldBe(31,2)||pipeFenceI),updateMaybe,IfuUpdate.Null)

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
		when(out.imme.r1Addr === pipeRdAddr || out.imme.r2Addr === pipeRdAddr){out.imme.valid := pipeLsuOp =/= LsuOp.Load}//store理论上也可以
	}
	when(pipeValid&&out.imme.csrAddr === pipeCsrAddr){out.imme.csrOut := out.pipe.csrMesg}

	if(Yosys == false){
		dontTouch(result)
		dontTouch(shouldBe)
		dontTouch(noSend)
	}
}