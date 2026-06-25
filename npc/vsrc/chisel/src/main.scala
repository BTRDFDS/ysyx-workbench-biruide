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
	circt.stage.ChiselStage.emitSystemVerilogFile(new ysyx_26020046(), Array("--target-dir", "build"), firtoolOptions)
}

import chisel3._
import chisel3.util._
import chisel3.Enum._


class ysyx_26020046(val Width:Int=32,val RegNumber:Int=32) extends Module {
	val RegWidth = log2Ceil(RegNumber)
	val io = IO(new Bundle {
	})
}
class ysyx_26020046_EXU(val Width:Int=32) extends Module {
	val io = IO(new Bundle {
		val water= new WaterIdAl(Width)
	})

}

class ysyx_26020046_WBU(val Width:Int=32,val RegNumber:Int=32) extends Module {
	val RegWidth = log2Ceil(RegNumber)
	val io = IO(new Bundle {
		val water= new WaterLsWb(Width,RegNumber)
		val imm = new ImmLsWb(Width)
	})
	val gpr = Reg(Vec(RegNumber, UInt(Width.W)))
	when(io.water.bits.cRd =/= 0.U){gpr(io.cRd) := io.iRd}
	io.oR1 := Mux(io.cR1 === 0.U, 0.U, gpr(io.cR1))
	io.oR2 := Mux(io.cR2 === 0.U, 0.U, gpr(io.cR2))
}