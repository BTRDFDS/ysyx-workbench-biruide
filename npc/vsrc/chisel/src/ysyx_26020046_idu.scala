import chisel3._
import chisel3.util._
class ysyx_26020046_idu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module{
	val io = IO(new Bundle{
		val waterIfId	= Flipped(new WaterIfId(Width))
		val waterIdEx	= new WaterIdEx(Width,RegNum,CsrWidth)
		val immIdIf		= new Imbefore()
		val immExId		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
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
	io.waterIdEx.lsuOp	:= LsuOp.N
	io.waterIdEx.r2		:= io.immExId.r2Out
	io.waterIdEx.r1		:= io.immExId.r1Out
	io.waterIdEx.sr		:= io.immExId.csrOut
	io.waterIdEx.enJcod	:= false.B
	io.waterIdEx.alu	:= ExuAlu.Null
	io.waterIdEx.bfu	:= ExuBfu.Null
	io.waterIdEx.csr	:= ExuCsr.Null
	io.waterIdEx.Res	:= ExuRes.Alu
	io.waterIdEx.In1	:= ExuIn1.R1
	io.waterIdEx.In2	:= ExuIn2.R2

	io.immIdIf.valid	:= io.immExId.valid
	io.immIdIf.wash		:= io.immExId.wash
	io.immIdIf.addr		:= io.immExId.addr

	io.immExId.r1Addr	:= 0.U
	io.immExId.r2Addr	:= 0.U
	io.immExId.csrAddr	:= 0.U

	when(io.waterIfId.res === IfuRes.Valid){
		val opCode	= io.waterIfId.instr( 6, 0)
		val rdAddr	= io.waterIfId.instr(11, 7)
		val funct3	= io.waterIfId.instr(14,12)
		val r1Addr	= io.waterIfId.instr(19,15)
		val r2Addr	= io.waterIfId.instr(24,20)
		val funct7	= io.waterIfId.instr(31,25)

		val bfuValid	= WireInit(true.B)
		val lsuValid	= WireInit(true.B)
		val aluValid	= WireInit(true.B)
		val (opEnum,opValid) = Op.safe(opCode)
		when(opValid){
			switch(opEnum){
				is(Op.Ului)		{io.waterIdEx.res := Cat(io.waterIfId.instr(31,12),0.U(12.W))}
				is(Op.Uauipc)	{io.waterIdEx.res := Cat(io.waterIfId.instr(31,12),0.U(12.W))}
				is(Op.Store)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,25),io.waterIfId.instr(11,7))}
				is(Op.Ialu)		{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Ijalr)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Iload)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Branch)	{io.waterIdEx.res := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(7),io.waterIfId.instr(30,25),io.waterIfId.instr(11,8),0.U(1.W))}
				is(Op.Jal)		{io.waterIdEx.res := Cat(Fill(12,io.waterIfId.instr(31)),io.waterIfId.instr(19,12),io.waterIfId.instr(20),io.waterIfId.instr(30,21),0.U(1.W))}
			}
			when(opEnum === Op.Uauipc){io.waterIdEx.In1 := ExuIn1.Pc}
			when(opEnum === Op.Ului | opEnum === Op.Ialu){io.waterIdEx.In2 := ExuIn2.Imm}
			when(
				opEnum === Op.Jal | opEnum === Op.Ijalr	|
				(opEnum === Op.Icsr & funct3 === 0.U(3.W))
			){io.waterIdEx.enJcod := true.B}
			switch(opEnum){
				is(Op.Uauipc){io.waterIdEx.alu := ExuAlu.Add}
				is(Op.Ialu){
					val aluEnum = AluOp.safe(Cat(0.U(1.W),funct3))
					io.waterIdEx.alu := aluEnum
					switch(aluEnum){
						is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
						is(ExuAlu.Srl){
							aluValid := false.B
							switch(funct7){
							    is(0b0000000){io.waterIdEx.alu := ExuAlu.Srl;aluValid := true.B}
								is(0b0100000){io.waterIdEx.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Ralu){
					switch(funct7){
						val aluEnum = AluOp.safe(funct3)
						aluValid := false.B
						is(0b0000000){io.waterIdEx.alu := aluEnum;aluValid := true.B}
						is(0b0100000){switch(aluEnum){
								is(ExuAlu.Add){io.waterIdEx.alu := ExuAlu.Sub;aluValid := true.B}
								is(ExuAlu.Srl){io.waterIdEx.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Jal)		{io.waterIdEx.alu := ExuAlu.ImPc}
				is(Op.Ijalr)	{io.waterIdEx.alu := ExuAlu.ImR1}
				is(Op.Iload)	{io.waterIdEx.alu := ExuAlu.ImR1}
				is(Op.Icsr)		{io.waterIdEx.alu := ExuAlu.Csr}
				is(Op.Branch)	{io.waterIdEx.alu := ExuAlu.ImPc}
				is(Op.Store)	{io.waterIdEx.alu := ExuAlu.ImR1}
				is(Op.Ilui)		{io.waterIdEx.alu := ExuAlu.Imm}
			}//TODO:还需要一个错误处理
			switch(opEnum){
				is(Op.Iload)	{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Ialu)		{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Uauipc)	{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Store)	{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Ralu)		{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Ului)		{io.waterIdEx.res := ExuRes.Alu}
				is(Op.Branch)	{io.waterIdEx.res := ExuRes.Null}
				is(Op.Ijalr)	{io.waterIdEx.res := ExuRes.Snpc}
				is(Op.Jal)		{io.waterIdEx.res := ExuRes.Snpc}
				is(Op.Icsr)		{io.waterIdEx.res := ExuRes.Csr}
			}
			when(opCode === op.Branch){
				val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
				bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
				when(bfuValid){io.waterIdEx.bfu := bfuEnum}
			}
			when(opCode === op.Iload | opCode === op.Store){
				val (lsuEnum,lsuValidAll) = LsuOp.safe(funct3)
				lsuValid := lsuValidAll & funct3 =/= LsuOp.Null.asUInt
				when(lsuValid){io.waterIdEx.lsu := lsuEnum}
			}
			io.waterIdEx.enS := opCode =/= op.Store
			io.waterIdEx.enL := opCode =/= op.Iload

			io.waterIdEx.rdAddr := rdAddr
			switch(opEnum){
				is(Op.Store)	{io.waterIdEx.r1Addr := 0.U(5.W)}
				is(Op.Branch)	{io.waterIdEx.r1Addr := 0.U(5.W)}
				is(Op.Icsr)		{io.waterIdEx.r1Addr := Mux(funct3 === 0.U(3.W),0.U(5.W),rdAddr)}
			}
			ioimmExId.r1Addr := r1Addr
			switch(opEnum){//反选
			    is(Op.Ului)		{io.immExId.r1Addr := 0.U(5.W)}
				is(Op.Uauipc)	{io.immExId.r1Addr := 0.U(5.W)}
				is(Op.Jal)		{io.immExId.r1Addr := 0.U(5.W)}
			}
			switch(opEnum){
				is(Op.Store)	{io.immExId.r2Addr := r2Addr}
				is(Op.Branch)	{io.immExId.r2Addr := r2Addr}
				is(Op.Ralu)		{io.immExId.r2Addr := r2Addr}
			}

		}
	}
}