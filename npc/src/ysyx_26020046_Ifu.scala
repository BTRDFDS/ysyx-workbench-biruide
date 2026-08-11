import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeBefore())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())
	//pc更新
		val hasChange= RegInit(true.B);
		val pipePc		= RegInit(PcInit(31,2))

		when(in.imme.back===Back.Error || in.imme.back===Back.Jump || (in.imme.ready && ~hasChange)){hasChange := true.B}
		.elsewhen(out.pipe.res === IfuRes.Valid)													{hasChange := false.B}

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
		dontTouch(hasChange)
		dontTouch(isBranch)
		dontTouch(isJal)
		dontTouch(isJalr)
		dontTouch(predBp2)
		dontTouch(predBtb)
		dontTouch(predRcnt)
		dontTouch(predWcnt)
		val ifuPc	= Mux(out.pipe.res === IfuRes.Valid,Cat(out.pipe.pc,0.U(2.W)),0.U(32.W));dontTouch(ifuPc)
		val ifuInst	= Mux(out.pipe.res === IfuRes.Valid,out.pipe.instr,0.U(BitWidth.W));dontTouch(ifuInst)
		val ifuChk = Module(new ysyx_26020046_IfuChk)
		ifuChk.clock	:= clock
		ifuChk.inst		:= ich.ready
		ifuChk.stall	:= out.pipe.res === IfuRes.Null
		ifuChk.unable	:= false.B
		ifuChk.jAb		:= false.B
		ifuChk.jAC		:= false.B
		// ifuChk.unable	:= ich.ready && (in.imme.back === Back.Jump || in.imme.back === Back.Error)
		// ifuChk.jAb		:= in.imme.back === Back.Jump && state === MemStatus.Back
		// ifuChk.jAC		:= (state === MemStatus.Call && ich.ready) =/= (state === MemStatus.Call && ich.ready & (in.imme.back === Back.Ready || in.imme.back === Back.Wait))
	}
}
class ysyx_26020046_IfuChk extends ExtModule{
	val inst	= IO(Input(Bool()))
	val stall	= IO(Input(Bool()))
	val jAb		= IO(Input(Bool()))
	val jAC		= IO(Input(Bool()))
	val unable	= IO(Input(Bool()))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_IfuChk.sv",
	"""
	module ysyx_26020046_IfuChk(
		input logic inst,
		input logic stall,
		input logic jAb	,
		input logic jAC,
		input logic unable,
		input logic clock
	);
	import "DPI-C" function void ifuInst();
	import "DPI-C" function void ifuStall();
	import "DPI-C" function void ifuJaB();
	import "DPI-C" function void ifuJaC();
	import "DPI-C" function void ifuUnable();

	always_ff@(posedge clock)begin
		if(stall)	ifuStall();
		if(inst)	ifuInst();
		if(jAb)		ifuJaB();
		if(jAC)		ifuJaC();
		if(unable)	ifuUnable();
	end
	// always_ff@(posedge inst)ifuInst();
	endmodule
	"""
	)
}