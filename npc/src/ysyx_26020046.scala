import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._

class ysyx_26020046(val PcInit:UInt=0x30000000L.U,val Yosys:Boolean=false) extends Module {
	val io = IO(new Bundle {
		val interrupt = Input(Bool())
		val master = new Axi4MasterOut()
		val slave = Flipped(new Axi4MasterOut())
	})
	val ich = Module(new ysyx_26020046_Ich(Yosys))
	val ifu = Module(new ysyx_26020046_Ifu(PcInit,Yosys))
	val idu = Module(new ysyx_26020046_Idu(Yosys))
	val exu = Module(new ysyx_26020046_Exu(Yosys))
	val lsu = Module(new ysyx_26020046_Lsu(Yosys))
	val wbu = Module(new ysyx_26020046_Wbu(Yosys))
	val clt = Module(new ysyx_26020046_Clt)
	val bar = Module(new ysyx_26020046_Bar(Yosys))
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
	ich.lsu <> lsu.ich
	ich.ifu <> ifu.ich
	bar.ifu <> ich.bar
	bar.lsu <> lsu.bar
	bar.clt	<> clt.axi4

	io.master.arvalid	<> bar.out.arvalid
	io.master.araddr	<> bar.out.araddr
	io.master.arid		:= 0.U
	io.master.arlen		:= bar.out.arlen
	io.master.arsize	:= bar.out.arsize
	io.master.arburst	:= bar.out.arburst
	io.master.arready	<> bar.out.arready

	io.master.rvalid	<> bar.out.rvalid
	io.master.rdata		<> bar.out.rdata
	io.master.rresp		<> bar.out.rresp
	// io.master.rid		:= 0.U //Input
	io.master.rlast		<> bar.out.rlast
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
	io.master.wlast		:= true.B
	io.master.wready	<> bar.out.wready

	io.master.bvalid	<> bar.out.bvalid
	io.master.bresp		<> bar.out.bresp
	// io.master.bid		:= 0.U //Input
	io.master.bready	<> bar.out.bready


	io.slave.arready:= false.B
	io.slave.rvalid	:= false.B
	io.slave.rdata	:= 0.U
	io.slave.rresp	:= 0.U
	io.slave.rid	:= 0.U
	io.slave.rlast	:= false.B
	io.slave.awready:= false.B
	io.slave.wready	:= false.B
	io.slave.bvalid	:= false.B
	io.slave.bresp	:= 0.U
	io.slave.bid	:= 0.U

	dontTouch(io.master)
	dontTouch(io.slave)
	dontTouch(io.interrupt)
	if(Yosys == false){
		// val ifuPc	= Mux(out.pipe.res === IfuRes.Valid,Cat(out.pipe.pc,0.U(2.W)),0.U(32.W));dontTouch(ifuPc)
		// val ifuInst	= Mux(out.pipe.res === IfuRes.Valid,out.pipe.instr,0.U(BitWidth.W));dontTouch(ifuInst)
		val pipePcIfu = Mux(Get(ifu.out.pipe.res) === IfuRes.Valid,Cat(Get(ifu.out.pipe.pc),0.U(2.W)),0.U(32.W));dontTouch(pipePcIfu)
	}
}
// class ysyx_26020046_Chk extends ExtModule{
// 	val inst	= IO(Input(Bool()))
// 	val stall	= IO(Input(Bool()))
// 	val jbMiss	= IO(Input(Bool()))
// 	val jbHit	= IO(Input(Bool()))
// 	val clock	= IO(Input(Clock()))
// 	setInline("ysyx_26020046_Chk.sv",
// 	"""
// 	module ysyx_26020046_Chk(
// 		input logic inst,
// 		input logic stall,
// 		input logic jbMiss,
// 		input logic jbHit,
// 		input logic clock
// 	);
// 	import "DPI-C" function void Inst();
// 	import "DPI-C" function void Stall();
// 	import "DPI-C" function void JbMiss();
// 	import "DPI-C" function void JbHit();

// 	always_ff@(posedge clock)begin
// 		if(stall)	Stall();
// 		if(inst)	Inst();
// 		if(jbMiss)	JbMiss();
// 		if(jbHit)	JbHit();
// 	end
// 	endmodule
// 	"""
// 	)
// }