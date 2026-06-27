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
	switch(io.waterIdEx.in1){
		is(ExuIn1.R1)	{input1 := io.waterIdEx.r1}
		is(ExuIn1.Pc)	{input1 := io.waterIdEx.addr}
	}
	switch(io.waterIdEx.in2){
		is(ExuIn2.R2)	{input2 := io.waterIdEx.r2}
		is(ExuIn2.Imm)	{input2 := io.waterIdEx.result}
	}
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
		is(ExuAlu.Sra)	{result := input1.asSInt >> input2(4,0)}
		is(ExuAlu.ImR1)	{result := io.waterIdEx.result+io.waterIdEx.r1}
		is(ExuAlu.ImPc)	{result := io.waterIdEx.result+io.waterIdEx.addr}
		is(ExuAlu.Csr)	{result := io.waterIdEx.csr}
		is(ExuAlu.Null)	{result := 0.U}
		otherwise {result := 0.U}//TODO
	}
	val enBfun = Wire(Bool())
	switch(io.waterIdEx.bfu){
		is(ExuBfu.Beq)	{enBfun := io.waterIdEx.r1 === io.waterIdEx.r2}
		is(ExuBfu.Bne)	{enBfun := io.waterIdEx.r1 =/= io.waterIdEx.r2}
		is(ExuBfu.Blt)	{enBfun := io.waterIdEx.r1.asSInt < io.waterIdEx.r2.asSInt}
		is(ExuBfu.Bge)	{enBfun := io.waterIdEx.r1.asSInt >= io.waterIdEx.r2.asSInt}
		is(ExuBfu.Bltu)	{enBfun := io.waterIdEx.r1 < io.waterIdEx.r2}
		is(ExuBfu.Bgeu)	{enBfun := io.waterIdEx.r1 >= io.waterIdEx.r2}
		is(ExuBfu.Null)	{enBfun := false.B}
		otherwise {enBfun := false.B}//TODO
	}
	switch(io.waterIdEx.csr){
		is(ExuCsr.Read)	{io.waterExLs.csrMesg := io.waterIdEx.r1}
		is(ExuCsr.Write){io.waterExLs.csrMesg := io.waterIdEx.r1|io.waterIdEx.csr}
		is(ExuCsr.Jump){io.waterExLs.csrMesg := io.waterIdEx.addr}
		is(ExuCsr.Null)	{io.waterExLs.csrMesg := 0.U}
	}
	switch(io.waterIdEx.res){
		is(ExuRes.Alu)	{io.waterExLs.result := result}
		is(ExuRes.Imm)	{io.waterExLs.result := io.waterIdEx.result}
		is(ExuRes.Snpc)	{io.waterExLs.result := io.waterIdEx.addr+4.U}
		is(ExuRes.Csr)	{io.waterExLs.result := io.waterIdEx.csr}
	}
	io.waterExLs.enSave	:= io.waterIdEx.enSave
	io.waterExLs.enLoad	:= io.waterIdEx.enLoad
	io.waterExLs.lsOp	:= io.waterIdEx.lsOp
	io.waterExLs.r2		:= io.waterIdEx.r2
	io.waterExLs.pc		:= io.waterIdEx.pc
	io.waterExLs.csrOp	:= io.waterIdEx.csrOp
	io.waterExLs.csrAddr:= io.waterIdEx.csrAddr
	io.waterExLs.valid	:= io.waterIdEx.valid
	io.immExId <> io.immLsEx
}