import chisel3._
import chisel3.util._

class ysyx_26020046_Exu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module {
	val io = IO(new Bundle {
        val pipeIn		= Flipped(new PipeIdEx(Width))
		val pipeOut	= new PipeExLs(Width)
		val immeOut		= new ImmeAfter(Width,RegNum,CsrWidth)
		val immeIn		= Flipped(new ImmeAfter(Width,RegNum,CsrWidth))
	})
	
	io.pipeOut.enSave	:= io.pipeIn.enSave
	io.pipeOut.enLoad	:= io.pipeIn.enLoad
	io.pipeOut.lsuOp	:= io.pipeIn.lsuOp
	io.pipeOut.r2		:= io.pipeIn.r2
	io.pipeOut.pc		:= io.pipeIn.pc
	io.pipeOut.csrOp	:= io.pipeIn.csrOp
	io.pipeOut.csrAddr	:= io.pipeIn.csrAddr
	io.pipeOut.valid	:= io.pipeIn.valid
	io.pipeOut.rdAddr	:= io.pipeIn.rdAddr
	io.pipeOut.result 	:= 0.U
	io.pipeOut.csrMesg	:= io.pipeIn.csrMesg
	
	io.immeOut.back		:= io.immeIn.back
	io.immeOut.addr		:= 0.U
	io.immeOut.r1Out	:= io.immeIn.r1Out
	io.immeOut.r2Out	:= io.immeIn.r2Out
	io.immeOut.csrOut	:= io.immeIn.csrOut
	io.immeIn.r1Addr	:= io.immeOut.r1Addr
	io.immeIn.r2Addr	:= io.immeOut.r2Addr
	io.immeIn.csrAddr	:= io.immeOut.csrAddr

	switch(io.immeIn.back){
		is(Back.Error){
			io.immeOut.back	:= Back.Error
			io.immeOut.addr	:= io.immeIn.addr
		}
		is(Back.Ready){when(io.pipeIn.valid){
			val input1 = Mux(io.pipeIn.In1 === ExuIn1.R1, io.pipeIn.r1, io.pipeIn.pc)
			val input2 = Mux(io.pipeIn.In2 === ExuIn2.R2, io.pipeIn.r2, io.pipeIn.result)
			val result = WireInit(0.U(Width.W))
			switch(io.pipeIn.alu){
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
				is(ExuAlu.ImR1)	{result := io.pipeIn.result+io.pipeIn.r1}
				is(ExuAlu.ImPc)	{result := io.pipeIn.result+io.pipeIn.pc}
				is(ExuAlu.Csr)	{result := io.pipeIn.csrMesg}
				is(ExuAlu.Imm)	{result := io.pipeIn.result}
			}
			val enBfun = WireInit(false.B)
			switch(io.pipeIn.bfu){
				is(ExuBfu.Beq)	{enBfun := io.pipeIn.r1 === io.pipeIn.r2}
				is(ExuBfu.Bne)	{enBfun := io.pipeIn.r1 =/= io.pipeIn.r2}
				is(ExuBfu.Blt)	{enBfun := io.pipeIn.r1.asSInt < io.pipeIn.r2.asSInt}
				is(ExuBfu.Bge)	{enBfun := io.pipeIn.r1.asSInt >= io.pipeIn.r2.asSInt}
				is(ExuBfu.Bltu)	{enBfun := io.pipeIn.r1 < io.pipeIn.r2}
				is(ExuBfu.Bgeu)	{enBfun := io.pipeIn.r1 >= io.pipeIn.r2}
			}
			switch(io.pipeIn.csr){
				is(ExuCsr.Read)	{io.pipeOut.csrMesg := io.pipeIn.r1}
				is(ExuCsr.Write){io.pipeOut.csrMesg := io.pipeIn.r1|io.pipeIn.csrMesg}
			}
			switch(io.pipeIn.res){
				is(ExuRes.Alu)	{io.pipeOut.result := result}
				is(ExuRes.Null)	{io.pipeOut.result := 0.U}
				is(ExuRes.Snpc)	{io.pipeOut.result := io.pipeIn.pc+4.U}
				is(ExuRes.Csr)	{io.pipeOut.result := io.pipeIn.csrMesg}
			}
			when(io.pipeIn.enJcod | enBfun){
				io.immeOut.addr := result
				io.immeOut.back := Back.Jump
			}otherwise{io.immeOut.back := Back.Ready}
		}}
		is(Back.Wait){io.immeOut.back := Back.Wait}
	}
}