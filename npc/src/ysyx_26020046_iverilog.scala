import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._
class ysyx_26020046_iverilog extends Module{
	val PcInit:UInt=0x80000000L.U
	val cpu = Module(new ysyx_26020046(PcInit,true))
	val mem = Module(new ysyx_26020046_iverilog_Mem())

	val rState	= RegInit(NpcState.Idle)
	val araddr	= RegInit(0.U(BitWidth.W))
	val arlen	= RegInit(0.U(LenWidth.W))
	val arsiz	= RegInit(0.U(SizeWidth.W))
	val arburst	= RegInit(0.U(BurstWidth.W))
	val cnt		= RegInit(0.U(CacheWidth.W))
	when(rState===NpcState.Idle){
		when(cpu.io.master.arvalid){
			rState	:= NpcState.Back
			araddr	:= cpu.io.master.araddr
			arlen	:= cpu.io.master.arlen
			arsiz	:= cpu.io.master.arsize
			arburst	:= cpu.io.master.arburst
		}
		cnt	:= 0.U
		cpu.io.master.arready	:= true.B
		cpu.io.master.rvalid	:= false.B
		cpu.io.master.rlast		:= false.B
		cpu.io.master.rdata		:= 0.U
		cpu.io.master.rresp		:= 0.U
		mem.read.valid			:= false.B
		mem.read.addr			:= 0.U
	}.otherwise{
		when(cpu.io.master.rready && Mux(arburst===2.U,cnt===arlen,true.B)){rState := NpcState.Idle}
		cnt := cnt + 1.U
		cpu.io.master.arready	:= false.B
		cpu.io.master.rvalid	:= true.B
		cpu.io.master.rlast		:= Mux(arburst===2.U,cnt===arlen,true.B)
		cpu.io.master.rdata		:= mem.read.data
		cpu.io.master.rresp		:= 0.U
		mem.read.valid	:= true.B
		mem.read.addr	:= Cat(araddr(31,CacheWidth+2),(cnt+araddr(CacheWidth+1,2)),0.U(2.W))
		when(arburst=/=2.U && arburst=/=0.U){printf("arburst=%x error\n",arburst);stop();}
		when(arsiz=/=0.U && arsiz=/=1.U && arsiz=/=2.U){printf("arsize=%x error\n",arsiz);stop();}
	}
	val wState = RegInit(NpcState.Idle)
	val awaddr= RegInit(0.U(BitWidth.W))
	val wdata = RegInit(0.U(BitWidth.W))
	val wstrb = RegInit(0.U(StrbWidth.W))
	val hasAddr = RegInit(false.B)
	val hasData = RegInit(false.B)
	when(wState===NpcState.Idle){
		when((hasAddr && hasData) || (cpu.io.master.awvalid && cpu.io.master.wvalid)){wState:=NpcState.Back}
		hasAddr := cpu.io.master.awvalid
		hasData := cpu.io.master.wvalid
		when(cpu.io.master.awvalid && ~hasAddr){
			awaddr := cpu.io.master.awaddr
		}
		when(cpu.io.master.wvalid && ~hasData){
			wdata := cpu.io.master.wdata
			wstrb := cpu.io.master.wstrb
		}
		cpu.io.master.awready	:= ~hasAddr
		cpu.io.master.wready	:= ~hasData
		cpu.io.master.bvalid	:= false.B
		cpu.io.master.bresp		:= 0.U
		mem.write.valid	:= false.B
		mem.write.addr		:= 0.U
		mem.write.strb		:= 0.U
		mem.write.data		:= 0.U
	}.otherwise{
		when(cpu.io.master.bready){wState := NpcState.Idle}
		hasAddr := false.B
		hasData := false.B
		cpu.io.master.awready	:= false.B
		cpu.io.master.wready	:= false.B
		cpu.io.master.bvalid	:= true.B
		cpu.io.master.bresp		:= 0.U
		mem.write.valid	:= true.B
		mem.write.addr		:= awaddr
		mem.write.strb		:= wstrb
		mem.write.data		:= wdata
	}

	// val arid	= Output(UInt(IdWidth.W))
	// val awid	= Output(UInt(IdWidth.W))
	// val awlen	= Output(UInt(LenWidth.W))
	// val awsize	= Output(UInt(SizeWidth.W))
	// val awburst	= Output(UInt(BurstWidth.W))
	// val wlast	= Output(Bool())Z
	cpu.io.master.rid	:= 0.U
	cpu.io.master.bid	:= 0.U

	cpu.io.interrupt	:= false.B
	
	cpu.io.slave.arvalid	:= false.B
	cpu.io.slave.rready		:= false.B
	cpu.io.slave.awvalid	:= false.B
	cpu.io.slave.wvalid		:= false.B
	cpu.io.slave.bready		:= false.B
	cpu.io.slave.wlast		:= false.B
	cpu.io.slave.araddr		:= 0.U
	cpu.io.slave.arlen		:= 0.U
	cpu.io.slave.arsize		:= 0.U
	cpu.io.slave.arburst	:= 0.U
	cpu.io.slave.awaddr		:= 0.U
	cpu.io.slave.wdata		:= 0.U
	cpu.io.slave.wstrb		:= 0.U
	cpu.io.slave.arid		:= 0.U
	cpu.io.slave.awid		:= 0.U
	cpu.io.slave.awlen		:= 0.U
	cpu.io.slave.awsize		:= 0.U
	cpu.io.slave.awburst	:= 0.U
	val shuouldStop = RegInit(false.B);when(shuouldStop){stop()}
	when((Get(cpu.wbu.pipeCsrOp) === CsrOp.Trap && Get(cpu.wbu.pipeValid) && Get(cpu.wbu.pipeCsrMesg) === 0x3L.U) || Get(cpu.wbu.error)){
		printf("Ebreak at 0x%8x a0=%8x\n",Cat(Get(cpu.wbu.pipePc),0.U(2.W)),Get(cpu.wbu.gpr)(10))
		shuouldStop := true.B
	}

	when((Get(cpu.wbu.pipeValid) === false.B & Get(cpu.wbu.pipeCsrOp) === CsrOp.Trap) || Get(cpu.wbu.error)){//TODO:mstatus
		when(Get(cpu.wbu.pipeValid) === false.B & Get(cpu.wbu.pipeCsrOp) === CsrOp.Trap){printf("pipe err catch\n")}
		when(Get(cpu.wbu.error)){printf("wbu err catch\n")}
		printf("error,stop!!! %x ",Get(cpu.wbu.pipeCsrMesg))//tval
		switch(Get(cpu.wbu.pipeCsrMesg)){
			is(3.U	){printf("ebreak\n")}
			is(11.U	){printf("ecall\n")}
			is(0.U	){printf("ifuN4\n")}
			is(1.U	){printf("ifuErr\n")}
			is(2.U	){printf("instr\n")}
			is(4.U	){printf("laddr\n")}
			is(5.U	){printf("lerror\n")}
			is(6.U	){printf("sAddr\n")}
			is(7.U	){printf("sError\n")}
		}
		shuouldStop := true.B
	}
	// when(mem.read.valid){printf("%8x read at %8x %8x\n",Cat(Get(cpu.lsu.pipePc),0.U(2.W)),mem.read.addr,mem.read.data)}
	// when(mem.write.valid){printf("%8x write at %8x %b %8x\n",Cat(Get(cpu.lsu.pipePc),0.U(2.W)),mem.write.addr,mem.write.strb,mem.write.data)}
}
class ysyx_26020046_iverilog_Mem extends Module{
	val read = IO(new Bundle{
		val valid	= Input(Bool())
		val addr	= Input(UInt(32.W))
		val data	= Output(UInt(32.W))
	})
	val write  = IO(new Bundle{
		val valid	= Input(Bool())
		val addr	= Input(UInt(32.W))
		val strb	= Input(UInt(4.W))
		val data	= Input(UInt(32.W))
	})
	val psram = Mem(0x01000000,UInt(8.W))
	loadMemoryFromFileInline(psram, "./test/iverilog/iverilog.hex")
	// val theFirst = RegInit(true.B);when(theFirst){theFirst := false.B
	// 	printf("%x\n",Cat(psram(0x0003),psram(0x0002),psram(0x0001),psram(0x0000)))
	// 	printf("%x\n",Cat(psram(0x0007),psram(0x0006),psram(0x0005),psram(0x0004)))
	// 	printf("%x\n",Cat(psram(0x000b),psram(0x000a),psram(0x0009),psram(0x0008)))
	// 	printf("%x\n",Cat(psram(0x000f),psram(0x000e),psram(0x000d),psram(0x000c)))
	// 	printf("%x\n",Cat(psram(0x0013),psram(0x0012),psram(0x0011),psram(0x0010)))
	// 	printf("%x\n",Cat(psram(0x0017),psram(0x0016),psram(0x0015),psram(0x0014)))
	// }



	val rdata = Cat(
		psram(Cat(read.addr(31,2),3.U(2.W))),
		psram(Cat(read.addr(31,2),2.U(2.W))),
		psram(Cat(read.addr(31,2),1.U(2.W))),
		psram(Cat(read.addr(31,2),0.U(2.W)))
	)
	read.data := Mux(read.valid,rdata,0.U)
	when(write.valid && write.addr(31,28)===0b1000.U){
		when(write.strb(0).asBool){psram(Cat(write.addr(31,2),0.U(2.W))) := write.data( 7, 0)}
		when(write.strb(1).asBool){psram(Cat(write.addr(31,2),1.U(2.W))) := write.data(15, 8)}
		when(write.strb(2).asBool){psram(Cat(write.addr(31,2),2.U(2.W))) := write.data(23,16)}
		when(write.strb(3).asBool){psram(Cat(write.addr(31,2),3.U(2.W))) := write.data(31,24)}
	}.elsewhen(write.valid && write.addr===0x10000000.U){
		printf("%c",write.data(7,0))
	}
}