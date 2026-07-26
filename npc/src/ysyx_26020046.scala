import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046(val PcInit:UInt=0x30000000L.U) extends Module {
	val io = IO(new Bundle {
		val interrupt = Input(Bool())
		val master = new Axi4MasterOut()
		val slave = Flipped(new Axi4MasterOut())
	})
	val ifu = Module(new ysyx_26020046_Ifu(PcInit))
	val idu = Module(new ysyx_26020046_Idu)
	val exu = Module(new ysyx_26020046_Exu)
	val lsu = Module(new ysyx_26020046_Lsu)
	val wbu = Module(new ysyx_26020046_Wbu)
	val clt = Module(new ysyx_26020046_Clt)
	val bar = Module(new ysyx_26020046_Bar)
	//流水线
	ifu.out.pipe <> idu.in.pipe
	idu.out.pipe <> exu.in.pipe
	exu.out.pipe <> lsu.in.pipe
	lsu.out.pipe <> wbu.in.pipe
	// //立即线
	wbu.out.imme <> lsu.in.imme
	lsu.out.imme <> exu.in.imme
	exu.out.imme <> idu.in.imme
	idu.out.imme <> ifu.in.imme

	//axi4
	bar.ifu	<> ifu.axi4
	bar.lsu	<> lsu.axi4
	bar.clt	<> clt.axi4
	// bar.out	<> io.master

	io.master.arvalid	<> bar.out.arvalid
	io.master.araddr	<> bar.out.araddr
	io.master.arid		:= 0.U
	io.master.arlen		:= 0.U
	io.master.arsize	:= 0.U
	io.master.barurst	:= 0.U
	io.master.arready	<> bar.out.arready

	io.master.rvalid	<> bar.out.rvalid
	io.master.rdata		<> bar.out.rdata
	io.master.rresp		<> bar.out.rresp
	// io.master.rid		:= 0.U //Input
	// io.master.rlast		:= 0.U //Input
	io.master.rready	<> bar.out.rready

	io.master.awvalid	<> bar.out.awvalid
	io.master.awaddr	<> bar.out.awaddr
	io.master.awid		:= 0.U
	io.master.awlen		:= 0.U
	io.master.awsize	:= 0.U
	io.master.awburst	:= 0.U
	io.master.awready	<> bar.out.awready

	io.master.wvalid	<> bar.out.wvalid
	io.master.wdata		<> bar.out.wdata
	io.master.wstrb		<> bar.out.wstrb
	io.master.wlast		:= false.B
	io.master.wready	<> bar.out.wready

	io.master.bvalid	<> bar.out.bvalid
	io.master.bresp		<> bar.out.bresp
	// io.master.bid		:= 0.U //Input
	io.master.bready	<> bar.out.bready


	io.slave.arready	:= false.B
	io.slave.rvalid	:= false.B
	io.slave.rdata	:= 0.U
	io.slave.rresp	:= 0.U
	io.slave.rid	:= 0.U
	io.slave.rlast	:= false.B
	io.slave.awready	:= false.B
	io.slave.wready	:= false.B
	io.slave.bvalid	:= false.B
	io.slave.bresp	:= 0.U
	io.slave.bid	:= 0.U

	dontTouch(io.master)
	dontTouch(io.slave)
	dontTouch(io.interrupt)
}