object main extends App {
	val firtoolOptions = Array(
		"--default-layer-specialization=enable",
		"--verification-flavor=immediate",
		// "--disable-all-randomization",//禁用随机化，这样子生成的文件就不会有一大堆宏定义
		"--lowering-options=" + List(
			// make yosys happy
			// see https://github.com/llvm/circt/blob/main/docs/VerilogGeneration.md
			"disallowLocalVariables",
			"disallowPackedArrays",
			"locationInfoStyle=wrapInAtSquareBracket"
		).reduce(_ + "," + _)
	)
	// circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_Ifu, Array("--target-dir", "build"), firtoolOptions)
	// circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_Idu, Array("--target-dir", "build"), firtoolOptions)
	// circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_Exu, Array("--target-dir", "build"), firtoolOptions)
	// circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_Lsu, Array("--target-dir", "build"), firtoolOptions)
	// circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_Wbu, Array("--target-dir", "build"), firtoolOptions)
	// circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_Clt, Array("--target-dir", "build"), firtoolOptions)
	// circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_Arb, Array("--target-dir", "build"), firtoolOptions)
	circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046, Array("--target-dir", "build"), firtoolOptions)
}

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
	ifu.io.pipeOut <> idu.io.pipeIn
	idu.io.pipeOut <> exu.io.pipeIn
	exu.io.pipeOut <> lsu.io.pipeIn
	lsu.io.pipeOut <> wbu.io.pipeIn
	//立即线
	wbu.io.immeOut <> lsu.io.immeIn
	lsu.io.immeOut <> exu.io.immeIn
	exu.io.immeOut <> idu.io.immeIn
	idu.io.immeOut <> ifu.io.immeIn
	//axi4
	arb.io.out	<> io.axi4
	arb.io.ifu	<> ifu.io.axi4
	arb.io.lsu	<> lsu.io.axi4
	arb.io.clt	<> clt.io.axi4
}