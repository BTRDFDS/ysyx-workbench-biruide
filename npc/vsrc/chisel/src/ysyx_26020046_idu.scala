import chisel3._
import chisel3.util._
class ysyx_26020046_idu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module{
	val io = IO(new Bundle{
		val waterIfId	= Flipped(new WaterIfId(Width))
		val waterIdEx	= new WaterIdEx(Width,RegNum,CsrWidth)
		val immIdIf		= new Imbefore()
		val immIdEx		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
	})
	when(io.waterIfId.res === IfuRes.Valid){
		val (opCode,opValid) = Op.safe(io.waterIfId.instr(6,0))
		when(opValid){
			switch(opCode){
				is(Op.Ului)		{io.waterIdEx.res := Cat(io.waterIfId.instr(31,12),0.U(12.W))}
				is(Op.Uauipc)	{io.waterIdEx.res := Cat(io.waterIfId.instr(31,12),0.U(12.W))}
				is(Op.Store)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,25),io.waterIfId.instr(11,7))}
				is(Op.Ialu)		{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Ijalr)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Iload)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Branch)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(7),io.waterIfId.instr(30,25),io.waterIfId.instr(11,8),0.U(1.W))}
				is(Op.Jal)		{io.waterIdEx.res := Cat(Fill(12,io.waterIfId.instr(31)),io.waterIfId.instr(19,12),io.waterIfId.instr(20),io.waterIfId.instr(30,21),0.U(1.W))}
			}
		}
	}
}