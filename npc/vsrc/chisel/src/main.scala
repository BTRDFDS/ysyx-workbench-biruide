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


// typedef struct packed {logic arvalid,rready;word_t araddr;}							AXI4rCal_t;
// typedef struct packed {logic arready;word_t rdata;resp_t rresp;logic rvalid;}		AXI4rBak_t;
// typedef struct packed {logic awvalid,wvalid,bready;word_t awaddr,wdata;mask_t wstrb;}AXI4wCal_t;
// typedef struct packed {logic awready,wready,bvalid;resp_t bresp;}					AXI4wBak_t;


class axi4Master (val Width:Int=32,val Strb:Int=4,val Resp:Int=2) extends Bundle {
	// val arvalid	= Output(Bool())
	// val rready	= Output(Bool())
    val araddr	= Output(UInt(Width.W))
	// val arready	= Input(Bool())
	// val rdata	= Input(UInt(Width.W))
	// val rresp	= Input(UInt(Resp.W))
	// val rvalid	= Input(Bool())

	// val awvalid	= Output(Bool())
	// val wvalid	= Output(Bool())
	// val bready	= Output(Bool())
	// val awaddr	= Output(UInt(Width.W))
	// val wdata	= Output(UInt(Width.W))
	// val wstrb	= Output(UInt(Strb.W))
	// val awready	= Input(Bool())
	// val wready	= Input(Bool())
	// val bvalid	= Input(Bool())
	// val bresp	= Input(UInt(Resp.W))
}


class ysyx_26020046(val Width:Int=32,val RegNumber:Int=32) extends Module {
	val RegWidth = log2Ceil(RegNumber)
	val io = IO(new Bundle {
		val rs1_addr = Input(UInt(RegWidth.W))
		val rs2_addr = Input(UInt(RegWidth.W))
		val rs1_data = Output(UInt(Width.W))
		val rs2_data = Output(UInt(Width.W))
		val waddr = Input(UInt(RegWidth.W))
		val wdata = Input(UInt(Width.W))
		val master = new axi4Master(Width)
	})
	val gpr = Reg(Vec(RegNumber, UInt(Width.W)))
	when(io.waddr =/= 0.U){gpr(io.waddr) := io.wdata}
	io.rs1_data := Mux(io.rs1_addr === 0.U, 0.U, gpr(io.rs1_addr))
	io.rs2_data := Mux(io.rs2_addr === 0.U, 0.U, gpr(io.rs2_addr))
	io.master.araddr := Mux(io.rs1_addr === 0.U, 0.U, gpr(io.rs1_addr))
}