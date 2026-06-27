import chisel3._
import chisel3.util._

class ysyx_26020046_EXU(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module {
	val io = IO(new Bundle {
        val waterIdEx	= Flipped(new WaterIdEx(Width))
		val waterExLs	= new WaterExLs(Width)
		val immExId		= new ImmAfter(Width,RegNum,CsrWidth)
		val immLsEx		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
	})
	val result = WireInit(0.U(Width.W))
	val input1 = Wire(UInt(Width.W))
	val input2 = Wire(UInt(Width.W))
	val enBfun = WireInit(false.B)
	
	io.waterExLs.enSave	:= io.waterIdEx.enSave
	io.waterExLs.enLoad	:= io.waterIdEx.enLoad
	io.waterExLs.lsOp	:= io.waterIdEx.lsOp
	io.waterExLs.r2		:= io.waterIdEx.r2
	io.waterExLs.pc		:= io.waterIdEx.pc
	io.waterExLs.csrOp	:= io.waterIdEx.csrOp
	io.waterExLs.csrAddr:= io.waterIdEx.csrAddr
	io.waterExLs.valid	:= io.waterIdEx.valid
	io.waterExLs.rdAddr	:= io.waterIdEx.rdAddr
	io.waterExLs.result := 0.U
	io.waterExLs.csrMesg:= io.waterIdEx.csrMesg
	io.immExId <> io.immLsEx

	input1 := Mux(io.waterIdEx.In1 === ExuIn1.R1, io.waterIdEx.r1, io.waterIdEx.pc)
	input2 := Mux(io.waterIdEx.In2 === ExuIn2.R2, io.waterIdEx.r2, io.waterIdEx.result)
	when(io.waterIdEx.valid){
		switch(io.waterIdEx.alu){
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
			is(ExuAlu.ImR1)	{result := io.waterIdEx.result+io.waterIdEx.r1}
			is(ExuAlu.ImPc)	{result := io.waterIdEx.result+io.waterIdEx.pc}
			is(ExuAlu.Csr)	{result := io.waterIdEx.sr}
			is(ExuAlu.Null)	{result := 0.U}
		}
		switch(io.waterIdEx.bfu){
			is(ExuBfu.Beq)	{enBfun := io.waterIdEx.r1 === io.waterIdEx.r2}
			is(ExuBfu.Bne)	{enBfun := io.waterIdEx.r1 =/= io.waterIdEx.r2}
			is(ExuBfu.Blt)	{enBfun := io.waterIdEx.r1.asSInt < io.waterIdEx.r2.asSInt}
			is(ExuBfu.Bge)	{enBfun := io.waterIdEx.r1.asSInt >= io.waterIdEx.r2.asSInt}
			is(ExuBfu.Bltu)	{enBfun := io.waterIdEx.r1 < io.waterIdEx.r2}
			is(ExuBfu.Bgeu)	{enBfun := io.waterIdEx.r1 >= io.waterIdEx.r2}
			is(ExuBfu.Null)	{enBfun := false.B}
		}
		switch(io.waterIdEx.csr){
			is(ExuCsr.Read)	{io.waterExLs.csrMesg := io.waterIdEx.r1}
			is(ExuCsr.Write){io.waterExLs.csrMesg := io.waterIdEx.r1|io.waterIdEx.sr}
			is(ExuCsr.Jump){io.waterExLs.csrMesg := io.waterIdEx.pc}
			is(ExuCsr.Null)	{io.waterExLs.csrMesg := 0.U}
		}
		switch(io.waterIdEx.res){
			is(ExuRes.Alu)	{io.waterExLs.result := result}
			is(ExuRes.Imm)	{io.waterExLs.result := io.waterIdEx.result}
			is(ExuRes.Snpc)	{io.waterExLs.result := io.waterIdEx.pc+4.U}
			is(ExuRes.Csr)	{io.waterExLs.result := io.waterIdEx.sr}
		}
	}
}