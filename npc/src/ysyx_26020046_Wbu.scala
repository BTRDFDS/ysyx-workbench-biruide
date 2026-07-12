import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Wbu() extends Module {
	val PcReset:UInt=0x80000000L.U(BitWidth.W)
	val RegWidth = log2Ceil(RegNum)
	val MstatuseReset = 0x1800.U(BitWidth.W)
	val ErrorMesg = 2.U(BitWidth.W)

	val in = IO(new Bundle {
		val pipe = Flipped(new PipeLsWb())
	})
	val out = IO(new Bundle {
		val imme = new ImmeAfter()
	})
	val gpr = Reg(Vec(RegNum, UInt(BitWidth.W)))

	val mepc		= RegInit(PcReset)
	val mstatus		= RegInit(MstatuseReset)
	val mtvec		= RegInit(PcReset)
	val mcause		= RegInit(0.U(BitWidth.W))
	val mcycle		= RegInit(0.U(BitWidth.W))
	val mcycleh		= RegInit(0.U(BitWidth.W))
	val marchid		= RegInit(0x018D08CE.U(BitWidth.W))
	val mvendorid	= RegInit(0x79737978.U(BitWidth.W))

	val error = WireInit(false.B)
	val nextMcycle	= Wire(UInt(BitWidth.W))
	val nextMcycleh	= Wire(UInt(BitWidth.W))
	nextMcycle	:= mcycle + 1.U
	nextMcycleh	:= Mux(mcycleh === (Fill(BitWidth,1.U)),mcycleh,mcycleh + 1.U)
		
	when(in.pipe.valid){//合法处理
		switch(in.pipe.csrOp){
			is(CsrOp.Mret){mstatus	:= MstatuseReset}//TODO
			is(CsrOp.Trap){
				mcause	:= in.pipe.csrMesg
				mepc 	:= in.pipe.pc
				when(in.pipe.csrMesg === 3.U){
					printf("ebreak,stop!!!\n")
					stop()
				}
				//TODO:mstatus
			}
			is(CsrOp.Write){
				val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(in.pipe.csrAddr)
				when(csrWriteValid){
					switch(csrWriteAddr){
						is(CsrAddr.Mcycle)		{nextMcycle	:= in.pipe.result}
						is(CsrAddr.Mcycleh)		{nextMcycleh:= in.pipe.result}
						is(CsrAddr.Mepc)		{mepc		:= in.pipe.result}
						is(CsrAddr.Mtvec)		{mtvec		:= in.pipe.result}
						is(CsrAddr.Mcause)		{mcause		:= in.pipe.result}
						is(CsrAddr.Mstatus)		{mstatus	:= in.pipe.result}
						is(CsrAddr.Marchid)		{marchid	:= in.pipe.result}
						is(CsrAddr.Mvendorid)	{mvendorid	:= in.pipe.result}
					}
				}otherwise{
					error	:= true.B
					mcause	:= ErrorMesg
					mepc	:= in.pipe.pc
					//TODO:mstatus
				}
			}
			is(CsrOp.Null){}//空，这里4个全覆盖了
		}
		when((in.pipe.rdAddr =/= 0.U)&(error === false.B)){gpr(in.pipe.rdAddr) := in.pipe.result}
	}
	when((in.pipe.valid === false.B & in.pipe.csrOp === CsrOp.Trap) | error){
		mcause	:= in.pipe.csrMesg
		mepc 	:= in.pipe.pc
		out.imme.back := Back.Error
		out.imme.addr	:= mtvec
		printf("error,stop!!!\n")
		assert(false.B)
		stop()
	}otherwise{
		out.imme.back := Back.Ready
		out.imme.addr	:= 0.U
	}
	mcycle	:= nextMcycle
	mcycleh	:= nextMcycleh

	{//提供数据
		out.imme.r1Out := Mux(out.imme.r1Addr === 0.U, 0.U, gpr(out.imme.r1Addr))
		out.imme.r2Out := Mux(out.imme.r2Addr === 0.U, 0.U, gpr(out.imme.r2Addr))
		val (csrReadAddr,csrReadValid)=CsrAddr.safe(out.imme.csrAddr)
		out.imme.csrOut := 0.U
		when(csrReadValid){
			switch(csrReadAddr){
				is(CsrAddr.Mcycle)		{out.imme.csrOut := mcycle}
				is(CsrAddr.Mcycleh)		{out.imme.csrOut := mcycleh}
				is(CsrAddr.Mepc)		{out.imme.csrOut := mepc}
				is(CsrAddr.Mtvec)		{out.imme.csrOut := mtvec}
				is(CsrAddr.Mcause)		{out.imme.csrOut := mcause}
				is(CsrAddr.Mstatus)		{out.imme.csrOut := mstatus}
				is(CsrAddr.Marchid)		{out.imme.csrOut := marchid}
				is(CsrAddr.Mvendorid)	{out.imme.csrOut := mvendorid}
			}
		}otherwise{out.imme.csrOut := 0.U}
	}
}