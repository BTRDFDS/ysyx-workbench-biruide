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
	val pipeReset	= reset.asBool||(out.imme.reloca && in.imme.ready)//||in.imme.reloca error被包含在jump里面了
	val pipeValid	= PipeReg(in.pipe.valid		,out.imme.ready,false.B		,pipeReset)
	val pipeCsrOp	= PipeReg(in.pipe.csrOp		,out.imme.ready,CsrOp.Null	,pipeReset)
	val pipeFenceI	= PipeReg(in.pipe.fenceI	,out.imme.ready)
	val pipeRdAddr	= PipeReg(in.pipe.rdAddr	,out.imme.ready)
	val pipeImm		= PipeReg(in.pipe.imm		,out.imme.ready)
	val pipePc		= PipeReg(in.pipe.pc		,out.imme.ready)
	val pipeCsrAddr	= PipeReg(in.pipe.csrAddr	,out.imme.ready)
	val pipeR1		= PipeReg(in.pipe.r1		,out.imme.ready)
	val pipeR2		= PipeReg(in.pipe.r2		,out.imme.ready)
	val pipeLsuOp	= PipeReg(in.pipe.lsuOp		,out.imme.ready,LsuOp.Null	,pipeReset)
	val pipeLsuAddr	= PipeReg(in.pipe.lsuAddr	,out.imme.ready)
	val pipeSext	= PipeReg(in.pipe.sext	,out.imme.ready)
	val pipeAlu		= PipeReg(in.pipe.alu		,out.imme.ready)
	val pipeBfu		= PipeReg(in.pipe.bfu		,out.imme.ready)
	val pipeCsr		= PipeReg(in.pipe.csr		,out.imme.ready)
	val pipeIn1		= PipeReg(in.pipe.in1		,out.imme.ready)
	val pipeIn2		= PipeReg(in.pipe.in2		,out.imme.ready)

	out.pipe.lsuAddr:= pipeLsuAddr
	out.pipe.lsuOp	:= pipeLsuOp
	out.pipe.sext:= pipeSext
	out.pipe.r2		:= pipeR2
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= pipeCsrOp
	out.pipe.csrAddr:= pipeCsrAddr
	out.pipe.valid	:= pipeValid
	out.pipe.rdAddr	:= pipeRdAddr

	val enBfun = WireInit(false.B)
	val result = WireInit(0.U(BitWidth.W))
	// val input1 = Mux(pipeIn1 === ExuIn1.R1, pipeR1, Cat(pipePc,0.U(2.W)))
	// val input2 = Mux(pipeIn2 === ExuIn2.R2, pipeR2, pipeImm)
	val input1 = Mux1H(Seq(
		(pipeIn1 === ExuIn1.R1)	->(pipeR1),
		(pipeIn1 === ExuIn1.Pc)	->(Cat(pipePc,0.U(2.W))),
		(pipeIn1 === ExuIn1.Sll)->(Reverse(pipeR1)),
	))
	val input2 = Mux1H(Seq(
		(pipeIn2 === ExuIn2.R2)	->(pipeR2),
		(pipeIn2 === ExuIn2.Imm)->(pipeImm),
		(pipeIn2 === ExuIn2.Sub)->((~pipeR2)+1.U),
	))
	val resultAdd = input1 + input2
	val snpc = Cat(pipePc+1.U,0.U(2.W))
	val sraInput = Cat(pipeSext&&input1(31),input1)
	val sraOutput= (sraInput.asSInt >> input2(4,0))(31,0).asUInt
	out.pipe.result := Mux1H(Seq(
		(pipeAlu === ExuAlu.Add)	->(resultAdd),//input1 + input2
		(pipeAlu === ExuAlu.Sll)	->(Reverse(sraOutput)),//(input1 << input2(4,0))(31,0)
		(pipeAlu === ExuAlu.Slt)	->(input1.asSInt < input2.asSInt),
		(pipeAlu === ExuAlu.Sltu)	->(input1 < input2),
		(pipeAlu === ExuAlu.Xor)	->(input1 ^ input2),
		(pipeAlu === ExuAlu.Srl)	->(sraOutput),//input1 >> input2(4,0)
		(pipeAlu === ExuAlu.Or)		->(input1 | input2),
		(pipeAlu === ExuAlu.And)	->(input1 & input2),
		// (pipeAlu === ExuAlu.Sub)	->(input1 - input2),
		// (pipeAlu === ExuAlu.Sra)	->((input1.asSInt >> input2(4,0)).asUInt),
		(pipeAlu === ExuAlu.Snpc)	->(snpc),
		(pipeAlu === ExuAlu.Imm)	->(pipeImm),
	))
	enBfun := Mux1H(Seq(
		(pipeBfu === ExuBfu.Beq)	->(pipeR1 === pipeR2),
		(pipeBfu === ExuBfu.Bne)	->(pipeR1 =/= pipeR2),
		(pipeBfu === ExuBfu.Blt)	->(pipeR1.asSInt < pipeR2.asSInt),
		(pipeBfu === ExuBfu.Bge)	->(pipeR1.asSInt >= pipeR2.asSInt),
		(pipeBfu === ExuBfu.Bltu)	->(pipeR1 < pipeR2),
		(pipeBfu === ExuBfu.Bgeu)	->(pipeR1 >= pipeR2),
		(pipeBfu === ExuBfu.Null)	->(false.B),
		(pipeBfu === ExuBfu.Jump)	->(true.B),
	))
	out.pipe.csrMesg := Mux1H(Seq(
		(pipeCsr === ExuCsr.Rs)		->(pipeR1 | pipeImm),
		(pipeCsr === ExuCsr.Rw)		->(pipeR1),
		(pipeCsr === ExuCsr.Null)	->(pipeImm),
	))
	val shouldBe = Mux(enBfun && ~pipeFenceI,resultAdd,snpc)
	val noSend = RegInit(true.B)
	when(out.imme.ready){noSend := true.B}
	.elsewhen(pipeValid&&(out.imme.reloca || pipeFenceI)){noSend := false.B}

	ich.fenceI		:= pipeValid&&noSend&&pipeFenceI
	out.imme.ready	:= in.imme.ready || ~pipeValid
	out.imme.reloca	:= in.imme.reloca || pipeValid&&(noSend&&(in.pipe.pc =/= shouldBe(31,2)||pipeFenceI))
	out.imme.addr	:= Mux(in.imme.reloca,in.imme.addr,shouldBe)
	out.imme.pc		:= pipePc
	out.imme.update	:= pipeValid&&noSend&&(~in.imme.reloca)&&(in.pipe.pc =/= shouldBe(31,2))&&enBfun

	 in.imme.r1Addr	:= out.imme.r1Addr
	 in.imme.r2Addr	:= out.imme.r2Addr
	 in.imme.csrAddr:= out.imme.csrAddr
	out.imme.r1Out	:= Mux(pipeValid&&pipeRdAddr === out.imme.r1Addr&&pipeRdAddr =/= 0.U,out.pipe.result,in.imme.r1Out)
	out.imme.r2Out	:= Mux(pipeValid&&pipeRdAddr === out.imme.r2Addr&&pipeRdAddr =/= 0.U,out.pipe.result,in.imme.r2Out)
	out.imme.csrOut	:= Mux(pipeValid&&out.imme.csrAddr === pipeCsrAddr,out.pipe.csrMesg,in.imme.csrOut)
	out.imme.r1Valid:= Mux(pipeValid&&pipeRdAddr === out.imme.r1Addr&&pipeRdAddr =/= 0.U,pipeLsuOp===LsuOp.Null,in.imme.r1Valid)
	out.imme.r2Valid:= Mux(pipeValid&&pipeRdAddr === out.imme.r2Addr&&pipeRdAddr =/= 0.U,pipeLsuOp===LsuOp.Null,in.imme.r2Valid)
	if(Yosys == false){
		dontTouch(result)
		dontTouch(shouldBe)
		dontTouch(noSend)
		dontTouch(sraInput)
		dontTouch(sraOutput)
	}
}