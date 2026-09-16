import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._
class driveMemVerilog extends Module{
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
	loadMemoryFromFileInline(psram, "./build/iverilog.hex")
	// val theFirst = RegInit(true.B);when(theFirst){theFirst := false.B
	// 	printf("%x\n",Cat(psram(0x0003),psram(0x0002),psram(0x0001),psram(0x0000)))
	// 	printf("%x\n",Cat(psram(0x0007),psram(0x0006),psram(0x0005),psram(0x0004)))
	// 	printf("%x\n",Cat(psram(0x000b),psram(0x000a),psram(0x0009),psram(0x0008)))
	// 	printf("%x\n",Cat(psram(0x000f),psram(0x000e),psram(0x000d),psram(0x000c)))
	// 	printf("%x\n",Cat(psram(0x0013),psram(0x0012),psram(0x0011),psram(0x0010)))
	// 	printf("%x\n",Cat(psram(0x0017),psram(0x0016),psram(0x0015),psram(0x0014)))
	// }

	val rdata = Wire(UInt(32.W))
	when(read.addr(31,28)===0x3.U){
		rdata := Mux(read.addr(2),0x00008067L.U,0x800000b7L.U)
	}.otherwise{
		rdata := Cat(
			psram(Cat(read.addr(31,2),3.U(2.W))),
			psram(Cat(read.addr(31,2),2.U(2.W))),
			psram(Cat(read.addr(31,2),1.U(2.W))),
			psram(Cat(read.addr(31,2),0.U(2.W)))
		)
	}
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