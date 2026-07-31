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
	val loader	= IO(new LoaderBus())
	val storer	= IO(new StorerBus())	


	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= in.pipe.rdAddr
	out.pipe.result	:= in.pipe.result
	out.pipe.pc		:= in.pipe.pc
	out.pipe.csrOp	:= in.pipe.csrOp
	out.pipe.csrAddr:= in.pipe.csrAddr
	out.pipe.csrMesg:= in.pipe.csrMesg

	//处理回传
	out.imme.r1Out	:= in.imme.r1Out
	out.imme.r2Out	:= in.imme.r2Out
	out.imme.csrOut	:= in.imme.csrOut
	out.imme.addr	:= in.imme.addr
	out.imme.back	:= in.imme.back

	in.imme.r1Addr	:= out.imme.r1Addr
	in.imme.r2Addr	:= out.imme.r2Addr
	in.imme.csrAddr	:= out.imme.csrAddr

	loader.valid:= false.B
	loader.addr	:= 0.U
	val addrError = WireInit(false.B)
	when(in.pipe.valid & in.pipe.lsuOp =/= LsuOp.Null){
		switch(in.pipe.lsuAddr){
			is(LsuAddr.H ){when(in.pipe.result(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.Hu){when(in.pipe.result(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.W ){when(in.pipe.result(1,0) =/= 0.U){addrError := true.B}}
		}
	}
	storer.valid:= false.B
	storer.addr	:= 0.U
	storer.data	:= 0.U
	storer.strb	:= 0.U
	when(in.pipe.valid && ~addrError && in.pipe.lsuOp =/= LsuOp.Null){//发出
		when(in.pipe.lsuOp === LsuOp.Load){
			loader.valid:= true.B
			loader.addr	:= in.pipe.result
		}.otherwise{
			loader.valid:= false.B
			loader.addr	:= 0.U
		}
		when(in.pipe.lsuOp === LsuOp.Store){
			storer.valid:= true.B
			storer.addr	:= in.pipe.result
			switch(in.pipe.lsuAddr){
				is(LsuAddr.B){storer.strb := 0b0001.U << in.pipe.result(1,0)}
				is(LsuAddr.H){storer.strb := 0b0011.U << in.pipe.result(1,0)}
				is(LsuAddr.W){storer.strb := 0b1111.U}
			}
			switch(in.pipe.lsuAddr){
				is(LsuAddr.B){storer.data	:= Fill(4,in.pipe.r2(7,0))}
				is(LsuAddr.H){storer.data	:= Fill(2,in.pipe.r2(15,0))}
				is(LsuAddr.W){storer.data	:= in.pipe.r2}
			}
		}.otherwise{
			storer.valid:= false.B
			storer.addr	:= 0.U
			storer.data	:= 0.U
		}
	}
	val backError = WireInit(false.B)
	when(in.pipe.valid && ~addrError && in.pipe.lsuOp =/= LsuOp.Null){//接收
		switch(in.pipe.lsuOp){
			is(LsuOp.Load)	{backError := loader.error && loader.ready}
			is(LsuOp.Store)	{backError := storer.error && storer.ready}
		}
		when(in.pipe.lsuOp === LsuOp.Load){
			val rdata = RegInit(0.U(BitWidth.W))
			when(storer.ready){rdata := storer.data >> (8.U * in.pipe.result(1,0))}
			switch(in.pipe.lsuAddr){
				is(LsuAddr.B ){out.pipe.result := Cat(Fill(BitWidth- 8,rdata( 7)),rdata( 7,0))}
				is(LsuAddr.H ){out.pipe.result := Cat(Fill(BitWidth-16,rdata(15)),rdata(15,0))}
				is(LsuAddr.W ){out.pipe.result := rdata}
				is(LsuAddr.Bu){out.pipe.result := Cat(0.U((BitWidth- 8).W),rdata( 7,0))}
				is(LsuAddr.Hu){out.pipe.result := Cat(0.U((BitWidth-16).W),rdata(15,0))}
			}
		}
	}
	when(addrError || backError){
		out.pipe.valid	:= false.B
		out.pipe.csrOp	:= CsrOp.Trap
		when(in.imme.back === Back.Error){out.imme.back	:= Back.Error}
		.otherwise{out.imme.back	:= Back.Wait}
	}otherwise{
		val ready = Mux1H(Seq(
			(in.pipe.lsuOp === LsuOp.Load)	-> loader.ready,
			(in.pipe.lsuOp === LsuOp.Store)	-> storer.ready,
			(in.pipe.lsuOp === LsuOp.Null)	-> true.B
		))
		out.pipe.valid:= ready & in.pipe.valid
		when(in.imme.back === Back.Error){out.imme.back	:= Back.Error}
		.elsewhen(ready & in.imme.back === Back.Ready){out.imme.back	:= Back.Ready}
		.otherwise{out.imme.back	:= Back.Wait}
	}
	when(addrError){switch(in.pipe.lsuOp){
		is(LsuOp.Load)	{out.pipe.csrMesg := 4.U;out.pipe.csrAddr := in.pipe.result}//读取地址不对齐
		is(LsuOp.Store)	{out.pipe.csrMesg := 6.U;out.pipe.csrAddr := in.pipe.result}//写入地址不对齐
	}}
	.elsewhen(backError){switch(in.pipe.lsuOp){
		is(LsuOp.Load)	{out.pipe.csrMesg := 5.U;out.pipe.csrAddr := in.pipe.result}//读取故障
		is(LsuOp.Store)	{out.pipe.csrMesg := 7.U;out.pipe.csrAddr := in.pipe.result}//写入故障
	}}

	if(Yosys == false){
		val lsuChk = Module(new ysyx_26020046_LsuChk)
		lsuChk.clock		:= clock
		lsuChk.io.load		:= in.pipe.valid && in.pipe.lsuOp === LsuOp.Load	&& loader.ready
		lsuChk.io.loadWait	:= in.pipe.valid && in.pipe.lsuOp === LsuOp.Load
		lsuChk.io.store		:= in.pipe.valid && in.pipe.lsuOp === LsuOp.Store	&& storer.ready
		lsuChk.io.storeWait	:= in.pipe.valid && in.pipe.lsuOp === LsuOp.Store
	}
}
class ysyx_26020046_LsuChk extends ExtModule{
	val io = IO(new Bundle{
		val load		= Input(Bool())
		val loadWait	= Input(Bool())
		val store		= Input(Bool())
		val storeWait	= Input(Bool())
	})
	val clock = IO(Input(Clock()))
	setInline("ysyx_26020046_LsuChk.sv",
	"""
	module ysyx_26020046_LsuChk(
		input logic io_load,
		input logic io_loadWait,
		input logic io_store,
		input logic io_storeWait,
		input logic clock
	);
	import "DPI-C" function void lsuLoad();
	import "DPI-C" function void lsuLoadWait();
	import "DPI-C" function void lsuStore();
	import "DPI-C" function void lsuStoreWait();
	always_ff@(posedge clock)begin
		if(io_load		)lsuLoad();
		if(io_loadWait	)lsuLoadWait();
		if(io_store		)lsuStore();
		if(io_storeWait	)lsuStoreWait();
	end
	endmodule
	"""
	)
}