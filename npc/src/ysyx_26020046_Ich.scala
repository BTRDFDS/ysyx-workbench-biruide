import chisel3._
import chisel3.util._
import WidthConsts._
object IchState extends ChiselEnum{val Imm,Out=Value}
class ysyx_26020046_Ich(val Yosys:Boolean=false) extends Module {
	val ifu = IO(Flipped(new InstrBus()))
	val bar = IO(new BurstBus())

	val CacheBit	= 2
	val CacheNum    = 1 << CacheBit
	// val CacheWidth	= 2
	// val CacheSize	= 1 << CacheWidth
	val CacheDone = (1 << CacheWidth)-1

	val data	= Reg(Vec(CacheNum,Vec(CacheSize,UInt(BitWidth.W))))
	val tag		= Reg(Vec(CacheNum, UInt((BitWidth-2-CacheBit-CacheWidth).W)))
	val valid	= RegInit(VecInit(Seq.fill(CacheNum)(false.B)))


	val addrTag		= Wire(UInt((BitWidth-2-CacheBit).W))
	val addrIdx		= Wire(UInt(CacheBit.W))
	val addrOffset = Wire(UInt(CacheWidth.W))

	val burstTag	= Reg(UInt((BitWidth-2-CacheBit).W))
	val burstIdx	= Reg(UInt(CacheBit.W))
	val burstOffset = Reg(UInt(CacheWidth.W))

	addrTag 	:= ifu.addr(BitWidth-2-1,CacheBit+CacheWidth)
	addrIdx 	:= ifu.addr(CacheBit+CacheWidth-1,CacheWidth)
	addrOffset	:= ifu.addr(CacheWidth-1,0)

	val state	= RegInit(IchState.Imm)
	val cnt		= RegInit(0.U(CacheWidth.W))
	switch(state){
		is(IchState.Imm){when(ifu.valid && ~(valid(addrIdx) && tag(addrIdx) === addrTag))					{state := IchState.Out}}
		is(IchState.Out){when((cnt === CacheDone.U) & (bar.res===BurstRes.Done | bar.res===BurstRes.Erro))	{state := IchState.Imm;}}
	}
	switch(state){
		is(IchState.Imm){cnt := 0.U}
		is(IchState.Out){
			when(bar.res === BurstRes.Done || bar.res === BurstRes.Read){
				data(burstIdx)(burstOffset+cnt) := bar.data
				tag(burstIdx)	:= burstTag
				valid(burstIdx)	:= true.B
			}
			when(bar.res === BurstRes.Read){
				cnt := cnt + 1.U
			}
		}
	}
	when(ifu.valid && ~(valid(addrIdx) && tag(addrIdx) === addrTag) && state === IchState.Imm){
		burstTag	:= addrTag
		burstIdx	:= addrIdx
		burstOffset	:= addrOffset
	}
	when(ifu.valid){
		when(valid(addrIdx) && tag(addrIdx) === addrTag){
			ifu.data 	:= data(addrIdx)(addrOffset)
			ifu.ready	:= state === IchState.Imm || (state === IchState.Imm && burstOffset+cnt > addrOffset)
			ifu.error	:= false.B
			bar.valid	:= false.B
			bar.addr	:= 0.U
		}.otherwise{
			bar.valid	:= true.B
			bar.addr	:= Cat(ifu.addr,0.U(2.W))
			ifu.data	:= Mux(bar.res === BurstRes.Read,bar.data,0.U)
			ifu.ready	:= bar.res === BurstRes.Read && cnt === 0.U
			ifu.error	:= bar.res===BurstRes.Erro || (bar.res===BurstRes.Done && cnt =/= CacheDone.U)
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