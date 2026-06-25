
import chisel3._
import chisel3.util._
import chisel3.Enum._

object AluCal extends ChiselEnum {val ADD,SLL,SLT,SLTU,XOR,SRL,OR,AND,SUB,SRA,NCAL = Value}
object AluBfu extends ChiselEnum {
	val BEQ  = Value()
	val BNE  = Value
	val NBFU = Value
	val BLT  = Value(0b100.U)
	val BGE  = Value
	val BLTU = Value(0b110.U)
	val BGEU = Value
}
object AluCsr extends ChiselEnum {val Read,Write,Jump,Null = Value}
object AluAdr extends ChiselEnum {val R1I,PCI,ECJ,ERE,NAD = Value}
object AluCho extends ChiselEnum {val NCHO,CAL,IMM,SNPC,CCSR = Value}
object In1 extends ChiselEnum {val IR1,PC = Value}
object In2 extends ChiselEnum {val IR2,IMM = Value}
object LsuOp extends ChiselEnum {
	val B = Value
	val H = Value
	val W = Value
	val NM = Value
	val BU = Value
	val HU = Value
}
object CsrOp extends ChiselEnum {val Mret,Error,Write,Null = Value}
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