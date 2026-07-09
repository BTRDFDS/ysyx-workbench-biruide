import chisel3._
import chisel3.util._

object IfuStatus extends ChiselEnum{val Back,Call,Func=Value}
class ysyx_26020046_Ifu(val Width:Int=32, val RegNum:Int=32,val PcInit:UInt=0x80000000L.U) extends Module{
	val io = IO(new Bundle{
		val pipeOut = new PipeIfId(Width)
		val immeIn  = Flipped(new ImmeBefore(Width))
		val axi4    = new Axi4Master()
	})
	//FSM
		val status = RegInit(IfuStatus.Call)
		val ready = io.immeIn.back	===	Back.Ready
		switch(status){
			is(IfuStatus.Call){when(io.axi4.arready){status := IfuStatus.Back}}
			is(IfuStatus.Back){when(io.axi4.rvalid)	{status := IfuStatus.Func}}
			is(IfuStatus.Func){when(ready)			{status := IfuStatus.Call}}
		}	
	//pc更新
		val pc = RegInit(PcInit)
		switch(io.immeIn.back){
			is(Back.Jump)	{pc := io.immeIn.addr}
			is(Back.Error)	{pc := io.immeIn.addr}
			is(Back.Ready)	{when(status === IfuStatus.Back){pc := pc + 4.U}}//TODO:可能有问题
		}
		io.pipeOut.pc	:= pc
	//输出指令
		val instr = RegInit(0.U(Width.W))
		when(status === IfuStatus.Back & io.axi4.rvalid === true.B){instr := io.axi4.rdata}
		io.pipeOut.instr := instr
	//输出状态
		io.pipeOut.res	:= IfuRes.Null
		switch(status){
			is(IfuStatus.Back){when(io.axi4.rvalid =/= 0.U){io.pipeOut.res := IfuRes.Fall}}
			is(IfuStatus.Func){io.pipeOut.res := IfuRes.Valid}
			is(IfuStatus.Call){when(pc(1,0) =/= 0.U){io.pipeOut.res := IfuRes.Un4b}}
		}
	//axi4输出信号
		io.axi4.araddr	:= pc
		io.axi4.arvalid	:= status === IfuStatus.Call
		io.axi4.rready	:= status === IfuStatus.Back
	//用不到的axi4
		io.axi4.awvalid	:= false.B
		io.axi4.wvalid	:= false.B
		io.axi4.bready	:= false.B
		io.axi4.awaddr	:= 0.U
		io.axi4.wdata	:= 0.U
		io.axi4.wstrb	:= 0.U
}