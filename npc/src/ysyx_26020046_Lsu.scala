import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Lsu(val Yosys:Boolean=false) extends Module{
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
	val pipeValid	= PipeReg(pipeReset,false.B				,out.imme.ready,in.pipe.valid	)
	val pipeRdAddr	= PipeReg(pipeReset,0.U(RegWidth.W)		,out.imme.ready,in.pipe.rdAddr	)
	val pipeResult	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.result	)
	val pipePc		= PipeReg(pipeReset,0.U((BitWidth-2).W)	,out.imme.ready,in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.csrAddr	)
	val pipeCsrMesg	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.csrMesg	)
	val pipeR2		= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.r2		)
	val pipeLsuOp	= PipeReg(pipeReset,LsuOp.Null			,out.imme.ready,in.pipe.lsuOp	)
	val pipeLsuAddr	= PipeReg(pipeReset,LsuAddr.B			,out.imme.ready,in.pipe.lsuAddr	)
	val pipeCsrOp	= PipeReg(pipeReset,CsrOp.Null			,out.imme.ready,in.pipe.csrOp	)

	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= pipeRdAddr
	out.pipe.result	:= pipeResult
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= pipeCsrOp
	out.pipe.csrAddr:= pipeCsrAddr
	out.pipe.csrMesg:= pipeCsrMesg

	val addrError = WireInit(false.B)
	when(pipeValid & pipeLsuOp =/= LsuOp.Null){
		switch(pipeLsuAddr){
			is(LsuAddr.H ){when(pipeResult(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.Hu){when(pipeResult(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.W ){when(pipeResult(1,0) =/= 0.U){addrError := true.B}}
		}
	}
	when(pipeValid && ~addrError){//状态机
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
	when(pipeValid && ~addrError && state === MemStatus.Call){//发出
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
				is(LsuAddr.B){bar.wstrb := 0b0001.U << pipeResult(1,0)}
				is(LsuAddr.H){bar.wstrb := 0b0011.U << pipeResult(1,0)}
				is(LsuAddr.W){bar.wstrb := 0b1111.U}
			}
			switch(pipeLsuAddr){
				is(LsuAddr.B){bar.wdata	:= Fill(4,pipeR2(7,0))}
				is(LsuAddr.H){bar.wdata	:= Fill(2,pipeR2(15,0))}
				is(LsuAddr.W){bar.wdata	:= pipeR2}
			}
		}
	}
	val backError = bar.error && bar.ready
	when(pipeValid && ~addrError && ~backError){//接收
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
	//错误处理
	when(addrError || backError){
		out.pipe.valid	:= false.B
		out.pipe.csrOp	:= CsrOp.Trap
	}.otherwise{
		out.pipe.valid:= (pipeLsuOp === LsuOp.Null || state === MemStatus.Back) && pipeValid
	}
	when(addrError){switch(pipeLsuOp){
		is(LsuOp.Load)	{out.pipe.csrMesg := 4.U;out.pipe.csrAddr := pipeResult}//读取地址不对齐
		is(LsuOp.Store)	{out.pipe.csrMesg := 6.U;out.pipe.csrAddr := pipeResult}//写入地址不对齐
	}}
	.elsewhen(backError){switch(pipeLsuOp){
		is(LsuOp.Load)	{out.pipe.csrMesg := 5.U;out.pipe.csrAddr := pipeResult}//读取故障
		is(LsuOp.Store)	{out.pipe.csrMesg := 7.U;out.pipe.csrAddr := pipeResult}//写入故障
	}}
	//处理回传
	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.error	:= in.imme.error
	out.imme.ready	:= (~pipeValid) || pipeLsuOp === LsuOp.Null || state === MemStatus.Back || in.imme.error

	 in.imme.r1Addr	:= out.imme.r1Addr
	 in.imme.r2Addr	:= out.imme.r2Addr
	 in.imme.csrAddr:= out.imme.csrAddr
	out.imme.valid	:=  in.imme.valid
	out.imme.csrOut	:=  in.imme.csrOut
	out.imme.r1Out	:=  in.imme.r1Out
	out.imme.r2Out	:=  in.imme.r2Out
	when(pipeValid && ~addrError && ~backError && pipeRdAddr=/=0.U){
		when(out.imme.r1Addr === pipeRdAddr){out.imme.r1Out := out.pipe.result}
		when(out.imme.r2Addr === pipeRdAddr){out.imme.r2Out := out.pipe.result}
		when(out.imme.csrAddr===pipeCsrAddr){out.imme.csrOut:= out.pipe.csrMesg}
		when(out.imme.r1Addr === pipeRdAddr || out.imme.r2Addr === pipeRdAddr){
			out.imme.valid := state === MemStatus.Back
		}
	}

	if(Yosys == false){}
}