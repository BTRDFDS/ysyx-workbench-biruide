import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046 extends Module {
	val io = IO(new Bundle {
		val axi4 = new Axi4Master()
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
	arb.out	<> io.axi4
	arb.ifu	<> ifu.axi4
	arb.lsu	<> lsu.axi4
	arb.clt	<> clt.axi4
}