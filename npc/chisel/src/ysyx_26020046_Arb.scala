import chisel3._
import chisel3.util._
import WidthConsts._

object ArbStatus extends ChiselEnum{val Idle,IfuR,LsuR,LsuW=Value}
object ArbAddr extends ChiselEnum{
	val Clint	= Value(0x02.U(8.W))
	val Sram	= Value(0x0f.U(8.W))
	val Gpio	= Value(0x10.U(8.W))
	val Mrom	= Value(0x20.U(8.W))
	val Psram	= Value(0x80.U(8.W))
}
class ysyx_26020046_Arb extends Module{
	val io = IO(new Bundle{
		val out = new Axi4Master()
		val clt = new Axi4Master()
		val ifu = Flipped(new Axi4Master())
		val lsu = Flipped(new Axi4Master())
	})
	//初始化
	io.ifu.arready	:= false.B
	io.ifu.rdata	:= 0.U
	io.ifu.rresp	:= 0.U
	io.ifu.rvalid	:= false.B
	io.ifu.awready	:= false.B
	io.ifu.wready	:= false.B
	io.ifu.bresp	:= 0.U
	io.ifu.bvalid	:= false.B

	io.lsu.arready	:= false.B
	io.lsu.rdata	:= 0.U
	io.lsu.rresp	:= 0.U
	io.lsu.rvalid	:= false.B
	io.lsu.awready	:= false.B
	io.lsu.wready	:= false.B
	io.lsu.bresp	:= 0.U
	io.lsu.bvalid	:= false.B

	io.out.arvalid	:= false.B
	io.out.rready	:= false.B
	io.out.araddr	:= 0.U
	io.out.awvalid	:= false.B
	io.out.wvalid	:= false.B
	io.out.wdata	:= 0.U
	io.out.wstrb	:= 0.U
	io.out.bready	:= false.B
	io.out.awaddr	:= 0.U

	io.clt.arvalid	:= false.B
	io.clt.rready	:= false.B
	io.clt.araddr	:= 0.U
	io.clt.awvalid	:= false.B
	io.clt.wvalid	:= false.B
	io.clt.wdata	:= 0.U
	io.clt.wstrb	:= 0.U
	io.clt.bready	:= false.B
	io.clt.awaddr	:= 0.U

	val status		= RegInit(ArbStatus.Idle)
	val backValid	= WireInit(Bool(),false.B)
	val addr 		= RegInit(0.U(8.W))
	switch(status){
		is(ArbStatus.Idle){
			when(io.lsu.arvalid)	{status := ArbStatus.LsuR}
			.elsewhen(io.lsu.awvalid){status := ArbStatus.LsuW}
			.elsewhen(io.ifu.arvalid){status := ArbStatus.IfuR}
		}
		is(ArbStatus.LsuR){when(io.lsu.rready & backValid){status := ArbStatus.Idle}}
		is(ArbStatus.LsuW){when(io.lsu.bready & backValid){status := ArbStatus.Idle}}
		is(ArbStatus.IfuR){when(io.ifu.rready & backValid){status := ArbStatus.Idle}}
	}
	when(status === ArbStatus.Idle){
		when(io.lsu.arvalid)		{addr := io.lsu.araddr(31,24)}
		.elsewhen(io.lsu.awvalid)	{addr := io.lsu.awaddr(31,24)}
		.elsewhen(io.ifu.arvalid)	{addr := io.ifu.araddr(31,24)}
	}
	val (addrEnum,addrValid) = ArbAddr.safe(addr)
	when(addrValid){
		switch(status){
			is(ArbStatus.LsuR){
				when(addrEnum === ArbAddr.Clint){io.lsu <> io.clt}
				.otherwise{io.lsu <> io.out}
			}
			is(ArbStatus.LsuW){io.lsu <> io.out}
			is(ArbStatus.IfuR){io.ifu <> io.out}
		}
	}
	.otherwise{
		when(status =/= ArbStatus.Idle){stop()}
		switch(status){
			is(ArbStatus.LsuR){io.lsu.rresp := 1.U}
			is(ArbStatus.LsuW){io.lsu.bresp := 1.U}
			is(ArbStatus.IfuR){io.ifu.rresp := 1.U}
		}
	}
}
