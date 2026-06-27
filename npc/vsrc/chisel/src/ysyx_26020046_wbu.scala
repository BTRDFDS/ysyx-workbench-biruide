import chisel3._
import chisel3.util._

class ysyx_26020046_WBU(val Width:Int=32,val RegNum:Int=32,val CsrWidth:Int=12,val PcReset:UInt=0x80000000L.U) extends Module {
	val RegWidth = log2Ceil(RegNum)
	val MstatuseReset = 0x1800.U(Width.W)
	val ErrorMesg = 2.U(Width.W)

	val io = IO(new Bundle {
		val waterLsWb	= Flipped(new WaterLsWb(Width,RegNum))
		val immWbLs		= new ImmAfter(Width,RegNum,CsrWidth)
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

	io.immWbLs.ready:= true.B
	io.immWbLs.addr	:= mtvec
	val error = WireInit(false.B)
	val nextMcycle = WireInit(Cat(mcycleh,mcycle) + 1.U)
	when(io.waterLsWb.valid){
		switch(io.waterLsWb.csrOp){
			is(CsrOp.Mret){
				mcycle	:= nextMcycle
				mstatus	:= MstatuseReset//简化处理，只考虑M模式
				mcause	:= 0.U
			}
			is(CsrOp.Error){
				mcycle	:= nextMcycle
				error 	:= true.B
				mepc	:= io.waterLsWb.pc
				mcause	:= io.waterLsWb.csrMesg
			}
			is(CsrOp.Write){
				val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(io.waterLsWb.csrAddr)
				when(csrWriteValid){
					when(csrWriteAddr =/= CsrAddr.Mcycle) {mcycle	:=nextMcycle(Width-1,0)}
					when(csrWriteAddr =/= CsrAddr.Mcycleh){mcycleh	:=nextMcycle(2*Width-1,Width)}
					switch(csrWriteAddr){
						is(CsrAddr.Mcycle)		{mcycle		:= io.waterLsWb.result}
						is(CsrAddr.Mcycleh)		{mcycleh	:= io.waterLsWb.result}
						is(CsrAddr.Mepc)		{mepc		:= io.waterLsWb.result}
						is(CsrAddr.Mtvec)		{mtvec		:= io.waterLsWb.result}
						is(CsrAddr.Mcause)		{mcause		:= io.waterLsWb.result}
						is(CsrAddr.Mstatus)		{mstatus	:= io.waterLsWb.result}
						is(CsrAddr.Marchid)		{marchid	:= io.waterLsWb.result}
						is(CsrAddr.Mvendorid)	{mvendorid	:= io.waterLsWb.result}
					}
				}otherwise{
					mcycle	:= nextMcycle
					error	:= true.B
					mepc	:= io.waterLsWb.pc
					mcause	:= ErrorMesg
				}
			}
			is(CsrOp.Null){mcycle:= nextMcycle}//啥都不干
		}
		when((io.waterLsWb.rdAddr =/= 0.U)&(error =/= true.B)){gpr(io.waterLsWb.rdAddr) := io.waterLsWb.result}
	}otherwise{mcycle:= nextMcycle}
	io.immWbLs.wash := error

	io.immWbLs.r1Out := Mux(io.immWbLs.r1Addr === 0.U, 0.U, gpr(io.immWbLs.r1Addr))
	io.immWbLs.r2Out := Mux(io.immWbLs.r2Addr === 0.U, 0.U, gpr(io.immWbLs.r2Addr))

	io.immWbLs.error := false.B
	val (csrReadAddr,csrReadValid)=CsrAddr.safe(io.immWbLs.csrAddr)
	io.immWbLs.csrOut := 0.U
	when(csrReadValid){
		switch(csrReadAddr){
			is(CsrAddr.Mcycle)		{io.immWbLs.csrOut := mcycle}
			is(CsrAddr.Mcycleh)		{io.immWbLs.csrOut := mcycleh}
			is(CsrAddr.Mepc)		{io.immWbLs.csrOut := mepc}
			is(CsrAddr.Mtvec)		{io.immWbLs.csrOut := mtvec}
			is(CsrAddr.Mcause)		{io.immWbLs.csrOut := mcause}
			is(CsrAddr.Mstatus)		{io.immWbLs.csrOut := mstatus}
			is(CsrAddr.Marchid)		{io.immWbLs.csrOut := marchid}
			is(CsrAddr.Mvendorid)	{io.immWbLs.csrOut := mvendorid}
		}
	}otherwise{
		io.immWbLs.error	:= true.B
		io.immWbLs.csrOut	:= 0.U
	}
}