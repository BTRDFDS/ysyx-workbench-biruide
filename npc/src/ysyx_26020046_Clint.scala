import chisel3._
import chisel3.util._
import WidthConsts._


object ClintAddr extends ChiselEnum{
	val mtime	= Value(0xBFF8L.U)
	val mtimeh	= Value(0xBFFCL.U)
}
object ClintStatus extends ChiselEnum{val Idle,Read=Value}//TODO:目前只读,没有,Write
class ysyx_26020046_Clt extends Module{
	val axi4 = IO(Flipped(new Axi4Master()))

	val mtime = RegInit(0.U((2*BitWidth).W))
	mtime := mtime + 1.U
	val status = RegInit(ClintStatus.Idle)
	val addr = RegInit(0.U(16.W))
	switch(status){
	    is(ClintStatus.Idle){when(axi4.arvalid)	{status := ClintStatus.Read}}
		is(ClintStatus.Read){when(axi4.rready)	{status := ClintStatus.Idle}}
	}
	axi4.arready := status === ClintStatus.Idle
	when(status === ClintStatus.Idle & axi4.arvalid){addr := axi4.araddr(15,0)}
	val (clintEnum,clintValid) = ClintAddr.safe(addr)
	axi4.rdata := 0.U
	axi4.rresp := 0.U
	when(clintValid){
		switch(clintEnum){
			is(ClintAddr.mtime)	{axi4.rdata	:= mtime}
			is(ClintAddr.mtimeh){axi4.rdata	:= mtime(63,32)}
		}
	}otherwise{
		switch(status){
			is(ClintStatus.Read){axi4.rresp := 0.U}
			is(ClintStatus.Idle){axi4.rresp := 1.U}
		}
	}
	axi4.arready:= status === ClintStatus.Idle
	axi4.rvalid := status === ClintStatus.Read
	//写通道无效
	axi4.awready	:= false.B
	axi4.wready	:= false.B
	axi4.bvalid	:= false.B
	axi4.bresp	:= 1.U//但凡想写就都是false
	axi4.alast	:= false.B
}