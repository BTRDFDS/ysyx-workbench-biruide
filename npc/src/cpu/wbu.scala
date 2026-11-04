import chisel3._
import chisel3.util._
import WidthConsts._

class wbu(val Yosys:Boolean=false) extends Module {
	val PcReset:UInt=0x80000000L.U(BitWidth.W)
	val MstatuseReset = 0x1800.U(BitWidth.W)
	val ErrorMesg = 2.U(4.W)

	val in = IO(new Bundle {
		val pipe = Flipped(new PipeLsWb())
	})
	val out = IO(new Bundle {
		val imme = new ImmeWbLs()
	})
	val pipeReset	= reset.asBool||out.imme.reloca
	val pipeValid	= PipeReg(in.pipe.valid		,false.B	,pipeReset)
	val pipeCsrOp	= PipeReg(in.pipe.csrOp		,CsrOp.Null	,pipeReset)
	val pipeRdAddr	= PipeReg(in.pipe.rdAddr	)
	val pipeResult	= PipeReg(in.pipe.result	)
	val pipePc		= PipeReg(in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(in.pipe.csrAddr	)
	val pipeCsrMesg	= PipeReg(in.pipe.csrMesg	)
	

	val gpr = Reg(Vec(RegNum, UInt(BitWidth.W)))
	val mtvec		= Reg(UInt(BitWidth.W))
	val mepc		= Reg(UInt(BitWidth.W))
	
	// val mstatus		= RegInit(MstatuseReset)
	val mpie		= RegInit(0.U(1.W))
	val mie			= RegInit(0.U(1.W))
	val mstatus = Cat(0.U(19.W),0b11.U(2.W),0.U(3.W),mpie,0.U(3.W),mie,0.U(3.W))

	val mcause		= RegInit(0.U(4.W))
	val mcycle		= RegInit(0.U(BitWidth.W))
	val mcycleh		= RegInit(0.U(BitWidth.W))
	val marchid		= 0x018D08CE.U
	val mvendorid	= 0x79737978.U

	val mcycleAdd = mcycle +& 1.U
	val nextMcycle	= Wire(UInt(BitWidth.W));nextMcycle	:= mcycleAdd(BitWidth-1,0)
	val nextMcycleh	= Wire(UInt(BitWidth.W));nextMcycleh:= mcycleh + mcycleAdd(32)
	// val (_,csrWriteValid)=CsrAddr.safe(pipeCsrAddr(CsrWidth-1,0))
	// val trap = pipeValid && ((pipeCsrOp === CsrOp.Trap) || (pipeCsrOp === CsrOp.Write && ~csrWriteValid))
	val trap = pipeValid && pipeCsrOp === CsrOp.Trap
	val mret = pipeValid && pipeCsrOp === CsrOp.Mret

	when(pipeValid && pipeCsrOp===CsrOp.Write && pipeCsrAddr === CsrAddr.Mcycle)	{nextMcycle	:= pipeCsrMesg}
	when(pipeValid && pipeCsrOp===CsrOp.Write && pipeCsrAddr === CsrAddr.Mcycleh)	{nextMcycleh:= pipeCsrMesg}
	// when(pipeValid && pipeCsrOp===CsrOp.Write && pipeCsrAddr === CsrAddr.Mstatus.asUInt)	{mstatus	:= pipeCsrMesg}
	when(pipeValid && pipeCsrOp===CsrOp.Write && pipeCsrAddr === CsrAddr.Mstatus)	{mpie		:= pipeCsrMesg(7)}
	when(pipeValid && pipeCsrOp===CsrOp.Write && pipeCsrAddr === CsrAddr.Mstatus)	{mie		:= pipeCsrMesg(3)}
	when(pipeValid && pipeCsrOp===CsrOp.Write && pipeCsrAddr === CsrAddr.Mtvec)		{mtvec		:= pipeCsrMesg}
	when(pipeValid && ((pipeCsrOp===CsrOp.Write && pipeCsrAddr===CsrAddr.Mepc)  || trap)){mepc	:= Mux(trap,Cat(pipePc,0.U(2.W)),pipeCsrMesg)}
	when(pipeValid && ((pipeCsrOp===CsrOp.Write && pipeCsrAddr===CsrAddr.Mcause)|| trap)){mcause	:= pipeCsrMesg(3,0)}
	when(pipeValid && pipeRdAddr=/=0.U && (pipeCsrOp===CsrOp.Null || pipeCsrOp===CsrOp.Write)){gpr(pipeRdAddr) := pipeResult}


//TODO
// mstatus := Cat(mstatus(31,13),0b11.U(2.W),mstatus(10,3),0.U(1.W),mstatus(2),mstatus(3),mstatus(0))
// mstatus := Cat(mstatus(31,13),0b00.U(2.W),mstatus(10,3),mstatus(1),mstatus(2),1.U(1.W),mstatus(0))




	mcycle := nextMcycle;mcycleh := nextMcycleh
	out.imme.addr	:= Mux(pipeCsrOp === CsrOp.Mret,mepc,mtvec)
	out.imme.reloca	:= trap || mret
//提供数据
	out.imme.r1Valid	:= true.B
	out.imme.r2Valid	:= true.B
	out.imme.csrOut := 0.U
	out.imme.r1Out	:= Mux(out.imme.r1Addr === 0.U, 0.U,Mux(pipeValid&&out.imme.r1Addr===pipeRdAddr,pipeResult,gpr(out.imme.r1Addr)))
	out.imme.r2Out	:= Mux(out.imme.r2Addr === 0.U, 0.U,Mux(pipeValid&&out.imme.r2Addr===pipeRdAddr,pipeResult,gpr(out.imme.r2Addr)))
	out.imme.csrOut := Mux1H(Seq(
		(out.imme.csrAddr===CsrAddr.Mcycle		)-> mcycle,
		(out.imme.csrAddr===CsrAddr.Mcycleh		)-> mcycleh,
		(out.imme.csrAddr===CsrAddr.Mepc		)-> mepc,
		(out.imme.csrAddr===CsrAddr.Mtvec		)-> mtvec,
		(out.imme.csrAddr===CsrAddr.Mcause		)-> Cat(0.U(28.W),mcause),
		(out.imme.csrAddr===CsrAddr.Mstatus		)-> mstatus,
		(out.imme.csrAddr===CsrAddr.Marchid		)-> marchid,
		(out.imme.csrAddr===CsrAddr.Mvendorid	)-> mvendorid,
	))
	if(Yosys == false){
		when(pipeCsrMesg =/= 3.U && pipeCsrMesg =/= 11.U && trap && pipeCsrOp =/= CsrOp.Mret){
			when(pipeValid === true.B & pipeCsrOp === CsrOp.Trap){printf("pipe err catch\n")}
			.elsewhen(trap){printf("wbu err catch\n")}
			printf("stop %x at %8x ",pipeCsrMesg,Cat(pipePc,0.U(2.W)))//tval
			switch(pipeCsrMesg){
				// is(3.U	){printf("ebreak\n")}
				// is(11.U	){printf("ecall\n")}
				is(0.U	){printf("ifuN4\n")}
				is(1.U	){printf("ifuErr\n")}
				is(2.U	){printf("instr\n")}
				is(4.U	){printf("laddr\n")}
				is(5.U	){printf("lerror\n")}
				is(6.U	){printf("sAddr\n")}
				is(7.U	){printf("sError\n")}
			}
			stop()
		}
	}
}