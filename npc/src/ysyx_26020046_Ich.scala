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

	addrTag := ifu.addr(BitWidth-2-1,CacheBit)
	addrIdx := ifu.addr(CacheBit-1,0)
	when(ifu.valid){
		when(valid(addrIdx) && tag(addrIdx) === addrTag){
			ifu.data 	:= data(addrIdx)
			ifu.ready	:= true.B
			ifu.error	:= false.B
			bar.valid	:= false.B
			bar.addr	:= 0.U
		}.otherwise{
			bar.valid	:= true.B
			bar.addr	:= Cat(addrTag,addrIdx,0.U(2.W))
			ifu.data	:= Mux(bar.ready,bar.data,0.U)
			ifu.ready	:= bar.ready
			ifu.error	:= bar.error
			when(bar.ready){
				data(addrIdx)	:= bar.data
				tag(addrIdx)	:= addrTag
				valid(addrIdx)	:= true.B
			}
		}
	}.otherwise{
		ifu.ready	:= false.B
		ifu.data	:= 0.U
		ifu.error	:= false.B
		bar.valid	:= false.B
		bar.addr	:= 0.U
	}

	if(Yosys == false){
		val ichChk = Module(new ysyx_26020046_IchChk)
		ichChk.hit	:= ifu.valid && (valid(addrIdx) && tag(addrIdx) === addrTag)
		ichChk.miss	:= ifu.valid && ~(valid(addrIdx) && tag(addrIdx) === addrTag)
	}
}
class ysyx_26020046_IchChk extends ExtModule{
	val hit		= IO(Input(Bool()))
	val miss	= IO(Input(Bool()))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_IchChk.sv",
	"""
	module ysyx_26020046_IchChk(
		input logic hit,
		input logic miss,
		input logic clock
	);
	import "DPI-C" function void ichHit();
	import "DPI-C" function void ichMiss();
	import "DPI-C" function void ichAccess();
	import "DPI-C" function void ichPenalty();

	always_ff@(posedge hit)	ichHit();
	always_ff@(posedge miss)ichMiss();
	always_ff@(posedge clock) begin
		if(hit) ichAccess();
		if(miss)ichPenalty();
	end
	endmodule
	"""
	)
}