
import chisel3._
import chisel3.util._
import chisel3.Enum._

object IfuRes extends ChiselEnum {val Null,valid,Un4b,Fall=Value}
object ExuAlu extends ChiselEnum {val ADD,SLL,SLT,SLTU,XOR,SRL,OR,AND,SUB,SRA,NCAL = Value}
object ExuBfu extends ChiselEnum {
	val BEQ  = Value()
	val BNE  = Value
	val NBFU = Value
	val BLT  = Value(0b100.U)
	val BGE  = Value
	val BLTU = Value(0b110.U)
	val BGEU = Value
}
object ExuCsr extends ChiselEnum {val Read,Write,Jump,Null = Value}
object ExuAdr extends ChiselEnum {val ImR1,ImPc,Ecal,Eret,Null = Value}
object ExuRes extends ChiselEnum {val nRes,alu,imm,snPc,csr = Value}
object In1 extends ChiselEnum {val r1,pc = Value}
object In2 extends ChiselEnum {val r2,imm = Value}
object LsuOp extends ChiselEnum {val b,h,w,n,bu,hu = Value}
object CsrOp extends ChiselEnum {val Mret,Error,Write,Null = Value}