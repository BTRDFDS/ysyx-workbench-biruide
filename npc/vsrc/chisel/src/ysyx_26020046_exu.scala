import chisel3._
import chisel3.util._

class ysyx_26020046_Exu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module {
	val io = IO(new Bundle {
        val waterIn		= Flipped(new WaterIdEx(Width))
		val waterOut	= new WaterExLs(Width)
		val immOut		= new ImmAfter(Width,RegNum,CsrWidth)
		val immIn		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
	})
	val result = WireInit(0.U(Width.W))
	val enBfun = WireInit(false.B)
	
	io.waterOut.enSave	:= io.waterIn.enSave
	io.waterOut.enLoad	:= io.waterIn.enLoad
	io.waterOut.lsuOp	:= io.waterIn.lsuOp
	io.waterOut.r2		:= io.waterIn.r2
	io.waterOut.pc		:= io.waterIn.pc
	io.waterOut.csrOp	:= io.waterIn.csrOp
	io.waterOut.csrAddr	:= io.waterIn.csrAddr
	io.waterOut.valid	:= io.waterIn.valid
	io.waterOut.rdAddr	:= io.waterIn.rdAddr
	io.waterOut.result 	:= 0.U
	io.waterOut.csrMesg	:= io.waterIn.csrMesg
	
	io.immOut.ready		:= io.immIn.ready
	io.immOut.wash		:= false.B
	io.immOut.addr		:= 0.U
	io.immOut.r1Out		:= io.immIn.r1Out
	io.immOut.r2Out		:= io.immIn.r2Out
	io.immOut.csrOut	:= io.immIn.csrOut
	io.immIn.r1Addr		:= io.immOut.r1Addr
	io.immIn.r2Addr		:= io.immOut.r2Addr
	io.immIn.csrAddr	:= io.immOut.csrAddr

	when(io.immIn.wash){
		io.immOut.wash	:= io.immIn.wash
		io.immOut.addr	:= io.immIn.addr
	}otherwise{
		when(io.waterIn.valid){
			val input1 = Mux(io.waterIn.In1 === ExuIn1.R1, io.waterIn.r1, io.waterIn.pc)
			val input2 = Mux(io.waterIn.In2 === ExuIn2.R2, io.waterIn.r2, io.waterIn.result)
			switch(io.waterIn.alu){
				is(ExuAlu.Add)	{result := input1 + input2}
				is(ExuAlu.Sll)	{result := input1 << input2(4,0)}
				is(ExuAlu.Slt)	{result := input1.asSInt < input2.asSInt}
				is(ExuAlu.Sltu)	{result := input1 < input2}
				is(ExuAlu.Xor)	{result := input1 ^ input2}
				is(ExuAlu.Srl)	{result := input1 >> input2(4,0)}
				is(ExuAlu.Or)	{result := input1 | input2}
				is(ExuAlu.And)	{result := input1 & input2}
				is(ExuAlu.Sub)	{result := input1 - input2}
				is(ExuAlu.Sra)	{result := (input1.asSInt >> input2(4,0)).asUInt}
				is(ExuAlu.ImR1)	{result := io.waterIn.result+io.waterIn.r1}
				is(ExuAlu.ImPc)	{result := io.waterIn.result+io.waterIn.pc}
				is(ExuAlu.Csr)	{result := io.waterIn.csrMesg}
			}
			switch(io.waterIn.bfu){
				is(ExuBfu.Beq)	{enBfun := io.waterIn.r1 === io.waterIn.r2}
				is(ExuBfu.Bne)	{enBfun := io.waterIn.r1 =/= io.waterIn.r2}
				is(ExuBfu.Blt)	{enBfun := io.waterIn.r1.asSInt < io.waterIn.r2.asSInt}
				is(ExuBfu.Bge)	{enBfun := io.waterIn.r1.asSInt >= io.waterIn.r2.asSInt}
				is(ExuBfu.Bltu)	{enBfun := io.waterIn.r1 < io.waterIn.r2}
				is(ExuBfu.Bgeu)	{enBfun := io.waterIn.r1 >= io.waterIn.r2}
			}
			switch(io.waterIn.csr){
				is(ExuCsr.Read)	{io.waterOut.csrMesg := io.waterIn.r1}
				is(ExuCsr.Write){io.waterOut.csrMesg := io.waterIn.r1|io.waterIn.csrMesg}
			}
			switch(io.waterIn.res){
				is(ExuRes.Alu)	{io.waterOut.result := result}
				is(ExuRes.Null)	{io.waterOut.result := 0.U}
				is(ExuRes.Snpc)	{io.waterOut.result := io.waterIn.pc+4.U}
				is(ExuRes.Csr)	{io.waterOut.result := io.waterIn.csrMesg}
			}
			val enJfun = io.waterIn.enJcod | enBfun
			io.immOut.wash	:= enJfun
			when(enJfun){io.immOut.addr := result}
		}
	}
}