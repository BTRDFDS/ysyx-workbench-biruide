package ysyx

import chisel3._
import chisel3.util._

class bitrev extends BlackBox {
	val io = IO(Flipped(new SPIIO(1)))
}
object BitrevEnum extends ChiselEnum{
	val Idle,Inp0,Inp1,Inp2,Inp3,Inp4,Inp5,Inp6,Inp7,Out0,Out1,Out2,Out3,Out4,Out5,Out6,Out7,Done = Value
}
class bitrevChisel extends RawModule { // we do not need clock and reset
	val io = IO(Flipped(new SPIIO(1)))
	// io.miso := true.B
	val status = RegInit(BitrevEnum.Idle)
	status := Mux(
		(io.ss | status === BitrevEnum.Done),
		BitrevEnum.Idle,
		((status.asUint)+1.U).asTypeOf(BitrevEnum)
	)
	val reg = withClock(io.sck){Reg(UInt(8.W))}
	when(status === BitrevEnum.Inp0){reg(0) := io.mosi.asUInt}
	when(status === BitrevEnum.Inp1){reg(1) := io.mosi.asUInt}
	when(status === BitrevEnum.Inp2){reg(2) := io.mosi.asUInt}
	when(status === BitrevEnum.Inp3){reg(3) := io.mosi.asUInt}
	when(status === BitrevEnum.Inp4){reg(4) := io.mosi.asUInt}
	when(status === BitrevEnum.Inp5){reg(5) := io.mosi.asUInt}
	when(status === BitrevEnum.Inp6){reg(6) := io.mosi.asUInt}
	when(status === BitrevEnum.Inp7){reg(7) := io.mosi.asUInt}
	io.miso := Mux1H(Seq(
		status === BitrevEnum.Idle -> true.B,
		status === BitrevEnum.Inp0 -> true.B,
		status === BitrevEnum.Inp1 -> true.B,
		status === BitrevEnum.Inp2 -> true.B,
		status === BitrevEnum.Inp3 -> true.B,
		status === BitrevEnum.Inp4 -> true.B,
		status === BitrevEnum.Inp5 -> true.B,
		status === BitrevEnum.Inp6 -> true.B,
		status === BitrevEnum.Inp7 -> true.B,
		status === BitrevEnum.Out0 -> reg(0).asBool,
		status === BitrevEnum.Out1 -> reg(1).asBool,
		status === BitrevEnum.Out2 -> reg(2).asBool,
		status === BitrevEnum.Out3 -> reg(3).asBool,
		status === BitrevEnum.Out4 -> reg(4).asBool,
		status === BitrevEnum.Out5 -> reg(5).asBool,
		status === BitrevEnum.Out6 -> reg(6).asBool,
		status === BitrevEnum.Out7 -> reg(7).asBool,
		status === BitrevEnum.Done -> true.B
	))
}
