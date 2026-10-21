import chisel3._
import chisel3.util._
import WidthConsts._
import chisel3.util.experimental.decode._
object BP {
	private def mk(w: Int, v: BigInt): BitPat = {
		val s = v.toString(2)
		require(s.length <= w, s"值 $v 放不进 $w 位")
		BitPat("b" + ("0" * (w - s.length)) + s)
	}
	def hex(h: String, w: Int): BitPat = mk(w, BigInt(h, 16))
	def apply(e: ChiselEnum#Type): BitPat = mk(e.getWidth, e.litValue)
	def apply(h: String, w: Int): BitPat = hex(h, w)
	val Y:BitPat = BitPat("b1")
	val N:BitPat = BitPat("b0")
	val X:BitPat = BitPat.dontCare(1)
}
object ImmOp extends ChiselEnum{val I,S,B,U,J,C,E,T=Value}
object DC {def apply[E <: ChiselEnum](t: E): BitPat = BitPat.dontCare(t().getWidth)}
object Decoder{
	case class Uops(
		exuAlu:BitPat,exuBfu:BitPat,exuCsr:BitPat,exuIn1:BitPat,exuIn2:BitPat,
		fence:BitPat,update:BitPat,
		r1:BitPat,r2:BitPat,rd:BitPat,imm:BitPat,
		lsuOp:BitPat,lsuAddr:BitPat,
		csrOp:BitPat,immT:BitPat,
		)
	case class Inst(bitPat: BitPat, mnem: String, p: Uops) extends DecodePattern
	val insts: Seq[Inst] = Seq(													//ExuAlu		,ExuBfu			,ExuCsr			,ExuIn1			,ExuIn2			,Fenc,Update				,R1  ,R2  ,Rd  ,Imme       ,LsuOp			,LsuAddr		,CsrOp			,ImmE
		Inst(BitPat("b???????_?????_?????_???_?????_0110111"),"lui"		,Uops(BP(ExuAlu.Imm)	,BP(ExuBfu.Null),DC(ExuCsr)		,DC(ExuIn1)		,DC(ExuIn2)		,BP.N,BP(IfuUpdate.Null)	,BP.N,BP.N,BP.Y,BP(ImmOp.U),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_???_?????_0010111"),"auipc"	,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.N,BP.N,BP.Y,BP(ImmOp.U),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_???_?????_1101111"),"jal"		,Uops(BP(ExuAlu.Snpc)	,BP(ExuBfu.Jump),DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Jal)		,BP.N,BP.N,BP.Y,BP(ImmOp.J),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_000_?????_1100111"),"jalr"	,Uops(BP(ExuAlu.Snpc)	,BP(ExuBfu.Jump),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Jalr)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_000_?????_1100011"),"beq"		,Uops(DC(ExuAlu)		,BP(ExuBfu.Beq)	,DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Branch)	,BP.Y,BP.Y,BP.N,BP(ImmOp.B),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_001_?????_1100011"),"bne"		,Uops(DC(ExuAlu)		,BP(ExuBfu.Bne)	,DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Branch)	,BP.Y,BP.Y,BP.N,BP(ImmOp.B),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_100_?????_1100011"),"blt"		,Uops(DC(ExuAlu)		,BP(ExuBfu.Blt)	,DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Branch)	,BP.Y,BP.Y,BP.N,BP(ImmOp.B),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_101_?????_1100011"),"bge"		,Uops(DC(ExuAlu)		,BP(ExuBfu.Bge)	,DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Branch)	,BP.Y,BP.Y,BP.N,BP(ImmOp.B),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_110_?????_1100011"),"bltu"	,Uops(DC(ExuAlu)		,BP(ExuBfu.Bltu),DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Branch)	,BP.Y,BP.Y,BP.N,BP(ImmOp.B),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_111_?????_1100011"),"bgeu"	,Uops(DC(ExuAlu)		,BP(ExuBfu.Bgeu),DC(ExuCsr)		,BP(ExuIn1.Pc)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Branch)	,BP.Y,BP.Y,BP.N,BP(ImmOp.B),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_000_?????_0000011"),"lb"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Load)	,BP(LsuAddr.B)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_001_?????_0000011"),"lh"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Load)	,BP(LsuAddr.H)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_010_?????_0000011"),"lw"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Load)	,BP(LsuAddr.W)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_100_?????_0000011"),"lbu"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Load)	,BP(LsuAddr.Bu)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_101_?????_0000011"),"lhu"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Load)	,BP(LsuAddr.Hu)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_000_?????_0100011"),"sb"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.S),BP(LsuOp.Store)	,BP(LsuAddr.B)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_001_?????_0100011"),"sh"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.S),BP(LsuOp.Store)	,BP(LsuAddr.H)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_010_?????_0100011"),"sw"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.S),BP(LsuOp.Store)	,BP(LsuAddr.W)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_000_?????_0010011"),"addi"	,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_010_?????_0010011"),"slti"	,Uops(BP(ExuAlu.Slt)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_011_?????_0010011"),"sltiu"	,Uops(BP(ExuAlu.Sltu)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_100_?????_0010011"),"xori"	,Uops(BP(ExuAlu.Xor)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_110_?????_0010011"),"ori"		,Uops(BP(ExuAlu.Or)		,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_111_?????_0010011"),"andi"	,Uops(BP(ExuAlu.And)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_001_?????_0010011"),"slli"	,Uops(BP(ExuAlu.Sll)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_101_?????_0010011"),"srli"	,Uops(BP(ExuAlu.Srl)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0100000_?????_?????_101_?????_0010011"),"srai"	,Uops(BP(ExuAlu.Sra)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_000_?????_0110011"),"add"		,Uops(BP(ExuAlu.Add)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0100000_?????_?????_000_?????_0110011"),"sub"		,Uops(BP(ExuAlu.Sub)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_001_?????_0110011"),"sll"		,Uops(BP(ExuAlu.Sll)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_010_?????_0110011"),"slt"		,Uops(BP(ExuAlu.Slt)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_011_?????_0110011"),"sltu"	,Uops(BP(ExuAlu.Sltu)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_100_?????_0110011"),"xor"		,Uops(BP(ExuAlu.Xor)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_101_?????_0110011"),"srl"		,Uops(BP(ExuAlu.Srl)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0100000_?????_?????_101_?????_0110011"),"sra"		,Uops(BP(ExuAlu.Sra)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_110_?????_0110011"),"or"		,Uops(BP(ExuAlu.Or)		,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_?????_?????_111_?????_0110011"),"and"		,Uops(BP(ExuAlu.And)	,BP(ExuBfu.Null),DC(ExuCsr)		,BP(ExuIn1.R1)	,BP(ExuIn2.R2)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.Y,BP.Y,BP(ImmOp.I),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_00000_00000_001_00000_0001111"),"fenceI"	,Uops(DC(ExuAlu)		,BP(ExuBfu.Jump),DC(ExuCsr)		,DC(ExuIn1)		,DC(ExuIn2)		,BP.Y,BP(IfuUpdate.Null)	,BP.N,BP.N,BP.N,DC(ImmOp)  ,BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Null)	,BitPat.dontCare(32))),
		Inst(BitPat("b0000000_00000_00000_000_00000_1110011"),"ecall"	,Uops(DC(ExuAlu)		,BP(ExuBfu.Null),BP(ExuCsr.Null),DC(ExuIn1)		,DC(ExuIn2)		,BP.N,BP(IfuUpdate.Null)	,BP.N,BP.N,BP.N,BP(ImmOp.T),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Trap)	,BP.hex("b",32)	 )),
		Inst(BitPat("b0000000_00001_00000_000_00000_1110011"),"ebreak"	,Uops(DC(ExuAlu)		,BP(ExuBfu.Null),BP(ExuCsr.Null),DC(ExuIn1)		,DC(ExuIn2)		,BP.N,BP(IfuUpdate.Null)	,BP.N,BP.N,BP.N,BP(ImmOp.T),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Trap)	,BP.hex("3",32)	 )),
		Inst(BitPat("b???????_?????_?????_001_?????_1110011"),"csrrw"	,Uops(BP(ExuAlu.Imm)	,BP(ExuBfu.Null),BP(ExuCsr.Rw)	,DC(ExuIn1)		,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.C),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Write),BitPat.dontCare(32))),
		Inst(BitPat("b???????_?????_?????_010_?????_1110011"),"csrrs"	,Uops(BP(ExuAlu.Imm)	,BP(ExuBfu.Null),BP(ExuCsr.Rs)	,DC(ExuIn1)		,BP(ExuIn2.Imm)	,BP.N,BP(IfuUpdate.Null)	,BP.Y,BP.N,BP.Y,BP(ImmOp.C),BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Write),BitPat.dontCare(32))),
		Inst(BitPat("b0011000_00010_00000_000_00000_1110011"),"mret"	,Uops(DC(ExuAlu)		,BP(ExuBfu.Null),BP(ExuCsr.Null),DC(ExuIn1)		,DC(ExuIn2)		,BP.N,BP(IfuUpdate.Null)	,BP.N,BP.N,BP.N,DC(ImmOp)  ,BP(LsuOp.Null)	,DC(LsuAddr)	,BP(CsrOp.Mret)	,BitPat.dontCare(32))),
	)
	val exuAlu = new DecodeField[Inst, ExuAlu.Type] {
		def name = "exuAlu"; def chiselType = ExuAlu()
		def genTable(i: Inst) = i.p.exuAlu
		override def default = DC(ExuAlu)
	}
	val exuBfu = new DecodeField[Inst, ExuBfu.Type] {
		def name = "exuBfu"; def chiselType = ExuBfu()
		def genTable(i: Inst) = i.p.exuBfu
		override def default = DC(ExuBfu)
	}
	val exuCsr = new DecodeField[Inst, ExuCsr.Type] {
		def name = "exuCsr"; def chiselType = ExuCsr()
		def genTable(i: Inst) = i.p.exuCsr
		override def default = DC(ExuCsr)
	}
	val exuIn1 = new DecodeField[Inst, ExuIn1.Type] {
		def name = "exuIn1"; def chiselType = ExuIn1()
		def genTable(i: Inst) = i.p.exuIn1
		override def default = DC(ExuIn1)
	}
	val exuIn2 = new DecodeField[Inst, ExuIn2.Type] {
		def name = "exuIn2"; def chiselType = ExuIn2()
		def genTable(i: Inst) = i.p.exuIn2
		override def default = DC(ExuIn2)
	}
	val fence = new BoolDecodeField[Inst] {
		def name = "fence"; def genTable(i: Inst) = i.p.fence
		override def default = BitPat.dontCare(1)
	}
	val update = new DecodeField[Inst, IfuUpdate.Type] {
		def name = "update"; def chiselType = IfuUpdate()
		def genTable(i: Inst) = i.p.update
		override def default = DC(IfuUpdate)
	}
	val r1 = new BoolDecodeField[Inst] {
		def name = "r1"; def genTable(i: Inst) = i.p.r1
		override def default = BitPat.dontCare(1)
	}
	val r2 = new BoolDecodeField[Inst] {
		def name = "r2"; def genTable(i: Inst) = i.p.r2
		override def default = BitPat.dontCare(1)
	}
	val rd = new BoolDecodeField[Inst] {
		def name = "rd"; def genTable(i: Inst) = i.p.rd
		override def default = BitPat.dontCare(1)
	}
	val imm = new DecodeField[Inst, ImmOp.Type] {
		def name = "imm"; def chiselType = ImmOp()
		def genTable(i: Inst) = i.p.imm
		override def default = DC(ImmOp)
	}
	val lsuOp = new DecodeField[Inst, LsuOp.Type] {
		def name = "lsuOp"; def chiselType = LsuOp()
		def genTable(i: Inst) = i.p.lsuOp
		override def default = DC(LsuOp)
	}
	val lsuAddr = new DecodeField[Inst, LsuAddr.Type] {
		def name = "lsuAddr"; def chiselType = LsuAddr()
		def genTable(i: Inst) = i.p.lsuAddr
		override def default = DC(LsuAddr)
	}
	val csrOp = new DecodeField[Inst, CsrOp.Type] {
		def name = "csrOp"; def chiselType = CsrOp()
		def genTable(i: Inst) = i.p.update
		override def default = DC(CsrOp)
	}
	val immT = new DecodeField[Inst, UInt] {
		def name = "immT"
		def chiselType = UInt(32.W)
		def genTable(i: Inst) = i.p.immT
		override def default = BitPat.dontCare(32)
	}
	val valid = new BoolDecodeField[Inst] {
		def name = "valid"; def genTable(i: Inst) = y
		override def default = n
	}

	val fields: Seq[DecodeField[Inst, _ <: Data]] = Seq(exuAlu,exuBfu,exuCsr,exuIn1,exuIn2,fence,update,r1,r2,rd,imm,lsuOp,lsuAddr,csrOp,immT,valid)
	val table = new DecodeTable(insts, fields)
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


	val decoder = Decoder.table.decode(pipeInstr)
	val immOp	= Mux(pipeRes===IfuRes.Valid && decoder(Decoder.valid),decoder(Decoder.imm),ImmOp.E)
	val immE = MuxCase(2.U(32.W),Seq(
		(pipeRes===IfuRes.Fall)->1.U(32.W),
		(pipeRes===IfuRes.Un4b)->0.U(32.W),
	))

	out.pipe.pc		:= pipePc
	out.pipe.r1		:= in.imme.r1Out
	out.pipe.r2		:= in.imme.r2Out
	out.pipe.rdAddr	:= Mux(decoder(Decoder.rd),pipeInstr( 6+RegWidth, 7),0.U)
	out.pipe.imm	:= Mux1H(Seq(
		(immOp === ImmOp.U)->Cat(pipeInstr(31,12),0.U(12.W)),
		(immOp === ImmOp.S)->Cat(Fill(20,pipeInstr(31)),pipeInstr(31,25),pipeInstr(11,7)),
		(immOp === ImmOp.B)->Cat(Fill(20,pipeInstr(31)),pipeInstr(7),pipeInstr(30,25),pipeInstr(11,8),0.U(1.W)),
		(immOp === ImmOp.J)->Cat(Fill(12,pipeInstr(31)),pipeInstr(19,12),pipeInstr(20),pipeInstr(30,21),0.U(1.W)),
		(immOp === ImmOp.I)->Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(immOp === ImmOp.C)->in.imme.csrOut,
		(immOp === ImmOp.T)->decoder(Decoder.immT),
		(immOp === ImmOp.E)->immE
	))
	out.pipe.csrOp	:= Mux(pipeRes===IfuRes.Valid && decoder(Decoder.valid),decoder(Decoder.csrOp),CsrOp.Trap)
	out.pipe.csrAddr:= pipeInstr(31,20)
	out.pipe.lsuOp	:= Mux(pipeRes===IfuRes.Valid && decoder(Decoder.valid),decoder(Decoder.lsuOp),LsuOp.Null)
	out.pipe.lsuAddr:= decoder(Decoder.lsuAddr)
	out.pipe.update := decoder(Decoder.update)
	out.pipe.fenceI := decoder(Decoder.fence)

	out.pipe.alu	:= decoder(Decoder.exuAlu)
	out.pipe.bfu	:= decoder(Decoder.exuBfu)
	out.pipe.csr	:= decoder(Decoder.exuCsr)
	out.pipe.in1	:= decoder(Decoder.exuIn1)
	out.pipe.in2	:= decoder(Decoder.exuIn2)

	val r1Ready = ~((decoder(Decoder.r1)&&pipeInstr(14+RegWidth,15)=/=0.U)^in.imme.r1Valid)
	val r2Ready = ~((decoder(Decoder.r2)&&pipeInstr(19+RegWidth,20)=/=0.U)^in.imme.r2Valid)
	out.pipe.valid	:= pipeRes=/=IfuRes.Null && ((r1Ready && r2Ready) || ~decoder(Decoder.valid))

	in.imme.csrAddr:= pipeInstr(31,20)
	in.imme.r1Addr := pipeInstr(14+RegWidth,15)
	in.imme.r2Addr := pipeInstr(19+RegWidth,20)

	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.ready	:= (in.imme.ready && (r1Ready && r2Ready)) || pipeRes === IfuRes.Null

	out.imme.reloca	:= in.imme.reloca
	out.imme.update	:= in.imme.update

	if(Yosys == false){
		val chkValid = decoder(Decoder.valid)
		dontTouch(chkValid)
		dontTouch(pipeReset)
	}

}
// class iduOld(val Yosys:Boolean=false) extends Module{
// 	val in = IO(new Bundle{
// 		val pipe	= Flipped(new PipeIfId())
// 		val imme	= Flipped(new ImmeExId())
// 	})
// 	val out = IO(new Bundle{
// 		val pipe	= new PipeIdEx()
// 		val imme	= new ImmeIdIf()
// 	})
// 	val pipeReset	= reset.asBool||in.imme.reloca
// 	val pipeRes		= PipeReg(in.pipe.res	,out.imme.ready,IfuRes.Null,pipeReset)
// 	val pipePc		= PipeReg(in.pipe.pc	,out.imme.ready)
// 	val pipeInstr	= PipeReg(in.pipe.instr	,out.imme.ready)
// 	//默认值
// 	out.pipe.valid	:= false.B
// 	out.pipe.rdAddr	:= pipeInstr( 6+RegWidth, 7)
// 	out.pipe.result	:= 0.U
// 	out.pipe.pc		:= pipePc
// 	out.pipe.csrOp	:= CsrOp.Null
// 	out.pipe.csrAddr:= pipeInstr(31,20)
// 	out.pipe.lsuAddr:= LsuAddr.B//000
// 	out.pipe.lsuOp	:= LsuOp.Null
// 	out.pipe.r2		:= in.imme.r2Out
// 	out.pipe.r1		:= in.imme.r1Out
// 	out.pipe.csrMesg:= in.imme.csrOut

// 	out.pipe.update := IfuUpdate.Null
// 	out.pipe.fenceI := pipeInstr === 0x0000100F.U
// 	out.pipe.jump	:= false.B

// 	out.pipe.alu	:= ExuAlu.Null
// 	out.pipe.bfu	:= ExuBfu.Null
// 	out.pipe.csr	:= ExuCsr.Null
// 	out.pipe.res	:= ExuRes.Alu
// 	out.pipe.in1	:= ExuIn1.R1
// 	out.pipe.in2	:= ExuIn2.R2

// 	in.imme.csrAddr	:= 0.U

// 	val opCode	= pipeInstr( 6, 0)
// 	val rdAddr	= pipeInstr( 6+RegWidth, 7)
// 	val funct3	= pipeInstr(14,12)
// 	val r1Addr	= pipeInstr(14+RegWidth,15)
// 	val r2Addr	= pipeInstr(19+RegWidth,20)
// 	val funct7	= pipeInstr(31,25)

// 	val bfuValid = WireInit(true.B)
// 	val lsuValid = WireInit(true.B)
// 	val aluValid = WireInit(true.B)
// 	val csrValid = WireInit(true.B)

// 	val csrOp	= WireInit(CsrOp.Null)
// 	val csrMesg = WireInit(in.imme.csrOut)
	
// 	val (opEnum,opValid) = Op.safe(opCode)
// 	out.pipe.rdAddr:= Mux(opEnum===Op.Store || opEnum===Op.Branch,0.U,pipeInstr( 6+RegWidth, 7))

// 	out.pipe.update := Mux(opEnum === Op.Jal || opEnum === Op.Ijalr || opEnum === Op.Branch,
// 		Mux1H(Seq(
// 			(opEnum === Op.Jal)		-> IfuUpdate.Jal,
// 			(opEnum === Op.Ijalr)	-> IfuUpdate.Jalr,
// 			(opEnum === Op.Branch)	-> IfuUpdate.Branch,
// 		)),IfuUpdate.Null)
// 	out.pipe.result := Mux1H(Seq(
// 		(opEnum === Op.Ului)	-> Cat(pipeInstr(31,12),0.U(12.W)),
// 		(opEnum === Op.Uauipc)	-> Cat(pipeInstr(31,12),0.U(12.W)),
// 		(opEnum === Op.Store)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,25),pipeInstr(11,7)),
// 		(opEnum === Op.Ialu)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
// 		(opEnum === Op.Ijalr)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
// 		(opEnum === Op.Iload)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
// 		(opEnum === Op.Branch)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(7),pipeInstr(30,25),pipeInstr(11,8),0.U(1.W)),
// 		(opEnum === Op.Jal)		-> Cat(Fill(12,pipeInstr(31)),pipeInstr(19,12),pipeInstr(20),pipeInstr(30,21),0.U(1.W)),
// 		(opEnum === Op.Icsr)	-> in.imme.csrOut,
// 		(opEnum === Op.Fence)	-> 0.U,
// 		(opEnum === Op.Ralu)	-> 0.U,
// 	))
// 	out.pipe.jump := opEnum === Op.Jal || opEnum === Op.Ijalr || Cat(pipeInstr(14,12),pipeInstr(6,0))===0x73.U(10.W)
// 	switch(opEnum){
// 		is(Op.Uauipc){out.pipe.alu := ExuAlu.Add}
// 		is(Op.Ialu){
// 			val (aluEnum,_) = ExuAlu.safe(Cat(0.U(1.W),funct3))
// 			out.pipe.alu := aluEnum
// 			switch(aluEnum){
// 				is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
// 				is(ExuAlu.Srl){
// 					aluValid := funct7===0b0000000.U || funct7===0b0100000.U
// 					switch(funct7){
// 						is(0b0000000.U){out.pipe.alu := ExuAlu.Srl}
// 						is(0b0100000.U){out.pipe.alu := ExuAlu.Sra}
// 					}
// 				}
// 			}
// 		}
// 		is(Op.Fence)	{out.pipe.alu := ExuAlu.Null}
// 		is(Op.Ralu){
// 			val (aluEnum,_) = ExuAlu.safe(funct3)
// 			aluValid := false.B
// 			switch(funct7){
// 				is(0b0000000.U){out.pipe.alu := aluEnum;aluValid := true.B}
// 				is(0b0100000.U){switch(aluEnum){
// 						is(ExuAlu.Add){out.pipe.alu := ExuAlu.Sub;aluValid := true.B}
// 						is(ExuAlu.Srl){out.pipe.alu := ExuAlu.Sra;aluValid := true.B}
// 					}
// 				}
// 			}
// 		}
// 		is(Op.Ijalr)	{out.pipe.alu := ExuAlu.Null}
// 		is(Op.Jal)		{out.pipe.alu := ExuAlu.Null}
// 		is(Op.Icsr)		{out.pipe.alu := ExuAlu.Null}
// 		is(Op.Iload)	{out.pipe.alu := ExuAlu.Add}
// 		is(Op.Branch)	{out.pipe.alu := ExuAlu.Null}
// 		is(Op.Store)	{out.pipe.alu := ExuAlu.Add}
// 	}
// 	out.pipe.in1 := Mux(opEnum === Op.Uauipc || opEnum === Op.Branch || opEnum === Op.Jal,ExuIn1.Pc,ExuIn1.R1)
// 	out.pipe.in2 := Mux(opEnum===Op.Ialu || opEnum===Op.Store || opEnum===Op.Iload || opEnum===Op.Uauipc,ExuIn2.Imm,ExuIn2.R2)//best
// 	switch(opEnum){//best
// 		is(Op.Ului,Op.Icsr)		{out.pipe.res := ExuRes.Imm}
// 		is(Op.Ijalr,Op.Jal)		{out.pipe.res := ExuRes.Snpc}
// 	}
// 	when(opEnum === Op.Branch){
// 		val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
// 		bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
// 		when(bfuValid){out.pipe.bfu := bfuEnum}
// 	}
// 	switch(opEnum){//best
// 		is(Op.Iload){out.pipe.lsuOp := LsuOp.Load}
// 		is(Op.Store){out.pipe.lsuOp := LsuOp.Store}
// 	}
// 		val (lsuEnum,lsuValidinside) = LsuAddr.safe(funct3)
// 	when(opEnum === Op.Iload || opEnum === Op.Store){
// 		lsuValid := lsuValidinside
// 		when(lsuValidinside){out.pipe.lsuAddr := lsuEnum}
// 	}
// 	when(opEnum === Op.Icsr){
// 		switch(funct3){
// 			is(0b000.U){
// 				out.pipe.csr := ExuCsr.Null
// 				when(Cat(pipeInstr(21,20)) === 0b10.U)
// 							{in.imme.csrAddr := CsrAddr.Mepc.asUInt	}
// 				.otherwise	{in.imme.csrAddr := CsrAddr.Mtvec.asUInt}
// 				}
// 			is(0b001.U){out.pipe.csr := ExuCsr.Write;	in.imme.csrAddr := pipeInstr(31,20)}
// 			is(0b010.U){out.pipe.csr := ExuCsr.Read;	in.imme.csrAddr := pipeInstr(31,20)}
// 		}
// 		csrValid := false.B
// 		switch(funct3){
// 			is(0b000.U){switch(Cat(pipeInstr(21,20))){
// 				is(0b00.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0xbL.U}
// 				is(0b01.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0x3L.U}
// 				is(0b10.U){csrOp := CsrOp.Mret;csrValid := true.B;}
// 			}}
// 			is(0b001.U){csrOp := CsrOp.Write;csrValid := true.B}
// 			is(0b010.U){csrOp := Mux(rdAddr === 0.U,CsrOp.Null,CsrOp.Write);csrValid := true.B}
// 		}
// 	}
// 	switch(pipeRes){is(IfuRes.Valid){
// 		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
// 			out.pipe.valid := in.imme.valid
// 			out.pipe.csrOp	:= csrOp
// 			out.pipe.csrMesg:= csrMesg
// 		}.otherwise{
// 			out.pipe.csrOp	:= CsrOp.Trap
// 			out.pipe.csrMesg:= 2.U//非法指令
// 		}
// 		}
// 		is(IfuRes.Un4b){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 0.U}//地址对齐
// 		is(IfuRes.Fall){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 1.U}//读错
// 	}
// 	in.imme.r1Addr := Mux(opEnum === Op.Ului || opEnum === Op.Uauipc || opEnum === Op.Fence || opEnum === Op.Jal,0.U,r1Addr)
// 	in.imme.r2Addr := Mux(opEnum === Op.Ralu || opEnum === Op.Branch || opEnum === Op.Store,r2Addr,0.U)

// 	out.imme.addr	:= in.imme.addr
// 	out.imme.pc		:= in.imme.pc
// 	out.imme.ready	:= (in.imme.ready && in.imme.valid) || pipeRes === IfuRes.Null

// 	out.imme.reloca	:= in.imme.reloca
// 	out.imme.update	:= in.imme.update

// 	if(Yosys == false){
// 		dontTouch(pipeReset)
// 	}

// }

