import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Wbu(val Yosys:Boolean=false) extends Module {
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
	val pipeValid	= PipeReg(pipeReset,false.B				,true.B,in.pipe.valid	)
	val pipeRdAddr	= PipeReg(pipeReset,0.U(RegWidth.W)		,true.B,in.pipe.rdAddr	)
	val pipeResult	= PipeReg(pipeReset,0.U(BitWidth.W)		,true.B,in.pipe.result	)
	val pipePc		= PipeReg(pipeReset,0.U((BitWidth-2).W)	,true.B,in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(pipeReset,0.U(CsrWidth.W)		,true.B,in.pipe.csrAddr	)
	val pipeCsrMesg	= PipeReg(pipeReset,0.U(BitWidth.W)		,true.B,in.pipe.csrMesg	)
	val pipeCsrOp	= PipeReg(pipeReset,CsrOp.Null			,true.B,in.pipe.csrOp	)
	

	val gpr = Reg(Vec(RegNum, UInt(BitWidth.W)))

	val mepc		= RegInit(PcReset)
	val mstatus		= RegInit(MstatuseReset)
	val mtvec		= RegInit(PcReset)
	val mcause		= RegInit(0xffffffffL.U(BitWidth.W))
	val mcycle		= RegInit(0.U(BitWidth.W))
	val mcycleh		= RegInit(0.U(BitWidth.W))
	val marchid		= 0x018D08CE.U
	val mvendorid	= 0x79737978.U

	val error = WireInit(false.B)
	val nextMcycle	= Wire(UInt(BitWidth.W));nextMcycle	:= mcycle + 1.U
	val nextMcycleh	= Wire(UInt(BitWidth.W));nextMcycleh:= Mux(mcycle === (Fill(BitWidth,1.U)),mcycleh + 1.U,mcycleh)
	when(pipeValid){//合法处理
		switch(pipeCsrOp){
			is(CsrOp.Mret){mstatus := MstatuseReset}//TODO
			is(CsrOp.Trap){//TODO:mstatus
				mcause	:= pipeCsrMesg
				mepc 	:= Cat(pipePc,0.U(2.W))
			}
			is(CsrOp.Write){
				val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(pipeCsrAddr(CsrWidth-1,0))
				when(csrWriteValid){
					switch(csrWriteAddr){
						is(CsrAddr.Mcycle)		{nextMcycle	:= pipeCsrMesg}
						is(CsrAddr.Mcycleh)		{nextMcycleh:= pipeCsrMesg}
						is(CsrAddr.Mepc)		{mepc		:= pipeCsrMesg}
						is(CsrAddr.Mtvec)		{mtvec		:= pipeCsrMesg}
						is(CsrAddr.Mcause)		{mcause		:= pipeCsrMesg}
						is(CsrAddr.Mstatus)		{mstatus	:= pipeCsrMesg}
					}
				}otherwise{error := true.B}
			}
			// is(CsrOp.Null){}//空，这里4个全覆盖了
		}
		when((pipeRdAddr =/= 0.U)&(error === false.B)){gpr(pipeRdAddr) := pipeResult}
	}
	mcycle := nextMcycle;mcycleh := nextMcycleh

	out.imme.addr	:= mtvec
	out.imme.pc		:= pipePc
	out.imme.error	:= false.B
	when((pipeValid === false.B & pipeCsrOp === CsrOp.Trap) || error){//TODO:mstatus
		mcause			:= Mux(error,ErrorMesg,pipeCsrMesg)
		mepc 			:= Cat(pipePc,0.U(2.W))
		out.imme.error	:= true.B
		if(Yosys == false){
			when(pipeValid === false.B & pipeCsrOp === CsrOp.Trap){printf("pipe err catch\n")}
			when(error){printf("wbu err catch\n")}
			printf("error,stop!!! %x",pipeCsrMesg)//tval
			switch(pipeCsrMesg){
				is(3.U	){printf("ebreak\n")}
				is(11.U	){printf("ecall\n")}
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
//提供数据
	out.imme.valid	:= true.B
	out.imme.csrOut := 0.U
	out.imme.r1Out	:= Mux(out.imme.r1Addr === 0.U, 0.U,Mux(pipeValid&&out.imme.r1Addr===pipeRdAddr,pipeResult,gpr(out.imme.r1Addr)))
	out.imme.r2Out	:= Mux(out.imme.r2Addr === 0.U, 0.U,Mux(pipeValid&&out.imme.r2Addr===pipeRdAddr,pipeResult,gpr(out.imme.r2Addr)))
	val (csrReadAddr,csrReadValid)=CsrAddr.safe(out.imme.csrAddr)
	when(pipeValid&&csrReadValid){switch(csrReadAddr){
		is(CsrAddr.Mcycle)		{out.imme.csrOut := mcycle}
		is(CsrAddr.Mcycleh)		{out.imme.csrOut := mcycleh}
		is(CsrAddr.Mepc)		{out.imme.csrOut := mepc}
		is(CsrAddr.Mtvec)		{out.imme.csrOut := mtvec}
		is(CsrAddr.Mcause)		{out.imme.csrOut := mcause}
		is(CsrAddr.Mstatus)		{out.imme.csrOut := mstatus}
		is(CsrAddr.Marchid)		{out.imme.csrOut := marchid}
		is(CsrAddr.Mvendorid)	{out.imme.csrOut := mvendorid}
	}}
	
	if(Yosys == false){}
}