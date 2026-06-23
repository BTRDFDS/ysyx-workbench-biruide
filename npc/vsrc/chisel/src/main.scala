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

// class axi4Master (val Width:UInt=32,val nReg:UInt=32) extends Bundle {
//     val raddr = Output(Unit(Width.W))
// }


class ysyx_26020046(val Width:Int=32,val RegNumber:Int=32) extends Module {
	val RegWidth = log2Ceil(RegNumber)
	val io = IO(new Bundle {
		val rs1_addr = Input(UInt(RegWidth.W))
		val rs2_addr = Input(UInt(RegWidth.W))
		val rs1_data = Output(UInt(Width.W))
		val rs2_data = Output(UInt(Width.W))
		val waddr = Input(UInt(RegWidth.W))
		val wdata = Input(UInt(Width.W))
	})
	val gpr = Reg(Vec(RegNumber, UInt(Width.W)))
	when(io.waddr =/= 0.U){gpr(io.waddr) := io.wdata}
	io.rs1_data := Mux(io.rs1_addr === 0.U, 0.U, gpr(io.rs1_addr))
	io.rs2_data := Mux(io.rs2_addr === 0.U, 0.U, gpr(io.rs2_addr))
}