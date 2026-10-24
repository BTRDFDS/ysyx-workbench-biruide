import chisel3._
import chisel3.util._
import WidthConsts._
class ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeIdIf())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())
	//pc更新
		val pipePc		= RegInit(PcInit(31,2))
		ich.addr	:= pipePc
		ich.valid	:= true.B
		out.pipe.instr	:= ich.data
		out.pipe.pc		:= pipePc
		// when(in.imme.reloca&&in.imme.addr(1,0)=/=0.U(2.W))	{out.pipe.res := IfuRes.Un4b}
		// .elsewhen(ich.ready&&pipeValid)		{out.pipe.res := Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
		// .otherwise							{out.pipe.res := IfuRes.Null}
		out.pipe.res := Mux(in.imme.reloca && (in.imme.addr(0) || in.imme.addr(0)),IfuRes.Un4b,Mux(ich.ready,Mux(ich.error,IfuRes.Fall,IfuRes.Valid),IfuRes.Null))
//////////////////////////////////////////////////////////////////////////////////////////////



	val BrBits	= 1
	val BrSize	= 1 << BrBits
	val brCnt	= RegInit(0.U(BrBits.W))
	val brPc	= RegInit(VecInit(Seq.fill(BrSize)(0.U((BitWidth-2).W))))
	val brAddr	= RegInit(VecInit(Seq.fill(BrSize)(0.U((BitWidth-2).W))))
	val brMatch = VecInit(brPc.map(_ === pipePc)).asUInt
	val brIndex = PriorityEncoder(brMatch)
	val brHit	= brMatch.orR

	when(in.imme.reloca || (in.imme.ready&&ich.ready)){pipePc := Mux(in.imme.reloca,in.imme.addr(31,2),Mux(brHit,brAddr(brIndex),pipePc+1.U))}
	when(in.imme.update){
		brPc(brCnt)	:= in.imme.pc
		brAddr(brCnt) := in.imme.addr(31,2)
		brCnt := brCnt + 1.U
	}
	if(Yosys == false){
		dontTouch(brCnt)
		dontTouch(brPc)
		dontTouch(brAddr)
		// dontTouch(jalCnt)
		// dontTouch(jalPc)
		// dontTouch(jalAddr)
		// dontTouch(jalrPc)
		// dontTouch(jalrAddr)
	}
}