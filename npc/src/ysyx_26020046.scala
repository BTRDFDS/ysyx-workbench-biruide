import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046 extends Module {
	val io = IO(new Bundle {
		val master = new Axi4MasterOut()
		val slave = Flipped(new Axi4MasterOut())
	})
	val ifu = Module(new ysyx_26020046_Ifu)
	val idu = Module(new ysyx_26020046_Idu)
	val exu = Module(new ysyx_26020046_Exu)
	val lsu = Module(new ysyx_26020046_Lsu)
	val wbu = Module(new ysyx_26020046_Wbu)
	val clt = Module(new ysyx_26020046_Clt)
	val arb = Module(new ysyx_26020046_Arb)
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
	arb.ifu	<> ifu.axi4
	arb.lsu	<> lsu.axi4
	arb.clt	<> clt.axi4
	// arb.out	<> io.master

	io.master.arvalid	<> arb.out.arvalid
	io.master.araddr	<> arb.out.araddr
	io.master.arid		:= 0.U
	io.master.arlen		:= 0.U
	io.master.arsize	:= 0.U
	io.master.arburst	:= 0.U
	io.master.arready	<> arb.out.arready

	io.master.rvalid	<> arb.out.rvalid
	io.master.rdata		<> arb.out.rdata
	io.master.rresp		<> arb.out.rresp
	// io.master.rid		:= 0.U //Input
	// io.master.rlast		:= 0.U //Input
	io.master.rready	<> arb.out.rready

	io.master.awvalid	<> arb.out.awvalid
	io.master.awaddr	<> arb.out.awaddr
	io.master.awid		:= 0.U
	io.master.awlen		:= 0.U
	io.master.awsize	:= 0.U
	io.master.awburst	:= 0.U
	io.master.awready	<> arb.out.awready

	io.master.wvalid	<> arb.out.wvalid
	io.master.wdata		<> arb.out.wdata
	io.master.wstrb		<> arb.out.wstrb
	io.master.wlast		:= false.B
	io.master.wready	<> arb.out.wready

	io.master.bvalid	<> arb.out.bvalid
	io.master.bresp		<> arb.out.bresp
	// io.master.bid		:= 0.U //Input
	io.master.bready	<> arb.out.bready


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
}