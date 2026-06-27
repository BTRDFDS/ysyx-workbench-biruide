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
	circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046_EXU(), Array("--target-dir", "build"), firtoolOptions)
}

import chisel3._
import chisel3.util._


class ysyx_26020046(val Width:Int=32,val RegNum:Int=32) extends Module {
	val RegWidth = log2Ceil(RegNum)
	val io = IO(new Bundle {
	})
}