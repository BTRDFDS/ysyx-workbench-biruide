import chisel3._
import chisel3.util._
import WidthConsts._

class wbu(val Yosys:Boolean=false) extends Module {
	val PcReset:UInt=0x80000000L.U(BitWidth.W)
	val MstatuseReset = 0x1800.U(BitWidth.W)
	val ErrorMesg = 2.U(BitWidth.W)

	val in = IO(new Bundle {
		val pipe = Flipped(new PipeLsWb())
	})
	val out = IO(new Bundle {
		val imme = new ImmeWbLs()
	})
	val pipeReset	= reset.asBool||out.imme.error
	val pipeValid	= PipeReg(in.pipe.valid		,false.B	,pipeReset)
	val pipeCsrOp	= PipeReg(in.pipe.csrOp		,CsrOp.Null	,pipeReset)
	val pipeRdAddr	= PipeReg(in.pipe.rdAddr	)
	val pipeResult	= PipeReg(in.pipe.result	)
	val pipePc		= PipeReg(in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(in.pipe.csrAddr	)
	val pipeCsrMesg	= PipeReg(in.pipe.csrMesg	)
	

	val gpr = Reg(Vec(RegNum, UInt(BitWidth.W)))

	// val mepc		= RegInit(PcReset)
	// val mtvec		= RegInit(PcReset)
	val mtvec		= Reg(UInt(BitWidth.W))
	val mepc		= Reg(UInt(BitWidth.W))
	val mstatus		= RegInit(MstatuseReset)
	val mcause		= RegInit(0xffffffffL.U(BitWidth.W))
	val mcycle		= RegInit(0.U(BitWidth.W))
	val mcycleh		= RegInit(0.U(BitWidth.W))
	val marchid		= 0x018D08CE.U
	val mvendorid	= 0x79737978.U

	val nextMcycle	= Wire(UInt(BitWidth.W));nextMcycle	:= mcycle + 1.U
	val nextMcycleh	= Wire(UInt(BitWidth.W));nextMcycleh:= Mux(mcycle === (Fill(BitWidth,1.U)),mcycleh + 1.U,mcycleh)
	val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(pipeCsrAddr(CsrWidth-1,0))
	val error = pipeValid && ((pipeCsrOp === CsrOp.Mret) || (pipeCsrOp === CsrOp.Write && ~csrWriteValid))
	val mret = pipeValid && pipeCsrOp === CsrOp.Mret
	// when(pipeValid){//合法处理
	// 	switch(pipeCsrOp){
	// 		is(CsrOp.Mret){
	// 			mstatus := Cat(mstatus(31,13),0b00.U(2.W),mstatus(10,3),mstatus(1),mstatus(2),1.U(1.W),mstatus(0))
	// 			}
			// is(CsrOp.Trap){
			// 	mstatus := Cat(mstatus(31,13),0b11.U(2.W),mstatus(10,3),0.U(1.W),mstatus(2),mstatus(3),mstatus(0))
			// 	mcause	:= pipeCsrMesg
			// 	mepc 	:= Cat(pipePc,0.U(2.W))
			// }//TODO
	// 		is(CsrOp.Write){
	// 			when(csrWriteValid){
	// 				switch(csrWriteAddr){
	// 					is(CsrAddr.Mcycle)		{nextMcycle	:= pipeCsrMesg}
	// 					is(CsrAddr.Mcycleh)		{nextMcycleh:= pipeCsrMesg}
	// 					is(CsrAddr.Mepc)		{mepc		:= pipeCsrMesg}
	// 					is(CsrAddr.Mtvec)		{mtvec		:= pipeCsrMesg}
	// 					is(CsrAddr.Mcause)		{mcause		:= pipeCsrMesg}
	// 					is(CsrAddr.Mstatus)		{mstatus	:= pipeCsrMesg}
	// 				}
	// 			}
	// 		}
	// 	}
		
	// }

	when(pipeValid && pipeCsrOp===CsrOp.Write && csrWriteValid && csrWriteAddr === CsrAddr.Mcycle)	{nextMcycle	:= pipeCsrMesg}
	when(pipeValid && pipeCsrOp===CsrOp.Write && csrWriteValid && csrWriteAddr === CsrAddr.Mcycleh)	{nextMcycleh:= pipeCsrMesg}
	when(pipeValid && pipeCsrOp===CsrOp.Write && csrWriteValid && csrWriteAddr === CsrAddr.Mcause)	{mcause		:= pipeCsrMesg}
	when(pipeValid && pipeCsrOp===CsrOp.Write && csrWriteValid && csrWriteAddr === CsrAddr.Mstatus)	{mstatus	:= pipeCsrMesg}
	when(pipeValid && pipeCsrOp===CsrOp.Write && csrWriteValid && csrWriteAddr === CsrAddr.Mepc)	{mepc		:= pipeCsrMesg}
	when(pipeValid && pipeCsrOp===CsrOp.Write && csrWriteValid && csrWriteAddr === CsrAddr.Mtvec)	{mtvec		:= pipeCsrMesg}
	when(pipeValid && pipeRdAddr=/=0.U && ~csrWriteValid){gpr(pipeRdAddr) := pipeResult}
	when(error){
		// mstatus := Cat(mstatus(31,13),0b11.U(2.W),mstatus(10,3),0.U(1.W),mstatus(2),mstatus(3),mstatus(0))
		mcause	:= pipeCsrMesg
		mepc 	:= Cat(pipePc,0.U(2.W))
	}

	mcycle := nextMcycle;mcycleh := nextMcycleh
	out.imme.addr	:= Mux(pipeCsrOp === CsrOp.Mret,mepc,mtvec)
	out.imme.pc		:= pipePc
	out.imme.error	:= error || mret
//提供数据
	out.imme.r1Valid	:= true.B
	out.imme.r2Valid	:= true.B
	out.imme.csrOut := 0.U
	out.imme.r1Out	:= Mux(out.imme.r1Addr === 0.U, 0.U,Mux(pipeValid&&out.imme.r1Addr===pipeRdAddr,pipeResult,gpr(out.imme.r1Addr)))
	out.imme.r2Out	:= Mux(out.imme.r2Addr === 0.U, 0.U,Mux(pipeValid&&out.imme.r2Addr===pipeRdAddr,pipeResult,gpr(out.imme.r2Addr)))
	out.imme.csrOut := Mux1H(Seq(
		(out.imme.csrAddr===CsrAddr.Mcycle.asUInt)		-> mcycle,
		(out.imme.csrAddr===CsrAddr.Mcycleh.asUInt)		-> mcycleh,
		(out.imme.csrAddr===CsrAddr.Mepc.asUInt)		-> mepc,
		(out.imme.csrAddr===CsrAddr.Mtvec.asUInt)		-> mtvec,
		(out.imme.csrAddr===CsrAddr.Mcause.asUInt)		-> mcause,
		(out.imme.csrAddr===CsrAddr.Mstatus.asUInt)		-> mstatus,
		(out.imme.csrAddr===CsrAddr.Marchid.asUInt)		-> marchid,
		(out.imme.csrAddr===CsrAddr.Mvendorid.asUInt)	-> mvendorid,
	))
	if(Yosys == false){
		when(pipeCsrMesg =/= 3.U && pipeCsrMesg =/= 11.U && error && pipeCsrOp =/= CsrOp.Mret){
			when(pipeValid === true.B & pipeCsrOp === CsrOp.Trap){printf("pipe err catch\n")}
			.elsewhen(error){printf("wbu err catch\n")}
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