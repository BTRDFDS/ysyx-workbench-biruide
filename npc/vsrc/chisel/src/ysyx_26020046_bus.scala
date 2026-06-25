import chisel3._
import chisel3.util._
import chisel3.Enum._

class WaterIfId(val Width:Int=32) {
    val valid = Output(Bool())
    val pc = Output(UInt(Width.W))
    val instr = Output(UInt(Width.W))
}
class WaterIdEx(val Width:Int=32) {
	val valid = Output(Bool())
	val Cal = Input(AluCsr())
	val Bfu = Input(AluBfu())
	val Csr = Input(AluCsr())
	val Adr = Input(AluAdr())
	val Cho = Input(AluCho())
	val In1 = Input(In1())
	val In2 = Input(In2())

	val imm	=Input(UInt(Width.W))
	val pc	=Input(UInt(Width.W))
	val enJcod=Input(Bool())
}


class WaterLsWb(val Width:Int=32,val RegNumber:Int=32){
	val RegWidth = log2Ceil(RegNumber)
    val valid = Output(Bool())
	val rdAddr = Input(UInt(RegWidth.W))
	val rdIn = Input(UInt(Width.W))

	val csrIn	= Input(UInt(Width.W))
	val csrOp	= Input(CsrOp())
	val csrAddr	= Input(UInt(Width.W))
	val csrMesg	= Input(UInt(Width.W))
}
class ImmWbLs(val Width:Int=32, val RegNumber:Int=32){//WB不需要ready
    val RegWidth= log2Ceil(RegNumber)
	val r1Addr	= Input(UInt(RegWidth.W))
	val r2Addr	= Input(UInt(RegWidth.W))
	val r1Out	= Output(UInt(Width.W))
	val r2Out	= Output(UInt(Width.W))
}
class ImmLsEx(val Width:Int=32,val RegNumber:Int=32){
    
}