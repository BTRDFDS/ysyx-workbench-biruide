import chisel3._
import chisel3.util._
import WidthConsts._
class ifu(val PcInit:UInt,val Yosys:Boolean=false) extends Module{
	val in	= IO(new Bundle{val imme = Flipped(new ImmeIdIf())})
	val out = IO(new Bundle{val pipe = new PipeIfId()})
	val ich	= IO(new InstrBus())

	val immePc		= RegNext(in.imme.pc	,0.U)
	val immeAddr	= RegNext(in.imme.addr	,0.U)
	val immeReloca	= RegNext(in.imme.reloca,false.B)
	val immeUpdate	= RegNext(in.imme.update,IfuUpdate.Null)

	//pc更新
		val pipePc		= RegInit(PcInit(31,2))
		val pipeValid	= RegNext(!in.imme.reloca,true.B)

		ich.addr	:= pipePc
		ich.valid	:= pipeValid

		out.pipe.instr	:= ich.data
		out.pipe.pc		:= pipePc

		when(immeReloca&&immeAddr(1,0)=/=0.U(2.W))	{out.pipe.res := IfuRes.Un4b}
		.elsewhen(ich.ready&&pipeValid)		{out.pipe.res := Mux(ich.error,IfuRes.Fall,IfuRes.Valid)}
		.otherwise							{out.pipe.res := IfuRes.Null}

//////////////////////////////////////////////////////////////////////////////////////////////



	val BrBits	= 2
	val BrSize	= 1 << BrBits
	val brCnt	= RegInit(0.U(BrBits.W))
	val brPc	= RegInit(VecInit(Seq.fill(BrSize)(0.U((BitWidth-2).W))))
	val brAddr	= RegInit(VecInit(Seq.fill(BrSize)(0.U((BitWidth-2).W))))
	val brMatch = VecInit(brPc.map(_ === pipePc)).asUInt
	val brIndex = PriorityEncoder(brMatch)
	val brHit	= brMatch.orR

	val JalBits = 1
	val JalSize = 1 << JalBits
	val jalCnt	= RegInit(0.U(JalBits.W))
	val jalPc	= RegInit(VecInit(Seq.fill(JalSize)(0.U((BitWidth-2).W))))
	val jalAddr	= RegInit(VecInit(Seq.fill(JalSize)(0.U((BitWidth-2).W))))
	val jalMatch= VecInit(jalPc.map(_ === pipePc)).asUInt
	val jalIndex= PriorityEncoder(jalMatch)
	val jalHit	= jalMatch.orR
	
	val jalrPc	= RegInit(0.U((BitWidth-2).W))
	val jalrAddr= RegInit(0.U((BitWidth-2).W))
	val JalrHit	= jalrPc === pipePc	

	when(immeReloca){
		pipePc := immeAddr(31,2)
	}.elsewhen(in.imme.ready&&ich.ready){
		pipePc := MuxCase(pipePc+1.U,Seq(
			brHit	-> brAddr(brIndex),
			jalHit	-> jalAddr(jalIndex),
			JalrHit	-> jalrAddr
		))
	}
	when(immeUpdate===IfuUpdate.Branch){
		brPc(brCnt)	:= immePc
		brAddr(brCnt) := immeAddr(31,2)
		brCnt := brCnt + 1.U
	}
	when(immeUpdate===IfuUpdate.Jal){
		jalPc(jalCnt)	:= immePc
		jalAddr(jalCnt) := immeAddr(31,2)
		jalCnt := jalCnt + 1.U
	}
	when(immeUpdate===IfuUpdate.Jalr){
		jalrPc	:= immePc
		jalrAddr:= immeAddr(31,2)
	}
	if(Yosys == false){
		dontTouch(brCnt)
		dontTouch(brPc)
		dontTouch(brAddr)
		dontTouch(jalCnt)
		dontTouch(jalPc)
		dontTouch(jalAddr)
		dontTouch(jalrPc)
		dontTouch(jalrAddr)
	}
}