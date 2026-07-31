import chisel3._
import chisel3.util._
import WidthConsts._

object ArbStatusLoad	extends ChiselEnum{val Idle,IfuCall,IfuBack,LsuCall,LsuBack=Value}
object ArbStatusStore	extends ChiselEnum{val Idle,Call,Back=Value}
object ArbAddr extends ChiselEnum{val Clint,Out,Error=Value}
class ysyx_26020046_Bar(val Yosys:Boolean=false) extends Module{
	val out = IO(new Axi4Master())
	val clt = IO(new Axi4Master())
	val ifuL = IO(Flipped(new LoaderBus()))
	val lsuL = IO(Flipped(new LoaderBus()))
	val lsuS = IO(Flipped(new StorerBus()))
	//初始化
	out.arvalid	:= false.B
	out.rready	:= false.B
	out.araddr	:= 0.U
	out.awvalid	:= false.B
	out.wvalid	:= false.B
	out.wdata	:= 0.U
	out.wstrb	:= 0.U
	out.bready	:= false.B
	out.awaddr	:= 0.U

	clt.arvalid	:= false.B
	clt.rready	:= false.B
	clt.araddr	:= 0.U
	clt.awvalid	:= false.B
	clt.wvalid	:= false.B
	clt.wdata	:= 0.U
	clt.wstrb	:= 0.U
	clt.bready	:= false.B
	clt.awaddr	:= 0.U
	{
		val status		= RegInit(ArbStatusLoad.Idle)
		val addr 		= RegInit(0.U(32.W))
		switch(status){
			is(ArbStatusLoad.Idle){
				when(lsuL.valid)		{status	:= ArbStatusLoad.LsuCall;addr := lsuL.addr}
				.elsewhen(ifuL.valid)	{status	:= ArbStatusLoad.IfuCall;addr := ifuL.addr}
			}
			is(ArbStatusLoad.IfuCall){when(Mux(addr(31:24) === 0x02.U(8.W),clt.arready,out.arready)){status := ArbStatusLoad.IfuBack}}
			is(ArbStatusLoad.LsuCall){when(Mux(addr(31:24) === 0x02.U(8.W),clt.arready,out.arready)){status := ArbStatusLoad.LsuBack}}
			is(ArbStatusLoad.IfuBack){when(Mux(addr(31:24) === 0x02.U(8.W),clt.rvalid,out.rvalid)){status := ArbStatusLoad.Idle}}
			is(ArbStatusLoad.LsuBack){when(Mux(addr(31:24) === 0x02.U(8.W),clt.rvalid,out.rvalid)){status := ArbStatusLoad.Idle}}
		}
		out.arvalid := (status === ArbStatusLoad.IfuCall || status === ArbStatusLoad.LsuCall) && addr(31:24) =/= 0x02.U(8.W)
		out.rready  := (status === ArbStatusLoad.IfuBack || status === ArbStatusLoad.LsuCall) && addr(31:24) =/= 0x02.U(8.W)
		out.araddr  := addr
		clt.arvalid := (status === ArbStatusLoad.IfuCall || status === ArbStatusLoad.LsuCall) && addr(31:24) === 0x02.U(8.W)
		clt.rready  := (status === ArbStatusLoad.IfuBack || status === ArbStatusLoad.LsuCall) && addr(31:24) === 0x02.U(8.W)
		clt.araddr  := addr
		ifuL.ready	:= Mux(status =/= IfuBack,0.U,Mux(addr(31:24) === 0x02.U(8.W),clt.rready,out.rready))
		ifuL.data	:= Mux(addr(31:24) === 0x02.U(8.W),clt.rdata,out.rdata)
		ifuL.error	:= Mux(status =/= IfuBack,0.U,Mux(addr(31:24) === 0x02.U(8.W),clt.rresp =/= 0.U,out.rresp =/= 0.U))
		lsuL.ready	:= Mux(status =/= LsuBack,0.U,Mux(addr(31:24) === 0x02.U(8.W),clt.rready,out.rready))
		lsuL.data	:= Mux(addr(31:24) === 0x02.U(8.W),clt.rdata,out.rdata)
		lsuL.error	:= Mux(status =/= LsuBack,0.U,Mux(addr(31:24) === 0x02.U(8.W),clt.rresp =/= 0.U,out.rresp =/= 0.U))
	}
	{
		val status		= RegInit(ArbStatusStore.Idle)
		val addr 		= RegInit(0.U(32.W))
		val hasAddr		= RegInit(false.B)
		val hasData		= RegInit(false.B)
		val finishAddr = hasAddr || out.awready
		val finishData = hasData || out.wready
		switch(status){
			is(ArbStatusStore.Idle){when(lsuS.valid){status := ArbStatusStore.Call;addr := lsuS.addr;}}
			is(ArbStatusStore.Call){when(finishAddr || finishData){status := ArbStatusStore.Back}}
			is(ArbStatusStore.Back){when(out.bvalid){status := ArbStatusStore.Idle}}
		}
		when(status === ArbStatusStore.Call){
			when(out.awready)	{hasAddr := true.B}
			when(out.wready)	{hasData := true.B}
		}otherwise{
			hasData := false.B
			hasAddr := false.B
		}
		out.awvalid	:= (status === ArbStatusStore.Call) && !hasAddr
		out.wvalid	:= (status === ArbStatusStore.Call) && !hasData
		out.wdata	:= lsuS.data
		out.wstrb	:= lsuS.strb
		out.bready	:= (status === ArbStatusStore.Back)
		out.awaddr	:= addr
		lsuS.ready	:= (status === ArbStatusStore.Back) && out.bvalid
		lsuS.error	:= (status === ArbStatusStore.Back) && out.bresp =/= 0.U
	}
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
	// 		when(status =/= ArbStatus.Idle){
	// 			printf("arb addr error %x\n",addr)
	// 			stop()
	// 		}
	// 	}
	// }
}
