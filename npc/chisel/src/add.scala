import chisel3._
import chisel3.util._
class add extends Module{
	val io = IO(new Bundle{
		val a = Input(UInt(32.W))
		val b = Input(UInt(32.W))
		val x = Output(UInt(32.W))
		val y = Output(UInt(32.W))
	})
	io.y := io.a + io.b
	val reg = RegInit(0.U(32.W))
	reg := reg + 1.U
	io.x := reg
}