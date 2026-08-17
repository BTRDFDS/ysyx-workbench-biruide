import chisel3._
import chisel3.util._
import WidthConsts._


object ClintAddr extends ChiselEnum{
	val Mtime	= Value(0xBFF8L.U)
	val Mtimeh	= Value(0xBFFCL.U)
}
object ClintStatus extends ChiselEnum{val Idle,Read=Value}//TODO:目前只读,没有,Write
class ysyx_26020046_Clt extends Module{
	val lsu = IO(Flipped(new MemBus()))
	val bar = IO(new MemBus())


	val mtime  = RegInit(0.U((BitWidth).W))
	val mtimeh = RegInit(0.U((BitWidth).W))
	mtime  := mtime + 1.U
	mtimeh := Mux(mtime === (Fill(BitWidth,1.U)),mtimeh + 1.U,mtimeh)

	bar.wdata := lsu.wdata
	bar.wstrb := lsu.wstrb
	bar.addr  := lsu.addr
	bar.write := lsu.write
	lsu.rdata := 0.U
	when(lsu.size =/= 0b11.U && lsu.addr(31,24) === 0x02.U){
		bar.size := 0b11.U
		lsu.ready := true.B
		val (clintEnum,clintValid) = ClintAddr.safe(lsu.addr(15,0))
		when(clintValid){switch(clintEnum){
			is(ClintAddr.Mtime)	{lsu.rdata:= mtime }
			is(ClintAddr.Mtimeh){lsu.rdata:= mtimeh}
		}}
		lsu.error := ~clintValid || lsu.write
	}.otherwise{
		bar.size := lsu.size
		lsu.rdata:= bar.rdata
		lsu.ready:= bar.ready
		lsu.error:= bar.error
	}

	// when(lsu.size =/= 0b11.U && lsu.addr(31,24) === 0x02.U){
	// 	printf("clint addr:%x %d %d\n",lsu.addr,Cat(mtimeh,mtime),lsu.rdata)
	// }

}