import chisel3._
import chisel3.util._
import WidthConsts._
//TODO:需要BlackBox
//根据官网，blackbox已经被废弃了，使用ExtModule
//TODO:1为了简化进行了一定程度的行为建模2写没有处理突发传输3读写可能冲不过应该问题不大
object NpcState extends ChiselEnum{val Idle,Back = Value}
class ysyx_26020046_Npc extends Module{
	val PcInit:UInt=0x80000000L.U
	val cpu = Module(new ysyx_26020046(PcInit))
	val mem = Module(new ysyx_26020046_Mem())

	val rState	= RegInit(NpcState.Idle)
	val araddr	= RegInit(0.U(BitWidth.W))
	val arlen	= RegInit(0.U(LenWidth.W))
	val arsiz	= RegInit(0.U(SizeWidth.W))
	val arburst	= RegInit(0.U(BurstWidth.W))
	val cnt		= RegInit(0.U(CacheWidth.W))
	when(rState===NpcState.Idle){
		when(cpu.io.master.arvalid){
			rState	:= NpcState.Back
			araddr	:= cpu.io.master.araddr
			arlen	:= cpu.io.master.arlen
			arsiz	:= cpu.io.master.arsize
			arburst	:= cpu.io.master.arburst
		}
		cnt	:= 0.U
		cpu.io.master.arready	:= true.B
		cpu.io.master.rvalid	:= false.B
		cpu.io.master.rlast		:= false.B
		cpu.io.master.rdata		:= 0.U
		cpu.io.master.rresp		:= 0.U
		mem.read.valid			:= false.B
		mem.read.addr			:= 0.U
	}.otherwise{
		when(cpu.io.master.rready && Mux(arburst===2.U,cnt===arlen,true.B)){rState := NpcState.Idle}
		cnt := cnt + 1.U
		cpu.io.master.arready	:= false.B
		cpu.io.master.rvalid	:= true.B
		cpu.io.master.rlast		:= Mux(arburst===2.U,cnt===arlen,true.B)
		cpu.io.master.rdata		:= mem.read.data
		cpu.io.master.rresp		:= 0.U
		mem.read.valid	:= true.B
		mem.read.addr	:= Cat(araddr(31,CacheWidth+2),(cnt+araddr(CacheWidth+1,2)),0.U(2.W))
		// val myAddr0 = Cat(araddr(31,CacheWidth+2),0.U((CacheWidth+2).W));dontTouch(myAddr0)
		// val myAddr1 = araddr(CacheWidth+1,2)							;dontTouch(myAddr1)
		// val myAddr2 = cnt+araddr(CacheWidth+1,2)						;dontTouch(myAddr2)
		when(arburst=/=2.U && arburst=/=0.U){printf("arburst=%x error\n",arburst);stop();}
		when(arsiz=/=0.U && arsiz=/=1.U && arsiz=/=2.U){printf("arsize=%x error\n",arsiz);stop();}
	}
	val wState = RegInit(NpcState.Idle)
	val awaddr= RegInit(0.U(BitWidth.W))
	val wdata = RegInit(0.U(BitWidth.W))
	val wstrb = RegInit(0.U(StrbWidth.W))
	val hasAddr = RegInit(false.B)
	val hasData = RegInit(false.B)
	when(wState===NpcState.Idle){
		when((hasAddr && hasData) || (cpu.io.master.awvalid && cpu.io.master.wvalid)){wState:=NpcState.Back}
		hasAddr := cpu.io.master.awvalid
		hasData := cpu.io.master.wvalid
		when(cpu.io.master.awvalid && ~hasAddr){
			awaddr := cpu.io.master.awaddr
		}
		when(cpu.io.master.wvalid && ~hasData){
			wdata := cpu.io.master.wdata
			wstrb := cpu.io.master.wstrb
		}
		cpu.io.master.awready	:= ~hasAddr
		cpu.io.master.wready	:= ~hasData
		cpu.io.master.bvalid	:= false.B
		cpu.io.master.bresp		:= 0.U
		mem.write.valid	:= false.B
		mem.write.addr		:= 0.U
		mem.write.strb		:= 0.U
		mem.write.data		:= 0.U
	}.otherwise{
		when(cpu.io.master.bready){wState := NpcState.Idle}
		hasAddr := false.B
		hasData := false.B
		cpu.io.master.awready	:= false.B
		cpu.io.master.wready	:= false.B
		cpu.io.master.bvalid	:= true.B
		cpu.io.master.bresp		:= 0.U
		mem.write.valid	:= true.B
		mem.write.addr		:= awaddr
		mem.write.strb		:= wstrb
		mem.write.data		:= wdata
	}

	// val arid	= Output(UInt(IdWidth.W))
	// val awid	= Output(UInt(IdWidth.W))
	// val awlen	= Output(UInt(LenWidth.W))
	// val awsize	= Output(UInt(SizeWidth.W))
	// val awburst	= Output(UInt(BurstWidth.W))
	// val wlast	= Output(Bool())Z
	cpu.io.master.rid	:= 0.U
	cpu.io.master.bid	:= 0.U

	cpu.io.interrupt	:= false.B
	
	cpu.io.slave.arvalid	:= false.B
	cpu.io.slave.rready		:= false.B
	cpu.io.slave.awvalid	:= false.B
	cpu.io.slave.wvalid		:= false.B
	cpu.io.slave.bready		:= false.B
	cpu.io.slave.wlast		:= false.B
    cpu.io.slave.araddr		:= 0.U
	cpu.io.slave.arlen		:= 0.U
	cpu.io.slave.arsize		:= 0.U
	cpu.io.slave.arburst	:= 0.U
	cpu.io.slave.awaddr		:= 0.U
	cpu.io.slave.wdata		:= 0.U
	cpu.io.slave.wstrb		:= 0.U
	cpu.io.slave.arid		:= 0.U
	cpu.io.slave.awid		:= 0.U
	cpu.io.slave.awlen		:= 0.U
	cpu.io.slave.awsize		:= 0.U
	cpu.io.slave.awburst	:= 0.U
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
	import "DPI-C" function int psram_read(input int addr);
	import "DPI-C" function void psram_write(input int addr, input int data);
	assign read_data = read_valid?psram_read({5'd0,read_addr[26:2],2'b00}):0;
	always_ff@(posedge write_valid) if(write_addr[31:28]==4'b1000)begin
		if(write_strb[0])psram_write({5'b0,write_addr[26:2],2'b00},{24'd0,write_data[ 7: 0]});
		if(write_strb[1])psram_write({5'b0,write_addr[26:2],2'b01},{24'd0,write_data[15: 8]});
		if(write_strb[2])psram_write({5'b0,write_addr[26:2],2'b10},{24'd0,write_data[23:16]});
		if(write_strb[3])psram_write({5'b0,write_addr[26:2],2'b11},{24'd0,write_data[31:24]});
	end else if(write_addr==32'h10000000)$write("%c",write_data[ 7: 0]);
	endmodule
	"""
	)
}