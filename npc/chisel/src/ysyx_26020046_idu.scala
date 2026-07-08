import chisel3._
import chisel3.util._
class ysyx_26020046_Idu(val Width:Int=32, val RegNum:Int=32,val CsrWidth:Int=12) extends Module{
	val io = IO(new Bundle{
		val pipeIn	= Flipped(new PipeIfId(Width))
		val pipeOut	= new PipeIdEx(Width,RegNum,CsrWidth)
		val immeOut	= new ImmeBefore(Width)
		val immeIn	= Flipped(new ImmeAfter(Width,RegNum,CsrWidth))
	})
	//默认值
	io.pipeOut.valid	:= false.B
	io.pipeOut.rdAddr	:= 0.U
	io.pipeOut.result	:= 0.U
	io.pipeOut.pc		:= io.pipeIn.pc
	io.pipeOut.csrOp	:= CsrOp.Trap
	io.pipeOut.csrAddr	:= 2.U//Illegal Instruction
	io.pipeOut.enSave	:= false.B
	io.pipeOut.enLoad	:= false.B
	io.pipeOut.lsuOp	:= LsuOp.Null
	io.pipeOut.r2		:= io.immeIn.r2Out
	io.pipeOut.r1		:= io.immeIn.r1Out
	io.pipeOut.csrMesg	:= io.immeIn.csrOut
	io.pipeOut.enJcod	:= false.B
	io.pipeOut.alu		:= ExuAlu.Null
	io.pipeOut.bfu		:= ExuBfu.Null
	io.pipeOut.csr		:= ExuCsr.Null
	io.pipeOut.res		:= ExuRes.Alu
	io.pipeOut.In1		:= ExuIn1.R1
	io.pipeOut.In2		:= ExuIn2.R2

	io.immeOut.back	:= io.immeIn.back
	io.immeOut.addr	:= io.immeIn.addr

	io.immeIn.r1Addr	:= 0.U
	io.immeIn.r2Addr	:= 0.U
	io.immeIn.csrAddr	:= 0.U

	switch(io.pipeIn.res){is(IfuRes.Valid){
		val opCode	= io.pipeIn.instr( 6, 0)
		val rdAddr	= io.pipeIn.instr(11, 7)
		val funct3	= io.pipeIn.instr(14,12)
		val r1Addr	= io.pipeIn.instr(19,15)
		val r2Addr	= io.pipeIn.instr(24,20)
		val funct7	= io.pipeIn.instr(31,25)

		val bfuValid = WireInit(true.B)
		val lsuValid = WireInit(true.B)
		val aluValid = WireInit(true.B)
		val csrValid = WireInit(true.B)

		val csrOp	= WireInit(CsrOp.Null)
		val csrMesg = WireInit(0.U(Width.W))

		val (opEnum,opValid) = Op.safe(opCode)
		when(opValid){
			switch(opEnum){
				is(Op.Ului)		{io.pipeOut.result := Cat(io.pipeIn.instr(31,12),0.U(12.W))}
				is(Op.Uauipc)	{io.pipeOut.result := Cat(io.pipeIn.instr(31,12),0.U(12.W))}
				is(Op.Store)	{io.pipeOut.result := Cat(Fill(20,io.pipeIn.instr(31)),io.pipeIn.instr(31,25),io.pipeIn.instr(11,7))}
				is(Op.Ialu)		{io.pipeOut.result := Cat(Fill(20,io.pipeIn.instr(31)),io.pipeIn.instr(31,20))}
				is(Op.Ijalr)	{io.pipeOut.result := Cat(Fill(20,io.pipeIn.instr(31)),io.pipeIn.instr(31,20))}
				is(Op.Iload)	{io.pipeOut.result := Cat(Fill(20,io.pipeIn.instr(31)),io.pipeIn.instr(31,20))}
				is(Op.Branch)	{io.pipeOut.result := Cat(Fill(20,io.pipeIn.instr(31)),io.pipeIn.instr(7),io.pipeIn.instr(30,25),io.pipeIn.instr(11,8),0.U(1.W))}
				is(Op.Jal)		{io.pipeOut.result := Cat(Fill(12,io.pipeIn.instr(31)),io.pipeIn.instr(19,12),io.pipeIn.instr(20),io.pipeIn.instr(30,21),0.U(1.W))}
			}
			when(opEnum === Op.Uauipc){io.pipeOut.In1 := ExuIn1.Pc}
			when(opEnum === Op.Ului | opEnum === Op.Ialu){io.pipeOut.In2 := ExuIn2.Imm}
			when(
				opEnum === Op.Jal | opEnum === Op.Ijalr	|
				(opEnum === Op.Icsr & funct3 === 0.U(3.W))
			){io.pipeOut.enJcod := true.B}
			switch(opEnum){
				is(Op.Uauipc){io.pipeOut.alu := ExuAlu.Add}
				is(Op.Ialu){
					val (aluEnum,_) = ExuAlu.safe(Cat(0.U(1.W),funct3))
					io.pipeOut.alu := aluEnum
					switch(aluEnum){
						is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
						is(ExuAlu.Srl){
							aluValid := false.B
							switch(funct7){
							    is(0b0000000.U){io.pipeOut.alu := ExuAlu.Srl;aluValid := true.B}
								is(0b0100000.U){io.pipeOut.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Ralu){
					val (aluEnum,_) = ExuAlu.safe(funct3)
					aluValid := false.B
					switch(funct7){
						is(0b0000000.U){io.pipeOut.alu := aluEnum;aluValid := true.B}
						is(0b0100000.U){switch(aluEnum){
								is(ExuAlu.Add){io.pipeOut.alu := ExuAlu.Sub;aluValid := true.B}
								is(ExuAlu.Srl){io.pipeOut.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Jal)		{io.pipeOut.alu := ExuAlu.ImPc}
				is(Op.Ijalr)	{io.pipeOut.alu := ExuAlu.ImR1}
				is(Op.Iload)	{io.pipeOut.alu := ExuAlu.ImR1}
				is(Op.Icsr)		{io.pipeOut.alu := ExuAlu.Csr}
				is(Op.Branch)	{io.pipeOut.alu := ExuAlu.ImPc}
				is(Op.Store)	{io.pipeOut.alu := ExuAlu.ImR1}
				is(Op.Ului)		{io.pipeOut.alu := ExuAlu.Imm}
			}
			switch(opEnum){
				is(Op.Iload)	{io.pipeOut.res := ExuRes.Alu}
				is(Op.Ialu)		{io.pipeOut.res := ExuRes.Alu}
				is(Op.Uauipc)	{io.pipeOut.res := ExuRes.Alu}
				is(Op.Store)	{io.pipeOut.res := ExuRes.Alu}
				is(Op.Ralu)		{io.pipeOut.res := ExuRes.Alu}
				is(Op.Ului)		{io.pipeOut.res := ExuRes.Alu}
				is(Op.Branch)	{io.pipeOut.res := ExuRes.Null}
				is(Op.Ijalr)	{io.pipeOut.res := ExuRes.Snpc}
				is(Op.Jal)		{io.pipeOut.res := ExuRes.Snpc}
				is(Op.Icsr)		{io.pipeOut.res := ExuRes.Csr}
			}
			when(opEnum === Op.Branch){
				val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
				bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
				when(bfuValid){io.pipeOut.bfu := bfuEnum}
			}	
			io.pipeOut.enSave := opEnum === Op.Store
			io.pipeOut.enLoad := opEnum === Op.Iload
			when(opEnum === Op.Iload | opEnum === Op.Store){
				val (lsuEnum,lsuValidAll) = LsuOp.safe(funct3)
				lsuValid := lsuValidAll & funct3 =/= LsuOp.Null.asUInt
				when(lsuValid){io.pipeOut.lsuOp := lsuEnum}
			}
			io.pipeOut.rdAddr := rdAddr
			switch(opEnum){
				is(Op.Store)	{io.pipeOut.rdAddr := 0.U(5.W)}
				is(Op.Branch)	{io.pipeOut.rdAddr := 0.U(5.W)}
				is(Op.Icsr)		{io.pipeOut.rdAddr := Mux(funct3 === 0.U(3.W),0.U(5.W),rdAddr)}
			}
			io.immeIn.r1Addr := r1Addr
			switch(opEnum){//反选
			    is(Op.Ului)		{io.immeIn.r1Addr := 0.U(5.W)}
				is(Op.Uauipc)	{io.immeIn.r1Addr := 0.U(5.W)}
				is(Op.Jal)		{io.immeIn.r1Addr := 0.U(5.W)}
			}
			switch(opEnum){
				is(Op.Store)	{io.immeIn.r2Addr := r2Addr}
				is(Op.Branch)	{io.immeIn.r2Addr := r2Addr}
				is(Op.Ralu)		{io.immeIn.r2Addr := r2Addr}
			}
			when(opEnum === Op.Icsr){
				switch(funct3){
					is(0b000.U){io.pipeOut.csr := ExuCsr.Null;	io.immeIn.csrAddr := CsrAddr.Mepc.asUInt}
					is(0b001.U){io.pipeOut.csr := ExuCsr.Write;io.immeIn.csrAddr := Cat(funct7,r2Addr)}
					is(0b010.U){io.pipeOut.csr := ExuCsr.Read;	io.immeIn.csrAddr := Cat(funct7,r2Addr)}
					//TODO:0b010这个地方有待验证，原本是(oIfId.code.r1=='0)?NACSR:RACSR;
				}
				csrValid := false.B
				switch(funct3){
					is(0b000.U){
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 11.U}//ECALL from M-mode
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg :=  3.U}//Breakpoint
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0011000_00010_00000_00000.U){csrOp := CsrOp.Mret;csrValid := true.B;}
					}
					is(0b001.U){io.pipeOut.csrAddr := Cat(funct7,r2Addr);csrOp := CsrOp.Write;csrValid := true.B}
					is(0b010.U){io.pipeOut.csrAddr := Cat(funct7,r2Addr);csrOp := Mux(r1Addr === 0.U(5.W),CsrOp.Null,CsrOp.Write);csrValid := true.B}
				}
			}
		}
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			io.pipeOut.valid	:= csrOp =/= CsrOp.Trap
			io.pipeOut.csrOp	:= csrOp
			io.pipeOut.csrMesg	:= csrMesg
		}}
		is(IfuRes.Un4b){io.pipeOut.csrMesg:= 0.U}//Instruction address misaligned
		is(IfuRes.Fall){io.pipeOut.csrMesg:= 1.U}//Instruction access fault
	}
}