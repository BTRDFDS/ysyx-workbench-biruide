import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._
object NpcState extends ChiselEnum{val Idle,Back = Value}
class driveTop(val Yosys:Boolean=false,val Netlist:Boolean=false) extends Module{
	val xbar = Module(new driveLinker(Yosys,Netlist))
	val rState	= RegInit(NpcState.Idle)
	val araddr	= RegInit(0.U(BitWidth.W))
	val arlen	= RegInit(0.U(LenWidth.W))
	val arsiz	= RegInit(0.U(SizeWidth.W))
	val arburst	= RegInit(0.U(BurstWidth.W))
	val cnt		= RegInit(0.U(CacheWidth.W))
	when(rState===NpcState.Idle){
		when(xbar.master.arvalid){
			rState	:= NpcState.Back
			araddr	:= xbar.master.araddr
			arlen	:= xbar.master.arlen
			arsiz	:= xbar.master.arsize
			arburst	:= xbar.master.arburst
		}
		cnt	:= 0.U
		xbar.master.arready	:= true.B
		xbar.master.rvalid	:= false.B
		xbar.master.rlast		:= false.B
		xbar.master.rdata		:= 0.U
		xbar.master.rresp		:= 0.U
		xbar.read.valid			:= false.B
		xbar.read.addr			:= 0.U
	}.otherwise{
		when(xbar.master.rready && Mux(arburst===2.U,cnt===arlen,true.B)){rState := NpcState.Idle}
		cnt := cnt + 1.U
		xbar.master.arready	:= false.B
		xbar.master.rvalid	:= true.B
		xbar.master.rlast		:= Mux(arburst===2.U,cnt===arlen,true.B)
		xbar.master.rdata		:= xbar.read.data
		xbar.master.rresp		:= 0.U
		xbar.read.valid	:= true.B
		xbar.read.addr	:= Cat(araddr(31,CacheWidth+2),(cnt+araddr(CacheWidth+1,2)),0.U(2.W))
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
		when((hasAddr && hasData) || (xbar.master.awvalid && xbar.master.wvalid)){wState:=NpcState.Back}
		hasAddr := xbar.master.awvalid
		hasData := xbar.master.wvalid
		when(xbar.master.awvalid && ~hasAddr){
			awaddr := xbar.master.awaddr
		}
		when(xbar.master.wvalid && ~hasData){
			wdata := xbar.master.wdata
			wstrb := xbar.master.wstrb
		}
		xbar.master.awready	:= ~hasAddr
		xbar.master.wready	:= ~hasData
		xbar.master.bvalid	:= false.B
		xbar.master.bresp		:= 0.U
		xbar.write.valid	:= false.B
		xbar.write.addr		:= 0.U
		xbar.write.strb		:= 0.U
		xbar.write.data		:= 0.U
	}.otherwise{
		when(xbar.master.bready){wState := NpcState.Idle}
		hasAddr := false.B
		hasData := false.B
		xbar.master.awready	:= false.B
		xbar.master.wready	:= false.B
		xbar.master.bvalid	:= true.B
		xbar.master.bresp		:= 0.U
		xbar.write.valid	:= true.B
		xbar.write.addr		:= awaddr
		xbar.write.strb		:= wstrb
		xbar.write.data		:= wdata
	}

	xbar.master.rid	:= 0.U
	xbar.master.bid	:= 0.U

	xbar.interrupt	:= false.B
	
	xbar.slave.arvalid	:= false.B
	xbar.slave.rready		:= false.B
	xbar.slave.awvalid	:= false.B
	xbar.slave.wvalid		:= false.B
	xbar.slave.bready		:= false.B
	xbar.slave.wlast		:= false.B
	xbar.slave.araddr		:= 0.U
	xbar.slave.arlen		:= 0.U
	xbar.slave.arsize		:= 0.U
	xbar.slave.arburst	:= 0.U
	xbar.slave.awaddr		:= 0.U
	xbar.slave.wdata		:= 0.U
	xbar.slave.wstrb		:= 0.U
	xbar.slave.arid		:= 0.U
	xbar.slave.awid		:= 0.U
	xbar.slave.awlen		:= 0.U
	xbar.slave.awsize		:= 0.U
	xbar.slave.awburst	:= 0.U

}