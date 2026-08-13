import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Idu(val Yosys:Boolean=false) extends Module{
	val in = IO(new Bundle{
		val pipe	= Flipped(new PipeIfId())
		val imme	= Flipped(new ImmeExId())
	})
	val out = IO(new Bundle{
		val pipe	= new PipeIdEx()
		val imme	= new ImmeIdIf()
	})
	val pipeReset	= reset.asBool||in.imme.jump
	val pipeRes		= PipeReg(pipeReset,IfuRes.Null			,out.imme.ready,in.pipe.res		)
	val pipePc		= PipeReg(pipeReset,0.U((BitWidth-2).W)	,out.imme.ready,in.pipe.pc		)
	val pipeInstr	= PipeReg(pipeReset,0.U(BitWidth.W)		,out.imme.ready,in.pipe.instr	)

	//默认值
	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= 0.U
	out.pipe.result	:= 0.U
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= CsrOp.Null
	out.pipe.csrAddr:= 0.U//Illegal Instruction
	out.pipe.lsuAddr:= LsuAddr.B//000
	out.pipe.lsuOp	:= LsuOp.Null
	out.pipe.fenceI	:= false.B
	out.pipe.r2		:= in.imme.r2Out
	out.pipe.r1		:= in.imme.r1Out
	out.pipe.csrMesg:= in.imme.csrOut
	out.pipe.enJcod	:= false.B
	out.pipe.enBpu	:= false.B
	out.pipe.alu	:= ExuAlu.Null
	out.pipe.bfu	:= ExuBfu.Null
	out.pipe.csr	:= ExuCsr.Null
	out.pipe.res	:= ExuRes.Alu
	out.pipe.in1	:= ExuIn1.R1
	out.pipe.in2	:= ExuIn2.R2

	in.imme.r1Addr	:= 0.U
	in.imme.r2Addr	:= 0.U
	in.imme.csrAddr	:= 0.U

	val opCode	= pipeInstr( 6, 0)
	val rdAddr	= pipeInstr( 6+RegWidth, 7)
	val funct3	= pipeInstr(14,12)
	val r1Addr	= pipeInstr(14+RegWidth,15)
	val r2Addr	= pipeInstr(19+RegWidth,20)
	val funct7	= pipeInstr(31,25)

	val bfuValid = WireInit(true.B)
	val lsuValid = WireInit(true.B)
	val aluValid = WireInit(true.B)
	val csrValid = WireInit(true.B)

	val csrOp	= WireInit(CsrOp.Null)
	val csrMesg = WireInit(in.imme.csrOut)
	
	val (opEnum,opValid) = Op.safe(opCode)

	switch(pipeRes){is(IfuRes.Valid){
		when(opValid){
			switch(opEnum){
				is(Op.Ului)		{out.pipe.result := Cat(pipeInstr(31,12),0.U(12.W))}
				is(Op.Uauipc)	{out.pipe.result := Cat(pipeInstr(31,12),0.U(12.W))}
				is(Op.Store)	{out.pipe.result := Cat(Fill(20,pipeInstr(31)),pipeInstr(31,25),pipeInstr(11,7))}
				is(Op.Ialu)		{out.pipe.result := Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20))}
				is(Op.Ijalr)	{out.pipe.result := Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20))}
				is(Op.Iload)	{out.pipe.result := Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20))}
				is(Op.Branch)	{out.pipe.result := Cat(Fill(20,pipeInstr(31)),pipeInstr(7),pipeInstr(30,25),pipeInstr(11,8),0.U(1.W))}
				is(Op.Jal)		{out.pipe.result := Cat(Fill(12,pipeInstr(31)),pipeInstr(19,12),pipeInstr(20),pipeInstr(30,21),0.U(1.W))}
				is(Op.Icsr)		{out.pipe.result := in.imme.csrOut}
			}
			when(
				opEnum === Op.Jal || opEnum === Op.Ijalr ||
				(opEnum === Op.Icsr & funct3 === 0.U(3.W))
			){out.pipe.enJcod := true.B}
			when(opEnum === Op.Jal || opEnum === Op.Branch){out.pipe.enBpu := true.B}
			switch(opEnum){
				is(Op.Uauipc){out.pipe.alu := ExuAlu.Add}
				is(Op.Ialu){
					val (aluEnum,_) = ExuAlu.safe(Cat(0.U(1.W),funct3))
					out.pipe.alu := aluEnum
					switch(aluEnum){
						is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
						is(ExuAlu.Srl){
							aluValid := false.B
							switch(funct7){
							    is(0b0000000.U){out.pipe.alu := ExuAlu.Srl;aluValid := true.B}
								is(0b0100000.U){out.pipe.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Ralu){
					val (aluEnum,_) = ExuAlu.safe(funct3)
					aluValid := false.B
					switch(funct7){
						is(0b0000000.U){out.pipe.alu := aluEnum;aluValid := true.B}
						is(0b0100000.U){switch(aluEnum){
								is(ExuAlu.Add){out.pipe.alu := ExuAlu.Sub;aluValid := true.B}
								is(ExuAlu.Srl){out.pipe.alu := ExuAlu.Sra;aluValid := true.B}
							}
						}
					}
				}
				is(Op.Jal)		{out.pipe.alu := ExuAlu.Add}
				is(Op.Ijalr)	{out.pipe.alu := ExuAlu.Jalr}
				is(Op.Iload)	{out.pipe.alu := ExuAlu.Add}
				is(Op.Icsr)		{out.pipe.alu := ExuAlu.Csr}
				is(Op.Branch)	{out.pipe.alu := ExuAlu.Add}
				is(Op.Store)	{out.pipe.alu := ExuAlu.Add}
				is(Op.Ului)		{out.pipe.alu := ExuAlu.Imm}
			}
			switch(opEnum){
				is(Op.Uauipc)	{out.pipe.in1 := ExuIn1.Pc}
				is(Op.Jal)		{out.pipe.in1 := ExuIn1.Pc}
				is(Op.Branch)	{out.pipe.in1 := ExuIn1.Pc}
			}
			switch(opEnum){
				is(Op.Uauipc)	{out.pipe.in2 := ExuIn2.Imm}
				is(Op.Ului)		{out.pipe.in2 := ExuIn2.Imm}
				is(Op.Ialu)		{out.pipe.in2 := ExuIn2.Imm}
				is(Op.Jal)		{out.pipe.in2 := ExuIn2.Imm}
				is(Op.Ijalr)	{out.pipe.in2 := ExuIn2.Imm}
				is(Op.Iload)	{out.pipe.in2 := ExuIn2.Imm}
				is(Op.Branch)	{out.pipe.in2 := ExuIn2.Imm}
				is(Op.Store)	{out.pipe.in2 := ExuIn2.Imm}
			}
			switch(opEnum){
				is(Op.Iload)	{out.pipe.res := ExuRes.Alu}
				is(Op.Ialu)		{out.pipe.res := ExuRes.Alu}
				is(Op.Uauipc)	{out.pipe.res := ExuRes.Alu}
				is(Op.Store)	{out.pipe.res := ExuRes.Alu}
				is(Op.Ralu)		{out.pipe.res := ExuRes.Alu}
				is(Op.Ului)		{out.pipe.res := ExuRes.Alu}
				is(Op.Branch)	{out.pipe.res := ExuRes.Null}
				is(Op.Ijalr)	{out.pipe.res := ExuRes.Snpc}
				is(Op.Jal)		{out.pipe.res := ExuRes.Snpc}
				is(Op.Icsr)		{out.pipe.res := ExuRes.Csr}
			}
			when(opEnum === Op.Branch){
				val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
				bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
				when(bfuValid){out.pipe.bfu := bfuEnum}
			}
			switch(opEnum){
				is(Op.Store){out.pipe.lsuOp := LsuOp.Store}
				is(Op.Iload){out.pipe.lsuOp := LsuOp.Load}
			}
			when(opEnum === Op.Iload || opEnum === Op.Store){
				val (lsuEnum,lsuValidinside) = LsuAddr.safe(funct3)
				lsuValid := lsuValidinside
				when(lsuValidinside){out.pipe.lsuAddr := lsuEnum}
			}
			out.pipe.rdAddr := rdAddr
			switch(opEnum){
				is(Op.Store)	{out.pipe.rdAddr := 0.U}
				is(Op.Branch)	{out.pipe.rdAddr := 0.U}
				is(Op.Icsr)		{out.pipe.rdAddr := Mux(funct3 === 0.U(3.W),0.U(5.W),rdAddr)}
			}
			in.imme.r1Addr := r1Addr
			switch(opEnum){//反选
			    is(Op.Ului)		{in.imme.r1Addr := 0.U}
				is(Op.Uauipc)	{in.imme.r1Addr := 0.U}
				is(Op.Jal)		{in.imme.r1Addr := 0.U}
			}
			switch(opEnum){
				is(Op.Store)	{in.imme.r2Addr := r2Addr}
				is(Op.Branch)	{in.imme.r2Addr := r2Addr}
				is(Op.Ralu)		{in.imme.r2Addr := r2Addr}
			}
			when(opEnum === Op.Icsr){
				switch(funct3){
					is(0b000.U){
						out.pipe.csr := ExuCsr.Null;
						when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0011000_00010_00000_00000.U){in.imme.csrAddr := CsrAddr.Mepc.asUInt}
						.otherwise{in.imme.csrAddr := CsrAddr.Mtvec.asUInt}
						}
					is(0b001.U){out.pipe.csr := ExuCsr.Write;	in.imme.csrAddr := Cat(funct7,r2Addr)}
					is(0b010.U){out.pipe.csr := ExuCsr.Read;	in.imme.csrAddr := Cat(funct7,r2Addr)}
					//TODO:0b010这个地方有待验证，原本是(oIfId.code.r1=='0)?NACSR:RACSR;
				}
				csrValid := false.B
				switch(funct3){
					is(0b000.U){
					when(Cat(funct7,pipeInstr(24,15),pipeInstr(11,7)) === 0b0000000_00000_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0xbL.U}//ECALL from M-mode
					when(Cat(funct7,pipeInstr(24,15),pipeInstr(11,7)) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0x3L.U}//Breakpoint
					when(Cat(funct7,pipeInstr(24,15),pipeInstr(11,7)) === 0b0011000_00010_00000_00000.U){csrOp := CsrOp.Mret;csrValid := true.B;}
					}
					is(0b001.U){out.pipe.csrAddr := Cat(0.U(8.W),funct7,r2Addr);csrOp := CsrOp.Write;csrValid := true.B}
					is(0b010.U){out.pipe.csrAddr := Cat(0.U(8.W),funct7,r2Addr);csrOp := Mux(r1Addr === 0.U(5.W),CsrOp.Null,CsrOp.Write);csrValid := true.B}
				}
			}
			out.pipe.fenceI := pipeInstr === 0x0000100F.U
		}
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			out.pipe.valid	:= in.imme.valid
			out.pipe.csrOp	:= csrOp
			out.pipe.csrMesg:= csrMesg
		}
		.otherwise{
			out.pipe.csrOp	:= CsrOp.Trap
			out.pipe.csrMesg:= 2.U//非法指令
			out.pipe.csrAddr:= pipeInstr//mtval
		}
		}
		is(IfuRes.Un4b){out.pipe.csrMesg:= 0.U;out.pipe.csrAddr := Cat(pipePc,0.U(2.W))}//Instruction address misaligned
		is(IfuRes.Fall){out.pipe.csrMesg:= 1.U;out.pipe.csrAddr := Cat(pipePc,0.U(2.W))}//Instruction access fault
	}

	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.ready	:= (in.imme.ready && in.imme.valid) || pipeRes === IfuRes.Null
	out.imme.jbtb	:= in.imme.jbtb
	out.imme.jbpu	:= in.imme.jbpu
	out.imme.jump	:= in.imme.jump && (in.imme.addr(31,2)=/=in.pipe.pc || pipeRes===IfuRes.Valid || ~in.imme.jbtb)

	if(Yosys == false){
		dontTouch(pipeReset)
	}

}