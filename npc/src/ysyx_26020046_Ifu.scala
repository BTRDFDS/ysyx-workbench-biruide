import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeIdIf())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())
	//pc更新
		val pipePc	= RegInit(PcInit(31,2))

		ich.addr	:= pipePc

		out.pipe.instr	:= ich.data
		out.pipe.pc		:= pipePc

		when(in.imme.addr(1,0)=/=0.U(2.W))	{out.pipe.res := IfuRes.Un4b}
		.elsewhen(ich.ready)				{out.pipe.res := Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
		.otherwise							{out.pipe.res := IfuRes.Null}

//////////////////////////////////////////////////////////////////////////////////////////////
	val bp2Cnt	= RegInit(2.U(2.W))
	val bp2Hit = bp2Cnt >= 2.U

	val BtbBits	= 3
	val BtbSize	= 1 << BtbBits
	val btbCnt	= RegInit(0.U(BtbBits.W))
	val btbPc	= RegInit(VecInit(Seq.fill(BtbSize)(0.U((BitWidth-2).W))))
	val btbAddr	= RegInit(VecInit(Seq.fill(BtbSize)(0.U((BitWidth-2).W))))
	val btbMatch= VecInit(btbPc.map(_ === pipePc)).asUInt
	val btbIndex= PriorityEncoder(btbMatch)
	val btbHit	= btbMatch.orR

	val isBranch= out.pipe.instr(6,0)===Op.Branch.asUInt
	val isJal	= out.pipe.instr(6,0)===Op.Jal.asUInt
	val isJalr	= out.pipe.instr(6,0)===Op.Ijalr.asUInt

	val jalNoStop = RegInit(true.B)
	when(in.imme.jump || in.imme.pcChg){jalNoStop := true.B}
	.elsewhen(in.imme.ready&&ich.ready&&jalNoStop&&(isJalr||(isJal && ~btbHit))){jalNoStop := false.B}
	when(in.imme.pcChg){
		pipePc := in.imme.addr(31,2)
	}.elsewhen(in.imme.ready&&ich.ready&&(jalNoStop || in.imme.jump)){
		when(((isBranch&&bp2Hit) || isJal)&&btbHit){//||isJalr
					pipePc := btbAddr(btbIndex)
		}.otherwise{pipePc := pipePc+1.U}
	}
	when(in.imme.bpChg){
		when(in.imme.jump){	when(bp2Cnt<=2.U){bp2Cnt := bp2Cnt + 1.U}}
		.otherwise{			when(bp2Cnt>=1.U){bp2Cnt := bp2Cnt - 1.U}}
	}
	when(in.imme.btChg && in.imme.addr(31,2)=/=pipePc){
		btbPc(btbCnt)	:= in.imme.pc
		btbAddr(btbCnt) := in.imme.addr(31,2)
		btbCnt := btbCnt + 1.U
	}
	out.pipe.bpJump	:= bp2Hit || isJal || isJalr
	out.pipe.btbGet := btbHit
	if(Yosys == false){
		dontTouch(isBranch)
		dontTouch(isJal)
		dontTouch(isJalr)
		dontTouch(btbCnt)
		dontTouch(btbPc)
		dontTouch(btbAddr)
		dontTouch(btbMatch)
		dontTouch(btbIndex)
		dontTouch(btbHit)
		dontTouch(bp2Cnt)
		dontTouch(bp2Hit)
	}
}