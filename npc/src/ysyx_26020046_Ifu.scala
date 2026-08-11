import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeBefore())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())
	//pc更新
		val pipePc		= RegInit(PcInit(31,2))

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

	val BtbBits	= 3
	val BtbSize	= 1 << BtbBits
	val btbCnt	= RegInit(0.U(BtbBits.W))
	val btbPc	= RegInit(VecInit(Seq.fill(BtbSize)(0.U((BitWidth-2).W))))
	val btbAddr	= RegInit(VecInit(Seq.fill(BtbSize)(0.U((BitWidth-2).W))))
	val btbMatch= VecInit(btbPc.map(_ === in.imme.addr(31,2))).asUInt
	val btbIndex= PriorityEncoder(btbMatch)
	val btbHit	= btbMatch.orR

	val PerdBits= 2
	val PerdSize= 1 << PerdBits
	val predRcnt= RegInit(0.U(PerdBits.W))
	val predWcnt= RegInit(0.U(PerdBits.W))
	val predBp2	= RegInit(VecInit(Seq.fill(PerdSize)(false.B)))
	val predBtb	= RegInit(VecInit(Seq.fill(PerdSize)(false.B)))

	val isBranch= out.pipe.instr(6,0)===Op.Branch.asUInt
	val isJal	= out.pipe.instr(6,0)===Op.Jal.asUInt
	val isJalr	= out.pipe.instr(6,0)===Op.Ijalr.asUInt

	when(in.imme.back===Back.Error||in.imme.back===Back.Jump){
		pipePc := in.imme.addr(31,2)
	}.elsewhen(in.imme.ready&&ich.ready){
		when((isBranch||isJal||isJalr) && bp2Hit&&btbHit){
					pipePc := btbAddr(btbIndex)
		}.otherwise{pipePc := pipePc+1.U}
	}
	switch(in.imme.back){
		is(Back.Null){when(ich.ready && (isBranch||isJal||isJalr)){
			predBp2(predWcnt) := bp2Hit
			predBtb(predWcnt) := btbHit
			predWcnt := predWcnt + 1.U
		}}
		is(Back.Suce){predRcnt := predRcnt + 1.U}
		is(Back.Jump){
			predWcnt := predRcnt
			val shouldNotJump = Cat(in.imme.pc+1.U,0.U(2.W)) === in.imme.addr
			when(shouldNotJump){
				when(bp2Cnt>=1.U){bp2Cnt := bp2Cnt - 1.U}
			}.otherwise{
				when(bp2Cnt<=3.U){bp2Cnt := bp2Cnt + 1.U}
				btbPc(btbCnt)	:= in.imme.pc
				btbAddr(btbCnt) := in.imme.addr(31,2)
				btbCnt := btbCnt + 1.U
			}

		}
	}

	if(Yosys == false){
		dontTouch(isBranch)
		dontTouch(isJal)
		dontTouch(isJalr)
		dontTouch(predBp2)
		dontTouch(predBtb)
		dontTouch(predRcnt)
		dontTouch(predWcnt)
		dontTouch(btbCnt)
		dontTouch(btbPc)
		dontTouch(btbAddr)
		dontTouch(btbMatch)
		dontTouch(btbIndex)
		dontTouch(btbHit)
		dontTouch(bp2Cnt)
		dontTouch(bp2Hit)
		val ifuPc	= Mux(out.pipe.res === IfuRes.Valid,Cat(out.pipe.pc,0.U(2.W)),0.U(32.W));dontTouch(ifuPc)
		val ifuInst	= Mux(out.pipe.res === IfuRes.Valid,out.pipe.instr,0.U(BitWidth.W));dontTouch(ifuInst)
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= ich.ready && out.pipe.res === IfuRes.Valid && in.imme.ready
		ifuChk.stall	:= out.pipe.res === IfuRes.Null
		ifuChk.jbMiss	:= in.imme.back===Back.Jump
		ifuChk.jbHit	:= in.imme.back===Back.Suce
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