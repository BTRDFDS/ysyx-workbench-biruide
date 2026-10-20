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

	val pipeReset	= reset.asBool||in.imme.error
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
	out.pipe.rdAddr	:= Mux(backError,pipeRdAddr,0.U)
	out.pipe.result	:= pipeResult
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

	bar.size	:= 0b11.U
	bar.wdata	:= 0.U
	bar.wstrb	:= 0.U
	bar.write	:= false.B
	bar.addr	:= 0.U
	when(pipeValid && state === MemStatus.Call){//发出
		when(pipeLsuOp === LsuOp.Load){
			switch(pipeLsuAddr){
				is(LsuAddr.B ){bar.size := 0b00.U}
				is(LsuAddr.Bu){bar.size := 0b00.U}
				is(LsuAddr.H ){bar.size := 0b01.U}
				is(LsuAddr.Hu){bar.size := 0b01.U}
				is(LsuAddr.W ){bar.size := 0b10.U}
			}
			bar.addr	:= pipeResult
		}
		when(pipeLsuOp === LsuOp.Store){
			bar.write	:= true.B
			switch(pipeLsuAddr){
				is(LsuAddr.B ){bar.size := 0b00.U}
				is(LsuAddr.H ){bar.size := 0b01.U}
				is(LsuAddr.W ){bar.size := 0b10.U}
			}
			bar.addr	:= pipeResult
			switch(pipeLsuAddr){
				is(LsuAddr.B){bar.wstrb := (0b0001.U << pipeResult(1,0))}
				is(LsuAddr.H){bar.wstrb := Mux(pipeResult(1),0b1100.U,0b0011.U)}
				is(LsuAddr.W){bar.wstrb := 0b1111.U}
			}
			switch(pipeLsuAddr){
				is(LsuAddr.B){bar.wdata	:= Fill(4,pipeR2(7,0))}
				is(LsuAddr.H){bar.wdata	:= Fill(2,pipeR2(15,0))}
				is(LsuAddr.W){bar.wdata	:= pipeR2}
			}
		}
	}
	when(pipeValid && ~backError){//接收
		when(pipeLsuOp === LsuOp.Load){
			val rdata = RegInit(0.U(BitWidth.W))
			when(state === MemStatus.Call && bar.ready){rdata := bar.rdata >> (8.U * pipeResult(1,0))}
			switch(pipeLsuAddr){
				is(LsuAddr.B ){out.pipe.result := Cat(Fill(BitWidth- 8,rdata( 7)),rdata( 7,0))}
				is(LsuAddr.H ){out.pipe.result := Cat(Fill(BitWidth-16,rdata(15)),rdata(15,0))}
				is(LsuAddr.W ){out.pipe.result := rdata}
				is(LsuAddr.Bu){out.pipe.result := Cat(0.U((BitWidth- 8).W),rdata( 7,0))}
				is(LsuAddr.Hu){out.pipe.result := Cat(0.U((BitWidth-16).W),rdata(15,0))}
			}
		}
	}
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
	out.imme.error	:= in.imme.error
	out.imme.ready	:= (~pipeValid) || pipeLsuOp === LsuOp.Null || state === MemStatus.Back

	 in.imme.r1Addr	:= out.imme.r1Addr
	 in.imme.r2Addr	:= out.imme.r2Addr
	 in.imme.csrAddr:= out.imme.csrAddr
	out.imme.valid	:=  in.imme.valid
	out.imme.csrOut	:= Mux(pipeValid && out.imme.csrAddr === pipeCsrAddr,out.pipe.csrMesg,in.imme.csrOut)
	out.imme.r1Out	:= Mux(pipeValid && pipeRdAddr=/=0.U && out.imme.r1Addr === pipeRdAddr,out.pipe.result,in.imme.r1Out)
	out.imme.r2Out	:= Mux(pipeValid && pipeRdAddr=/=0.U && out.imme.r2Addr === pipeRdAddr,out.pipe.result,in.imme.r2Out)
	out.imme.r1Valid:= pipeValid && pipeRdAddr=/=0.U && out.imme.r1Addr === pipeRdAddr && (state === MemStatus.Back || ~(pipeLSUoP === LsuOp.Load))
	out.imme.r2Valid:= pipeValid && pipeRdAddr=/=0.U && out.imme.r2Addr === pipeRdAddr && (state === MemStatus.Back || ~(pipeLSUoP === LsuOp.Load))
	if(Yosys == false){}
}