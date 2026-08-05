import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Lsu(val Yosys:Boolean=false) extends Module{
	val in = IO(new Bundle{
		val pipe = Flipped(new PipeExLs())
		val imme = Flipped(new ImmeAfter())
	})
	val out = IO(new Bundle{
		val pipe = new PipeLsWb()
		val imme = new ImmeAfter()
	})
	val bar		= IO(new MemBus())
	val ich		= IO(new FecneBus())
	val state	= RegInit(MemStatus.Call)

	val pipeReady 	= Wire(Bool())
	val pipeReset	= reset.asBool||(out.imme.back===Back.Error)
	val pipeValid	= PipeReg(pipeReset,false.B			,pipeReady,in.pipe.valid	)
	val pipeFenceI	= PipeReg(pipeReset,false.B			,pipeReady,in.pipe.fenceI	)
	val pipeRdAddr	= PipeReg(pipeReset,0.U(RegWidth.W)	,pipeReady,in.pipe.rdAddr	)
	val pipeResult	= PipeReg(pipeReset,0.U(RegWidth.W)	,pipeReady,in.pipe.result	)
	val pipePc		= PipeReg(pipeReset,0.U(RegWidth.W)	,pipeReady,in.pipe.pc		)
	val pipeCsrAddr	= PipeReg(pipeReset,0.U(RegWidth.W)	,pipeReady,in.pipe.csrAddr	)
	val pipeCsrMesg	= PipeReg(pipeReset,0.U(RegWidth.W)	,pipeReady,in.pipe.csrMesg	)
	val pipeR2		= PipeReg(pipeReset,0.U(RegWidth.W)	,pipeReady,in.pipe.r2		)
	val pipeLsuOp	= PipeReg(pipeReset,LsuOp.Null		,pipeReady,in.pipe.lsuOp	)
	val pipeLsuAddr	= PipeReg(pipeReset,LsuAddr.B		,pipeReady,in.pipe.lsuAddr	)
	val pipeCsrOp	= PipeReg(pipeReset,CsrOp.Null		,pipeReady,in.pipe.csrOp	)

	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= pipeRdAddr
	out.pipe.result	:= pipeResult
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= pipeCsrOp
	out.pipe.csrAddr:= pipeCsrAddr
	out.pipe.csrMesg:= pipeCsrMesg
	ich.fenceI		:= pipeFenceI

	//处理回传
	out.imme.csrOut	:= in.imme.csrOut
	out.imme.addr	:= in.imme.addr
	out.imme.back	:= in.imme.back
	out.imme.r1Out	:= in.imme.r1Out//这三都是默认值
	out.imme.r2Out	:= in.imme.r2Out
	out.imme.valid	:= in.imme.valid

	in.imme.r1Addr	:= out.imme.r1Addr
	in.imme.r2Addr	:= out.imme.r2Addr
	in.imme.csrAddr	:= out.imme.csrAddr

	val addrError = WireInit(false.B)
	when(pipeValid & pipeLsuOp =/= LsuOp.Null){
		switch(pipeLsuAddr){
			is(LsuAddr.H ){when(pipeResult(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.Hu){when(pipeResult(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.W ){when(pipeResult(1,0) =/= 0.U){addrError := true.B}}
		}
	}
	//状态机
	when(pipeValid && ~addrError){
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
	when(pipeValid && ~addrError && pipeLsuOp =/= LsuOp.Null){//接收
		when(pipeLsuOp === LsuOp.Load){
			val rdata = RegInit(0.U(BitWidth.W))
			val result = RegInit(0.U(BitWidth.W))
			when(state === MemStatus.Call && bar.ready){rdata := bar.rdata >> (8.U * pipeResult(1,0))}
			switch(pipeLsuAddr){
				is(LsuAddr.B ){result := Cat(Fill(BitWidth- 8,rdata( 7)),rdata( 7,0))}
				is(LsuAddr.H ){result := Cat(Fill(BitWidth-16,rdata(15)),rdata(15,0))}
				is(LsuAddr.W ){result := rdata}
				is(LsuAddr.Bu){result := Cat(0.U((BitWidth- 8).W),rdata( 7,0))}
				is(LsuAddr.Hu){result := Cat(0.U((BitWidth-16).W),rdata(15,0))}
			}
			out.pipe.result := result
			when(out.imme.r1Addr === pipeRdAddr & pipeRdAddr=/=0.U){out.imme.r1Out := result}
			when(out.imme.r2Addr === pipeRdAddr & pipeRdAddr=/=0.U){out.imme.r2Out := result}
			when(pipeRdAddr=/=0.U & (out.imme.r1Addr === pipeRdAddr | out.imme.r2Addr === pipeRdAddr)){
				out.imme.valid := state === MemStatus.Back
			}
		}
	}
	val backError = bar.error && bar.ready
	when(addrError || backError){
		out.pipe.valid	:= false.B
		out.pipe.csrOp	:= CsrOp.Trap
		when(in.imme.back === Back.Error){out.imme.back	:= Back.Error}
		.otherwise{out.imme.back	:= Back.Wait}
	}otherwise{
		pipeReady := Mux(pipeLsuOp === LsuOp.Null,true.B,state === MemStatus.Back)
		out.pipe.valid:= pipeReady & pipeValid
		when(in.imme.back === Back.Error){out.imme.back	:= Back.Error}
		.elsewhen(pipeReady & in.imme.back === Back.Ready){out.imme.back	:= Back.Ready}
		.otherwise{out.imme.back	:= Back.Wait}
	}
	when(addrError){switch(pipeLsuOp){
		is(LsuOp.Load)	{out.pipe.csrMesg := 4.U;out.pipe.csrAddr := pipeResult}//读取地址不对齐
		is(LsuOp.Store)	{out.pipe.csrMesg := 6.U;out.pipe.csrAddr := pipeResult}//写入地址不对齐
	}}
	.elsewhen(backError){switch(pipeLsuOp){
		is(LsuOp.Load)	{out.pipe.csrMesg := 5.U;out.pipe.csrAddr := pipeResult}//读取故障
		is(LsuOp.Store)	{out.pipe.csrMesg := 7.U;out.pipe.csrAddr := pipeResult}//写入故障
	}}

	if(Yosys == false){
		val lsuChk = Module(new ysyx_26020046_LsuChk)
		lsuChk.clock	:= clock
		lsuChk.load		:= pipeValid && pipeLsuOp === LsuOp.Load	&& bar.ready
		lsuChk.loadWait	:= pipeValid && pipeLsuOp === LsuOp.Load
		lsuChk.store	:= pipeValid && pipeLsuOp === LsuOp.Store	&& bar.ready
		lsuChk.storeWait:= pipeValid && pipeLsuOp === LsuOp.Store
		lsuChk.addr		:= pipeResult
	}
}
class ysyx_26020046_LsuChk extends ExtModule{
	val load		= IO(Input(Bool()))
	val loadWait	= IO(Input(Bool()))
	val store		= IO(Input(Bool()))
	val storeWait	= IO(Input(Bool()))
	val addr		= IO(Input(UInt(32.W)))
	val clock		= IO(Input(Clock()))
	setInline("ysyx_26020046_LsuChk.sv",
	"""
	module ysyx_26020046_LsuChk(
		input logic load,
		input logic loadWait,
		input logic store,
		input logic storeWait,
		input logic [31:0] addr,
		input logic clock
	);
	import "DPI-C" function void lsuLoad();
	import "DPI-C" function void lsuLoadWait();
	import "DPI-C" function void lsuStore();
	import "DPI-C" function void lsuStoreWait();
	import "DPI-C" function void lsuTrace(int addr);
	always_ff@(posedge clock)begin
		if(load			)lsuLoad();
		if(loadWait		)lsuLoadWait();
		if(store		)lsuStore();
		if(storeWait	)lsuStoreWait();
	end
	always_ff@(posedge load or posedge store)lsuTrace(addr);
	endmodule
	"""
	)
}