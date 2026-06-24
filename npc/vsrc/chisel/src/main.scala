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


	// typedef enum logic[3:0] {ADD_,SLL_,SLT_,SLTU,XOR_,SRL_,OR__,AND_,SUB_,SRA_,NCAL} ALUopCal_t;
object AluCal extends ChiselEnum {val ADD,SLL,SLT,SLTU,XOR,SRL,OR,AND,SUB,SRA,NCAL = Value}
class axi4Master (val Width:Int=32,val Strb:Int=4,val Resp:Int=2) extends Bundle {
	val arvalid	= Output(Bool())
	val rready	= Output(Bool())
    val araddr	= Output(UInt(Width.W))
	val arready	= Input(Bool())
	val rdata	= Input(UInt(Width.W))
	val rresp	= Input(UInt(Resp.W))
	val rvalid	= Input(Bool())

	val awvalid	= Output(Bool())
	val wvalid	= Output(Bool())
	val bready	= Output(Bool())
	val awaddr	= Output(UInt(Width.W))
	val wdata	= Output(UInt(Width.W))
	val wstrb	= Output(UInt(Strb.W))
	val awready	= Input(Bool())
	val wready	= Input(Bool())
	val bvalid	= Input(Bool())
	val bresp	= Input(UInt(Resp.W))
}

class ysyx_26020046(val Width:Int=32,val RegNumber:Int=32) extends Module {
	val RegWidth = log2Ceil(RegNumber)
	val io = IO(new Bundle {
		val cRd = Input(UInt(RegWidth.W))
		val cR1 = Input(UInt(RegWidth.W))
		val cR2 = Input(UInt(RegWidth.W))
		val iRd = Input(UInt(Width.W))
		val oR1 = Output(UInt(Width.W))
		val oR2 = Output(UInt(Width.W))
	})
	val wbu = Module(new ysyx_26020046_WBU(Width,RegNumber))
	io.oR1 := wbu.io.oR1
	io.oR2 := wbu.io.oR2
	wbu.io.cRd := io.cRd
	wbu.io.cR1 := io.cR1
	wbu.io.cR2 := io.cR2
	wbu.io.iRd := io.iRd
}
class ysyx_26020046_WBU(val Width:Int=32,val RegNumber:Int=32) extends Module {
	val RegWidth = log2Ceil(RegNumber)
	val io = IO(new Bundle {
		val cRd = Input(UInt(RegWidth.W))
		val cR1 = Input(UInt(RegWidth.W))
		val cR2 = Input(UInt(RegWidth.W))
		val iRd = Input(UInt(Width.W))
		val oR1 = Output(UInt(Width.W))
		val oR2 = Output(UInt(Width.W))
	})
	val gpr = Reg(Vec(RegNumber, UInt(Width.W)))
	when(io.cRd =/= 0.U){gpr(io.cRd) := io.iRd}
	io.oR1 := Mux(io.cR1 === 0.U, 0.U, gpr(io.cR1))
	io.oR2 := Mux(io.cR2 === 0.U, 0.U, gpr(io.cR2))
}