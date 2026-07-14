import chisel3._
import chisel3.util._
import WidthConsts._

object ArbStatus extends ChiselEnum{val Idle,IfuR,LsuR,LsuW=Value}
object ArbAddr extends ChiselEnum{val Clint,Out,Error=Value}
class ysyx_26020046_Arb extends Module{
	val out = IO(new Axi4Master())
	val clt = IO(new Axi4Master())
	val ifu = IO(Flipped(new Axi4Master()))
	val lsu = IO(Flipped(new Axi4Master()))
	//初始化
	ifu.arready	:= false.B
	ifu.rdata	:= 0.U
	ifu.rresp	:= 0.U
	ifu.rvalid	:= false.B
	ifu.awready	:= false.B
	ifu.wready	:= false.B
	ifu.bresp	:= 0.U
	ifu.bvalid	:= false.B

	lsu.arready	:= false.B
	lsu.rdata	:= 0.U
	lsu.rresp	:= 0.U
	lsu.rvalid	:= false.B
	lsu.awready	:= false.B
	lsu.wready	:= false.B
	lsu.bresp	:= 0.U
	lsu.bvalid	:= false.B

	out.arvalid	:= false.B
	out.rready	:= false.B
	out.araddr	:= 0.U
	out.awvalid	:= false.B
	out.wvalid	:= false.B
	out.wdata	:= 0.U
	out.wstrb	:= 0.U
	out.bready	:= false.B
	out.awaddr	:= 0.U

	clt.arvalid	:= false.B
	clt.rready	:= false.B
	clt.araddr	:= 0.U
	clt.awvalid	:= false.B
	clt.wvalid	:= false.B
	clt.wdata	:= 0.U
	clt.wstrb	:= 0.U
	clt.bready	:= false.B
	clt.awaddr	:= 0.U

	val status		= RegInit(ArbStatus.Idle)
	val backValid	= WireInit(Bool(),false.B)
	val addr 		= RegInit(0.U(8.W))
	switch(status){
		is(ArbStatus.Idle){
			when(lsu.arvalid)		{status := ArbStatus.LsuR}
			.elsewhen(lsu.awvalid)	{status := ArbStatus.LsuW}
			.elsewhen(ifu.arvalid)	{status := ArbStatus.IfuR}
		}
		is(ArbStatus.LsuR){when(lsu.rready & backValid){status := ArbStatus.Idle}}
		is(ArbStatus.LsuW){when(lsu.bready & backValid){status := ArbStatus.Idle}}
		is(ArbStatus.IfuR){when(ifu.rready & backValid){status := ArbStatus.Idle}}
	}
	when(status === ArbStatus.Idle){
		when(lsu.arvalid)		{addr := lsu.araddr(31,24)}
		.elsewhen(lsu.awvalid)	{addr := lsu.awaddr(31,24)}
		.elsewhen(ifu.arvalid)	{addr := ifu.araddr(31,24)}
	}
	// val (addrEnum,addrValid) = ArbAddr.safe(addr)
	val addrValid = 
		(addr === 0x02.U(8.W)) ||
		(addr === 0x0f.U(8.W)) ||
		(addr === 0x20.U(8.W)) ||
		(addr(7:5)===0b100.U(3.W))
	when(addrValid){
		switch(status){
			is(ArbStatus.LsuR){
				when(addrEnum === ArbAddr.Clint){lsu <> clt}
				.otherwise{lsu <> out}
			}
			is(ArbStatus.LsuW){lsu <> out}
			is(ArbStatus.IfuR){ifu <> out}
		}
	}
	.otherwise{
		when(status =/= ArbStatus.Idle){stop()}
		switch(status){
			is(ArbStatus.LsuR){lsu.rresp := 1.U}
			is(ArbStatus.LsuW){lsu.bresp := 1.U}
			is(ArbStatus.IfuR){ifu.rresp := 1.U}
		}
	}
	switch(status){
		is(ArbStatus.LsuR){backValid := Mux(addrEnum === ArbAddr.Clint,clt.rvalid,out.rvalid)}
		is(ArbStatus.IfuR){backValid := Mux(addrEnum === ArbAddr.Clint,clt.rvalid,out.rvalid)}
		is(ArbStatus.LsuW){backValid := Mux(addrEnum === ArbAddr.Clint,clt.bvalid,out.bvalid)}
		is(ArbStatus.Idle){backValid := false.B}
	}
}
