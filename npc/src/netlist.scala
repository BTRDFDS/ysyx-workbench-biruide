import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._
class driveNetlist extends Module{
	val cpu = Module(new ysyx_26020046_netlistLink())
	cpu.clock := clock
	cpu.reset := reset
	val mem = Module(new driveIverilogMem())

	val rState	= RegInit(NpcState.Idle)
	val araddr	= RegInit(0.U(BitWidth.W))
	val arlen	= RegInit(0.U(LenWidth.W))
	val arsiz	= RegInit(0.U(SizeWidth.W))
	val arburst	= RegInit(0.U(BurstWidth.W))
	val cnt		= RegInit(0.U(CacheWidth.W))
	when(rState===NpcState.Idle){
		when(cpu.master.arvalid){
			rState	:= NpcState.Back
			araddr	:= cpu.master.araddr
			arlen	:= cpu.master.arlen
			arsiz	:= cpu.master.arsize
			arburst	:= cpu.master.arburst
		}
		cnt	:= 0.U
		cpu.master.arready	:= true.B
		cpu.master.rvalid	:= false.B
		cpu.master.rlast		:= false.B
		cpu.master.rdata		:= 0.U
		cpu.master.rresp		:= 0.U
		mem.read.valid			:= false.B
		mem.read.addr			:= 0.U
	}.otherwise{
		when(cpu.master.rready && Mux(arburst===2.U,cnt===arlen,true.B)){rState := NpcState.Idle}
		cnt := cnt + 1.U
		cpu.master.arready	:= false.B
		cpu.master.rvalid	:= true.B
		cpu.master.rlast		:= Mux(arburst===2.U,cnt===arlen,true.B)
		cpu.master.rdata		:= mem.read.data
		cpu.master.rresp		:= 0.U
		mem.read.valid	:= true.B
		mem.read.addr	:= Cat(araddr(31,CacheWidth+2),(cnt+araddr(CacheWidth+1,2)),0.U(2.W))
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
		when((hasAddr && hasData) || (cpu.master.awvalid && cpu.master.wvalid)){wState:=NpcState.Back}
		hasAddr := cpu.master.awvalid
		hasData := cpu.master.wvalid
		when(cpu.master.awvalid && ~hasAddr){
			awaddr := cpu.master.awaddr
		}
		when(cpu.master.wvalid && ~hasData){
			wdata := cpu.master.wdata
			wstrb := cpu.master.wstrb
		}
		cpu.master.awready	:= ~hasAddr
		cpu.master.wready	:= ~hasData
		cpu.master.bvalid	:= false.B
		cpu.master.bresp		:= 0.U
		mem.write.valid	:= false.B
		mem.write.addr		:= 0.U
		mem.write.strb		:= 0.U
		mem.write.data		:= 0.U
	}.otherwise{
		when(cpu.master.bready){wState := NpcState.Idle}
		hasAddr := false.B
		hasData := false.B
		cpu.master.awready	:= false.B
		cpu.master.wready	:= false.B
		cpu.master.bvalid	:= true.B
		cpu.master.bresp		:= 0.U
		mem.write.valid	:= true.B
		mem.write.addr		:= awaddr
		mem.write.strb		:= wstrb
		mem.write.data		:= wdata
	}
	cpu.master.rid	:= 0.U
	cpu.master.bid	:= 0.U
}
class ysyx_26020046_netlistLink extends ExtModule{
	val clock	= IO(Input(Clock()))
	val reset	= IO(Input(Reset()))
	val master	= IO(new Axi4MasterOut())
}