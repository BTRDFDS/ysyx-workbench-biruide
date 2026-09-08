import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._
class driveLinker(val Yosys:Boolean=false,val Netlist:Boolean=false) extends Module{
	val interrupt = IO(Input(Bool()))
	val master = IO(new Axi4MasterOut())
	val slave = IO(Flipped(new Axi4MasterOut()))
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
	if(Yosys){
		val mem = Module(new driveMemVerilog())
		read	<> mem.read
		write	<> mem.write
		if(Netlist){
			val cpu = Module(new ysyx_26020046())
			cpu.clock := clock
			cpu.reset := reset
			dontTouch(cpu.io)
			master		<> cpu.io.master
			slave		<> cpu.io.slave
			interrupt	<> cpu.io.interrupt
		}else{
			val cpu = Module(new cpu(0x30000000L.U,true))
			master		<> cpu.io.master
			slave		<> cpu.io.slave
			interrupt	<> cpu.io.interrupt
			val pc = Cat(Get(cpu.ifu.pipePc),0.U(2.W));dontTouch(pc)
			val shouldStop = RegInit(false.B);when(shouldStop){stop()}	
			when((Get(cpu.wbu.pipeCsrOp) === CsrOp.Trap && Get(cpu.wbu.pipeValid) && Get(cpu.wbu.pipeCsrMesg) === 0x3L.U) || Get(cpu.wbu.error)){
				printf("Ebreak at 0x%8x a0=%8x\n",Cat(Get(cpu.wbu.pipePc),0.U(2.W)),Get(cpu.wbu.gpr)(10))
				shouldStop := true.B
			}
			when((Get(cpu.wbu.pipeValid) === false.B & Get(cpu.wbu.pipeCsrOp) === CsrOp.Trap) || Get(cpu.wbu.error)){
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
				shouldStop := true.B
			}
			// when(mem.read.valid){printf("%8x read at %8x %8x\n",Cat(Get(cpu.io.lsu.pipePc),0.U(2.W)),mem.read.addr,mem.read.data)}
			// when(mem.write.valid){printf("%8x write at %8x %b %8x\n",Cat(Get(cpu.io.lsu.pipePc),0.U(2.W)),mem.write.addr,mem.write.strb,mem.write.data)}
		}
	}else{
		val cpu = Module(new cpu(0x80000000L.U))
		master		<> cpu.io.master
		slave		<> cpu.io.slave
		interrupt	<> cpu.io.interrupt
		val mem = Module(new driveMemCpp())
		read	<> mem.read
		write	<> mem.write
	}
}