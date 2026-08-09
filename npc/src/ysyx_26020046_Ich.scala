import chisel3._
import chisel3.util._
import WidthConsts._
object IchState extends ChiselEnum{val Imm,Out=Value}
class ysyx_26020046_Ich(val Yosys:Boolean=false) extends Module {
	val ifu = IO(Flipped(new InstrBus()))
	val bar = IO(new BurstBus())
	val lsu	= IO(Flipped(new FecneBus()))

	// val CacheBit	= 2
	// val CacheNum    = 1 << CacheBit
	// val CacheWidth	= 2
	// val CacheSize	= 1 << CacheWidth
	val CacheDone = (1 << CacheWidth)-1

	val data	= Reg(Vec(CacheNum,Vec(CacheSize,UInt(BitWidth.W))))
	val tag		= Reg(Vec(CacheNum, UInt((BitWidth-2-CacheBit-CacheWidth).W)))
	val valid	= RegInit(VecInit(Seq.fill(CacheNum)(false.B)))


	val addrTag		= Wire(UInt((BitWidth-2-CacheBit).W))
	val addrIdx		= Wire(UInt(CacheBit.W))
	val addrOffset	= Wire(UInt(CacheWidth.W))


	addrTag 	:= ifu.addr(BitWidth-2-1,CacheBit+CacheWidth)
	addrIdx 	:= ifu.addr(CacheBit+CacheWidth-1,CacheWidth)
	addrOffset	:= ifu.addr(CacheWidth-1,0)
	dontTouch(addrIdx)
	dontTouch(addrOffset)
	dontTouch(addrTag)

	val pipeValid		= RegInit(false.B)
	val cnt			= RegInit(0.U(CacheWidth.W))
	val burstValid	= RegInit(VecInit(Seq.fill(CacheSize)(false.B)))
	val burstTag	= Reg(UInt((BitWidth-2-CacheBit).W))
	val burstIdx	= Reg(UInt(CacheBit.W))
	val burstOffset = Reg(UInt(CacheWidth.W))
	when(pipeValid){
		bar.valid	:= true.B
		bar.addr	:= Cat(burstTag,burstIdx,burstOffset)
		when(bar.res === BurstRes.Done || bar.res === BurstRes.Read){
			data(burstIdx)(burstOffset+cnt) := bar.data
			burstValid(burstOffset+cnt)		:= true.B
		}
		when(bar.res === BurstRes.Read){cnt := cnt + 1.U}
		when((bar.res===BurstRes.Done&&cnt===CacheDone.U)||bar.res===BurstRes.Erro){pipeValid := false.B}
	}.otherwise{
		bar.valid	:= false.B
		bar.addr	:= 0.U
		cnt			:= 0.U
		foreach(burstValid){_ := false.B}
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
	when(lsu.fenceI){valid.foreach(_ := false.B)}

	if(Yosys == false){
		val ichChk = Module(new ysyx_26020046_IchChk)
		ichChk.hit	:= ifu.valid && ifu.ready
		ichChk.waits:= ifu.valid && ~ifu.ready && pipeValid && burstIdx===addrIdx
		ichChk.miss	:= ifu.valid && ~ifu.ready
		ichChk.clock:= clock
	}

	// val state	= RegInit(IchState.Imm)
	// switch(state){
	// 	is(IchState.Imm){when(ifu.valid && ~(valid(addrIdx) && tag(addrIdx) === addrTag))					{state := IchState.Out}}
	// 	is(IchState.Out){when((cnt === CacheDone.U) & (bar.res===BurstRes.Done | bar.res===BurstRes.Erro))	{state := IchState.Imm}}
	// }
	// switch(state){
	// 	is(IchState.Imm){
	// 		cnt := 0.U
	// 		// when(ifu.valid && ~(valid(addrIdx) && tag(addrIdx) === addrTag) && ~lsu.fenceI){valid(burstIdx) := true.B}
	// 	}
	// 	is(IchState.Out){
	// 		when(bar.res === BurstRes.Read && cnt=== 0.U){
	// 			valid(burstIdx) := true.B
	// 			tag(burstIdx)	:= burstTag
	// 		}
	// 		when(bar.res === BurstRes.Done || bar.res === BurstRes.Read){
	// 			data(burstIdx)(burstOffset+cnt) := bar.data
	// 			tag(burstIdx)	:= burstTag
	// 		}
	// 		when(bar.res === BurstRes.Read){
	// 			cnt := cnt + 1.U
	// 		}
	// 	}
	// }
	// when(ifu.valid && ~(valid(addrIdx) && tag(addrIdx) === addrTag) && state === IchState.Imm){
	// 	burstTag	:= addrTag
	// 	burstIdx	:= addrIdx
	// 	burstOffset	:= addrOffset
	// }
	// when(ifu.valid){
	// 	when(valid(addrIdx) && tag(addrIdx) === addrTag){
	// 		ifu.data 	:= data(addrIdx)(addrOffset)
	// 		ifu.ready	:= state === IchState.Imm || (state === IchState.Out && cnt > addrOffset-burstOffset && addrOffset >= burstOffset)
	// 		ifu.error	:= false.B
	// 		bar.valid	:= false.B
	// 		bar.addr	:= 0.U
	// 	}.otherwise{
	// 		bar.valid	:= true.B
	// 		bar.addr	:= ifu.addr
	// 		ifu.data	:= Mux(bar.res === BurstRes.Read,bar.data,0.U)
	// 		// ifu.ready	:= bar.res === BurstRes.Read && cnt === 0.U
	// 		ifu.ready	:= false.B
	// 		ifu.error	:= bar.res===BurstRes.Erro || (bar.res===BurstRes.Done && cnt =/= CacheDone.U)
	// 	}
	// }.otherwise{
	// 	ifu.ready	:= false.B
	// 	ifu.data	:= 0.U
	// 	ifu.error	:= false.B
	// 	bar.valid	:= false.B
	// 	bar.addr	:= 0.U
	// }
	// when(lsu.fenceI){valid.foreach(_ := false.B)}

	// if(Yosys == false){
	// 	val ichChk = Module(new ysyx_26020046_IchChk)
	// 	ichChk.hit	:= ifu.valid && (valid(addrIdx) && tag(addrIdx) === addrTag)
	// 	ichChk.waits:= ifu.valid && (valid(addrIdx) && tag(addrIdx) === addrTag) && (state === IchState.Out && ~(cnt > addrOffset-burstOffset && addrOffset >= burstOffset))
	// 	ichChk.miss	:= ifu.valid && ~(valid(addrIdx) && tag(addrIdx) === addrTag)
	// 	ichChk.clock:= clock
	// }
}
class ysyx_26020046_IchChk extends ExtModule{
	val hit		= IO(Input(Bool()))
	val waits	= IO(Input(Bool()))
	val miss	= IO(Input(Bool()))
	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_IchChk.sv",
	"""
	module ysyx_26020046_IchChk(
		input logic hit,
		input logic waits,
		input logic miss,
		input logic clock
	);
	import "DPI-C" function void ichHit();
	import "DPI-C" function void ichWait();
	import "DPI-C" function void ichMiss();
	import "DPI-C" function void ichAccess();
	import "DPI-C" function void ichReady();
	import "DPI-C" function void ichPenalty();

	always_ff@(posedge hit)	ichHit();
	always_ff@(posedge waits)ichWait();
	always_ff@(posedge miss)ichMiss();
	always_ff@(posedge clock) begin
		if(hit)  ichAccess();
		if(miss) ichPenalty();
		if(waits)ichReady();
	end
	endmodule
	"""
	)
}