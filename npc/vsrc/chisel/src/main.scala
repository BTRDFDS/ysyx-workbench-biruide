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

class ysyx_26020046_WBU(val Width:Int=32,val RegNumber:Int=32,val CsrWidth:Int=12,val PcReset:Int=0x80000000) extends Module {
	val RegWidth = log2Ceil(RegNumber)
	val MstatuseReset = 0x1800.U(Width.W)

	val io = IO(new Bundle {
		val water	= new WaterLsWb(Width,RegNumber,CsrWidth)
		val imm		= new ImmAfter(Width,RegNumber,CsrWidth)
	})
	val gpr = Reg(Vec(RegNumber, UInt(Width.W)))

	val mepc		= RegInit(PcReset.U(Width.W))
	val mstatuse	= RegInit(MstatuseReset.U)
	val mtvec		= RegInit(PcReset.U(Width.W))
	val mcause		= RegInit(0.U(Width.W))
	val mcycle		= RegInit(0.U(Width.W))
	val mcycleh		= RegInit(0.U(Width.W))
	val marchid		= RegInit(0x018D08CE.U(Width.W))
	val mvendorid	= RegInit(0x79737978.U(Width.W))

	when(io.water.valid){
		when(io.water.rdAddr =/= 0.U){gpr(io.water.rdAddr) := io.water.result}
		switch(io.water.csrOp){
			is(CsrOp.Mret){
				mstatuse:= MstatuseReset.U
				mcause	:= 0.U
			}
			is(CsrOp.Error){
				mepc	:= io.water.addr
				mcause	:= io.water.csrMesg
				// stop()
			}
			is(CsrOp.Write){
				switch(io.water.csrAddr){
					is(CsrAddr.Mcycle)	{mcycle	:= io.water.result}
					is(CsrAddr.Mcycleh)	{mcycleh	:= io.water.result}
					is(CsrAddr.Mepc)	{mepc	:= io.water.result}
					is(CsrAddr.Mtvec)	{mtvec	:= io.water.result}
					is(CsrAddr.Mcause)	{mcause	:= io.water.result}
					is(CsrAddr.Mstatus){mstatuse:= io.water.result}
					is(CsrAddr.Marchid){marchid	:= io.water.result}
					is(CsrAddr.Mvendorid){mvendorid:= io.water.result}
				}
			}
			otherwise{}//啥都不干
		}
	}otherwise{}//也是啥都不干

	io.oR1 := Mux(io.cR1 === 0.U, 0.U, gpr(io.cR1))
	io.oR2 := Mux(io.cR2 === 0.U, 0.U, gpr(io.cR2))
}