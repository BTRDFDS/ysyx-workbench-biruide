import chisel3._
import chisel3.util._
import chisel3.Enum._

class ysyx_26020046_WBU(val Width:Int=32,val RegNum:Int=32,val CsrWidth:Int=12,val PcReset:Int=0x80000000) extends Module {
	val RegWidth = log2Ceil(RegNum)
	val MstatuseReset = 0x1800.U(Width.W)
	val ErrorMesg = 2.U(Width.W)

	val io = IO(new Bundle {
		val waterLsWb	= Flipped(new WaterLsWb(Width,RegNum,CsrWidth))
		val immWbLs		= new ImmAfter(Width,RegNum,CsrWidth)
	})
	val gpr = Reg(Vec(RegNum, UInt(Width.W)))

	val mepc		= RegInit(PcReset.U(Width.W))
	val mstatuse	= RegInit(MstatuseReset.U)
	val mtvec		= RegInit(PcReset.U(Width.W))
	val mcause		= RegInit(0.U(Width.W))
	val mcycle		= RegInit(0.U(Width.W))
	val mcycleh		= RegInit(0.U(Width.W))
	val marchid		= RegInit(0x018D08CE.U(Width.W))
	val mvendorid	= RegInit(0x79737978.U(Width.W))

	io.immWbLs.wash	:= False.B
	io.immWbLs.ready:= True.B
	io.immWbLs.addr	:= mtvec
	when(io.waterLsWb.valid){
		when(io.waterLsWb.rdAddr =/= 0.U){gpr(io.waterLsWb.rdAddr) := io.waterLsWb.result}//TODO:错误拦截、计数器自增
		switch(io.waterLsWb.csrOp){
			is(CsrOp.Mret){
				mstatuse:= MstatuseReset.U
				mcause	:= 0.U
			}
			is(CsrOp.Error){
				io.immWbLs.wash	:= True.B
				mepc	:= io.waterLsWb.pc
				mcause	:= io.waterLsWb.csrMesg
				// stop()
			}
			is(CsrOp.Write){
				switch(io.waterLsWb.csrAddr){
					is(CsrAddr.Mcycle)		{mcycle		:= io.waterLsWb.result}
					is(CsrAddr.Mcycleh)		{mcycleh	:= io.waterLsWb.result}
					is(CsrAddr.Mepc)		{mepc		:= io.waterLsWb.result}
					is(CsrAddr.Mtvec)		{mtvec		:= io.waterLsWb.result}
					is(CsrAddr.Mcause)		{mcause		:= io.waterLsWb.result}
					is(CsrAddr.Mstatus)		{mstatuse	:= io.waterLsWb.result}
					is(CsrAddr.Marchid)		{marchid	:= io.waterLsWb.result}
					is(CsrAddr.Mvendorid)	{mvendorid	:= io.waterLsWb.result}
					otherwise{
						io.immWbLs.wash := True.B
						mepc	:= io.waterLsWb.pc
						mcause	:= ErrorMesg
					}
				}
			}
			is(CsrOp.Null){}//啥都不干
		}
	}

	io.immWbLs.r1Out := Mux(io.immWbLs.r1Addr === 0.U, 0.U, gpr(io.immWbLs.r1Addr))
	io.immWbLs.r2Out := Mux(io.immWbLs.r2Addr === 0.U, 0.U, gpr(io.immWbLs.r2Addr))

	io.immWbLs.error := False.U
	switch(io.immWbLs.csrAddr){
		is(CsrAddr.Mcycle)		{io.immWbLs.csrOut := mcycle}
		is(CsrAddr.Mcycleh)		{io.immWbLs.csrOut := mcycleh}
		is(CsrAddr.Mepc)		{io.immWbLs.csrOut := mepc}
		is(CsrAddr.Mtvec)		{io.immWbLs.csrOut := mtvec}
		is(CsrAddr.Mcause)		{io.immWbLs.csrOut := mcause}
		is(CsrAddr.Mstatus)		{io.immWbLs.csrOut := mstatuse}
		is(CsrAddr.Marchid)		{io.immWbLs.csrOut := marchid}
		is(CsrAddr.Mvendorid)	{io.immWbLs.csrOut := mvendorid}
		otherwise{
			io.immWbLs.error := True.B
			io.immWbLs.csrOut := 0.U
		}
	}

}