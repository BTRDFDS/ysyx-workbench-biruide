import chisel3._
import chisel3.util._
import WidthConsts._

class xbar(val Yosys:Boolean=false) extends Module{
	val out = IO(new Axi4Master())
	val clt = IO(new Axi4Master())
	val ifu = IO(Flipped(new BurstBus()))
	val lsu = IO(Flipped(new MemBus()))
object BarRstate	extends ChiselEnum{val Idle,IfuCall,IfuBack,LsuCall,LsuBack=Value}
	val rState		= RegInit(BarRstate.Idle)
	val rAddr 		= RegInit(0.U(32.W))
	// switch(rState){
	// 	is(BarRstate.Idle){
	// 		when(lsu.valid&& ~lsu.write){rState:= BarRstate.LsuCall}
	// 		.elsewhen(ifu.valid)		{rState := BarRstate.IfuCall}
	// 	}
	// 	is(BarRstate.IfuCall){when(out.arready)													{rState := BarRstate.IfuBack}}
	// 	is(BarRstate.IfuBack){when(out.rlast)													{rState := BarRstate.Idle	}}
	// 	is(BarRstate.LsuCall){when(Mux(rAddr(31,24) === 0x02.U(8.W),clt.arready,out.arready))	{rState := BarRstate.LsuBack}}
	// 	is(BarRstate.LsuBack){when(Mux(rAddr(31,24) === 0x02.U(8.W),clt.rvalid,out.rvalid))		{rState := BarRstate.Idle	}}
	// }
	rState := Mux1H(Seq(
		(rState===BarRstate.Idle)	-> Mux(lsu.valid&& ~lsu.write,BarRstate.LsuCall,Mux(ifu.valid,BarRstate.IfuCall,BarRstate.Idle)),
		(rState===BarRstate.IfuCall)-> Mux(out.arready	,BarRstate.IfuBack	,BarRstate.IfuCall),
		(rState===BarRstate.IfuBack)-> Mux(out.rlast	,BarRstate.Idle		,BarRstate.IfuBack),
		(rState===BarRstate.LsuCall)-> Mux(Mux(rAddr(31,24) === 0x02.U(8.W),clt.arready,out.arready),BarRstate.LsuBack	,BarRstate.LsuCall),
		(rState===BarRstate.LsuBack)-> Mux(Mux(rAddr(31,24) === 0x02.U(8.W),clt.rvalid ,out.rvalid ),BarRstate.Idle		,BarRstate.LsuBack),
	))
	when(rState === BarRstate.Idle){rAddr := Mux(lsu.valid&& ~lsu.write,lsu.addr,Cat(ifu.addr,0.U(2.W)))}
	out.arvalid := (rState === BarRstate.IfuCall || rState === BarRstate.LsuCall) && rAddr(31,24) =/= 0x02.U(8.W)
	out.rready  := (rState === BarRstate.IfuBack || rState === BarRstate.LsuBack) && rAddr(31,24) =/= 0x02.U(8.W)
	out.araddr  := rAddr
	out.arlen	:= Mux(rState === BarRstate.IfuCall,(CacheSize-1).U,0.U)//只有ifu能突发
	out.arsize	:= Mux(rState === BarRstate.IfuCall,2.U,lsu.size)
	out.arburst := Mux(rState === BarRstate.IfuCall,2.U,0.U)
	clt.arvalid := (rState === BarRstate.LsuCall) && rAddr(31,24) === 0x02.U(8.W)
	clt.rready  := (rState === BarRstate.LsuBack) && rAddr(31,24) === 0x02.U(8.W)
	clt.araddr  := rAddr
	clt.arlen	:= 0.U
	clt.arsize	:= 0.U//用不到
	clt.arburst := 0.U
	ifu.data	:= Mux(rAddr(31,24) === 0x02.U(8.W),clt.rdata,out.rdata)
	when(rState === BarRstate.IfuBack){
		when(out.rresp =/= 0.U)	{ifu.res := BurstRes.Erro}
		.elsewhen(out.rlast)	{ifu.res := BurstRes.Done}
		.elsewhen(out.rvalid)	{ifu.res := BurstRes.Read}
		.otherwise				{ifu.res := BurstRes.Idle}
	}.otherwise{ifu.res := BurstRes.Idle}
	lsu.rdata	:= Mux(rAddr(31,24) === 0x02.U(8.W),clt.rdata,out.rdata)

object BarWstate	extends ChiselEnum{val Idle,Call,Back=Value}
	val wState		= RegInit(BarWstate.Idle)
	val wAddr 		= RegInit(0.U(32.W))
	val hasAddr		= RegInit(false.B)
	val hasData		= RegInit(false.B)
	val finishAddr = hasAddr || out.awready
	val finishData = hasData || out.wready

	// switch(wState){
	// 	is(BarWstate.Idle){when(lsu.write && lsu.valid)		{wState := BarWstate.Call}}
	// 	is(BarWstate.Call){when(finishAddr || finishData)	{wState := BarWstate.Back}}
	// 	is(BarWstate.Back){when(out.bvalid)					{wState := BarWstate.Idle}}
	// }
	wState := Mux1H(Seq(
		(wState===BarWstate.Idle) -> Mux(lsu.write && lsu.valid		,BarWstate.Call,BarWstate.Idle),
		(wState===BarWstate.Call) -> Mux(finishAddr || finishData	,BarWstate.Back,BarWstate.Call),
		(wState===BarWstate.Back) -> Mux(out.bvalid					,BarWstate.Idle,BarWstate.Back),
	))
	when(wState === BarWstate.Idle){wAddr := lsu.addr}
	when(wState === BarWstate.Call){
		when(out.awready)	{hasAddr := true.B}
		when(out.wready)	{hasData := true.B}
	}otherwise{
		hasData := false.B
		hasAddr := false.B
	}
	out.awvalid	:= (wState === BarWstate.Call) && !hasAddr
	out.wvalid	:= (wState === BarWstate.Call) && !hasData
	out.wdata	:= lsu.wdata
	out.wstrb	:= lsu.wstrb
	out.bready	:= (wState === BarWstate.Back)
	out.awaddr	:= wAddr
	clt.awvalid := false.B
	clt.awaddr	:= 0.U
	clt.wdata	:= 0.U
	clt.wstrb	:= 0.U
	clt.wvalid	:= false.B
	clt.bready	:= false.B

	lsu.ready	:= ((wState === BarWstate.Back) && out.bvalid)			|| (rState === BarRstate.LsuBack && Mux(rAddr(31,24) === 0x02.U(8.W),clt.rvalid,out.rvalid))
	lsu.error	:= ((wState === BarWstate.Back) && out.bresp =/= 0.U)	|| (rState === BarRstate.LsuBack && Mux(rAddr(31,24) === 0x02.U(8.W),clt.rresp,out.rresp) =/= 0.U)
	


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
