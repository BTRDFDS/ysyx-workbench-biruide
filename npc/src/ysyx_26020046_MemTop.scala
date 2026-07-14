import chisel3._
import chisel3.util._
import WidthConsts._
//TODO:需要BlackBox
//根据官网，blackbox已经被废弃了，使用ExtModule
object MemStatus extends ChiselEnum{val Idle,Read,Write = Value}
class ysyx_26020046_MemTop extends Module{
	val cpu = Module(new ysyx_26020046())
	val mem = Module(new ysyx_26020046_Mem())
	val status = RegInit(MemStatus.Idle)
	val rAddr = RegInit(0.U(32.W))
	val wAddr = RegInit(0.U(32.W))
	val wData = RegInit(0.U(32.W))
	val wStrb = RegInit(0.U(4.W))
	val wAddrValid = RegInit(false.B)
	val wDataValid = RegInit(false.B)
	val writeValid = (wAddrValid||cpu.io.master.awvalid)&(wDataValid||cpu.io.master.wvalid)
	switch(status){
		is(MemStatus.Idle){
			when(cpu.io.master.arvalid)	{status := MemStatus.Read}
			.elsewhen(writeValid)		{status := MemStatus.Write}
		}
		is(MemStatus.Read)	{when(cpu.io.master.rready){status := MemStatus.Idle}}
		is(MemStatus.Write)	{when(cpu.io.master.bready){status := MemStatus.Idle}}
	}
	cpu.io.master.arready := status === MemStatus.Idle
	cpu.io.master.rdata	:= Mux(status === MemStatus.Read,mem.read.data,0.U)
	cpu.io.master.rresp	:= 0.U//OKAY
	cpu.io.master.rvalid	:= status === MemStatus.Read
	when(status === MemStatus.Idle & cpu.io.master.arvalid){rAddr := cpu.io.master.araddr}

	cpu.io.master.awready	:= status === MemStatus.Idle
	cpu.io.master.wready	:= status === MemStatus.Idle
	cpu.io.master.bresp	:= 0.U//OKAY
	cpu.io.master.bvalid	:= status === MemStatus.Write
	when(status === MemStatus.Idle & cpu.io.master.awvalid){
		wAddr := cpu.io.master.awaddr
		wAddrValid := true.B
	}
	when(status === MemStatus.Write & cpu.io.master.bready){
		wAddrValid := false.B
		wDataValid := false.B
	}
	when(status === MemStatus.Idle & cpu.io.master.wvalid){
		wData := cpu.io.master.wdata
		wStrb := cpu.io.master.wstrb
		wDataValid := true.B
	}

	mem.read.valid 	:= status === MemStatus.Read
	mem.read.addr  	:= rAddr
	mem.write.valid := status === MemStatus.Write
	mem.write.addr  := wAddr
	mem.write.strb  := wStrb
	mem.write.data  := wData

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
		val strb	= Input(UInt(4.W))
		val data	= Input(UInt(32.W))
	})
	setInline("ysyx_26020046_Mem.sv",
	"""
	module ysyx_26020046_Mem(
		input logic read_valid,
		input logic[31:0] read_addr,
		output logic[31:0] read_data,
		input logic write_valid,
		input logic[31:0] write_addr,
		input logic[3:0] write_strb,
		input logic[31:0] write_data
	);
	import "DPI-C" function int pmem_read(input int addr);
	import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);
	assign read_data = read_valid?pmem_read(read_addr):0;
	always_ff@(posedge write_valid) begin
			pmem_write(write_addr, write_data, {4'b0,write_strb});
	end
	endmodule
	"""
	)
}