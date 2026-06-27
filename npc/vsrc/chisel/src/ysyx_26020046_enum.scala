
import chisel3._
import chisel3.util._
import chisel3.Enum._

object IfuRes extends ChiselEnum {val Null,valid,Un4b,Fall=Value}
object ExuAlu extends ChiselEnum {val Add,Sll,Slt,Sltu,Xor,Sra,Or,And,Sub,Sra,ImR1,ImPc,Csr,Null = Value}
object ExuBfu extends ChiselEnum {
	val Beq	= Value()
	val Bne	= Value
	val Null= Value
	val Blt	= Value(0b100.U)
	val Bge	= Value
	val Bltu= Value(0b110.U)
	val Bgeu= Value
}
object ExuCsr extends ChiselEnum {val Read,Write,Jump,Null = Value}
object ExuRes extends ChiselEnum {val Alu,Imm,Snpc,Csr = Value}
object ExuIn1 extends ChiselEnum {val R1,Pc = Value}
object ExuIn2 extends ChiselEnum {val R2,Imm = Value}
object LsuOp extends ChiselEnum {val b,h,w,n,bu,hu = Value}
object CsrOp extends ChiselEnum {val Mret,Error,Write,Null = Value}