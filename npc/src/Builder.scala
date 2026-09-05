object FirtoolOptions{
	val firtoolOptions = Array(
		"--default-layer-specialization=enable",
		"--verification-flavor=immediate",
		"--lowering-options=" + List(
			// make yosys happy
			// see https://github.com/llvm/circt/blob/main/docs/VerilogGeneration.md
			"disallowLocalVariables",
			"disallowPackedArrays",
			"locationInfoStyle=wrapInAtSquareBracket"
		).reduce(_ + "," + _)
	)
	val firtoolOptionsIverilog = Array(
		"--default-layer-specialization=enable",
		"--verification-flavor=immediate",
		"--lowering-options=" + List(
			// make yosys happy
			// see https://github.com/llvm/circt/blob/main/docs/VerilogGeneration.md
			"disallowLocalVariables",
			"disallowPackedArrays",
			"noAlwaysComb",//iverilog
			"locationInfoStyle=wrapInAtSquareBracket"
		).reduce(_ + "," + _)
	)
}
import FirtoolOptions._
import circt.stage.ChiselStage.emitSystemVerilogFile
import chisel3._
object BuilderNpc		extends App	{emitSystemVerilogFile(new ysyx_26020046_Npc				,Array("--target-dir","./build/npc")		,firtoolOptions)}
object BuilderYsyxSoc	extends App	{emitSystemVerilogFile(new ysyx_26020046					,Array("--target-dir","./build/ysyxsoc")	,firtoolOptions)}
object BuilderSta		extends App	{emitSystemVerilogFile(new ysyx_26020046(0x80000000L.U,true)	,Array("--target-dir","./build/sta")		,firtoolOptions)}
object BuilderIcache	extends App	{emitSystemVerilogFile(new ysyx_26020046_Ich(true)			,Array("--target-dir","./build/icache")		,firtoolOptions)}
object BuilderIverilog	extends App	{emitSystemVerilogFile(new ysyx_26020046_iverilog			,Array("--target-dir","./build/iverilog")	,firtoolOptionsIverilog)}
object BuilderNetlist	extends App	{emitSystemVerilogFile(new ysyx_26020046_netlist			,Array("--target-dir","./build/netlist")	,firtoolOptionsIverilog)}