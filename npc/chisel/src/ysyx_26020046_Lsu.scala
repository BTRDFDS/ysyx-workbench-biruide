import chisel3._
import chisel3.util._
import WidthConsts._

object LsuStatus extends ChiselEnum{val Back,Call,Idle,Suce=Value}

class ysyx_26020046_Lsu extends Module{
	val io = IO(new Bundle{
		val pipeIn  = Flipped(new PipeExLs())
		val pipeOut	= new PipeLsWb()
		val immeIn	= Flipped(new ImmeAfter())
		val immeOut = new ImmeAfter()
		val axi4	= new Axi4Master()
	})
	io.pipeOut.valid	:= false.B
	io.pipeOut.rdAddr	:= io.pipeIn.rdAddr
	io.pipeOut.result	:= io.pipeIn.result
	io.pipeOut.pc		:= io.pipeIn.pc
	io.pipeOut.csrOp	:= io.pipeIn.csrOp
	io.pipeOut.csrAddr	:= io.pipeIn.csrAddr
	io.pipeOut.csrMesg	:= io.pipeIn.csrMesg

	//处理回传
	io.immeOut.r1Out	:= io.immeIn.r1Out
	io.immeOut.r2Out	:= io.immeIn.r2Out
	io.immeOut.csrOut	:= io.immeIn.csrOut
	io.immeOut.addr		:= io.immeIn.addr
	io.immeOut.back		:= io.immeIn.back

	io.immeIn.r1Addr	:= io.immeOut.r1Addr
	io.immeIn.r2Addr	:= io.immeOut.r2Addr
	io.immeIn.csrAddr	:= io.immeOut.csrAddr

	val hasAddr = RegInit(false.B)
	val hasData = RegInit(false.B)
	val finishAddr = hasAddr | io.axi4.awready
	val finishData = hasData | io.axi4.wready

	val backError = WireInit(false.B)
	val addrError = WireInit(false.B)

	val status = RegInit(LsuStatus.Idle)

	io.axi4.awaddr	:= 0.U
	io.axi4.awvalid	:= false.B
	io.axi4.wdata	:= 0.U
	io.axi4.wstrb	:= 0.U
	io.axi4.wvalid	:= false.B
	io.axi4.bready	:= false.B
	
	io.axi4.araddr	:= 0.U
	io.axi4.arvalid	:= false.B
	io.axi4.rready	:= false.B

	when(io.pipeIn.valid & io.pipeIn.lsuOp =/= LsuOp.Null){
		switch(io.pipeIn.lsuAddr){
			is(LsuAddr.H ){when(io.pipeIn.result(0)===1.U)	{addrError := true.B}}
			is(LsuAddr.Hu){when(io.pipeIn.result(1)===1.U)	{addrError := true.B}}
			is(LsuAddr.W ){when(io.pipeIn.result(1,0) =/= 0.U){addrError := true.B}}
		}
	}
	when(io.pipeIn.valid & addrError =/= true.B){
		switch(status){
			is(LsuStatus.Idle){when(io.pipeIn.lsuOp =/= LsuOp.Null){status := LsuStatus.Call}}
			is(LsuStatus.Call){switch(io.pipeIn.lsuOp){
				is(LsuOp.Load)	{when(io.axi4.arready)		{status := LsuStatus.Back}}
				is(LsuOp.Store)	{when(finishAddr&finishData){status := LsuStatus.Back}}
			}}
			is(LsuStatus.Back){switch(io.pipeIn.lsuOp){
				is(LsuOp.Load)	{when(io.axi4.rvalid){status := LsuStatus.Suce}}
				is(LsuOp.Store)	{when(io.axi4.bvalid){status := LsuStatus.Suce}}
			}}
			is(LsuStatus.Suce){when(io.immeIn.back === Back.Ready){status := LsuStatus.Idle}}
		}
		switch(io.pipeIn.lsuOp){
			is(LsuOp.Store){
				when(status === LsuStatus.Call){
					when(io.axi4.wready)	{hasData := true.B}
					when(io.axi4.awready)	{hasAddr := true.B}
				}otherwise{
					hasData := false.B
					hasAddr := false.B
				}
				io.axi4.awaddr	:= io.pipeIn.result
				io.axi4.awvalid	:= status === LsuStatus.Call
				io.axi4.wvalid	:= status === LsuStatus.Call
				// io.axi4.wdata	:= io.pipeIn.r2
				io.axi4.bready	:= status === LsuStatus.Back
				switch(io.pipeIn.lsuAddr){
					is(LsuAddr.B){io.axi4.wstrb := 0b0001.U << io.pipeIn.result(1,0)}
					is(LsuAddr.H){io.axi4.wstrb := 0b0011.U << io.pipeIn.result(1,0)}
					is(LsuAddr.W){io.axi4.wstrb := 0b1111.U}
				}
				switch(io.pipeIn.lsuAddr){
					is(LsuAddr.B){io.axi4.wdata	:= Fill(4,io.pipeIn.r2(7,0))}
					is(LsuAddr.H){io.axi4.wdata	:= Fill(2,io.pipeIn.r2(15,0))}
					is(LsuAddr.W){io.axi4.wdata	:= io.pipeIn.r2}
				}
			}
			is(LsuOp.Load){
				io.axi4.araddr	:= Cat(io.pipeIn.result(BitWidth-1,2),0.U(2.W))
				io.axi4.arvalid	:= status === LsuStatus.Call
				io.axi4.rready	:= status === LsuStatus.Back
			}
		}
		when(status === LsuStatus.Back){
			switch(io.pipeIn.lsuOp){
				is(LsuOp.Load)	{backError := io.axi4.rresp =/= 0.U}
				is(LsuOp.Store)	{backError := io.axi4.bresp =/= 0.U}
			}
		}
		when(io.pipeIn.lsuOp === LsuOp.Load){
			val rdata = RegInit(0.U(BitWidth.W))
			when(status === LsuStatus.Back & io.axi4.rvalid){rdata := io.axi4.rdata >> (8.U * io.pipeIn.result(1,0))}
			switch(io.pipeIn.lsuAddr){
				is(LsuAddr.B ){io.pipeOut.result := Cat(Fill(BitWidth-8,	io.axi4.rdata(7)),	io.axi4.rdata(7,0))}
				is(LsuAddr.H ){io.pipeOut.result := Cat(Fill(BitWidth-16,	io.axi4.rdata(15)),	io.axi4.rdata(15,0))}
				is(LsuAddr.W ){io.pipeOut.result := rdata}
				is(LsuAddr.Bu){io.pipeOut.result := Cat(0.U((BitWidth-8).W),	io.axi4.rdata(7,0))}
				is(LsuAddr.Hu){io.pipeOut.result := Cat(0.U((BitWidth-16).W),	io.axi4.rdata(15,0))}
			}
		}
	}
	when(addrError | backError){
		io.pipeOut.valid	:= false.B
		when(io.immeIn.back === Back.Error){io.immeOut.back	:= Back.Error}
		.otherwise{io.immeOut.back	:= Back.Wait}
	}otherwise{
		val ready = ~(status === LsuStatus.Suce^io.pipeIn.lsuOp =/= LsuOp.Null)
		io.pipeOut.valid:= ready & io.pipeIn.valid
		when(io.immeIn.back === Back.Error){io.immeOut.back	:= Back.Error}
		.elsewhen(ready & io.immeIn.back === Back.Ready){io.immeOut.back	:= Back.Ready}
		.otherwise{io.immeOut.back	:= Back.Wait}
	}
}