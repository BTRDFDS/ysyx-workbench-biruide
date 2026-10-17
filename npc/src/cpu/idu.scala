import chisel3._
import chisel3.util._
import WidthConsts._
import chisel3.util.experimental.decode._

sealed trait InstPattern extends DecodePattern
case object InstrLui    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_???_?????_0110111")}
case object InstrAuipc  extends InstPattern{val bitPat = BitPat("b???????_?????_?????_???_?????_0010111")}
case object InstrJal    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_???_?????_1101111")}
case object InstrJalr   extends InstPattern{val bitPat = BitPat("b???????_?????_?????_000_?????_1100111")}
case object InstrBeq    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_000_?????_1100011")}
case object InstrBne    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_001_?????_1100011")}
case object InstrBlt    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_100_?????_1100011")}
case object InstrBge    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_101_?????_1100011")}
case object InstrBltu   extends InstPattern{val bitPat = BitPat("b???????_?????_?????_110_?????_1100011")}
case object InstrBgeu   extends InstPattern{val bitPat = BitPat("b???????_?????_?????_111_?????_1100011")}
case object InstrLb     extends InstPattern{val bitPat = BitPat("b???????_?????_?????_000_?????_0000011")}
case object InstrLh     extends InstPattern{val bitPat = BitPat("b???????_?????_?????_001_?????_0000011")}
case object InstrLw     extends InstPattern{val bitPat = BitPat("b???????_?????_?????_010_?????_0000011")}
case object InstrLbu    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_100_?????_0000011")}
case object InstrLhu    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_101_?????_0000011")}
case object InstrSb     extends InstPattern{val bitPat = BitPat("b???????_?????_?????_000_?????_0100011")}
case object InstrSh     extends InstPattern{val bitPat = BitPat("b???????_?????_?????_001_?????_0100011")}
case object InstrSw     extends InstPattern{val bitPat = BitPat("b???????_?????_?????_010_?????_0100011")}
case object InstrAddi   extends InstPattern{val bitPat = BitPat("b???????_?????_?????_000_?????_0010011")}
case object InstrSlti   extends InstPattern{val bitPat = BitPat("b???????_?????_?????_010_?????_0010011")}
case object InstrSltiu  extends InstPattern{val bitPat = BitPat("b???????_?????_?????_011_?????_0010011")}
case object InstrXori   extends InstPattern{val bitPat = BitPat("b???????_?????_?????_100_?????_0010011")}
case object InstrOri    extends InstPattern{val bitPat = BitPat("b???????_?????_?????_110_?????_0010011")}
case object InstrAndi   extends InstPattern{val bitPat = BitPat("b???????_?????_?????_111_?????_0010011")}
case object InstrSlli   extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_001_?????_0010011")}
case object InstrSrli   extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_101_?????_0010011")}
case object InstrSrai   extends InstPattern{val bitPat = BitPat("b0100000_?????_?????_101_?????_0010011")}
case object InstrAdd    extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_000_?????_0110011")}
case object InstrSub    extends InstPattern{val bitPat = BitPat("b0100000_?????_?????_000_?????_0110011")}
case object InstrSll    extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_001_?????_0110011")}
case object InstrSlt    extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_010_?????_0110011")}
case object InstrSltu   extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_011_?????_0110011")}
case object InstrXor    extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_100_?????_0110011")}
case object InstrSrl    extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_101_?????_0110011")}
case object InstrSra    extends InstPattern{val bitPat = BitPat("b0100000_?????_?????_101_?????_0110011")}
case object InstrOr     extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_110_?????_0110011")}
case object InstrAnd    extends InstPattern{val bitPat = BitPat("b0000000_?????_?????_111_?????_0110011")}
case object InstrFenceI extends InstPattern{val bitPat = BitPat("b0000000_00000_00000_001_00000_0001111")}
case object InstrEcall  extends InstPattern{val bitPat = BitPat("b0000000_00000_00000_000_00000_1110011")}
case object InstrEbreak extends InstPattern{val bitPat = BitPat("b0000000_00001_00000_000_00000_1110011")}
case object InstrCsrrw  extends InstPattern{val bitPat = BitPat("b???????_?????_?????_001_?????_1110011")}
case object InstrCsrrs  extends InstPattern{val bitPat = BitPat("b???????_?????_?????_010_?????_1110011")}
case object InstrMret   extends InstPattern{val bitPat = BitPat("b0011000_00010_00000_000_00000_1110011")}
object DecoderExuAlu extends DecodeField[InstPattern, ExuAlu.Type] {
	override def name = "exuAlu"
	override def chiselType = ExuAlu.Type()
	override def genTable(i: InstPattern): BitPat = i match {
		case InstrAuipc	=> BitPat(ExuAlu.Add.asUInt)

		case InstrAddi	=> BitPat(ExuAlu.Add	.asUInt)
		case InstrSlti	=> BitPat(ExuAlu.Slt	.asUInt)
		case InstrSltiu	=> BitPat(ExuAlu.Sltu	.asUInt)
		case InstrXori	=> BitPat(ExuAlu.Xor	.asUInt)
		case InstrOri	=> BitPat(ExuAlu.Or		.asUInt)
		case InstrAndi	=> BitPat(ExuAlu.And	.asUInt)
		case InstrSlli	=> BitPat(ExuAlu.Sll	.asUInt)
		case InstrSrli	=> BitPat(ExuAlu.Srl	.asUInt)
		case InstrSrai	=> BitPat(ExuAlu.Sra	.asUInt)
		case InstrAdd	=> BitPat(ExuAlu.Add	.asUInt)
		case InstrSub	=> BitPat(ExuAlu.Sub	.asUInt)
		case InstrSll	=> BitPat(ExuAlu.Sll	.asUInt)
		case InstrSlt	=> BitPat(ExuAlu.Slt	.asUInt)
		case InstrSltu	=> BitPat(ExuAlu.Sltu	.asUInt)
		case InstrXor	=> BitPat(ExuAlu.Xor	.asUInt)
		case InstrSrl	=> BitPat(ExuAlu.Srl	.asUInt)
		case InstrSra	=> BitPat(ExuAlu.Sra	.asUInt)
		case InstrOr	=> BitPat(ExuAlu.Or		.asUInt)
		case InstrAnd	=> BitPat(ExuAlu.And	.asUInt)

		case InstrLw	=> BitPat(ExuAlu.Add.asUInt)
		case InstrLh	=> BitPat(ExuAlu.Add.asUInt)
		case InstrLhu	=> BitPat(ExuAlu.Add.asUInt)
		case InstrLb	=> BitPat(ExuAlu.Add.asUInt)
		case InstrLbu	=> BitPat(ExuAlu.Add.asUInt)
		case InstrSw	=> BitPat(ExuAlu.Add.asUInt)
		case InstrSh	=> BitPat(ExuAlu.Add.asUInt)
		case InstrSb	=> BitPat(ExuAlu.Add.asUInt)

		case _ => BitPat.dontCare(ExuAlu.Add.asUInt.getWidth)
	}
	override def default: BitPat = BitPat.dontCare(ExuAlu.Add.asUInt.getWidth)
}
object DecoderExuBfu extends DecodeField[InstPattern, ExuBfu.Type] {
    override def name = "exuBfu"
    override def chiselType = ExuBfu.Type()
    override def genTable(i: InstPattern): BitPat = i match {
		case InstrBeq	=> BitPat(ExuBfu.Beq	.asUInt)
		case InstrBne	=> BitPat(ExuBfu.Bne	.asUInt)
		case InstrBlt	=> BitPat(ExuBfu.Blt	.asUInt)
		case InstrBge	=> BitPat(ExuBfu.Bge	.asUInt)
		case InstrBltu	=> BitPat(ExuBfu.Bltu	.asUInt)
		case InstrBgeu	=> BitPat(ExuBfu.Bgeu	.asUInt)
		
		case _ => BitPat.dontCare(ExuBfu.Beq.asUInt.getWidth)
    }
    override def default: BitPat = BitPat.dontCare(ExuBfu.Beq.asUInt.getWidth)
}
object DecoderExuCsr extends DecodeField[InstPattern, ExuCsr.Type] {
    override def name = "exuCsr"
    override def chiselType = ExuCsr.Type()
    override def genTable(i: InstPattern): BitPat = i match {
		case InstrCsrrw	=> BitPat(ExuCsr.Write	.asUInt)
		case InstrCsrrs	=> BitPat(ExuCsr.Read	.asUInt)

		case _ => BitPat.dontCare(ExuCsr.Write.asUInt.getWidth)
    }
    override def default: BitPat = BitPat.dontCare(ExuCsr.Write.asUInt.getWidth)
}
object DecoderExuRes extends DecodeField[InstPattern, ExuRes.Type] {
    override def name = "exuRes"
    override def chiselType = ExuRes.Type()
    override def genTable(i: InstPattern): BitPat = i match {
		case InstrLui	=> BitPat(ExuRes.Imm	.asUInt)
		case InstrCsrrs	=> BitPat(ExuRes.Imm	.asUInt)
		case InstrCsrrw	=> BitPat(ExuRes.Imm	.asUInt)
		case InstrJalr	=> BitPat(ExuRes.Snpc	.asUInt)
		case InstrJal	=> BitPat(ExuRes.Snpc	.asUInt)

		case InstrAddi	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSlti	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSltiu	=> BitPat(ExuRes.Alu.asUInt)
		case InstrXori	=> BitPat(ExuRes.Alu.asUInt)
		case InstrOri	=> BitPat(ExuRes.Alu.asUInt)
		case InstrAndi	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSlli	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSrli	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSrai	=> BitPat(ExuRes.Alu.asUInt)
		case InstrAdd	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSub	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSll	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSlt	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSltu	=> BitPat(ExuRes.Alu.asUInt)
		case InstrXor	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSrl	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSra	=> BitPat(ExuRes.Alu.asUInt)
		case InstrOr	=> BitPat(ExuRes.Alu.asUInt)
		case InstrAnd	=> BitPat(ExuRes.Alu.asUInt)

		case InstrLw	=> BitPat(ExuRes.Alu.asUInt)
		case InstrLh	=> BitPat(ExuRes.Alu.asUInt)
		case InstrLhu	=> BitPat(ExuRes.Alu.asUInt)
		case InstrLb	=> BitPat(ExuRes.Alu.asUInt)
		case InstrLbu	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSw	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSh	=> BitPat(ExuRes.Alu.asUInt)
		case InstrSb	=> BitPat(ExuRes.Alu.asUInt)

		case _ => BitPat.dontCare(ExuRes.Alu.asUInt.getWidth)
	}
    override def default: BitPat = BitPat.dontCare(ExuRes.Alu.asUInt.getWidth)
}
object DecoderExuIn1 extends DecodeField[InstPattern, ExuIn1.Type] {
    override def name = "exuIn1"
    override def chiselType = ExuIn1.Type()
    override def genTable(i: InstPattern): BitPat = i match {
		case InstrAuipc	=> BitPat(ExuIn1.Pc.asUInt)
		case InstrBeq	=> BitPat(ExuIn1.Pc.asUInt)
		case InstrBne	=> BitPat(ExuIn1.Pc.asUInt)
		case InstrBlt	=> BitPat(ExuIn1.Pc.asUInt)
		case InstrBge	=> BitPat(ExuIn1.Pc.asUInt)
		case InstrBltu	=> BitPat(ExuIn1.Pc.asUInt)
		case InstrBgeu	=> BitPat(ExuIn1.Pc.asUInt)
		case InstrJal	=> BitPat(ExuIn1.Pc.asUInt)

		case InstrAddi	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSlti	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSltiu	=> BitPat(ExuIn1.R1.asUInt)
		case InstrXori	=> BitPat(ExuIn1.R1.asUInt)
		case InstrOri	=> BitPat(ExuIn1.R1.asUInt)
		case InstrAndi	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSlli	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSrli	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSrai	=> BitPat(ExuIn1.R1.asUInt)
		case InstrAdd	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSub	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSll	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSlt	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSltu	=> BitPat(ExuIn1.R1.asUInt)
		case InstrXor	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSrl	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSra	=> BitPat(ExuIn1.R1.asUInt)
		case InstrOr	=> BitPat(ExuIn1.R1.asUInt)
		case InstrAnd	=> BitPat(ExuIn1.R1.asUInt)

		case InstrLw	=> BitPat(ExuIn1.R1.asUInt)
		case InstrLh	=> BitPat(ExuIn1.R1.asUInt)
		case InstrLhu	=> BitPat(ExuIn1.R1.asUInt)
		case InstrLb	=> BitPat(ExuIn1.R1.asUInt)
		case InstrLbu	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSw	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSh	=> BitPat(ExuIn1.R1.asUInt)
		case InstrSb	=> BitPat(ExuIn1.R1.asUInt)

		case _ => BitPat.dontCare(ExuIn1.R1.asUInt.getWidth)
	}
	override def default: BitPat = BitPat.dontCare(ExuIn1.R1.asUInt.getWidth)
}

class idu(val Yosys:Boolean=false) extends Module{
	val in = IO(new Bundle{
		val pipe	= Flipped(new PipeIfId())
		val imme	= Flipped(new ImmeExId())
	})
	val out = IO(new Bundle{
		val pipe	= new PipeIdEx()
		val imme	= new ImmeIdIf()
	})
	val pipeReset	= reset.asBool||in.imme.reloca
	val pipeRes		= PipeReg(in.pipe.res	,out.imme.ready,IfuRes.Null,pipeReset)
	val pipePc		= PipeReg(in.pipe.pc	,out.imme.ready)
	val pipeInstr	= PipeReg(in.pipe.instr	,out.imme.ready)
	//默认值
	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= pipeInstr( 6+RegWidth, 7)
	out.pipe.result	:= 0.U
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= CsrOp.Null
	out.pipe.csrAddr:= pipeInstr(31,20)
	out.pipe.lsuAddr:= LsuAddr.B//000
	out.pipe.lsuOp	:= LsuOp.Null
	out.pipe.r2		:= in.imme.r2Out
	out.pipe.r1		:= in.imme.r1Out
	out.pipe.csrMesg:= in.imme.csrOut

	out.pipe.update := IfuUpdate.Null
	out.pipe.fenceI := pipeInstr === 0x0000100F.U
	out.pipe.jump	:= false.B

	out.pipe.alu	:= ExuAlu.Null
	out.pipe.bfu	:= ExuBfu.Null
	out.pipe.csr	:= ExuCsr.Null
	out.pipe.res	:= ExuRes.Alu
	out.pipe.in1	:= ExuIn1.R1
	out.pipe.in2	:= ExuIn2.R2

	in.imme.csrAddr	:= 0.U

	val opCode	= pipeInstr( 6, 0)
	val rdAddr	= pipeInstr( 6+RegWidth, 7)
	val funct3	= pipeInstr(14,12)
	val r1Addr	= pipeInstr(14+RegWidth,15)
	val r2Addr	= pipeInstr(19+RegWidth,20)
	val funct7	= pipeInstr(31,25)

	val bfuValid = WireInit(true.B)
	val lsuValid = WireInit(true.B)
	val aluValid = WireInit(true.B)
	val csrValid = WireInit(true.B)

	val csrOp	= WireInit(CsrOp.Null)
	val csrMesg = WireInit(in.imme.csrOut)
	
	val (opEnum,opValid) = Op.safe(opCode)
	out.pipe.rdAddr:= Mux(opEnum===Op.Store || opEnum===Op.Branch,0.U,pipeInstr( 6+RegWidth, 7))

	out.pipe.update := Mux(opEnum === Op.Jal || opEnum === Op.Ijalr || opEnum === Op.Branch,
		Mux1H(Seq(
			(opEnum === Op.Jal)		-> IfuUpdate.Jal,
			(opEnum === Op.Ijalr)	-> IfuUpdate.Jalr,
			(opEnum === Op.Branch)	-> IfuUpdate.Branch,
		)),IfuUpdate.Null)
	out.pipe.result := Mux1H(Seq(
		(opEnum === Op.Ului)	-> Cat(pipeInstr(31,12),0.U(12.W)),
		(opEnum === Op.Uauipc)	-> Cat(pipeInstr(31,12),0.U(12.W)),
		(opEnum === Op.Store)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,25),pipeInstr(11,7)),
		(opEnum === Op.Ialu)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Ijalr)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Iload)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Branch)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(7),pipeInstr(30,25),pipeInstr(11,8),0.U(1.W)),
		(opEnum === Op.Jal)		-> Cat(Fill(12,pipeInstr(31)),pipeInstr(19,12),pipeInstr(20),pipeInstr(30,21),0.U(1.W)),
		(opEnum === Op.Icsr)	-> in.imme.csrOut,
		(opEnum === Op.Fence)	-> 0.U,
		(opEnum === Op.Ralu)	-> 0.U,
	))
	out.pipe.jump := opEnum === Op.Jal || opEnum === Op.Ijalr || Cat(pipeInstr(14,12),pipeInstr(6,0))===0x73.U(10.W)

	out.pipe.in2 := Mux(opEnum===Op.Ialu || opEnum===Op.Store || opEnum===Op.Iload || opEnum===Op.Uauipc,ExuIn2.Imm,ExuIn2.R2)//best

	switch(opEnum){//best
		is(Op.Iload){out.pipe.lsuOp := LsuOp.Load}
		is(Op.Store){out.pipe.lsuOp := LsuOp.Store}
	}
		val (lsuEnum,lsuValidinside) = LsuAddr.safe(funct3)
	when(opEnum === Op.Iload || opEnum === Op.Store){
		lsuValid := lsuValidinside
		when(lsuValidinside){out.pipe.lsuAddr := lsuEnum}
	}
	when(opEnum === Op.Icsr){
		switch(funct3){
			is(0b000.U){
				out.pipe.csr := ExuCsr.Null
				when(Cat(pipeInstr(21,20)) === 0b10.U)
							{in.imme.csrAddr := CsrAddr.Mepc.asUInt	}
				.otherwise	{in.imme.csrAddr := CsrAddr.Mtvec.asUInt}
				}
			is(0b001.U){out.pipe.csr := ExuCsr.Write;	in.imme.csrAddr := pipeInstr(31,20)}
			is(0b010.U){out.pipe.csr := ExuCsr.Read;	in.imme.csrAddr := pipeInstr(31,20)}
		}
		csrValid := false.B
		switch(funct3){
			is(0b000.U){switch(Cat(pipeInstr(21,20))){
				is(0b00.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0xbL.U}
				is(0b01.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0x3L.U}
				is(0b10.U){csrOp := CsrOp.Mret;csrValid := true.B;}
			}}
			is(0b001.U){csrOp := CsrOp.Write;csrValid := true.B}
			is(0b010.U){csrOp := Mux(rdAddr === 0.U,CsrOp.Null,CsrOp.Write);csrValid := true.B}
		}
	}
	switch(pipeRes){is(IfuRes.Valid){
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			out.pipe.valid := in.imme.valid
			out.pipe.csrOp	:= csrOp
			out.pipe.csrMesg:= csrMesg
		}.otherwise{
			out.pipe.csrOp	:= CsrOp.Trap
			out.pipe.csrMesg:= 2.U//非法指令
		}
		}
		is(IfuRes.Un4b){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 0.U}//地址对齐
		is(IfuRes.Fall){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 1.U}//读错
	}
	in.imme.r1Addr := Mux(opEnum === Op.Ului || opEnum === Op.Uauipc || opEnum === Op.Fence || opEnum === Op.Jal,0.U,r1Addr)
	in.imme.r2Addr := Mux(opEnum === Op.Ralu || opEnum === Op.Branch || opEnum === Op.Store,r2Addr,0.U)

	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.ready	:= (in.imme.ready && in.imme.valid) || pipeRes === IfuRes.Null

	out.imme.reloca	:= in.imme.reloca
	out.imme.update	:= in.imme.update

	if(Yosys == false){
		dontTouch(pipeReset)
	}

}
class iduOld(val Yosys:Boolean=false) extends Module{
	val in = IO(new Bundle{
		val pipe	= Flipped(new PipeIfId())
		val imme	= Flipped(new ImmeExId())
	})
	val out = IO(new Bundle{
		val pipe	= new PipeIdEx()
		val imme	= new ImmeIdIf()
	})
	val pipeReset	= reset.asBool||in.imme.reloca
	val pipeRes		= PipeReg(in.pipe.res	,out.imme.ready,IfuRes.Null,pipeReset)
	val pipePc		= PipeReg(in.pipe.pc	,out.imme.ready)
	val pipeInstr	= PipeReg(in.pipe.instr	,out.imme.ready)
	//默认值
	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= pipeInstr( 6+RegWidth, 7)
	out.pipe.result	:= 0.U
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= CsrOp.Null
	out.pipe.csrAddr:= pipeInstr(31,20)
	out.pipe.lsuAddr:= LsuAddr.B//000
	out.pipe.lsuOp	:= LsuOp.Null
	out.pipe.r2		:= in.imme.r2Out
	out.pipe.r1		:= in.imme.r1Out
	out.pipe.csrMesg:= in.imme.csrOut

	out.pipe.update := IfuUpdate.Null
	out.pipe.fenceI := pipeInstr === 0x0000100F.U
	out.pipe.jump	:= false.B

	out.pipe.alu	:= ExuAlu.Null
	out.pipe.bfu	:= ExuBfu.Null
	out.pipe.csr	:= ExuCsr.Null
	out.pipe.res	:= ExuRes.Alu
	out.pipe.in1	:= ExuIn1.R1
	out.pipe.in2	:= ExuIn2.R2

	in.imme.csrAddr	:= 0.U

	val opCode	= pipeInstr( 6, 0)
	val rdAddr	= pipeInstr( 6+RegWidth, 7)
	val funct3	= pipeInstr(14,12)
	val r1Addr	= pipeInstr(14+RegWidth,15)
	val r2Addr	= pipeInstr(19+RegWidth,20)
	val funct7	= pipeInstr(31,25)

	val bfuValid = WireInit(true.B)
	val lsuValid = WireInit(true.B)
	val aluValid = WireInit(true.B)
	val csrValid = WireInit(true.B)

	val csrOp	= WireInit(CsrOp.Null)
	val csrMesg = WireInit(in.imme.csrOut)
	
	val (opEnum,opValid) = Op.safe(opCode)
	out.pipe.rdAddr:= Mux(opEnum===Op.Store || opEnum===Op.Branch,0.U,pipeInstr( 6+RegWidth, 7))

	out.pipe.update := Mux(opEnum === Op.Jal || opEnum === Op.Ijalr || opEnum === Op.Branch,
		Mux1H(Seq(
			(opEnum === Op.Jal)		-> IfuUpdate.Jal,
			(opEnum === Op.Ijalr)	-> IfuUpdate.Jalr,
			(opEnum === Op.Branch)	-> IfuUpdate.Branch,
		)),IfuUpdate.Null)
	out.pipe.result := Mux1H(Seq(
		(opEnum === Op.Ului)	-> Cat(pipeInstr(31,12),0.U(12.W)),
		(opEnum === Op.Uauipc)	-> Cat(pipeInstr(31,12),0.U(12.W)),
		(opEnum === Op.Store)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,25),pipeInstr(11,7)),
		(opEnum === Op.Ialu)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Ijalr)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Iload)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Branch)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(7),pipeInstr(30,25),pipeInstr(11,8),0.U(1.W)),
		(opEnum === Op.Jal)		-> Cat(Fill(12,pipeInstr(31)),pipeInstr(19,12),pipeInstr(20),pipeInstr(30,21),0.U(1.W)),
		(opEnum === Op.Icsr)	-> in.imme.csrOut,
		(opEnum === Op.Fence)	-> 0.U,
		(opEnum === Op.Ralu)	-> 0.U,
	))
	out.pipe.jump := opEnum === Op.Jal || opEnum === Op.Ijalr || Cat(pipeInstr(14,12),pipeInstr(6,0))===0x73.U(10.W)
	switch(opEnum){
		is(Op.Uauipc){out.pipe.alu := ExuAlu.Add}
		is(Op.Ialu){
			val (aluEnum,_) = ExuAlu.safe(Cat(0.U(1.W),funct3))
			out.pipe.alu := aluEnum
			switch(aluEnum){
				is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
				is(ExuAlu.Srl){
					aluValid := funct7===0b0000000.U || funct7===0b0100000.U
					switch(funct7){
						is(0b0000000.U){out.pipe.alu := ExuAlu.Srl}
						is(0b0100000.U){out.pipe.alu := ExuAlu.Sra}
					}
				}
			}
		}
		is(Op.Fence)	{out.pipe.alu := ExuAlu.Null}
		is(Op.Ralu){
			val (aluEnum,_) = ExuAlu.safe(funct3)
			aluValid := false.B
			switch(funct7){
				is(0b0000000.U){out.pipe.alu := aluEnum;aluValid := true.B}
				is(0b0100000.U){switch(aluEnum){
						is(ExuAlu.Add){out.pipe.alu := ExuAlu.Sub;aluValid := true.B}
						is(ExuAlu.Srl){out.pipe.alu := ExuAlu.Sra;aluValid := true.B}
					}
				}
			}
		}
		is(Op.Ijalr)	{out.pipe.alu := ExuAlu.Null}
		is(Op.Jal)		{out.pipe.alu := ExuAlu.Null}
		is(Op.Icsr)		{out.pipe.alu := ExuAlu.Null}
		is(Op.Iload)	{out.pipe.alu := ExuAlu.Add}
		is(Op.Branch)	{out.pipe.alu := ExuAlu.Null}
		is(Op.Store)	{out.pipe.alu := ExuAlu.Add}
	}
	out.pipe.in1 := Mux(opEnum === Op.Uauipc || opEnum === Op.Branch || opEnum === Op.Jal,ExuIn1.Pc,ExuIn1.R1)
	out.pipe.in2 := Mux(opEnum===Op.Ialu || opEnum===Op.Store || opEnum===Op.Iload || opEnum===Op.Uauipc,ExuIn2.Imm,ExuIn2.R2)//best
	switch(opEnum){//best
		is(Op.Ului,Op.Icsr)		{out.pipe.res := ExuRes.Imm}
		is(Op.Ijalr,Op.Jal)		{out.pipe.res := ExuRes.Snpc}
	}
	when(opEnum === Op.Branch){
		val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
		bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
		when(bfuValid){out.pipe.bfu := bfuEnum}
	}
	switch(opEnum){//best
		is(Op.Iload){out.pipe.lsuOp := LsuOp.Load}
		is(Op.Store){out.pipe.lsuOp := LsuOp.Store}
	}
		val (lsuEnum,lsuValidinside) = LsuAddr.safe(funct3)
	when(opEnum === Op.Iload || opEnum === Op.Store){
		lsuValid := lsuValidinside
		when(lsuValidinside){out.pipe.lsuAddr := lsuEnum}
	}
	when(opEnum === Op.Icsr){
		switch(funct3){
			is(0b000.U){
				out.pipe.csr := ExuCsr.Null
				when(Cat(pipeInstr(21,20)) === 0b10.U)
							{in.imme.csrAddr := CsrAddr.Mepc.asUInt	}
				.otherwise	{in.imme.csrAddr := CsrAddr.Mtvec.asUInt}
				}
			is(0b001.U){out.pipe.csr := ExuCsr.Write;	in.imme.csrAddr := pipeInstr(31,20)}
			is(0b010.U){out.pipe.csr := ExuCsr.Read;	in.imme.csrAddr := pipeInstr(31,20)}
		}
		csrValid := false.B
		switch(funct3){
			is(0b000.U){switch(Cat(pipeInstr(21,20))){
				is(0b00.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0xbL.U}
				is(0b01.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0x3L.U}
				is(0b10.U){csrOp := CsrOp.Mret;csrValid := true.B;}
			}}
			is(0b001.U){csrOp := CsrOp.Write;csrValid := true.B}
			is(0b010.U){csrOp := Mux(rdAddr === 0.U,CsrOp.Null,CsrOp.Write);csrValid := true.B}
		}
	}
	switch(pipeRes){is(IfuRes.Valid){
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			out.pipe.valid := in.imme.valid
			out.pipe.csrOp	:= csrOp
			out.pipe.csrMesg:= csrMesg
		}.otherwise{
			out.pipe.csrOp	:= CsrOp.Trap
			out.pipe.csrMesg:= 2.U//非法指令
		}
		}
		is(IfuRes.Un4b){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 0.U}//地址对齐
		is(IfuRes.Fall){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 1.U}//读错
	}
	in.imme.r1Addr := Mux(opEnum === Op.Ului || opEnum === Op.Uauipc || opEnum === Op.Fence || opEnum === Op.Jal,0.U,r1Addr)
	in.imme.r2Addr := Mux(opEnum === Op.Ralu || opEnum === Op.Branch || opEnum === Op.Store,r2Addr,0.U)

	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.ready	:= (in.imme.ready && in.imme.valid) || pipeRes === IfuRes.Null

	out.imme.reloca	:= in.imme.reloca
	out.imme.update	:= in.imme.update

	if(Yosys == false){
		dontTouch(pipeReset)
	}

}

