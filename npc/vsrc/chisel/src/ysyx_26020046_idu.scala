import chisel3._
import chisel3.util._
class ysyx_26020046_Idu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module{
	val io = IO(new Bundle{
		val waterIn		= Flipped(new WaterIfId(Width))
		val waterOut	= new WaterIdEx(Width,RegNum,CsrWidth)
		val immOut		= new ImmBefore()
		val immIn		= Flipped(new ImmAfter(Width,RegNum,CsrWidth))
	})
	//默认值
	io.waterOut.valid	:= false.B
	io.waterOut.rdAddr	:= 0.U
	io.waterOut.result	:= 0.U
	io.waterOut.pc		:= io.waterIn.pc
	io.waterOut.csrOp	:= CsrOp.Trap
	io.waterOut.csrAddr	:= 2.U//Illegal Instruction
	io.waterOut.enSave	:= false.B
	io.waterOut.enLoad	:= false.B
	io.waterOut.lsuOp	:= LsuOp.Null
	io.waterOut.r2		:= io.immIn.r2Out
	io.waterOut.r1		:= io.immIn.r1Out
	io.waterOut.csrMesg	:= io.immIn.csrOut
	io.waterOut.enJcod	:= false.B
	io.waterOut.alu		:= ExuAlu.Null
	io.waterOut.bfu		:= ExuBfu.Null
	io.waterOut.csr		:= ExuCsr.Null
	io.waterOut.res		:= ExuRes.Alu
	io.waterOut.In1		:= ExuIn1.R1
	io.waterOut.In2		:= ExuIn2.R2

	io.immOut.ready		:= io.immIn.ready
	io.immOut.wash		:= io.immIn.wash
	io.immOut.addr		:= io.immIn.addr

	io.immIn.r1Addr	:= 0.U
	io.immIn.r2Addr	:= 0.U
	io.immIn.csrAddr	:= 0.U

	switch(io.waterIn.res){is(IfuRes.Valid){
		val opCode	= io.waterIn.instr( 6, 0)
		val rdAddr	= io.waterIn.instr(11, 7)
		val funct3	= io.waterIn.instr(14,12)
		val r1Addr	= io.waterIn.instr(19,15)
		val r2Addr	= io.waterIn.instr(24,20)
		val funct7	= io.waterIn.instr(31,25)

		val bfuValid = WireInit(true.B)
		val lsuValid = WireInit(true.B)
		val aluValid = WireInit(true.B)
		val csrValid = WireInit(true.B)

		val csrOp	= WireInit(CsrOp.Null)
		val csrMesg = WireInit(0.U(Width.W))

		val (opEnum,opValid) = Op.safe(opCode)
		when(opValid){
			switch(opEnum){
				is(Op.Ului)		{io.waterOut.result := Cat(io.waterIn.instr(31,12),0.U(12.W))}
				is(Op.Uauipc)	{io.waterOut.result := Cat(io.waterIn.instr(31,12),0.U(12.W))}
				is(Op.Store)	{io.waterOut.result := Cat(Fill(20,io.waterIn.instr(31)),io.waterIn.instr(31,25),io.waterIn.instr(11,7))}
				is(Op.Ialu)		{io.waterOut.result := Cat(Fill(20,io.waterIn.instr(31)),io.waterIn.instr(31,20))}
				is(Op.Ijalr)	{io.waterOut.result := Cat(Fill(20,io.waterIn.instr(31)),io.waterIn.instr(31,20))}
				is(Op.Iload)	{io.waterOut.result := Cat(Fill(20,io.waterIn.instr(31)),io.waterIn.instr(31,20))}
				is(Op.Branch)	{io.waterOut.result := Cat(Fill(20,io.waterIn.instr(31)),io.waterIn.instr(7),io.waterIn.instr(30,25),io.waterIn.instr(11,8),0.U(1.W))}
				is(Op.Jal)		{io.waterOut.result := Cat(Fill(12,io.waterIn.instr(31)),io.waterIn.instr(19,12),io.waterIn.instr(20),io.waterIn.instr(30,21),0.U(1.W))}
			}
			when(opEnum === Op.Uauipc){io.waterOut.In1 := ExuIn1.Pc}
			when(opEnum === Op.Ului | opEnum === Op.Ialu){io.waterOut.In2 := ExuIn2.Imm}
			when(
				opEnum === Op.Jal | opEnum === Op.Ijalr	|
				(opEnum === Op.Icsr & funct3 === 0.U(3.W))
			){io.waterOut.enJcod := true.B}
			switch(opEnum){
				is(Op.Uauipc){io.waterOut.alu := ExuAlu.Add}
				is(Op.Ialu){
					val (aluEnum,_) = ExuAlu.safe(Cat(0.U(1.W),funct3))
					io.waterOut.alu := aluEnum
					switch(aluEnum){
						is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
						is(ExuAlu.Srl){
							aluValid := false.B
							switch(funct7){
							    is(0b0000000.U){io.waterOut.alu := ExuAlu.Srl;aluValid := true.B}
								is(0b0100000.U){io.waterOut.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Ralu){
					val (aluEnum,_) = ExuAlu.safe(funct3)
					aluValid := false.B
					switch(funct7){
						is(0b0000000.U){io.waterOut.alu := aluEnum;aluValid := true.B}
						is(0b0100000.U){switch(aluEnum){
								is(ExuAlu.Add){io.waterOut.alu := ExuAlu.Sub;aluValid := true.B}
								is(ExuAlu.Srl){io.waterOut.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Jal)		{io.waterOut.alu := ExuAlu.ImPc}
				is(Op.Ijalr)	{io.waterOut.alu := ExuAlu.ImR1}
				is(Op.Iload)	{io.waterOut.alu := ExuAlu.ImR1}
				is(Op.Icsr)		{io.waterOut.alu := ExuAlu.Csr}
				is(Op.Branch)	{io.waterOut.alu := ExuAlu.ImPc}
				is(Op.Store)	{io.waterOut.alu := ExuAlu.ImR1}
				is(Op.Ului)		{io.waterOut.alu := ExuAlu.Imm}
			}
			switch(opEnum){
				is(Op.Iload)	{io.waterOut.res := ExuRes.Alu}
				is(Op.Ialu)		{io.waterOut.res := ExuRes.Alu}
				is(Op.Uauipc)	{io.waterOut.res := ExuRes.Alu}
				is(Op.Store)	{io.waterOut.res := ExuRes.Alu}
				is(Op.Ralu)		{io.waterOut.res := ExuRes.Alu}
				is(Op.Ului)		{io.waterOut.res := ExuRes.Alu}
				is(Op.Branch)	{io.waterOut.res := ExuRes.Null}
				is(Op.Ijalr)	{io.waterOut.res := ExuRes.Snpc}
				is(Op.Jal)		{io.waterOut.res := ExuRes.Snpc}
				is(Op.Icsr)		{io.waterOut.res := ExuRes.Csr}
			}
			when(opEnum === Op.Branch){
				val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
				bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
				when(bfuValid){io.waterOut.bfu := bfuEnum}
			}	
			io.waterOut.enSave := opEnum === Op.Store
			io.waterOut.enLoad := opEnum === Op.Iload
			when(opEnum === Op.Iload | opEnum === Op.Store){
				val (lsuEnum,lsuValidAll) = LsuOp.safe(funct3)
				lsuValid := lsuValidAll & funct3 =/= LsuOp.Null.asUInt
				when(lsuValid){io.waterOut.lsuOp := lsuEnum}
			}
			io.waterOut.rdAddr := rdAddr
			switch(opEnum){
				is(Op.Store)	{io.waterOut.rdAddr := 0.U(5.W)}
				is(Op.Branch)	{io.waterOut.rdAddr := 0.U(5.W)}
				is(Op.Icsr)		{io.waterOut.rdAddr := Mux(funct3 === 0.U(3.W),0.U(5.W),rdAddr)}
			}
			io.immIn.r1Addr := r1Addr
			switch(opEnum){//反选
			    is(Op.Ului)		{io.immIn.r1Addr := 0.U(5.W)}
				is(Op.Uauipc)	{io.immIn.r1Addr := 0.U(5.W)}
				is(Op.Jal)		{io.immIn.r1Addr := 0.U(5.W)}
			}
			switch(opEnum){
				is(Op.Store)	{io.immIn.r2Addr := r2Addr}
				is(Op.Branch)	{io.immIn.r2Addr := r2Addr}
				is(Op.Ralu)		{io.immIn.r2Addr := r2Addr}
			}
			when(opEnum === Op.Icsr){
				switch(funct3){
					is(0b000.U){io.waterOut.csr := ExuCsr.Null;	io.immIn.csrAddr := CsrAddr.Mepc.asUInt}
					is(0b001.U){io.waterOut.csr := ExuCsr.Write;io.immIn.csrAddr := Cat(funct7,r2Addr)}
					is(0b010.U){io.waterOut.csr := ExuCsr.Read;	io.immIn.csrAddr := Cat(funct7,r2Addr)}
					//TODO:0b010这个地方有待验证，原本是(oIfId.code.r1=='0)?NACSR:RACSR;
				}
				csrValid := false.B
				switch(funct3){
					is(0b000.U){
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 11.U}//ECALL from M-mode
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg :=  3.U}//Breakpoint
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0011000_00010_00000_00000.U){csrOp := CsrOp.Mret;csrValid := true.B;}
					}
					is(0b001.U){io.waterOut.csrAddr := Cat(funct7,r2Addr);csrOp := CsrOp.Write;csrValid := true.B}
					is(0b010.U){io.waterOut.csrAddr := Cat(funct7,r2Addr);csrOp := Mux(r1Addr === 0.U(5.W),CsrOp.Null,CsrOp.Write);csrValid := true.B}
				}
			}
		}
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			io.waterOut.valid	:= csrOp =/= CsrOp.Trap
			io.waterOut.csrOp	:= csrOp
			io.waterOut.csrMesg	:= csrMesg
		}}
		is(IfuRes.Un4b){io.waterOut.csrMesg:= 0.U}//Instruction address misaligned
		is(IfuRes.Fall){io.waterOut.csrMesg:= 1.U}//Instruction access fault
	}
}