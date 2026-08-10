import chisel3._
import chisel3.util._

object  WidthConsts{//const
	val BitWidth	= 32
	val RegNum		= 16
    val RegWidth	= log2Ceil(RegNum)
	val CsrWidth	= 12
	val RespWidth	= 2
	val StrbWidth	= 4
	val IdWidth		= 4
	val LenWidth	= 8
	val SizeWidth	= 3
	val BurstWidth	= 2

	val CacheBit	= 3
	val CacheWidth	= 2
	val CacheNum    = 1 << CacheBit
	val CacheSize	= 1 << CacheWidth

	def PipeReg[T <: Data](pipeReset:Bool,pipeInit:T,pipeChange:Bool,pipeNext:T): T = {
		val reg = Reg(pipeInit.cloneType)
		when	 (pipeReset ){reg := pipeInit}
		.elsewhen(pipeChange){reg := pipeNext}
		reg
	}
}

import WidthConsts._
class PipeIfId extends Bundle{
	val res		= Output(IfuRes())
	val pc		= Output(UInt((BitWidth-2).W))
	val instr	= Output(UInt(BitWidth.W))
}
class PipeLsWb extends Bundle{
	val valid	= Output(Bool())
	val rdAddr	= Output(UInt(RegWidth.W))
	val result	= Output(UInt(BitWidth.W))
	val pc		= Output(UInt((BitWidth-2).W))
	val csrOp	= Output(CsrOp())
	val csrAddr	= Output(UInt(BitWidth.W))
	val csrMesg	= Output(UInt(BitWidth.W))
}
class PipeExLs extends PipeLsWb(){
	val lsuOp	= Output(LsuOp())
	val lsuAddr	= Output(LsuAddr())
	val r2		= Output(UInt(BitWidth.W))
	val fenceI	= Output(Bool())
}
class PipeIdEx extends PipeExLs(){
	val alu = Output(ExuAlu())
	val bfu = Output(ExuBfu())
	val csr = Output(ExuCsr())
	val res = Output(ExuRes())
	val in1 = Output(ExuIn1())
	val in2 = Output(ExuIn2())

	val enJcod	=Output(Bool())
	val r1		=Output(UInt(BitWidth.W))
}
class ImmeBefore extends Bundle{
	val jump	= Output(Bool())
	val error	= Output(Bool())
	val ready	= Output(Bool())
	val addr	= Output(UInt((BitWidth).W))
	val pc		= Output(UInt((BitWidth-2).W))
}
class ImmeAfter extends ImmeBefore(){

	val r1Addr	= Input(UInt(RegWidth.W))
	val r2Addr	= Input(UInt(RegWidth.W))
	val r1Out	= Output(UInt(BitWidth.W))
	val r2Out	= Output(UInt(BitWidth.W))
	val valid	= Output(Bool())

	val csrAddr	= Input(UInt(CsrWidth.W))
	val csrOut	= Output(UInt(BitWidth.W))
}
class Axi4Master extends Bundle {
	val arvalid	= Output(Bool())
    val araddr	= Output(UInt(BitWidth.W))
	val arready	= Input(Bool())
	val arlen	= Output(UInt(LenWidth.W))
	val arsize	= Output(UInt(SizeWidth.W))
	val arburst	= Output(UInt(BurstWidth.W))

	val rvalid	= Input(Bool())
	val rdata	= Input(UInt(BitWidth.W))
	val rresp	= Input(UInt(2.W))
	val rready	= Output(Bool())
	val rlast	= Input(Bool())

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
class Axi4MasterOut extends Axi4Master {
	val arid	= Output(UInt(IdWidth.W))

	val rid		= Input(UInt(IdWidth.W))

	val awid	= Output(UInt(IdWidth.W))
	val awlen	= Output(UInt(LenWidth.W))
	val awsize	= Output(UInt(SizeWidth.W))
	val awburst	= Output(UInt(BurstWidth.W))

	val wlast	= Output(Bool())

	val bid		= Input(UInt(IdWidth.W))
}
class InstrBus extends Bundle{
	val valid	= Output(Bool())
	val addr	= Output(UInt((BitWidth-2).W))
	val data	= Input(UInt(BitWidth.W))
	val ready	= Input(Bool())
	val error	= Input(Bool())
}
class BurstBus extends Bundle{
	val valid	= Output(Bool())
	val addr	= Output(UInt((BitWidth-2).W))
	val data	= Input(UInt(BitWidth.W))
	val res		= Input(BurstRes())
}
class MemBus extends Bundle{
	val addr	= Output(UInt(BitWidth.W))
	val rdata	=  Input(UInt(BitWidth.W))
	val wdata	= Output(UInt(BitWidth.W))
	val wstrb	= Output(UInt(StrbWidth.W))
	val error	=  Input(Bool())
	val ready	=  Input(Bool())
	val size	= Output(UInt(2.W))
	val write	= Output(Bool())
}
class FecneBus extends Bundle{
	val fenceI	= Output(Bool())
}