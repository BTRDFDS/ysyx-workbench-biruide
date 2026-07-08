import chisel3._
import chisel3.util._

class PipeIfId(val Width:Int=32) extends Bundle{
	val res		= Output(IfuRes())
	val pc		= Output(UInt(Width.W))
	val instr	= Output(UInt(Width.W))
}
class PipeLsWb(val Width:Int=32,val RegNum:Int=32,val CsrWidth:Int=12) extends Bundle{
	val RegWidth = log2Ceil(RegNum)

    val valid	= Output(Bool())
	val rdAddr	= Output(UInt(RegWidth.W))
	val result	= Output(UInt(Width.W))
	val pc		= Output(UInt(Width.W))
	val csrOp	= Output(CsrOp())
	val csrAddr	= Output(UInt(CsrWidth.W))
	val csrMesg	= Output(UInt(Width.W))
}
class PipeExLs(Width:Int=32,RegNum:Int=32,CsrWidth:Int=12) extends PipeLsWb(Width,RegNum,CsrWidth){
	val enSave	= Output(Bool())
	val enLoad	= Output(Bool())
	val lsuOp	= Output(LsuOp())
	val r2		= Output(UInt(Width.W))
}
class PipeIdEx(Width:Int=32,RegNum:Int=32,CsrWidth:Int=12) extends PipeExLs(Width,RegNum,CsrWidth){
	val alu = Output(ExuAlu())
	val bfu = Output(ExuBfu())
	val csr = Output(ExuCsr())
	val res = Output(ExuRes())
	val In1 = Output(ExuIn1())
	val In2 = Output(ExuIn2())

	val enJcod	=Output(Bool())
	val r1		=Output(UInt(Width.W))
}
class ImmeBefore(val Width:Int=32)extends Bundle{
	val back	= Output(Back())
	val addr	= Output(UInt(Width.W))
}
class ImmeAfter(Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12)extends ImmeBefore(Width){
    val RegWidth= log2Ceil(RegNum)

	val r1Addr	= Input(UInt(RegWidth.W))
	val r2Addr	= Input(UInt(RegWidth.W))
	val r1Out	= Output(UInt(Width.W))
	val r2Out	= Output(UInt(Width.W))

	val csrAddr	= Input(UInt(CsrWidth.W))
	val csrOut	= Output(UInt(Width.W))
}
class Axi4Master (val Width:Int=32,val Strb:Int=4,val Resp:Int=2) extends Bundle {
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