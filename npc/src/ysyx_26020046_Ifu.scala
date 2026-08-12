import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeIdIf())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())
	//pc更新
		val pipePc	= RegInit(PcInit(31,2))

		ich.valid	:= true.B
		ich.addr	:= pipePc

		out.pipe.instr	:= ich.data
		out.pipe.pc		:= pipePc

		when(in.imme.addr(1,0)=/=0.U(2.W))	{out.pipe.res := IfuRes.Un4b}
		.elsewhen(ich.ready)	{out.pipe.res := Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
		.otherwise							{out.pipe.res := IfuRes.Null}

//////////////////////////////////////////////////////////////////////////////////////////////
	val bp2Cnt	= RegInit(2.U(2.W))
	val bp2Hit = bp2Cnt >= 2.U

	val BtbBrBits	= 3
	val BtbBrSize	= 1 << BtbBrBits
	val btbBrCnt	= RegInit(0.U(BtbBrBits.W))
	val btbBrPc	= RegInit(VecInit(Seq.fill(BtbBrSize)(0.U((BitWidth-2).W))))
	val btbBrAddr	= RegInit(VecInit(Seq.fill(BtbBrSize)(0.U((BitWidth-2).W))))
	val btbBrMatch= VecInit(btbBrPc.map(_ === pipePc)).asUInt
	val btbBrIndex= PriorityEncoder(btbBrMatch)
	val btbBrHit	= btbBrMatch.orR

	val BtbJlBits	= 2
	val BtbJlSize	= 1 << BtbJlBits
	val btbJlCnt	= RegInit(0.U(BtbJlBits.W))
	val btbJlPc	= RegInit(VecInit(Seq.fill(BtbJlSize)(0.U((BitWidth-2).W))))
	val btbJlAddr	= RegInit(VecInit(Seq.fill(BtbJlSize)(0.U((BitWidth-2).W))))
	val btbJlMatch= VecInit(btbJlPc.map(_ === pipePc)).asUInt
	val btbJlIndex= PriorityEncoder(btbJlMatch)
	val btbJlHit	= btbJlMatch.orR

	val isBranch= out.pipe.instr(6,0)===Op.Branch.asUInt
	val isJal	= out.pipe.instr(6,0)===Op.Jal.asUInt
	val isJalr	= out.pipe.instr(6,0)===Op.Ijalr.asUInt

	when(in.imme.jump){
		pipePc := in.imme.addr(31,2)
	}.elsewhen(in.imme.ready&&ich.ready){
		when((isBranch) &&btbBrHit && bp2Hit)	{pipePc := btbBrAddr(btbBrIndex)}
		.elsewhen(isJal &&btbJlHit)				{pipePc := btbJlAddr(btbJlIndex)}
		.otherwise								{pipePc := pipePc+1.U}
	}
	when(in.imme.jump){
		when(in.imme.btbb){
			val shouldNotJump = in.imme.pc+1.U === in.imme.addr(31,2)
			when(shouldNotJump){when(bp2Cnt>=1.U){bp2Cnt := bp2Cnt - 1.U}
			}.otherwise{		when(bp2Cnt<=2.U){bp2Cnt := bp2Cnt + 1.U}
				btbBrPc(btbBrCnt)	:= in.imme.pc
				btbBrAddr(btbBrCnt) := in.imme.addr(31,2)
				btbBrCnt			:= btbBrCnt + 1.U
			}
		}
		when(in.imme.btbj){
			btbJlPc(btbJlCnt)	:= in.imme.pc
			btbJlAddr(btbJlCnt) := in.imme.addr(31,2)
			btbJlCnt			:= btbJlCnt + 1.U
		}
	}
	if(Yosys == false){
		dontTouch(isBranch)
		dontTouch(isJal)
		dontTouch(isJalr)
		dontTouch(btbBrCnt)
		dontTouch(btbBrPc)
		dontTouch(btbBrAddr)
		dontTouch(btbBrMatch)
		dontTouch(btbBrIndex)
		dontTouch(btbBrHit)
		dontTouch(btbJlCnt)
		dontTouch(btbJlPc)
		dontTouch(btbJlAddr)
		dontTouch(btbJlMatch)
		dontTouch(btbJlIndex)
		dontTouch(btbJlHit)
		dontTouch(bp2Cnt)
		dontTouch(bp2Hit)
		val ifuPc	= Mux(out.pipe.res === IfuRes.Valid,Cat(out.pipe.pc,0.U(2.W)),0.U(32.W));dontTouch(ifuPc)
		val ifuInst	= Mux(out.pipe.res === IfuRes.Valid,out.pipe.instr,0.U(BitWidth.W));dontTouch(ifuInst)
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= ich.ready && out.pipe.res === IfuRes.Valid && in.imme.ready
		ifuChk.stall	:= out.pipe.res === IfuRes.Null
		ifuChk.jbMiss	:= in.imme.jump && (in.imme.btbb || in.imme.btbj)
		ifuChk.jbHit	:= in.imme.ready && ich.ready && (isBranch || isJal)// || isJalr
	}
}
class ysyx_26020046_IfuChk extends ExtModule{
	val inst	= IO(Input(Bool()))
	val stall	= IO(Input(Bool()))
	val jbMiss	= IO(Input(Bool()))
	val jbHit	= IO(Input(Bool()))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_IfuChk.sv",
	"""
	module ysyx_26020046_IfuChk(
		input logic inst,
		input logic stall,
		input logic jbMiss,
		input logic jbHit,
		input logic clock
	);
	import "DPI-C" function void ifuInst();
	import "DPI-C" function void ifuStall();
	import "DPI-C" function void ifuJbMiss();
	import "DPI-C" function void ifuJbHit();

	always_ff@(posedge clock)begin
		if(stall)	ifuStall();
		if(inst)	ifuInst();
		if(jbMiss)	ifuJbMiss();
		if(jbHit)	ifuJbHit();
	end
	endmodule
	"""
	)
}