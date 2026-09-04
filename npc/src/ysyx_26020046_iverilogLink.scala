import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_iverilogLink() extends Module {
	val interrupt	= IO(Input(Bool()))
	val master		= IO(new Axi4MasterOut())
	val slave		= IO(Flipped(new Axi4MasterOut()))
	val cpu = Module(new ysyx_26020046(0x80000000L.U,true))
	interrupt	<> cpu.io.interrupt
	master		<> cpu.io.master
	slave		<> cpu.io.slave
}