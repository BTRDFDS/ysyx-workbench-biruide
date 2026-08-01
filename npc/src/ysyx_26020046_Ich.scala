import chisel3._
import chisel3.util._
import WidthConsts._
// class Block(val CacheBit: Int=4) extends Bundle{
//     val data    = UInt(BitWidth.W)
//     val tag     = UInt((BitWidth-2-CacheBit).W)
//     val valid   = Bool()
// }
class ysyx_26020046_Ich(val Yosys:Boolean=false) extends Module {
	val ifu = IO(Flipped(new LoaderBus(BitWidth-2)))
	val bar = IO(new LoaderBus())

	val CacheBit   = 4
	val CacheNum    = 1 << CacheBit

	val data	= Reg(Vec(CacheNum, UInt(BitWidth.W)))
	val tag		= Reg(Vec(CacheNum, UInt((BitWidth-2-CacheBit).W)))
	val valid	= RegInit(VecInit(Seq.fill(CacheNum)(false.B)))


	val addrTag = Wire(UInt((BitWidth-2-CacheBit).W))
	val addrIdx = Wire(UInt(CacheBit.W))

	addrTag := ifu.addr(BitWidth-2,CacheBit)
	addrIdx := ifu.addr(CacheBit-1,0)
	when(ifu.valid){
		when(valid(addrIdx) && tag(addrIdx) === addrTag){
			ifu.data 	:= data(addrIdx)
			ifu.ready	:= true.B
			bar.valid	:= false.B
			bar.addr	:= 0.U
		}.otherwise{
			bar.valid	:= true.B
			bar.addr	:= Cat(addrTag,addrIdx,0.U(2.W))
			ifu.data	:= Mux(bar.ready,bar.data,0.U)
			ifu.ready	:= bar.ready
			when(bar.ready){
				data(addrIdx)	:= bar.data
				tag(addrIdx)	:= addrTag
				valid(addrIdx)	:= true.B
			}
		}
	}.otherwise{
		ifu.ready	:= false.B
		ifu.data	:= 0.U
		bar.valid	:= false.B
		bar.addr	:= 0.U
	}
}