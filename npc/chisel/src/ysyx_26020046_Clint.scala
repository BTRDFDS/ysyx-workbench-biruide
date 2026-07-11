import chisel3._
import chisel3.util._
import WidthConsts._


object ClintAddr extends ChiselEnum{
	val mtime	= Value(0xBFF8L.U)
	val mtimeh	= Value(0xBFFCL.U)
}
object ClintStatus extends ChiselEnum{val Idle,Read=Value}//TODO:目前只读,没有,Write
class ysyx_26020046_Clt extends Module{
	val io = IO(new Bundle{
		val axi4 = Flipped(new Axi4Master())
	})
	val mtime = RegInit(0.U((2*BitWidth).W))
	mtime := mtime + 1.U
	val status = RegInit(ClintStatus.Idle)
	val addr = RegInit(0.U(16.W))
	switch(status){
	    is(ClintStatus.Idle){when(io.axi4.arvalid)	{status := ClintStatus.Read}}
		is(ClintStatus.Read){when(io.axi4.rready)	{status := ClintStatus.Idle}}
	}
	io.axi4.arready := status === ClintStatus.Idle
	when(status === ClintStatus.Idle & io.axi4.arvalid){addr := io.axi4.araddr(15,0)}
	val (clintEnum,clintValid) = ClintAddr.safe(addr)
	io.axi4.rdata := 0.U
	io.axi4.rresp := 0.U
	when(clintValid){
		switch(clintEnum){
			is(ClintAddr.mtime)	{io.axi4.rdata	:= mtime}
			is(ClintAddr.mtimeh){io.axi4.rdata	:= mtime(63,32)}
		}
	}otherwise{
		switch(status){
			is(ClintStatus.Read){io.axi4.rresp := 0.U}
			is(ClintStatus.Idle){io.axi4.rresp := 1.U}
		}
	}
	io.axi4.arready:= status === ClintStatus.Idle
	io.axi4.rvalid := status === ClintStatus.Read
	//写通道无效
	io.axi4.awready	:= false.B
	io.axi4.wready	:= false.B
	io.axi4.bvalid	:= false.B
	io.axi4.bresp	:= 1.U//但凡想写就都是false
}