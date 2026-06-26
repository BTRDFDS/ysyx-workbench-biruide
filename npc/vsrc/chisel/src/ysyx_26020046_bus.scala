import chisel3._
import chisel3.util._
import chisel3.Enum._

class WaterIfId(val Width:Int=32) extends Bundle{
	val res		= Output(IfuRes())
	val pc		= Output(UInt(Width.W))
	val instr	= Output(UInt(Width.W))
}
class WaterLsWb(val Width:Int=32,val RegNumber:Int=32) extends Bundle{
	val RegWidth = log2Ceil(RegNumber)

    val valid	= Output(Bool())
	val rdAddr	= Output(UInt(RegWidth.W))
	val result	= Output(UInt(Width.W))
	val addr	= Output(UInt(Width.W))
	val csrRes	= Output(UInt(Width.W))
	val csrOp	= Output(CsrOp())
	val csrAddr	= Output(UInt(Width.W))
	val csrMesg	= Output(UInt(Width.W))
}
class WaterExLs(val Width:Int=32,val RegNumber:Int=32) extends WaterLsWb(Width,RegNumber){
	val enSave	= Output(Bool())
	val enLoad	= Output(Bool())
	val lsOp	= Output(LSUop())
}
class WaterIdEx(val Width:Int=32,val RegNumber:Int=32) extends WaterExLs(Width,RegNumber){
	val alu = Output(ExuCsr())
	val bfu = Output(ExuBfu())
	val csr = Output(ExuCsr())
	val adr = Output(ExuAdr())
	val res = Output(ExuRes())
	val In1 = Output(In1())
	val In2 = Output(In2())

	val enJcod=Output(Bool())
}
class ImmBefore(val Width:Int=32)extends Bundle{
	val ready	= Output(Bool())
	val wash	= Output(Bool())
	val addr	= Output(UInt(Width.W))
}
class ImmAfter(val Width:Int=32, val RegNumber:Int=32,val CsrWidth:Int=12)extends ImmBefore(Width){//WB不需要ready
    val RegWidth= log2Ceil(RegNumber)

	val r1Addr	= Input(UInt(RegWidth.W))
	val r2Addr	= Input(UInt(RegWidth.W))
	val r1Out	= Output(UInt(Width.W))
	val r2Out	= Output(UInt(Width.W))

	val csrAddr	= Input(UInt(CsrWidth.W))
	val csrOut	= Output(UInt(Width.W))
}
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