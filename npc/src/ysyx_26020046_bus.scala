object  WidthConsts{//const
	val BitWidth	= 32
	val RegNum		= 32
    val RegWidth	= log2Ceil(RegNum)
	val CsrWidth	= 12
	val RespWidth	= 2
	val StrbWidth	= 4
	val IdWidth		= 4
	val LenWidth	= 8
	val SizeWidth	= 3
	val BurstWidth	= 2
}
import chisel3._
import chisel3.util._
import WidthConsts._
class PipeIfId extends Bundle{
	val res		= Output(IfuRes())
	val pc		= Output(UInt(BitWidth.W))
	val instr	= Output(UInt(BitWidth.W))
}
class PipeLsWb extends Bundle{

    val valid	= Output(Bool())
	val rdAddr	= Output(UInt(RegWidth.W))
	val result	= Output(UInt(BitWidth.W))
	val pc		= Output(UInt(BitWidth.W))
	val csrOp	= Output(CsrOp())
	val csrAddr	= Output(UInt(BitWidth.W))
	val csrMesg	= Output(UInt(BitWidth.W))
}
class PipeExLs extends PipeLsWb(){
	val lsuOp	= Output(LsuOp())
	val lsuAddr	= Output(LsuAddr())
	val r2		= Output(UInt(BitWidth.W))
}
class PipeIdEx extends PipeExLs(){
	val alu = Output(ExuAlu())
	val bfu = Output(ExuBfu())
	val csr = Output(ExuCsr())
	val res = Output(ExuRes())
	val In1 = Output(ExuIn1())
	val In2 = Output(ExuIn2())

	val enJcod	=Output(Bool())
	val r1		=Output(UInt(BitWidth.W))
}
class ImmeBefore extends Bundle{
	val back	= Output(Back())
	val addr	= Output(UInt(BitWidth.W))
}
class ImmeAfter extends ImmeBefore(){

	val r1Addr	= Input(UInt(RegWidth.W))
	val r2Addr	= Input(UInt(RegWidth.W))
	val r1Out	= Output(UInt(BitWidth.W))
	val r2Out	= Output(UInt(BitWidth.W))

	val csrAddr	= Input(UInt(CsrWidth.W))
	val csrOut	= Output(UInt(BitWidth.W))
}
class Axi4Master extends Bundle {
	val arvalid	= Output(Bool())
    val araddr	= Output(UInt(BitWidth.W))
	val arready	= Input(Bool())

	val rvalid	= Input(Bool())
	val rdata	= Input(UInt(BitWidth.W))
	val rresp	= Input(UInt(2.W))
	val rready	= Output(Bool())

	val awvalid	= Output(Bool())
	val awaddr	= Output(UInt(BitWidth.W))
	val awready	= Input(Bool())

	val wvalid	= Output(Bool())
	val wdata	= Output(UInt(BitWidth.W))
	val wstrb	= Output(UInt(StrbWidth.W))
	val wready	= Input(Bool())

	val bvalid	= Input(Bool())
	val bresp	= Input(UInt(RespWidth.W))
	val bready	= Output(Bool())
}
class Axi4MasterOut extends Bundle {
	val arvalid	= Output(Bool())
    val araddr	= Output(UInt(BitWidth.W))
	val arid	= Output(UInt(IdWidth.W))
	val arlen	= Output(UInt(LenWidth.W))
	val arsize	= Output(UInt(SizeWidth.W))
	val arburst	= Output(UInt(BurstWidth.W))
	val arready	= Input(Bool())

	val rvalid	= Input(Bool())
	val rdata	= Input(UInt(BitWidth.W))
	val rresp	= Input(UInt(2.W))
	val rid		= Input(UInt(IdWidth.W))
	val rlast	= Input(Bool())
	val rready	= Output(Bool())

	val awvalid	= Output(Bool())
	val awaddr	= Output(UInt(BitWidth.W))
	val awid	= Output(UInt(IdWidth.W))
	val awlen	= Output(UInt(LenWidth.W))
	val awsize	= Output(UInt(SizeWidth.W))
	val awburst	= Output(UInt(BurstWidth.W))
	val awready	= Input(Bool())

	val wvalid	= Output(Bool())
	val wdata	= Output(UInt(BitWidth.W))
	val wstrb	= Output(UInt(StrbWidth.W))
	val wlast	= Output(Bool())
	val wready	= Input(Bool())

	val bvalid	= Input(Bool())
	val bresp	= Input(UInt(RespWidth.W))
	val bid		= Input(UInt(IdWidth.W))
	val bready	= Output(Bool())
}