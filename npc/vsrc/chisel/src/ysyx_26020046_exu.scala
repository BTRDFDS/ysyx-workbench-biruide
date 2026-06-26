import chisel3._
import chisel3.util._
import chisel3.Enum._

class ysyx_26020046_EXU(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module {
	val io = IO(new Bundle {
        val waterIdEx	= Flipped(new WaterIdEx(Width))
		val waterExLs	= new WaterExLs(Width)
		val immExId		= new ImmAfter(Width,RegNum,CsrWidth)
		val immLsEx		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
	})
	val result = Wire(UInt(Width.W))
	val input1 = Wire(UInt(Width.W))
	val input2 = Wire(UInt(Width.W))
	switch(io.waterIdEx.alu){
		is(ExuAlu.ADD){result := input1 + input2}
		is(ExuAlu.SLL){result := input1 << input2(4,0)}
	}
}