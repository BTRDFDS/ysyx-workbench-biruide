/*
// 三种等价译码实现：DecodeTable / Mux1H / switch，接口完全一致，便于综合对比。
// 覆盖指令：add addi lw lb sw sb jal lui beq bne
import chisel3._
import chisel3.util._
import chisel3.util.experimental.decode._

// ============================================================
// 1. 输出枚举：值个数铺满编码空间（NOP 必须是第一个值 ⇒ 编码 0）
// ============================================================
object ExuAluTry extends ChiselEnum { val NOP, ADD = Value }                                // 2 值 => 1 位
object ExuBfuTry extends ChiselEnum { val NOP, EQ, NE, Rsv0 = Value }                       // 4 值 => 2 位
object LsuOpTry  extends ChiselEnum { val NOP, LW, LB, SW, SB, Rsv0, Rsv1, Rsv2 = Value }   // 8 值 => 3 位
// 枚举「值」=> 定宽 BitPat：ChiselEnum#Type 是"任意枚举的值"的公共上界
object BP {
  private def mk(w: Int, v: BigInt): BitPat = {
    val s = v.toString(2)
    require(s.length <= w, s"值 $v 放不进 $w 位")
    BitPat("b" + ("0" * (w - s.length)) + s)
  }
  def apply(e: ChiselEnum#Type): BitPat = mk(e.getWidth, e.litValue)

  val YES: BitPat = BitPat("b1")
  val NO:  BitPat = BitPat("b0")
}

// 枚举「类型」=> 该宽度的全 don't-care：E <: ChiselEnum 收的就是 object 本身
object DC {
  def apply[E <: ChiselEnum](t: E): BitPat = BitPat.dontCare(t().getWidth)
}
// ============================================================
// 2. DecodeTable 版
// ============================================================
object Dec {
  case class Ctrl(alu: BitPat, bfu: BitPat, lsu: BitPat, jump: BitPat)
  case class Inst(bitPat: BitPat, mnem: String, p: Ctrl) extends DecodePattern

  val insts: Seq[Inst] = Seq(
    //                 funct7  rs2    rs1    fn3  rd     opcode
    Inst(BitPat("b0000000??????????000?????0110011"), "add",  Ctrl(BP(ExuAluTry.ADD), BP(ExuBfuTry.NOP), BP(LsuOpTry.NOP), BP.NO)),
    //                 imm[11:0]        rs1    fn3  rd     opcode
    Inst(BitPat("b?????????????????000?????0010011"), "addi", Ctrl(BP(ExuAluTry.ADD), BP(ExuBfuTry.NOP), BP(LsuOpTry.NOP), BP.NO)),
    Inst(BitPat("b?????????????????010?????0000011"), "lw",   Ctrl(DC(ExuAluTry),    BP(ExuBfuTry.NOP), BP(LsuOpTry.LW),  BP.NO)),
    Inst(BitPat("b?????????????????000?????0000011"), "lb",   Ctrl(DC(ExuAluTry),    BP(ExuBfuTry.NOP), BP(LsuOpTry.LB),  BP.NO)),
    //                 imm[11:5]        rs2    rs1    fn3  imm[4:0] opcode
    Inst(BitPat("b?????????????????010?????0100011"), "sw",   Ctrl(DC(ExuAluTry),    BP(ExuBfuTry.NOP), BP(LsuOpTry.SW),  BP.NO)),
    Inst(BitPat("b?????????????????000?????0100011"), "sb",   Ctrl(DC(ExuAluTry),    BP(ExuBfuTry.NOP), BP(LsuOpTry.SB),  BP.NO)),
    //                 imm(20) + rd(5) = 25 个 ?
    Inst(BitPat("b?????????????????????????1101111"), "jal",  Ctrl(BP(ExuAluTry.ADD), BP(ExuBfuTry.NOP), BP(LsuOpTry.NOP), BP.YES)),
    Inst(BitPat("b?????????????????????????0110111"), "lui",  Ctrl(BP(ExuAluTry.ADD), BP(ExuBfuTry.NOP), BP(LsuOpTry.NOP), BP.NO)),
    //                 imm[12|10:5]     rs2    rs1    fn3  imm[4:1|11] opcode
    Inst(BitPat("b?????????????????000?????1100011"), "beq",  Ctrl(DC(ExuAluTry),    BP(ExuBfuTry.EQ),  BP(LsuOpTry.NOP), BP.NO)),
    Inst(BitPat("b?????????????????001?????1100011"), "bne",  Ctrl(DC(ExuAluTry),    BP(ExuBfuTry.NE),  BP(LsuOpTry.NOP), BP.NO))
  )

  val aluOp = new DecodeField[Inst, ExuAluTry.Type] {
    def name = "aluOp"; def chiselType = ExuAluTry()
    def genTable(i: Inst) = i.p.alu
    override def default = BP(ExuAluTry.NOP)
  }
  val bfuOp = new DecodeField[Inst, ExuBfuTry.Type] {
    def name = "bfuOp"; def chiselType = ExuBfuTry()
    def genTable(i: Inst) = i.p.bfu
    override def default = BP(ExuBfuTry.NOP)
  }
  val lsuOp = new DecodeField[Inst, LsuOpTry.Type] {
    def name = "lsuOp"; def chiselType = LsuOpTry()
    def genTable(i: Inst) = i.p.lsu
    override def default = BP(LsuOpTry.NOP)
  }
  val enJump = new BoolDecodeField[Inst] {
    def name = "enJump"; def genTable(i: Inst) = i.p.jump
    override def default = n
  }
  val valid = new BoolDecodeField[Inst] {
    def name = "valid"; def genTable(i: Inst) = y
    override def default = n
  }

  val fields: Seq[DecodeField[Inst, _ <: Data]] = Seq(aluOp, bfuOp, lsuOp, enJump, valid)
  val table = new DecodeTable(insts, fields)
}

class TryDecode extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val valid  = Output(Bool())
    val aluOp  = Output(ExuAluTry())
    val bfuOp  = Output(ExuBfuTry())
    val lsuOp  = Output(LsuOpTry())
    val enJump = Output(Bool())
  })
  val d = Dec.table.decode(io.inst)
  io.valid  := d(Dec.valid)
  io.aluOp  := d(Dec.aluOp)
  io.bfuOp  := d(Dec.bfuOp)
  io.lsuOp  := d(Dec.lsuOp)
  io.enJump := d(Dec.enJump)
}

// ============================================================
// 3. 手工版 A：逐条匹配 + Mux1H
// ============================================================
class TryMux1H extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val valid  = Output(Bool())
    val aluOp  = Output(ExuAluTry())
    val bfuOp  = Output(ExuBfuTry())
    val lsuOp  = Output(LsuOpTry())
    val enJump = Output(Bool())
  })

  private val opc = io.inst(6, 0)
  private val f3  = io.inst(14, 12)
  private val f7  = io.inst(31, 25)

  private val isAdd  = opc === "b0110011".U && f3 === 0.U && f7 === 0.U
  private val isAddi = opc === "b0010011".U && f3 === 0.U
  private val isLw   = opc === "b0000011".U && f3 === 2.U
  private val isLb   = opc === "b0000011".U && f3 === 0.U
  private val isSw   = opc === "b0100011".U && f3 === 2.U
  private val isSb   = opc === "b0100011".U && f3 === 0.U
  private val isJal  = opc === "b1101111".U
  private val isLui  = opc === "b0110111".U
  private val isBeq  = opc === "b1100011".U && f3 === 0.U
  private val isBne  = opc === "b1100011".U && f3 === 1.U

  io.valid := isAdd || isAddi || isLw || isLb || isSw ||
              isSb  || isJal  || isLui || isBeq || isBne

  io.aluOp  := Mux1H(Seq(isAdd -> ExuAluTry.ADD, isAddi -> ExuAluTry.ADD,
                         isJal -> ExuAluTry.ADD, isLui  -> ExuAluTry.ADD))
  io.bfuOp  := Mux1H(Seq(isBeq -> ExuBfuTry.EQ,  isBne -> ExuBfuTry.NE))
  io.lsuOp  := Mux1H(Seq(isLw  -> LsuOpTry.LW,   isLb  -> LsuOpTry.LB,
                         isSw  -> LsuOpTry.SW,   isSb  -> LsuOpTry.SB))
  io.enJump := isJal
}

// ============================================================
// 4. 手工版 B：switch(opcode) + when(funct3/funct7)
// ============================================================
class TrySwitch extends Module {
  val io = IO(new Bundle {
    val inst   = Input(UInt(32.W))
    val valid  = Output(Bool())
    val aluOp  = Output(ExuAluTry())
    val bfuOp  = Output(ExuBfuTry())
    val lsuOp  = Output(LsuOpTry())
    val enJump = Output(Bool())
  })

  private val opc = io.inst(6, 0)
  private val f3  = io.inst(14, 12)
  private val f7  = io.inst(31, 25)

  // 未匹配的默认值：全 NOP + 不跳 + valid=0
  io.valid  := false.B
  io.aluOp  := ExuAluTry.NOP
  io.bfuOp  := ExuBfuTry.NOP
  io.lsuOp  := LsuOpTry.NOP
  io.enJump := false.B

  private def act(a: ExuAluTry.Type, b: ExuBfuTry.Type, l: LsuOpTry.Type, j: Bool): Unit = {
    io.valid  := true.B
    io.aluOp  := a
    io.bfuOp  := b
    io.lsuOp  := l
    io.enJump := j
  }

  switch (opc) {
    is ("b0110011".U) { when (f3 === 0.U && f7 === 0.U) { act(ExuAluTry.ADD, ExuBfuTry.NOP, LsuOpTry.NOP, false.B) } }
    is ("b0010011".U) { when (f3 === 0.U)              { act(ExuAluTry.ADD, ExuBfuTry.NOP, LsuOpTry.NOP, false.B) } }
    is ("b0000011".U) {
      when      (f3 === 2.U) { act(ExuAluTry.NOP, ExuBfuTry.NOP, LsuOpTry.LW, false.B) }
      .elsewhen (f3 === 0.U) { act(ExuAluTry.NOP, ExuBfuTry.NOP, LsuOpTry.LB, false.B) }
    }
    is ("b0100011".U) {
      when      (f3 === 2.U) { act(ExuAluTry.NOP, ExuBfuTry.NOP, LsuOpTry.SW, false.B) }
      .elsewhen (f3 === 0.U) { act(ExuAluTry.NOP, ExuBfuTry.NOP, LsuOpTry.SB, false.B) }
    }
    is ("b1101111".U) { act(ExuAluTry.ADD, ExuBfuTry.NOP, LsuOpTry.NOP, true.B)  }   // jal
    is ("b0110111".U) { act(ExuAluTry.ADD, ExuBfuTry.NOP, LsuOpTry.NOP, false.B) }   // lui
    is ("b1100011".U) {
      when      (f3 === 0.U) { act(ExuAluTry.NOP, ExuBfuTry.EQ, LsuOpTry.NOP, false.B) }
      .elsewhen (f3 === 1.U) { act(ExuAluTry.NOP, ExuBfuTry.NE, LsuOpTry.NOP, false.B) }
    }
  }
}
*/