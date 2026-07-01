import chisel3._
import chisel3.util._

class ysyx_26020046_Wbu(val Width:Int=32,val RegNum:Int=32,val CsrWidth:Int=12,val PcReset:UInt=0x80000000L.U) extends Module {
	val RegWidth = log2Ceil(RegNum)
	val MstatuseReset = 0x1800.U(Width.W)
	val ErrorMesg = 2.U(Width.W)

	val io = IO(new Bundle {
		val waterIn	= Flipped(new WaterLsWb(Width,RegNum))
		val immOut	= new ImmAfter(Width,RegNum,CsrWidth)
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

	io.immOut.ready:= true.B
	io.immOut.addr	:= mtvec
	val error = WireInit(false.B)
	val nextMcycle = WireInit(Cat(mcycleh,mcycle) + 1.U)
	when(io.waterIn.valid){
		switch(io.waterIn.csrOp){
			is(CsrOp.Mret){
				mcycle	:= nextMcycle
				mstatus	:= MstatuseReset//简化处理，只考虑M模式
				mcause	:= 0.U
			}
			is(CsrOp.Trap){
				mcycle	:= nextMcycle
				error 	:= true.B
				mepc	:= io.waterIn.pc
				mcause	:= io.waterIn.csrMesg
			}
			is(CsrOp.Write){
				val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(io.waterIn.csrAddr)
				when(csrWriteValid){
					when(csrWriteAddr =/= CsrAddr.Mcycle) {mcycle	:=nextMcycle(Width-1,0)}
					when(csrWriteAddr =/= CsrAddr.Mcycleh){mcycleh	:=nextMcycle(2*Width-1,Width)}
					switch(csrWriteAddr){
						is(CsrAddr.Mcycle)		{mcycle		:= io.waterIn.result}
						is(CsrAddr.Mcycleh)		{mcycleh	:= io.waterIn.result}
						is(CsrAddr.Mepc)		{mepc		:= io.waterIn.result}
						is(CsrAddr.Mtvec)		{mtvec		:= io.waterIn.result}
						is(CsrAddr.Mcause)		{mcause		:= io.waterIn.result}
						is(CsrAddr.Mstatus)		{mstatus	:= io.waterIn.result}
						is(CsrAddr.Marchid)		{marchid	:= io.waterIn.result}
						is(CsrAddr.Mvendorid)	{mvendorid	:= io.waterIn.result}
					}
				}otherwise{
					mcycle	:= nextMcycle
					error	:= true.B
					mepc	:= io.waterIn.pc
					mcause	:= ErrorMesg
				}
			}
			is(CsrOp.Null){mcycle:= nextMcycle}//啥都不干
		}
		when((io.waterIn.rdAddr =/= 0.U)&(error =/= true.B)){gpr(io.waterIn.rdAddr) := io.waterIn.result}
	}otherwise{mcycle:= nextMcycle}
	io.immOut.wash := error

	io.immOut.r1Out := Mux(io.immOut.r1Addr === 0.U, 0.U, gpr(io.immOut.r1Addr))
	io.immOut.r2Out := Mux(io.immOut.r2Addr === 0.U, 0.U, gpr(io.immOut.r2Addr))

	io.immOut.wash	 := false.B
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
		io.immOut.wash		:= true.B
		io.immOut.csrOut	:= 0.U
	}
}