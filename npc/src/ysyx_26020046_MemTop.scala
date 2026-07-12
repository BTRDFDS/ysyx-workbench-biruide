import chisel3._
import chisel3.util._
import WidthConsts._
// import chisel3.experimental.ExtModule
//TODO:需要BlackBox
//根据官网，blackbox已经被废弃了，使用import chisel3.experimental.ExtModule
object MemStatus extends ChiselEnum{val Idle,Read,Write = Value}
class ysyx_26020046_MemTop extends Module{
	val cpu = new ysyx_26020046()
	val mem = new ysyx_26020046_Mem()
	val status = RegInit(MemStatus.Idle)
	val rAddr = RegInit(0.U(32.W))
	val wAddr = RegInit(0.U(32.W))
	val wData = RegInit(0.U(32.W))
	val wStrb = RegInit(0.U(4.W))
	val wAddrValid = RegInit(false.B)
	val wDataValid = RegInit(false.B)
	val writeValid = (wAddrValid|cpu.io.axi4.awvalid)&(wDataValid|cpu.io.axi4.wvalid)
	switch(status){
		is(MemStatus.Idle){
			when(cpu.io.axi4.arvalid)	{status := MemStatus.Read}
			.elsewhen(writeValid)		{status := MemStatus.Write}
		}
		is(MemStatus.Read)	{when(cpu.io.axi4.rready){status := MemStatus.Idle}}
		is(MemStatus.Write)	{when(cpu.io.axi4.bready){status := MemStatus.Idle}}
	}
	cpu.io.axi4.arready := status === MemStatus.Idle
	cpu.io.axi4.rdata	:= Mux(status === MemStatus.Read,mem.read.data,0.U)
	cpu.io.axi4.rresp	:= 0.U//OKAY
	cpu.io.axi4.rvalid	:= status === MemStatus.Read
	when(status === MemStatus.Idle & cpu.io.axi4.arvalid){rAddr := cpu.io.axi4.araddr}

	cpu.io.axi4.awready	:= status === MemStatus.Idle
	cpu.io.axi4.wready	:= status === MemStatus.Idle
	cpu.io.axi4.bresp	:= 0.U//OKAY
	cpu.io.axi4.bvalid	:= status === MemStatus.Write
	when(status === MemStatus.Idle & cpu.io.axi4.awvalid){
		wAddr := cpu.io.axi4.awaddr
		wAddrValid := true.B
	}
	when(status === MemStatus.Write & cpu.io.axi4.bready){
		wAddrValid := false.B
		wDataValid := false.B
	}
	when(status === MemStatus.Idle & cpu.io.axi4.wvalid){
		wData := cpu.io.axi4.wdata
		wStrb := cpu.io.axi4.wstrb
		wDataValid := true.B
	}

}
class ysyx_26020046_Mem extends ExtModule{
    val read = IO(new Bundle{
		val valid	= Input(Bool())
		val addr	= Input(UInt(32.W))
		val data	= Output(UInt(32.W))
	})
	val write  = IO(new Bundle{
		val valid	= Input(Bool())
		val addr	= Input(UInt(32.W))
		val data	= Input(UInt(32.W))
	})
}