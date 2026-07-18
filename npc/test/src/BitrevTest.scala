import chisel3._
import chisel3.simulator.scalatest.ChiselSim
import org.scalatest.funsuite.AnyFunSuite

class BitrevTest extends AnyFunSuite with ChiselSim{
	test("半自动测试") {simulateRaw(new bitrevChisel) { dut =>
        val a = 0b0100110
        dut.io.ss.poke(0.U)
        dut.io.mosi.poke(false.B)
        dut.io.miso.expect(true.B)

        dut.io.sck.poke(false.B)
		// dut.io.sck.step(1)

        dut.io.sck.poke(true.B)
		// dut.io.sck.step(1)

        dut.io.sck.poke(false.B)
		// dut.io.sck.step(1)
    
        for(i <- 0 until 7){
            dut.io.sck.poke(true.B)
            dut.io.ss.poke(0.U)
            dut.io.mosi.poke((a >> i) & 1.U)
            dut.io.miso.expect(true.B)
		    // dut.io.sck.step(1)
            dut.io.sck.poke(false.B)
		    // dut.io.sck.step(1)
        }
        for(i <- 0 until 7){
            dut.io.sck.poke(true.B)
            dut.io.ss.poke(0.U)
            dut.io.mosi.poke(false.B)
		    // dut.io.sck.step(1)
            printf(dut.io.miso.peek())
            dut.io.sck.poke(false.B)
		    // dut.io.sck.step(1)
        }
	}}
}