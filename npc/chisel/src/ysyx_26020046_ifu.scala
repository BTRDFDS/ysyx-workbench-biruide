import chisel3._
import chisel3.util._

object IfuStatus extends ChiselEnum{val Back,Call,Func=Value}
class ysyx_26020046_Ifu(val Width:Int=32, val RegNum:Int=32,val PcInit:UInt=0x80000000L.U) extends Module{
	val io = IO(new Bundle{
		val pipeOut = new PipeIfId(Width)
		val immeIn  = Flipped(new ImmeBefore(Width))
		val axi4    = new Axi4Master()
	})
	val pc = RegInit(PcInit)
	val instr = RegInit(0.U(Width.W))
	val status = RegInit(IfuStatus.Call)
	val nextStatus = WireInit(IfuStatus.Call)
	val ready = io.immeIn.back	===	Back.Ready
	switch(status){
		is(IfuStatus.Call){nextStatus := Mux(io.axi4.arready,	IfuStatus.Call,IfuStatus.Back)}
		is(IfuStatus.Back){nextStatus := Mux(io.axi4.rvalid,	IfuStatus.Back,IfuStatus.Func)}
		is(IfuStatus.Func){nextStatus := Mux(ready,				IfuStatus.Func,IfuStatus.Call)}
	}
	io.axi4.araddr  := pc
	io.axi4.arvalid  := status === IfuStatus.Call
	io.axi4.rready   := status === IfuStatus.Back
	
	status := nextStatus

	switch(io.immeIn.back){
		is(Back.Jump)	{pc := io.immeIn.addr}
		is(Back.Error)	{pc := io.immeIn.addr}
		is(Back.Ready)	{when(status === IfuStatus.Back){pc := pc + 4.U}}
	}
	io.pipeOut.res	:= IfuRes.Null
	io.pipeOut.pc	:= pc
	switch(status){
		is(IfuStatus.Back){when(io.axi4.rvalid =/= 0.U){io.pipeOut.res := IfuRes.Fall}}
		is(IfuStatus.Func){io.pipeOut.res := IfuRes.Valid}
	}
	when(status === IfuStatus.Back & nextStatus === IfuStatus.Func){instr := io.axi4.rdata}//FSM时序信号
	io.pipeOut.instr := instr

	//用不到
	io.axi4.awvalid := false.B
	io.axi4.wvalid := false.B
	io.axi4.bready := false.B
	io.axi4.awaddr := 0.U
	io.axi4.wdata := 0.U
	io.axi4.wstrb := 0.U
}