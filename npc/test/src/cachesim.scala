import chisel3._
import chisel3.simulator.scalatest.ChiselSim
import org.scalatest.funsuite.AnyFunSuite

class icachesim extends AnyFunSuite with ChiselSim{
	test("icache延迟测试") {simulate(new ich(true)) { dut =>
			dut.ifu.valid.poke(true.B)
			dut.ifu.addr.poke(0x1000.U)

			dut.bar.valid.expect(true.B)
			dut.bar.addr.expect(0x4000.U)
			println(dut.bar.valid.peek())
			println(dut.bar.addr.peek())
	}}
}