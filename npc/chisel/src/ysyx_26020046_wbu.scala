import chisel3._
import chisel3.util._

class ysyx_26020046_Wbu(val Width:Int=32,val RegNum:Int=32,val CsrWidth:Int=12,val PcReset:UInt=0x80000000L.U) extends Module {
	val RegWidth = log2Ceil(RegNum)
	val MstatuseReset = 0x1800.U(Width.W)
	val ErrorMesg = 2.U(Width.W)

	val io = IO(new Bundle {
		val pipeIn	= Flipped(new PipeLsWb(Width,RegNum))
		val immeOut	= new ImmeAfter(Width,RegNum,CsrWidth)
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
	val nextMcycle = WireInit(Cat(mcycleh,mcycle) + 1.U)
	
	when(io.pipeIn.valid){//合法寄存器处理
		switch(io.pipeIn.csrOp){
			is(CsrOp.Mret){mstatus	:= MstatuseReset}//TODO
			is(CsrOp.Trap){
				mcause	:= io.pipeIn.csrMesg
				mepc := io.pipeIn.pc
				//TODO:mstatus
			}
			is(CsrOp.Write){
				val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(io.pipeIn.csrAddr)
				when(csrWriteValid){
					switch(csrWriteAddr){
						is(CsrAddr.Mcycle)		{nextMcycle(Width-1,0)		:= io.pipeIn.result}
						is(CsrAddr.Mcycleh)		{nextMcycle(2*Width-1,Width):= io.pipeIn.result}
						is(CsrAddr.Mepc)		{mepc		:= io.pipeIn.result}
						is(CsrAddr.Mtvec)		{mtvec		:= io.pipeIn.result}
						is(CsrAddr.Mcause)		{mcause		:= io.pipeIn.result}
						is(CsrAddr.Mstatus)		{mstatus	:= io.pipeIn.result}
						is(CsrAddr.Marchid)		{marchid	:= io.pipeIn.result}
						is(CsrAddr.Mvendorid)	{mvendorid	:= io.pipeIn.result}
					}
				}otherwise{
					error	:= true.B
					mcause	:= ErrorMesg
					mepc	:= io.pipeIn.pc
					//TODO:mstatus
				}
			}
			is(CsrOp.Null){}//空，这里4个全覆盖了
		}
		when((io.pipeIn.rdAddr =/= 0.U)&(error === false.B)){gpr(io.pipeIn.rdAddr) := io.pipeIn.result}
	}
	mcycle	:= nextMcycle(Width-1,0)
	mcycleh	:= nextMcycle(2*Width-1,Width)

	{//提供数据
		io.immeOut.r1Out := Mux(io.immeOut.r1Addr === 0.U, 0.U, gpr(io.immeOut.r1Addr))
		io.immeOut.r2Out := Mux(io.immeOut.r2Addr === 0.U, 0.U, gpr(io.immeOut.r2Addr))
		val (csrReadAddr,csrReadValid)=CsrAddr.safe(io.immeOut.csrAddr)
		io.immeOut.csrOut := 0.U
		when(csrReadValid){
			switch(csrReadAddr){
				is(CsrAddr.Mcycle)		{io.immeOut.csrOut := mcycle}
				is(CsrAddr.Mcycleh)		{io.immeOut.csrOut := mcycleh}
				is(CsrAddr.Mepc)		{io.immeOut.csrOut := mepc}
				is(CsrAddr.Mtvec)		{io.immeOut.csrOut := mtvec}
				is(CsrAddr.Mcause)		{io.immeOut.csrOut := mcause}
				is(CsrAddr.Mstatus)		{io.immeOut.csrOut := mstatus}
				is(CsrAddr.Marchid)		{io.immeOut.csrOut := marchid}
				is(CsrAddr.Mvendorid)	{io.immeOut.csrOut := mvendorid}
			}
		}otherwise{io.immeOut.csrOut := 0.U}
	}
	when(error){//返回状态
		io.immeOut.back := Back.Error
		io.immeOut.addr	:= mtvec
	}otherwise{
		io.immeOut.back := Back.Ready
		io.immeOut.addr	:= 0.U	
	}
}