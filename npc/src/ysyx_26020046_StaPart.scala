import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_StaPart extends Module{
    val exu = Module(new ysyx_26020046_StaExu)
	val idu = Module(new ysyx_26020046_StaIdu)
	val wbu = Module(new ysyx_26020046_Wbu)
}
class ysyx_26020046_StaExu extends Module{
	val r1Addr	= Reg(UInt(RegWidth.W))
	val r2Addr	= Reg(UInt(RegWidth.W))
	val csrAddrI= Reg(UInt(CsrWidth.W))

	val r1Out	= Reg(UInt(BitWidth.W))
	val r2Out	= Reg(UInt(BitWidth.W))
	val csrOut	= Reg(UInt(BitWidth.W))

	val lsuOp	= Reg(LsuOp())
	val lsuAddr	= Reg(LsuAddr())
	val r2		= Reg(UInt(BitWidth.W))
    val valid	= Reg(Bool())
	val rdAddr	= Reg(UInt(RegWidth.W))
	val result	= Reg(UInt(BitWidth.W))
	val pc		= Reg(UInt(BitWidth.W))
	val csrOp	= Reg(CsrOp())
	val csrAddr	= Reg(UInt(BitWidth.W))
	val csrMesg	= Reg(UInt(BitWidth.W))

	val exu = Module(new ysyx_26020046_Exu(true))

	r1Addr	:= exu.in.imme.r1Addr
	r2Addr	:= exu.in.imme.r2Addr
	csrAddrI:= exu.in.imme.csrAddr

	r1Out	:= exu.out.imme.r1Out
	r2Out	:= exu.out.imme.r2Out
	csrOut	:= exu.out.imme.csrOut


	lsuOp	:= exu.out.pipe.lsuOp
	lsuAddr	:= exu.out.pipe.lsuAddr
	r2		:= exu.out.pipe.r2
    valid	:= exu.out.pipe.valid
	rdAddr	:= exu.out.pipe.rdAddr
	result	:= exu.out.pipe.result
	pc		:= exu.out.pipe.pc
	csrOp	:= exu.out.pipe.csrOp
	csrAddr	:= exu.out.pipe.csrAddr
	csrMesg	:= exu.out.pipe.csrMesg
}
class ysyx_26020046_StaIdu extends Module{
	val back	= Reg(Back())
	val addr	= Reg(UInt(BitWidth.W))

	val r1Addr	= Reg(UInt(RegWidth.W))
	val r2Addr	= Reg(UInt(RegWidth.W))
	val csrAddrI= Reg(UInt(CsrWidth.W))

	val alu		= Reg(ExuAlu())
	val bfu		= Reg(ExuBfu())
	val csr		= Reg(ExuCsr())
	val res		= Reg(ExuRes())
	val In1		= Reg(ExuIn1())
	val In2		= Reg(ExuIn2())
	val enJcod	= Reg(Bool())
	val r1		= Reg(UInt(BitWidth.W))
	val lsuOp	= Reg(LsuOp())
	val lsuAddr	= Reg(LsuAddr())
	val r2		= Reg(UInt(BitWidth.W))
    val valid	= Reg(Bool())
	val rdAddr	= Reg(UInt(RegWidth.W))
	val result	= Reg(UInt(BitWidth.W))
	val pc		= Reg(UInt(BitWidth.W))
	val csrOp	= Reg(CsrOp())
	val csrAddr	= Reg(UInt(BitWidth.W))
	val csrMesg	= Reg(UInt(BitWidth.W))

	val idu = Module(new ysyx_26020046_Idu(true))
	back	:= idu.out.imme.back
	addr	:= idu.out.imme.addr
	r1Addr	:= idu.in.imme.r1Addr
	r2Addr	:= idu.in.imme.r2Addr
	csrAddrI:= idu.in.imme.csrAddr

	alu		:= idu.out.pipe.alu
	bfu		:= idu.out.pipe.bfu
	csr		:= idu.out.pipe.csr
	res		:= idu.out.pipe.res
	In1		:= idu.out.pipe.In1
	In2		:= idu.out.pipe.In2
	enJcod	:= idu.out.pipe.enJcod
	r1		:= idu.out.pipe.r1
	lsuOp	:= idu.out.pipe.lsuOp
	lsuAddr	:= idu.out.pipe.lsuAddr
	r2		:= idu.out.pipe.r2
    valid	:= idu.out.pipe.valid
	rdAddr	:= idu.out.pipe.rdAddr
	result	:= idu.out.pipe.result
	pc		:= idu.out.pipe.pc
	csrOp	:= idu.out.pipe.csrOp
	csrAddr	:= idu.out.pipe.csrAddr
	csrMesg	:= idu.out.pipe.csrMesg
}