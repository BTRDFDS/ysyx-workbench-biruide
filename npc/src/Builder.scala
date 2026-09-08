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
object BuilderYsyxSoc	extends App	{emitSystemVerilogFile(new cpu(0x30000000L.U,false)	,Array("--target-dir","./build/ysyxsoc")	,firtoolOptions)}
object BuilderSta		extends App	{emitSystemVerilogFile(new cpu(0x30000000L.U,true)	,Array("--target-dir","./build/sta")		,firtoolOptions)}
object BuilderIcache	extends App	{emitSystemVerilogFile(new icache(true)				,Array("--target-dir","./build/icache")		,firtoolOptions)}
object BuilderNpc		extends App	{emitSystemVerilogFile(new driveTop(false,false)	,Array("--target-dir","./build/npc")		,firtoolOptions)}
object BuilderIverilog	extends App	{emitSystemVerilogFile(new driveTop(true ,false)	,Array("--target-dir","./build/iverilog")	,firtoolOptionsIverilog)}
object BuilderNetlist	extends App	{emitSystemVerilogFile(new driveTop(true ,true )	,Array("--target-dir","./build/netlist")	,firtoolOptionsIverilog)}