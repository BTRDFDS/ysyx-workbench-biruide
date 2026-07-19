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
}
import FirtoolOptions._
import circt.stage.ChiselStage.emitSystemVerilogFile
object BuilderNpc extends App			{emitSystemVerilogFile(new ysyx_26020046_MemTop, 	Array("--target-dir", "./build/npc"),			firtoolOptions)}
object BuilderYsyxSoc extends App		{emitSystemVerilogFile(new ysyx_26020046,			Array("--target-dir", "./build/ysyxsoc"),		firtoolOptions)}
object BuilderBitrevChisel extends App	{emitSystemVerilogFile(new bitrevChisel,			Array("--target-dir", "./build/bitrevChisel"),	firtoolOptions)}