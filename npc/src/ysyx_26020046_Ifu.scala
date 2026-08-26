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

	when(in.imme.reloca){
		pipePc := in.imme.addr(31,2)
	}.elsewhen(in.imme.ready&&ich.ready){
		pipePc := MuxCase(pipePc+1.U,Seq(
			brHit	-> brAddr(brIndex),
			jalHit	-> jalAddr(jalIndex),
			JalrHit	-> jalrAddr
		))
	}
	when(in.imme.update===IfuUpdate.Branch){
		brPc(brCnt)	:= in.imme.pc
		brAddr(brCnt) := in.imme.addr(31,2)
		brCnt := brCnt + 1.U
	}
	when(in.imme.update===IfuUpdate.Jal){
		jalPc(jalCnt)	:= in.imme.pc
		jalAddr(jalCnt) := in.imme.addr(31,2)
		jalCnt := jalCnt + 1.U
	}
	when(in.imme.update===IfuUpdate.Jalr){
		jalrPc	:= in.imme.pc
		jalrAddr:= in.imme.addr(31,2)
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