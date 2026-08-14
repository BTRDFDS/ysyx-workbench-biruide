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
	val pipeReset	= reset.asBool||(out.imme.jump && in.imme.ready)//||in.imme.error error被包含在jump里面了
	val pipeValid	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.valid	)
	val pipeFenceI	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.fenceI	)
	val pipeEnJcod	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.enJcod	)
	val pipeEnBpu	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.enBpu	)
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

	val shouldBe = Mux((pipeEnJcod || enBfun),result,Cat(pipePc+1.U,0.U(2.W)))
	val noSend = RegInit(true.B)
	when(out.imme.ready){noSend := true.B}
	.elsewhen(pipeValid&&(pipeEnJcod||pipeEnBpu || pipeFenceI)){noSend := false.B}

	// ich.fenceI	:= (~in.imme.error && pipeValid) && pipeFenceI && noSend
	// out.imme.jbtb := (~in.imme.error && pipeValid) && (pipeEnBpu)
	// out.imme.jbpu := (~in.imme.error && pipeValid) && ~pipeEnJcod && pipeEnBpu
	
	ich.fenceI		:= false.B
	out.imme.jbtb 	:= false.B
	out.imme.jbpu 	:= false.B
	when((~in.imme.error && pipeValid)){
	ich.fenceI		:= pipeFenceI && noSend
	out.imme.jbtb	:= pipeEnBpu
	out.imme.jbpu	:= pipeEnBpu  && ~pipeEnJcod
	}
	out.imme.jump :=  in.imme.error || (pipeValid&& noSend  && (((pipeEnBpu || pipeEnJcod)&& shouldBe(31,2)=/=in.pipe.pc) || pipeFenceI))//shouldBe其实还需要out.imme.jbtb，但是这里未进行拆分因此可以直接这样子

	out.imme.ready	:= in.imme.ready || ~pipeValid
	out.imme.addr	:= Mux(in.imme.error,in.imme.addr,shouldBe)
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

	if(Yosys == false){}
}