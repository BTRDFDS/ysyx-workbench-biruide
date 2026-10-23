import chisel3._
import chisel3.util._
import WidthConsts._

class lsu(val Yosys:Boolean=false) extends Module{
	val in = IO(new Bundle{
		val pipe = Flipped(new PipeExLs())
		val imme = Flipped(new ImmeWbLs())
	})
	val out = IO(new Bundle{
		val pipe = new PipeLsWb()
		val imme = new ImmeLsEx()
	})
	val bar		= IO(new MemBus())
	val state	= RegInit(MemStatus.Call)

	val pipeReset	= reset.asBool||in.imme.reloca
	val pipeValid	= PipeReg(in.pipe.valid		,out.imme.ready,false.B		,pipeReset)
	val pipeCsrOp	= PipeReg(in.pipe.csrOp		,out.imme.ready,CsrOp.Null	,pipeReset)
	val pipeLsuOp	= PipeReg(in.pipe.lsuOp		,out.imme.ready,LsuOp.Null	,pipeReset)
	val pipeRdAddr	= PipeReg(in.pipe.rdAddr	,out.imme.ready)
	val pipeResult	= PipeReg(in.pipe.result	,out.imme.ready)
	val pipePc		= PipeReg(in.pipe.pc		,out.imme.ready)
	val pipeCsrAddr	= PipeReg(in.pipe.csrAddr	,out.imme.ready)
	val pipeCsrMesg	= PipeReg(in.pipe.csrMesg	,out.imme.ready)
	val pipeR2		= PipeReg(in.pipe.r2		,out.imme.ready)
	val pipeLsuAddr	= PipeReg(in.pipe.lsuAddr	,out.imme.ready)


	val backError = bar.error && bar.ready
	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= pipeRdAddr
	// out.pipe.result	:= pipeResult
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= pipeCsrOp
	out.pipe.csrAddr:= pipeCsrAddr
	out.pipe.csrMesg:= pipeCsrMesg

	when(pipeValid){//状态机
		switch(state){
			is(MemStatus.Call){switch(pipeLsuOp){
				is(LsuOp.Load)	{when(bar.ready){state := MemStatus.Back}}
				is(LsuOp.Store)	{when(bar.ready){state := MemStatus.Back}}
			}}
			is(MemStatus.Back){state := MemStatus.Call}//WBU无需等待
		}
	}

	bar.write	:= pipeLsuOp === LsuOp.Store
	bar.addr	:= pipeResult
	bar.wstrb	:= Mux1H(Seq(
		(pipeLsuAddr === LsuAddr.B)	-> (0b0001.U << pipeResult(1,0)),
		(pipeLsuAddr === LsuAddr.H)	-> Mux(pipeResult(1),0b1100.U,0b0011.U),
		(pipeLsuAddr === LsuAddr.W)	-> 0b1111.U,
	))
	bar.wdata := Mux1H(Seq(
		(pipeLsuAddr === LsuAddr.B) -> Fill(4,pipeR2(7,0)),
		(pipeLsuAddr === LsuAddr.H) -> Fill(2,pipeR2(15,0)),
		(pipeLsuAddr === LsuAddr.W) -> pipeR2,
	))
	bar.valid	:= pipeValid && state===MemStatus.Call && pipeLsuOp=/=LsuOp.Null
	bar.size	:= Mux1H(Seq(
		(pipeLsuAddr === LsuAddr.B)	-> 0b00.U,
		(pipeLsuAddr === LsuAddr.Bu)-> 0b00.U,
		(pipeLsuAddr === LsuAddr.H)	-> 0b01.U,
		(pipeLsuAddr === LsuAddr.Hu)-> 0b01.U,
		(pipeLsuAddr === LsuAddr.W)	-> 0b10.U,
	))
	val rdata = Reg(UInt(BitWidth.W))
	when(state === MemStatus.Call && bar.ready){rdata := bar.rdata >> (8.U * pipeResult(1,0))}
	out.pipe.result := Mux(pipeLsuOp =/= LsuOp.Load,pipeResult,Mux1H(Seq(
		(pipeLsuAddr === LsuAddr.B)	-> Cat(Fill(BitWidth- 8,rdata( 7)),rdata( 7,0)),
		(pipeLsuAddr === LsuAddr.H)	-> Cat(Fill(BitWidth-16,rdata(15)),rdata(15,0)),
		(pipeLsuAddr === LsuAddr.W)	-> rdata,
		(pipeLsuAddr === LsuAddr.Bu)-> Cat(0.U((BitWidth- 8).W),rdata( 7,0)),
		(pipeLsuAddr === LsuAddr.Hu)-> Cat(0.U((BitWidth-16).W),rdata(15,0)),
	)))
	out.pipe.valid := (pipeLsuOp === LsuOp.Null || state === MemStatus.Back) && pipeValid && ~backError
	out.pipe.csrOp := Mux(backError,CsrOp.Trap,pipeCsrOp)
	// when(addrError){switch(pipeLsuOp){
	// 	is(LsuOp.Load)	{out.pipe.csrMesg := 4.U;out.pipe.csrAddr := pipeResult}//读取地址不对齐
	// 	is(LsuOp.Store)	{out.pipe.csrMesg := 6.U;out.pipe.csrAddr := pipeResult}//写入地址不对齐
	// }}.
	when(backError){switch(pipeLsuOp){
		is(LsuOp.Load)	{out.pipe.csrMesg := 5.U}//读取故障
		is(LsuOp.Store)	{out.pipe.csrMesg := 7.U}//写入故障
	}}
	//处理回传
	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.reloca	:= in.imme.reloca
	out.imme.ready	:= (~pipeValid) || pipeLsuOp === LsuOp.Null || state === MemStatus.Back

	 in.imme.r1Addr	:= out.imme.r1Addr
	 in.imme.r2Addr	:= out.imme.r2Addr
	 in.imme.csrAddr:= out.imme.csrAddr
	out.imme.csrOut	:= Mux(pipeValid && out.imme.csrAddr === pipeCsrAddr,out.pipe.csrMesg,in.imme.csrOut)
	out.imme.r1Out	:= Mux(pipeValid && pipeRdAddr=/=0.U && out.imme.r1Addr === pipeRdAddr,out.pipe.result,in.imme.r1Out)
	out.imme.r2Out	:= Mux(pipeValid && pipeRdAddr=/=0.U && out.imme.r2Addr === pipeRdAddr,out.pipe.result,in.imme.r2Out)
	out.imme.r1Valid:= Mux(pipeValid && pipeRdAddr=/=0.U && out.imme.r1Addr === pipeRdAddr,state===MemStatus.Back || pipeLsuOp =/= LsuOp.Load,true.B)
	out.imme.r2Valid:= Mux(pipeValid && pipeRdAddr=/=0.U && out.imme.r2Addr === pipeRdAddr,state===MemStatus.Back || pipeLsuOp =/= LsuOp.Load,true.B)

	if(Yosys == false){}
}