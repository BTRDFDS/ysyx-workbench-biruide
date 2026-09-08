import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._
class ysyx_26020046 extends ExtModule{
	val clock	= IO(Input(Clock()))
	val reset	= IO(Input(Reset()))
	val io = IO(new Bundle {
		val interrupt = Input(Bool())
		val master = new Axi4MasterOut()
		val slave = Flipped(new Axi4MasterOut())
	})
	dontTouch(io.master)
	dontTouch(io.slave)
	dontTouch(io.interrupt)
}