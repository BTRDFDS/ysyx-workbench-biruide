import chisel3._
import chisel3.util._
import WidthConsts._
class ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeIdIf())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())

	// val immePc		= RegNext(in.imme.pc	,0.U)
	// val immeAddr	= RegNext(in.imme.addr	,0.U)
	// val immeReloca	= RegNext(in.imme.reloca,false.B)
	// val immeUpdate	= RegNext(in.imme.update,IfuUpdate.Null)
	val immePc		= in.imme.pc
	val immeAddr	= in.imme.addr
	val immeReloca	= in.imme.reloca
	val immeUpdate	= in.imme.update

	//pc更新
		val pipePc		= RegInit(PcInit(31,2))
		// val pipeValid	= RegNext(!in.imme.reloca,true.B)
		val pipeValid	= true.B

		ich.addr	:= pipePc
		ich.valid	:= pipeValid

		out.pipe.instr	:= ich.data
		out.pipe.pc		:= pipePc

		when(immeReloca&&immeAddr(1,0)=/=0.U(2.W))	{out.pipe.res := IfuRes.Un4b}
		.elsewhen(ich.ready&&pipeValid)		{out.pipe.res := Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
		.otherwise							{out.pipe.res := IfuRes.Null}

//////////////////////////////////////////////////////////////////////////////////////////////



	val BrBits	= 1
	val BrSize	= 1 << BrBits
	val brCnt	= RegInit(0.U(BrBits.W))
	val brPc	= RegInit(VecInit(Seq.fill(BrSize)(0.U((BitWidth-2).W))))
	val brAddr	= RegInit(VecInit(Seq.fill(BrSize)(0.U((BitWidth-2).W))))
	val brMatch = VecInit(brPc.map(_ === pipePc)).asUInt
	val brIndex = PriorityEncoder(brMatch)
	val brHit	= brMatch.orR

	// when(immeReloca){
	// 	pipePc := immeAddr(31,2)
	// }.elsewhen(in.imme.ready&&ich.ready){
	// 	pipePc := MuxCase(pipePc+1.U,Seq(
	// 		brHit	-> brAddr(brIndex),
	// 		jalHit	-> jalAddr(jalIndex),
	// 		JalrHit	-> jalrAddr
	// 	))
	// }
	pipePc := Mux(immeReloca,immeAddr(31,2),Mux(brHit,brAddr(brIndex),pipePc+1.U))
	when(immeUpdate){
		brPc(brCnt)	:= immePc
		brAddr(brCnt) := immeAddr(31,2)
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