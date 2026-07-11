import chisel3._
import chisel3.util._
import WidthConsts._

object LsuStatus extends ChiselEnum{val Back,Call,Idle,Suce=Value}

class ysyx_26020046_Lsu extends Module{
	val in = IO(new Bundle{
		val pipe = Flipped(new PipeExLs())
		val imme = Flipped(new ImmeAfter())
	})
	val out = IO(new Bundle{
		val pipe = new PipeLsWb()
		val imme = new ImmeAfter()
	})
	val axi4 = IO(new Axi4Master())
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

	val hasAddr = RegInit(false.B)
	val hasData = RegInit(false.B)
	val finishAddr = hasAddr | axi4.awready
	val finishData = hasData | axi4.wready

	val backError = WireInit(false.B)
	val addrError = WireInit(false.B)

	val status = RegInit(LsuStatus.Idle)

	axi4.awaddr	:= 0.U
	axi4.awvalid	:= false.B
	axi4.wdata	:= 0.U
	axi4.wstrb	:= 0.U
	axi4.wvalid	:= false.B
	axi4.bready	:= false.B
	
	axi4.araddr	:= 0.U
	axi4.arvalid	:= false.B
	axi4.rready	:= false.B

	when(in.pipe.valid & in.pipe.lsuOp =/= LsuOp.Null){
		switch(in.pipe.lsuAddr){
			is(LsuAddr.H ){when(in.pipe.result(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.Hu){when(in.pipe.result(1)===1.U)	{addrError := true.B}}
			is(LsuAddr.W ){when(in.pipe.result(1,0) =/= 0.U){addrError := true.B}}
		}
	}
	when(in.pipe.valid & addrError =/= true.B){
		switch(status){
			is(LsuStatus.Idle){when(in.pipe.lsuOp =/= LsuOp.Null){status := LsuStatus.Call}}
			is(LsuStatus.Call){switch(in.pipe.lsuOp){
				is(LsuOp.Load)	{when(axi4.arready)		{status := LsuStatus.Back}}
				is(LsuOp.Store)	{when(finishAddr&finishData){status := LsuStatus.Back}}
			}}
			is(LsuStatus.Back){switch(in.pipe.lsuOp){
				is(LsuOp.Load)	{when(axi4.rvalid){status := LsuStatus.Suce}}
				is(LsuOp.Store)	{when(axi4.bvalid){status := LsuStatus.Suce}}
			}}
			is(LsuStatus.Suce){when(in.imme.back === Back.Ready){status := LsuStatus.Idle}}
		}
		switch(in.pipe.lsuOp){
			is(LsuOp.Store){
				when(status === LsuStatus.Call){
					when(axi4.wready)	{hasData := true.B}
					when(axi4.awready)	{hasAddr := true.B}
				}otherwise{
					hasData := false.B
					hasAddr := false.B
				}
				axi4.awaddr	:= in.pipe.result
				axi4.awvalid	:= status === LsuStatus.Call
				axi4.wvalid	:= status === LsuStatus.Call
				// axi4.wdata	:= in.pipe.r2
				axi4.bready	:= status === LsuStatus.Back
				switch(in.pipe.lsuAddr){
					is(LsuAddr.B){axi4.wstrb := 0b0001.U << in.pipe.result(1,0)}
					is(LsuAddr.H){axi4.wstrb := 0b0011.U << in.pipe.result(1,0)}
					is(LsuAddr.W){axi4.wstrb := 0b1111.U}
				}
				switch(in.pipe.lsuAddr){
					is(LsuAddr.B){axi4.wdata	:= Fill(4,in.pipe.r2(7,0))}
					is(LsuAddr.H){axi4.wdata	:= Fill(2,in.pipe.r2(15,0))}
					is(LsuAddr.W){axi4.wdata	:= in.pipe.r2}
				}
			}
			is(LsuOp.Load){
				axi4.araddr	:= Cat(in.pipe.result(BitWidth-1,2),0.U(2.W))
				axi4.arvalid	:= status === LsuStatus.Call
				axi4.rready	:= status === LsuStatus.Back
			}
		}
		when(status === LsuStatus.Back){
			switch(in.pipe.lsuOp){
				is(LsuOp.Load)	{backError := axi4.rresp =/= 0.U}
				is(LsuOp.Store)	{backError := axi4.bresp =/= 0.U}
			}
		}
		when(in.pipe.lsuOp === LsuOp.Load){
			val rdata = RegInit(0.U(BitWidth.W))
			when(status === LsuStatus.Back & axi4.rvalid){rdata := axi4.rdata >> (8.U * in.pipe.result(1,0))}
			switch(in.pipe.lsuAddr){
				is(LsuAddr.B ){out.pipe.result := Cat(Fill(BitWidth-8,	axi4.rdata(7)),	axi4.rdata(7,0))}
				is(LsuAddr.H ){out.pipe.result := Cat(Fill(BitWidth-16,	axi4.rdata(15)),	axi4.rdata(15,0))}
				is(LsuAddr.W ){out.pipe.result := rdata}
				is(LsuAddr.Bu){out.pipe.result := Cat(0.U((BitWidth-8).W),	axi4.rdata(7,0))}
				is(LsuAddr.Hu){out.pipe.result := Cat(0.U((BitWidth-16).W),	axi4.rdata(15,0))}
			}
		}
	}
	when(addrError | backError){
		out.pipe.valid	:= false.B
		when(in.imme.back === Back.Error){out.imme.back	:= Back.Error}
		.otherwise{out.imme.back	:= Back.Wait}
	}otherwise{
		val ready = ~(status === LsuStatus.Suce^in.pipe.lsuOp =/= LsuOp.Null)
		out.pipe.valid:= ready & in.pipe.valid
		when(in.imme.back === Back.Error){out.imme.back	:= Back.Error}
		.elsewhen(ready & in.imme.back === Back.Ready){out.imme.back	:= Back.Ready}
		.otherwise{out.imme.back	:= Back.Wait}
	}
}