import chisel3._
import chisel3.util._
import WidthConsts._

object BarState	extends ChiselEnum{val Idle,IfuCall,IfuBack,LsuCall,LsuBack,LsuWrit,LsuDone=Value}
class ysyx_26020046_Bar(val Yosys:Boolean=false) extends Module{
	val out = IO(new Axi4Master())
	val clt = IO(new Axi4Master())
	val ifu = IO(Flipped(new BurstBus()))
	val lsu = IO(Flipped(new MemBus()))
	
	val state		= RegInit(BarState.Idle)
	val addr 		= RegInit(0.U(32.W))
	val hasAddr		= RegInit(false.B)
	val hasData		= RegInit(false.B)
	val finishAddr = hasAddr || out.awready
	val finishData = hasData || out.wready

	switch(state){
		is(BarState.Idle){
			when(lsu.size =/= 0b11.U){
				state	:= Mux(lsu.write,BarState.LsuWrit,BarState.LsuCall)
				addr	:= lsu.addr
			}.elsewhen(ifu.valid){state := BarState.IfuCall;addr := ifu.addr}
		}
		is(BarState.IfuCall){when(out.arready)												{state := BarState.IfuBack	}}
		is(BarState.IfuBack){when(out.rlast)												{state := BarState.Idle	}}
		is(BarState.LsuCall){when(Mux(addr(31,24) === 0x02.U(8.W),clt.arready,out.arready))	{state := BarState.LsuBack	}}
		is(BarState.LsuBack){when(Mux(addr(31,24) === 0x02.U(8.W),clt.rvalid,out.rvalid))	{state := BarState.Idle	}}
		is(BarState.LsuWrit){when(finishAddr || finishData)									{state := BarState.LsuDone	}}
		is(BarState.LsuDone){when(out.bvalid)												{state := BarState.Idle	}}
	}
	out.arvalid := (state === BarState.IfuCall || state === BarState.LsuCall) && addr(31,24) =/= 0x02.U(8.W)
	out.rready  := (state === BarState.IfuBack || state === BarState.LsuBack) && addr(31,24) =/= 0x02.U(8.W)
	out.araddr  := addr
	out.arlen	:= Mux(state === BarState.IfuCall,(CacheSize-1).U,0.U)//只有ifu能突发
	out.arsize	:= Mux(state === BarState.IfuCall,2.U,lsu.size)
	out.arburst := Mux(state === BarState.IfuCall,2.U,0.U)
	clt.arvalid := (state === BarState.IfuCall || state === BarState.LsuCall) && addr(31,24) === 0x02.U(8.W)
	clt.rready  := (state === BarState.IfuBack || state === BarState.LsuBack) && addr(31,24) === 0x02.U(8.W)
	clt.araddr  := addr
	clt.arlen	:= 0.U
	clt.arsize	:= 0.U//用不到
	clt.arburst := 0.U

	ifu.data	:= Mux(addr(31,24) === 0x02.U(8.W),clt.rdata,out.rdata)

	when(state === BarState.IfuBack){
		when(out.rresp === 0.U)	{ifu.res := BurstRes.Erro}
		.elsewhen(out.rlast)	{ifu.res := BurstRes.Done}
		.elsewhen(out.rvalid)	{ifu.res := BurstRes.Read}
		.otherwise				{ifu.res := BurstRes.Idle}
	}.otherwise{ifu.res := BurstRes.Idle}

	lsu.rdata	:= Mux(addr(31,24) === 0x02.U(8.W),clt.rdata,out.rdata)
	when(state === BarState.LsuWrit){
		when(out.awready)	{hasAddr := true.B}
		when(out.wready)	{hasData := true.B}
	}otherwise{
		hasData := false.B
		hasAddr := false.B
	}
	out.awvalid	:= (state === BarState.LsuWrit) && !hasAddr
	out.wvalid	:= (state === BarState.LsuWrit) && !hasData
	out.wdata	:= lsu.wdata
	out.wstrb	:= lsu.wstrb
	out.bready	:= (state === BarState.LsuDone)
	out.awaddr	:= addr
	lsu.ready	:= ((state === BarState.LsuDone) && out.bvalid) || (state === BarState.LsuBack && Mux(addr(31,24) === 0x02.U(8.W),clt.rvalid,out.rvalid))
	lsu.error	:= ((state === BarState.LsuDone) && out.bresp =/= 0.U) || (state === BarState.LsuBack && Mux(addr(31,24) === 0x02.U(8.W),clt.rresp,out.rresp) =/= 0.U)
	
	clt.awvalid := false.B
	clt.wvalid	:= false.B
	clt.bready	:= false.B
	clt.awaddr	:= 0.U
	clt.wdata	:= 0.U
	clt.wstrb	:= 0.U
	clt.arlen	:= 0.U
	clt.arsize	:= 0.U
	clt.arburst := 0.U


	// val addrValid = (
	// 	(addr		=== 0x02.U(8.W))	||//clint
	// 	(addr		=== 0x0f.U(8.W))	||//sram
	// 	(addr		=== 0x10.U(8.W))	||//UART16550 or SPI or GPIO or PS2
	// 	(addr		=== 0x20.U(8.W))	||//mrom
	// 	(addr		=== 0x21.U(8.W))	||//vga
	// 	(addr(7,4))	===	0x3.U(4.W)		||//flash
	// 	(addr(7,5)	=== 0b100.U(3.W))	||//psram
	// 	(addr(7,5)	=== 0b101.U(3.W))	||//sdram
	// 	(addr(7,6)	=== 0b11.U(2.W)))	  //ChipLink
	// when(~addrValid){
	// 	if(Yosys == false){
	// 		when(state =/= ArbStatus.Idle){
	// 			printf("arb addr error %x\n",addr)
	// 			stop()
	// 		}
	// 	}
	// }
}
