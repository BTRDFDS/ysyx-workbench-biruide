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
	val ich		= IO(new FecneBus())
	val pipeReset	= reset.asBool||(out.imme.reloca && in.imme.ready)//||in.imme.error error被包含在jump里面了
	val pipeValid	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.valid	)
	val pipeFenceI	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.fenceI	)
	val pipeJump	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.jump	)
	val pipeUpdate	= PipeReg(pipeReset,IfuUpdate.Null		,out.imme.ready,in.pipe.update	)
	val pipeRdAddr	= PipeReg(pipeReset,0.U(RegWidth.W)		,out.imme.ready,in.pipe.rdAddr	)
	val pipeResult	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.result	)
	val pipePc		= PipeReg(pipeReset,0.U((BitWidth-2).W)	,out.imme.ready,in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(pipeReset,0.U(CsrWidth.W)		,out.imme.ready,in.pipe.csrAddr	)
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
			is(ExuAlu.Sll)	{result :=(input1 << input2(4,0))(31,0)}
			is(ExuAlu.Slt)	{result := input1.asSInt < input2.asSInt}
			is(ExuAlu.Sltu)	{result := input1 < input2}
			is(ExuAlu.Xor)	{result := input1 ^ input2}
			is(ExuAlu.Srl)	{result := input1 >> input2(4,0)}
			is(ExuAlu.Or)	{result := input1 | input2}
			is(ExuAlu.And)	{result := input1 & input2}
			is(ExuAlu.Sub)	{result := input1 - input2}
			is(ExuAlu.Sra)	{result :=(input1.asSInt >> input2(4,0)).asUInt}
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

	val shouldBe = Mux((pipeJump || enBfun),result,Cat(pipePc+1.U,0.U(2.W)))
	val noSend = RegInit(true.B)
	when(out.imme.ready){noSend := true.B}
	.elsewhen(pipeValid&&(out.imme.reloca || pipeFenceI)){noSend := false.B}

	ich.fenceI	:= (~in.imme.error && pipeValid) && pipeFenceI && noSend
	out.imme.ready	:= in.imme.ready || ~pipeValid
	out.imme.update	:= IfuUpdate.Null
	out.imme.reloca	:= false.B
	when(in.imme.error){
		out.imme.addr	:= in.imme.addr
		out.imme.pc		:= in.imme.pc
		out.imme.reloca	:= true.B
	}.otherwise{
		out.imme.addr	:= shouldBe
		out.imme.pc		:= pipePc
		when(pipeValid&&noSend){
			when(in.pipe.pc =/= shouldBe(31,2)||pipeFenceI){
				out.imme.reloca := true.B
				out.imme.update	:= Mux1H(Seq(
					(pipeUpdate === IfuUpdate.Jalr)		-> IfuUpdate.Jalr,
					(pipeUpdate === IfuUpdate.Jal)		-> IfuUpdate.Jal,
					(pipeUpdate === IfuUpdate.Branch)	-> Mux(enBfun,IfuUpdate.Branch,IfuUpdate.Null),
					(pipeUpdate === IfuUpdate.Null)		-> IfuUpdate.Null
				))
			}
		}
	}

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

	if(Yosys == false){
		dontTouch(result)
		dontTouch(shouldBe)
		dontTouch(noSend)
	}
}