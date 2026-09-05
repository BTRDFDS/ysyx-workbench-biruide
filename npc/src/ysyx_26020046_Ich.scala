import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Ich(val Yosys:Boolean=false) extends Module {
	val ifu = IO(Flipped(new InstrBus()))
	val bar = IO(new BurstBus())
	val exu	= IO(Flipped(new FecneBus()))

	// val CacheBit	= 2
	// val CacheNum    = 1 << CacheBit
	// val CacheWidth	= 2
	// val CacheSize	= 1 << CacheWidth
	val CacheDone = (1 << CacheWidth)-1

	val data	= Reg(Vec(CacheNum,Vec(CacheSize,UInt(BitWidth.W))))
	val tag		= Reg(Vec(CacheNum, UInt((BitWidth-2-CacheBit-CacheWidth).W)))
	val valid	= RegInit(VecInit(Seq.fill(CacheNum)(false.B)))


	val addrTag		= Wire(UInt((BitWidth-2-CacheBit-CacheWidth).W))
	val addrIdx		= Wire(UInt(CacheBit.W))
	val addrOffset	= Wire(UInt(CacheWidth.W))


	addrTag 	:= ifu.addr(BitWidth-2-1,CacheBit+CacheWidth)
	addrIdx 	:= ifu.addr(CacheBit+CacheWidth-1,CacheWidth)
	addrOffset	:= ifu.addr(CacheWidth-1,0)

	val pipeValid	= RegInit(false.B)//拉取状态机valid
	val cnt			= RegInit(0.U(CacheWidth.W))
	val burstValid	= RegInit(VecInit(Seq.fill(CacheSize)(false.B)))
	val burstTag	= Reg(UInt((BitWidth-2-CacheBit-CacheWidth).W))
	val burstIdx	= Reg(UInt(CacheBit.W))
	val burstOffset = Reg(UInt(CacheWidth.W))
	when(pipeValid){
		bar.valid	:= true.B
		bar.addr	:= Cat(burstTag,burstIdx,burstOffset)
		when(bar.res === BurstRes.Done || bar.res === BurstRes.Read){
			data(burstIdx)(burstOffset+cnt) := bar.data
			burstValid(burstOffset+cnt)		:= true.B
		}
		// when(bar.res === BurstRes.Read){cnt := cnt + 1.U}
		cnt := Mux1H(Seq(
			(bar.res === BurstRes.Read) -> (cnt + 1.U),
			(bar.res === BurstRes.Done) -> (0.U),
			(bar.res === BurstRes.Erro) -> (0.U),
			(bar.res === BurstRes.Idle) -> (cnt),
		))
		when((bar.res===BurstRes.Done||cnt===CacheDone.U)||bar.res===BurstRes.Erro){pipeValid := false.B}
	}.otherwise{
		bar.valid	:= false.B
		bar.addr	:= 0.U
		cnt			:= 0.U
		burstValid.foreach(_ := false.B)
	}
	ifu.ready	:= false.B
	ifu.data	:= data(addrIdx)(addrOffset)
	ifu.error := bar.res===BurstRes.Erro || (pipeValid && bar.res===BurstRes.Done && cnt =/= CacheDone.U)
	when(ifu.valid){
		when(pipeValid){
			when(burstIdx===addrIdx){ifu.ready	:= tag(addrIdx) === addrTag && burstValid(addrOffset)}
			.otherwise				{ifu.ready	:= tag(addrIdx) === addrTag && valid(addrIdx)}
		}.otherwise{
		    when(valid(addrIdx) && tag(addrIdx) === addrTag){ifu.ready	:= true.B}
			.otherwise{
				burstIdx		:= addrIdx
				burstTag		:= addrTag
				burstOffset		:= addrOffset
				pipeValid		:= true.B
				valid(addrIdx)	:= true.B
				tag(addrIdx)	:= addrTag
			}
		}
	}
	when(exu.fenceI){valid.foreach(_ := false.B)}

	if(Yosys == false){
		val ichChk = Module(new ysyx_26020046_IchChk)
		dontTouch(addrIdx)
		dontTouch(addrOffset)
		dontTouch(addrTag)
		ichChk.hit	:=  ifu.ready//ifu.valid && 
		ichChk.miss := ~ifu.ready//ifu.valid && 
		ichChk.clock:= clock
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

	always_ff@(posedge hit)	ichHit();
	always_ff@(negedge miss)ichMiss();
	endmodule
	"""
	)
}