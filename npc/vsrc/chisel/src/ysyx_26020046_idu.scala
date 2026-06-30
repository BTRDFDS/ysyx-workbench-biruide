import chisel3._
import chisel3.util._
class ysyx_26020046_Idu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module{
	val io = IO(new Bundle{
		val waterIfId	= Flipped(new WaterIfId(Width))
		val waterIdEx	= new WaterIdEx(Width,RegNum,CsrWidth)
		val immIdIf		= new ImmBefore()
		val immExId		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
	})
	//默认值
	io.waterIdEx.valid	:= false.B
	io.waterIdEx.rdAddr	:= 0.U
	io.waterIdEx.result	:= 0.U
	io.waterIdEx.pc		:= io.waterIfId.pc
	io.waterIdEx.csrOp	:= CsrOp.Trap
	io.waterIdEx.csrAddr:= 2.U//Illegal Instruction
	io.waterIdEx.enSave	:= false.B
	io.waterIdEx.enLoad	:= false.B
	io.waterIdEx.lsuOp	:= LsuOp.Null
	io.waterIdEx.r2		:= io.immExId.r2Out
	io.waterIdEx.r1		:= io.immExId.r1Out
	io.waterIdEx.csrMesg:= io.immExId.csrOut
	io.waterIdEx.enJcod	:= false.B
	io.waterIdEx.alu	:= ExuAlu.Null
	io.waterIdEx.bfu	:= ExuBfu.Null
	io.waterIdEx.csr	:= ExuCsr.Null
	io.waterIdEx.res	:= ExuRes.Alu
	io.waterIdEx.In1	:= ExuIn1.R1
	io.waterIdEx.In2	:= ExuIn2.R2

	io.immIdIf.ready	:= io.immExId.ready
	io.immIdIf.wash		:= io.immExId.wash
	io.immIdIf.addr		:= io.immExId.addr

	io.immExId.r1Addr	:= 0.U
	io.immExId.r2Addr	:= 0.U
	io.immExId.csrAddr	:= 0.U

	switch(io.waterIfId.res){is(IfuRes.Valid){
		val opCode	= io.waterIfId.instr( 6, 0)
		val rdAddr	= io.waterIfId.instr(11, 7)
		val funct3	= io.waterIfId.instr(14,12)
		val r1Addr	= io.waterIfId.instr(19,15)
		val r2Addr	= io.waterIfId.instr(24,20)
		val funct7	= io.waterIfId.instr(31,25)

		val bfuValid = WireInit(true.B)
		val lsuValid = WireInit(true.B)
		val aluValid = WireInit(true.B)
		val csrValid = WireInit(true.B)

		val csrOp	= WireInit(CsrOp.Null)
		val csrAddr = WireInit(0.U(CsrWidth.W))

		val (opEnum,opValid) = Op.safe(opCode)
		when(opValid){
			switch(opEnum){
				is(Op.Ului)		{io.waterIdEx.result := Cat(io.waterIfId.instr(31,12),0.U(12.W))}
				is(Op.Uauipc)	{io.waterIdEx.result := Cat(io.waterIfId.instr(31,12),0.U(12.W))}
				is(Op.Store)	{io.waterIdEx.result := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,25),io.waterIfId.instr(11,7))}
				is(Op.Ialu)		{io.waterIdEx.result := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Ijalr)	{io.waterIdEx.result := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Iload)	{io.waterIdEx.result := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(31,20))}
				is(Op.Branch)	{io.waterIdEx.result := Cat(Fill(20,io.waterIfId.instr(31)),io.waterIfId.instr(7),io.waterIfId.instr(30,25),io.waterIfId.instr(11,8),0.U(1.W))}
				is(Op.Jal)		{io.waterIdEx.result := Cat(Fill(12,io.waterIfId.instr(31)),io.waterIfId.instr(19,12),io.waterIfId.instr(20),io.waterIfId.instr(30,21),0.U(1.W))}
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
					val (aluEnum,_) = ExuAlu.safe(Cat(0.U(1.W),funct3))
					io.waterIdEx.alu := aluEnum
					switch(aluEnum){
						is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
						is(ExuAlu.Srl){
							aluValid := false.B
							switch(funct7){
							    is(0b0000000.U){io.waterIdEx.alu := ExuAlu.Srl;aluValid := true.B}
								is(0b0100000.U){io.waterIdEx.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Ralu){
					val (aluEnum,_) = ExuAlu.safe(funct3)
					aluValid := false.B
					switch(funct7){
						is(0b0000000.U){io.waterIdEx.alu := aluEnum;aluValid := true.B}
						is(0b0100000.U){switch(aluEnum){
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
				is(Op.Ului)		{io.waterIdEx.alu := ExuAlu.Imm}
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
			when(opEnum === Op.Branch){
				val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
				bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
				when(bfuValid){io.waterIdEx.bfu := bfuEnum}
			}	
			io.waterIdEx.enSave := opEnum === Op.Store
			io.waterIdEx.enLoad := opEnum === Op.Iload
			when(opEnum === Op.Iload | opEnum === Op.Store){
				val (lsuEnum,lsuValidAll) = LsuOp.safe(funct3)
				lsuValid := lsuValidAll & funct3 =/= LsuOp.Null.asUInt
				when(lsuValid){io.waterIdEx.lsuOp := lsuEnum}
			}
			io.waterIdEx.rdAddr := rdAddr
			switch(opEnum){
				is(Op.Store)	{io.waterIdEx.rdAddr := 0.U(5.W)}
				is(Op.Branch)	{io.waterIdEx.rdAddr := 0.U(5.W)}
				is(Op.Icsr)		{io.waterIdEx.rdAddr := Mux(funct3 === 0.U(3.W),0.U(5.W),rdAddr)}
			}
			io.immExId.r1Addr := r1Addr
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
			when(opEnum === Op.Icsr){
				switch(funct3){
					is(0b000.U){io.waterIdEx.csr := ExuCsr.Jump;	io.immExId.csrAddr := CsrAddr.Mepc.asUInt}
					is(0b001.U){io.waterIdEx.csr := ExuCsr.Write;	io.immExId.csrAddr := Cat(funct7,r2Addr)}
					is(0b010.U){io.waterIdEx.csr := ExuCsr.Read;	io.immExId.csrAddr := Cat(funct7,r2Addr)}
					//TODO:0b010这个地方有待验证，原本是(oIfId.code.r1=='0)?NACSR:RACSR;
				}
				csrValid := false.B
				switch(funct3){
					is(0b000.U){
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrAddr := 11.U}//ECALL from M-mode
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrAddr :=  3.U}//Breakpoint
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0011000_00010_00000_00000.U){csrOp := CsrOp.Mret;csrValid := true.B;}
					}
					is(0b001.U){csrAddr := Cat(funct7,r2Addr);csrOp := CsrOp.Write;csrValid := true.B}
					is(0b010.U){csrAddr := Cat(funct7,r2Addr);csrOp := Mux(r1Addr === 0.U(5.W),CsrOp.Null,CsrOp.Write);csrValid := true.B}
				}
			}
		}
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			io.waterIdEx.valid	:= csrOp =/= CsrOp.Trap
			io.waterIdEx.csrOp	:= csrOp
			io.immExId.csrAddr	:= csrAddr
		}}
		is(IfuRes.Un4b){io.waterIdEx.csrAddr:= 0.U}//Instruction address misaligned
		is(IfuRes.Fall){io.waterIdEx.csrAddr:= 1.U}//Instruction access fault
	}
}