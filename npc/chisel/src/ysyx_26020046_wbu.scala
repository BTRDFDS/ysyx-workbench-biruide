import chisel3._
import chisel3.util._

class ysyx_26020046_Wbu(val Width:Int=32,val RegNum:Int=32,val CsrWidth:Int=12,val PcReset:UInt=0x80000000L.U) extends Module {
	val RegWidth = log2Ceil(RegNum)
	val MstatuseReset = 0x1800.U(Width.W)
	val ErrorMesg = 2.U(Width.W)

	val io = IO(new Bundle {
		val waterIn	= Flipped(new PipeLsWb(Width,RegNum))
		val immOut	= new ImmeAfter(Width,RegNum,CsrWidth)
	})
	val gpr = Reg(Vec(RegNum, UInt(Width.W)))

	val mepc		= RegInit(PcReset)
	val mstatus		= RegInit(MstatuseReset)
	val mtvec		= RegInit(PcReset)
	val mcause		= RegInit(0.U(Width.W))
	val mcycle		= RegInit(0.U(Width.W))
	val mcycleh		= RegInit(0.U(Width.W))
	val marchid		= RegInit(0x018D08CE.U(Width.W))
	val mvendorid	= RegInit(0x79737978.U(Width.W))

	val error = WireInit(false.B)
	val csrMesg = WireInit(0.U(Width.W))
	val nextMcycle = WireInit(Cat(mcycleh,mcycle) + 1.U)
	
	when(io.waterIn.valid){//合法寄存器处理
		switch(io.waterIn.csrOp){
			is(CsrOp.Mret){
				mcycle	:= nextMcycle
				mstatus	:= MstatuseReset//简化处理，只考虑M模式-->TODO
				mcause	:= 0.U
			}
			is(CsrOp.Trap){
				error 	:= true.B
				csrMesg	:= io.waterIn.csrMesg
			}
			is(CsrOp.Write){
				val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(io.waterIn.csrAddr)
				when(csrWriteValid){
					switch(csrWriteAddr){
						is(CsrAddr.Mcycle)		{nextMcycle(Width-1,0)		:= io.waterIn.result}
						is(CsrAddr.Mcycleh)		{nextMcycle(2*Width-1,Width):= io.waterIn.result}
						is(CsrAddr.Mepc)		{mepc		:= io.waterIn.result}
						is(CsrAddr.Mtvec)		{mtvec		:= io.waterIn.result}
						is(CsrAddr.Mcause)		{mcause		:= io.waterIn.result}
						is(CsrAddr.Mstatus)		{mstatus	:= io.waterIn.result}
						is(CsrAddr.Marchid)		{marchid	:= io.waterIn.result}
						is(CsrAddr.Mvendorid)	{mvendorid	:= io.waterIn.result}
					}
				}otherwise{error	:= true.B
					// mcycle	:= nextMcycle
					// mepc	:= io.waterIn.pc
					// mcause	:= ErrorMesg
					//TODO:考虑整合进入后续的流程中
				}
			}
			is(CsrOp.Null){mcycle:= nextMcycle}//啥都不干
		}
		when((io.waterIn.rdAddr =/= 0.U)&(error =/= true.B)){gpr(io.waterIn.rdAddr) := io.waterIn.result}
	}otherwise{}

	mcycle	:= nextMcycle(Width-1,0)
	mcycleh	:= nextMcycle(2*Width-1,Width)

	io.immOut.flush := error

	io.immOut.r1Out := Mux(io.immOut.r1Addr === 0.U, 0.U, gpr(io.immOut.r1Addr))
	io.immOut.r2Out := Mux(io.immOut.r2Addr === 0.U, 0.U, gpr(io.immOut.r2Addr))

	io.immOut.flush	 := false.B
	val (csrReadAddr,csrReadValid)=CsrAddr.safe(io.immOut.csrAddr)
	io.immOut.csrOut := 0.U
	when(csrReadValid){
		switch(csrReadAddr){
			is(CsrAddr.Mcycle)		{io.immOut.csrOut := mcycle}
			is(CsrAddr.Mcycleh)		{io.immOut.csrOut := mcycleh}
			is(CsrAddr.Mepc)		{io.immOut.csrOut := mepc}
			is(CsrAddr.Mtvec)		{io.immOut.csrOut := mtvec}
			is(CsrAddr.Mcause)		{io.immOut.csrOut := mcause}
			is(CsrAddr.Mstatus)		{io.immOut.csrOut := mstatus}
			is(CsrAddr.Marchid)		{io.immOut.csrOut := marchid}
			is(CsrAddr.Mvendorid)	{io.immOut.csrOut := mvendorid}
		}
	}otherwise{
		io.immOut.flush		:= true.B
		io.immOut.csrOut	:= 0.U
	}
	io.immOut.back	:= Back.Ready
	io.immOut.addr	:= mtvec
}