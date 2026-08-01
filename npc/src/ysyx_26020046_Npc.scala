import chisel3._
import chisel3.util._
import WidthConsts._
//TODO:需要BlackBox
//根据官网，blackbox已经被废弃了，使用ExtModule
object NpcStatus extends ChiselEnum{val Idle,Read,Write = Value}
class ysyx_26020046_Npc extends Module{
	val PcInit:UInt=0x80000000L.U
	val cpu = Module(new ysyx_26020046(PcInit))
	val mem = Module(new ysyx_26020046_Mem())
	val status = RegInit(NpcStatus.Idle)
	val rAddr = RegInit(0.U(32.W))
	val wAddr = RegInit(0.U(32.W))
	val wData = RegInit(0.U(32.W))
	val wStrb = RegInit(0.U(4.W))
	val wAddrValid = RegInit(false.B)
	val wDataValid = RegInit(false.B)
	val writeValid = (wAddrValid||cpu.io.master.awvalid)&(wDataValid||cpu.io.master.wvalid)
	switch(status){
		is(NpcStatus.Idle){
			when(cpu.io.master.arvalid)	{status := NpcStatus.Read}
			.elsewhen(writeValid)		{status := NpcStatus.Write}
		}
		is(NpcStatus.Read)	{when(cpu.io.master.rready){status := NpcStatus.Idle}}
		is(NpcStatus.Write)	{when(cpu.io.master.bready){status := NpcStatus.Idle}}
	}
	when(cpu.io.master.arvalid && cpu.io.master.araddr(31,28) =/= 0x8.U(4.W)){
		printf("npc mem error rAddr:%x\n",cpu.io.master.araddr)
		stop()
	}
	when(cpu.io.master.awvalid && ~(
		cpu.io.master.awaddr(31,28) === 0x8.U(4.W) ||
		cpu.io.master.awaddr === 0x10000000.U(32.W)
	)){
		printf("npc mem error wAddr:%x\n",cpu.io.master.awaddr)
		stop()
	}
	cpu.io.master.arready := status === NpcStatus.Idle
	cpu.io.master.rdata	:= Mux(status === NpcStatus.Read,mem.read.data,0.U)
	cpu.io.master.rresp	:= 0.U//OKAY
	cpu.io.master.rvalid	:= status === NpcStatus.Read
	when(status === NpcStatus.Idle & cpu.io.master.arvalid){rAddr := cpu.io.master.araddr}

	cpu.io.master.awready	:= status === NpcStatus.Idle
	cpu.io.master.wready	:= status === NpcStatus.Idle
	cpu.io.master.bresp	:= 0.U//OKAY
	cpu.io.master.bvalid	:= status === NpcStatus.Write
	when(status === NpcStatus.Idle & cpu.io.master.awvalid){
		wAddr := cpu.io.master.awaddr
		wAddrValid := true.B
	}
	when(status === NpcStatus.Write & cpu.io.master.bready){
		wAddrValid := false.B
		wDataValid := false.B
	}
	when(status === NpcStatus.Idle & cpu.io.master.wvalid){
		wData := cpu.io.master.wdata
		wStrb := cpu.io.master.wstrb
		wDataValid := true.B
	}

	mem.read.valid 	:= status === NpcStatus.Read
	mem.read.addr  	:= rAddr
	mem.write.valid := status === NpcStatus.Write && wAddr(31,28) === 0x8.U(4.W)
	mem.write.addr  := wAddr
	mem.write.strb  := wStrb
	mem.write.data  := wData

	when(status === NpcStatus.Write && wAddr === 0x10000000.U(32.W)){printf("%c",wData(7,0))}

	cpu.io.master.rid	:= 0.U
	cpu.io.master.rlast	:= false.B
	cpu.io.master.bid	:= 0.U

	cpu.io.slave.arvalid:= false.B
	cpu.io.slave.araddr	:= 0.U
	cpu.io.slave.arid	:= 0.U
	cpu.io.slave.arlen	:= 0.U
	cpu.io.slave.arsize	:= 0.U
	cpu.io.slave.arburst:= 0.U
	cpu.io.slave.rready	:= false.B
	cpu.io.slave.awvalid:= false.B
	cpu.io.slave.awaddr	:= 0.U
	cpu.io.slave.awid	:= 0.U
	cpu.io.slave.awlen	:= 0.U
	cpu.io.slave.awsize	:= 0.U
	cpu.io.slave.awburst:= 0.U
	cpu.io.slave.wvalid	:= false.B
	cpu.io.slave.wdata	:= 0.U
	cpu.io.slave.wstrb	:= 0.U
	cpu.io.slave.wlast	:= false.B
	cpu.io.slave.bready	:= false.B

	cpu.io.interrupt	:= false.B;
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
	import "DPI-C" function int sdram_read(input int addr);
	import "DPI-C" function void sdram_write(input int addr, input int data);
	assign read_data = read_valid?sdram_read({5'd0,read_addr[26:2],2'b00}):0;
	always_ff@(posedge write_valid) begin
		if(write_strb[0])sdram_write({5'b0,write_addr[26:2],2'b00},{24'd0,write_data[ 7: 0]});
		if(write_strb[1])sdram_write({5'b0,write_addr[26:2],2'b01},{24'd0,write_data[15: 8]});
		if(write_strb[2])sdram_write({5'b0,write_addr[26:2],2'b10},{24'd0,write_data[23:16]});
		if(write_strb[3])sdram_write({5'b0,write_addr[26:2],2'b11},{24'd0,write_data[31:24]});
	end
	endmodule
	"""
	)
}