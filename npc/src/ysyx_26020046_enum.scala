
import chisel3._
import chisel3.util._

object MemStatus extends ChiselEnum{val Call,Back = Value}
object IfuRes extends ChiselEnum {val Null,Valid,Un4b,Fall=Value}
object IfuUpdate extends ChiselEnum {val Null,Branch,Jal,Jalr=Value}
object Jump extends ChiselEnum {val Null,Suce,Chag,Nchg=Value}
object ExuAlu extends ChiselEnum {val Add,Sll,Slt,Sltu,Xor,Srl,Or,And,Sub,Sra,Csr,Imm,Jalr,Null = Value}
object ExuBfu extends ChiselEnum {
	val Beq	= Value(0b000.U)
	val Bne	= Value(0b001.U)
	val Null= Value(0b010.U)
	val Blt	= Value(0b100.U)
	val Bge	= Value(0b101.U)
	val Bltu= Value(0b110.U)
	val Bgeu= Value(0b111.U)
}
object ExuCsr extends ChiselEnum {val Read,Write,Null = Value}
object ExuRes extends ChiselEnum {val Alu,Snpc,Csr,Null = Value}
object ExuIn1 extends ChiselEnum {val R1,Pc = Value}
object ExuIn2 extends ChiselEnum {val R2,Imm = Value}
object LsuAddr extends ChiselEnum {
	val B	= Value(0b000.U)
	val H	= Value(0b001.U)
	val W	= Value(0b010.U)
	val Bu	= Value(0b100.U)
	val Hu	= Value(0b101.U)
}
object LsuOp extends ChiselEnum {val Null,Load,Store = Value}
object CsrOp extends ChiselEnum {val Mret,Trap,Write,Null = Value}
object CsrAddr extends ChiselEnum {
	val Mstatus		=Value(0x300.U)
	val Mtvec		=Value(0x305.U)
	val Mepc		=Value(0x341.U)
	val Mcause		=Value(0x342.U)
    val Mcycle		=Value(0xB00.U)
	val Mcycleh		=Value(0xB80.U)
	val Mvendorid	=Value(0xF11.U)
	val Marchid		=Value(0xF12.U)
}
object Op extends ChiselEnum {
	val Iload	= Value(0b0000011.U)
	val Fence	= Value(0b0001111.U)
	val Ialu	= Value(0b0010011.U)
	val Uauipc	= Value(0b0010111.U)
	val Store	= Value(0b0100011.U)
	val Ralu	= Value(0b0110011.U)
	val Ului	= Value(0b0110111.U)
	val Branch	= Value(0b1100011.U)
    val Ijalr	= Value(0b1100111.U)
	val Jal		= Value(0b1101111.U)
	val Icsr	= Value(0b1110011.U)
}
object BurstRes extends ChiselEnum{val Idle,Read,Done,Erro= Value}