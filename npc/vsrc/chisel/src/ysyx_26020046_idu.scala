import chisel3._
import chisel3.util._
class ysyx_26020046_idu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module{
	val io = IO(new Bundle{
		val waterIfId	= Flipped(new WaterIfId(Width))
		val waterIdEx	= new WaterIdEx(Width,RegNum,CsrWidth)
		val immIdIf		= new Imbefore()
		val immIdEx		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
	})
	//默认值
	io.waterIdEx.valid	:= false.B
	io.waterIdEx.rdAddr	:= 0.U
	io.waterIdEx.result	:= 0.U
	io.waterIdEx.pc		:= 0.U
	io.waterIdEx.csrOp	:= CsrOp.Null
	io.waterIdEx.csrAddr:= 0.U
	io.waterIdEx.csrMesg:= 0.U
	io.waterIdEx.enSave	:= false.B
	io.waterIdEx.enLoad	:= false.B
	io.waterIdEx.lsOp	:= LsuOp.N
	io.waterIdEx.r2		:= 0.U
	io.waterIdEx.r1		:= 0.U
	io.waterIdEx.enJcod	:= false.B
	io.waterIdEx.sr		:= 0.U
	io.waterIdEx.alu	:= ExuAlu.Error
	io.waterIdEx.bfu	:= ExuBfu.Null
	io.waterIdEx.csr	:= ExuCsr.Null
	io.waterIdEx.Res	:= ExuRes.Alu
	io.waterIdEx.In1	:= ExuIn1.R1
	io.waterIdEx.In2	:= ExuIn2.R2

	val errAlu = WireInit(false.B)

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
			when(opCode === Op.Uauipc){io.waterIdEx.In1 := ExuIn1.Pc}
			when(opCode === Op.Ului | opCode === Op.Ialu){io.waterIdEx.In2 := ExuIn2.Imm}
			when(
				opCode === Op.Jal | opCode === Op.Ijalr	|
				(opCode === Op.Icsr & io.waterIfId.instr(14,12) === 0.U(3.W))
			){io.waterIdEx.enJcod := true.B}
			switch(opCode){
				is(Op.Uauipc)	{io.waterIdEx.alu := ExuAlu.Add}
				is(Op.Ialu)		{
					switch(io.waterIfId.instr(14,12)){
						is(0b000){io.waterIdEx.alu := ExuAlu.Add}
						is(0b010){io.waterIdEx.alu := ExuAlu.Slt}
						is(0b011){io.waterIdEx.alu := ExuAlu.Sltu}
						is(0b100){io.waterIdEx.alu := ExuAlu.Xor}
						is(0b110){io.waterIdEx.alu := ExuAlu.Or}
						is(0b111){io.waterIdEx.alu := ExuAlu.And}
						is(0b001){when(io.waterIfId.instr(31,25) === 0.U(7.W)){io.waterIdEx.alu := ExuAlu.Sll}}
						is(0b101){
							switch(io.waterIfId.instr(31,25)){
							    is(0b0000000){io.waterIdEx.alu := ExuAlu.Srl}
								is(0b0100000){io.waterIdEx.alu := ExuAlu.Sra}
							}
						}
					}
				}
				is(Op.Ralu)		{
					switch(io.waterIfId.instr(31,25)){
						is(0b0000000){
							switch(io.waterIfId.instr(14,12)){
								is(0b000){io.waterIdEx.alu := ExuAlu.Add}
								is(0b010){io.waterIdEx.alu := ExuAlu.Slt}
								is(0b011){io.waterIdEx.alu := ExuAlu.Sltu}
								is(0b100){io.waterIdEx.alu := ExuAlu.Xor}
								is(0b110){io.waterIdEx.alu := ExuAlu.Or}
								is(0b111){io.waterIdEx.alu := ExuAlu.And}
								is(0b001){io.waterIdEx.alu := ExuAlu.Sll}
								is(0b101){io.waterIdEx.alu := ExuAlu.Srl}
							}
						}
						is(0b0100000){
							switch(io.waterIfId.instr(14,12)){
								is(0b000){io.waterIdEx.alu := ExuAlu.Sub}
								is(0b101){io.waterIdEx.alu := ExuAlu.Sra}
							}
						}
					}
				}
				is(Op.Jal)		{io.waterIdEx.alu := ExuAlu.ImPc}//ImR1,ImPc,Csr
				is(Op.Ijalr)	{io.waterIdEx.alu := ExuAlu.ImR1}
				is(Op.Iload)	{io.waterIdEx.alu := ExuAlu.ImR1}
				is(Op.Icsr)		{io.waterIdEx.alu := ExuAlu.Csr}
				is(Op.Branch)	{io.waterIdEx.alu := ExuAlu.ImPc}
				is(Op.Store)	{io.waterIdEx.alu := ExuAlu.ImR1}
				is(Op.Ilui)		{io.waterIdEx.alu := ExuAlu.Imm}
			}//TODO:还需要一个错误处理
			switch(opCode){
				is(Op.Iload)	{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Ialu)		{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Uauipc)	{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Store)	{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Ralu)		{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Ului)		{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Branch)	{io.waterIdEx.res := ExuRes.Null}
				//TODO:地址好像会冲突
			}
		}
	}
}