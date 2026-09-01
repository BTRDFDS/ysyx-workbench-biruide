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
	val pipeReset	= reset.asBool||in.imme.reloca
	val pipeRes		= PipeReg(pipeReset	,IfuRes.Null			,out.imme.ready,in.pipe.res		)
	val pipePc		= PipeReg(false.B	,0.U((BitWidth-2).W)	,out.imme.ready,in.pipe.pc		)
	val pipeInstr	= PipeReg(false.B	,0.U(BitWidth.W)		,out.imme.ready,in.pipe.instr	)

	//默认值
	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= pipeInstr( 6+RegWidth, 7)
	out.pipe.result	:= 0.U
	out.pipe.pc		:= pipePc
	out.pipe.csrOp	:= CsrOp.Null
	out.pipe.csrAddr:= pipeInstr(31,20)
	out.pipe.lsuAddr:= LsuAddr.B//000
	out.pipe.lsuOp	:= LsuOp.Null
	out.pipe.r2		:= in.imme.r2Out
	out.pipe.r1		:= in.imme.r1Out
	out.pipe.csrMesg:= in.imme.csrOut

	out.pipe.fenceI := pipeInstr === 0x0000100F.U
	out.pipe.jump	:= false.B
	out.pipe.update	:= IfuUpdate.Null

	out.pipe.alu	:= ExuAlu.Null
	out.pipe.bfu	:= ExuBfu.Null
	out.pipe.csr	:= ExuCsr.Null
	out.pipe.res	:= ExuRes.Alu
	out.pipe.in1	:= ExuIn1.R1
	out.pipe.in2	:= ExuIn2.R2

	in.imme.r1Addr	:= pipeInstr(14+RegWidth,15)
	in.imme.r2Addr	:= pipeInstr(19+RegWidth,20)
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

			when(opEnum === Op.Jal || opEnum === Op.Ijalr || Cat(pipeInstr(14,12),pipeInstr(6,0))===0x73.U(10.W)){out.pipe.jump := true.B}
			switch(opEnum){
				is(Op.Jal)		{out.pipe.update := IfuUpdate.Jal}
				is(Op.Branch)	{out.pipe.update := IfuUpdate.Branch}
				is(Op.Ijalr)	{out.pipe.update := IfuUpdate.Jalr}
			}

			switch(opEnum){
				is(Op.Uauipc){out.pipe.alu := ExuAlu.Add}
				is(Op.Ialu){
					val (aluEnum,_) = ExuAlu.safe(Cat(0.U(1.W),funct3))
					out.pipe.alu := aluEnum
					switch(aluEnum){
						is(ExuAlu.Sll){aluValid := funct7 === 0.U(7.W)}
						is(ExuAlu.Srl){
							aluValid := funct7===0b0000000.U || funct7===0b0100000.U
							switch(funct7){
							    is(0b0000000.U){out.pipe.alu := ExuAlu.Srl;}
								is(0b0100000.U){out.pipe.alu := ExuAlu.Sra;}
							}
						}
					}
				}
				is(Op.Fence)	{out.pipe.alu := ExuAlu.Null}
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
				is(Op.Ijalr)	{out.pipe.alu := ExuAlu.Null}
				is(Op.Jal)		{out.pipe.alu := ExuAlu.Null}
				is(Op.Icsr)		{out.pipe.alu := ExuAlu.Null}
				is(Op.Iload)	{out.pipe.alu := ExuAlu.Add}
				is(Op.Branch)	{out.pipe.alu := ExuAlu.Null}
				is(Op.Store)	{out.pipe.alu := ExuAlu.Add}
			}
			switch(opEnum){//bast
				is(Op.Uauipc)	{out.pipe.in1 := ExuIn1.Pc}
				is(Op.Jal)		{out.pipe.in1 := ExuIn1.Pc}
				is(Op.Branch)	{out.pipe.in1 := ExuIn1.Pc}
			}
			out.pipe.in2 := MuxCase(ExuIn2.R2,Seq(//best
				(opEnum===Op.Iload)	-> ExuIn2.Imm,
				(opEnum===Op.Ialu)	-> ExuIn2.Imm,
				(opEnum===Op.Store)	-> ExuIn2.Imm,
				(opEnum===Op.Uauipc)-> ExuIn2.Imm,
			))
			switch(opEnum){//best
				is(Op.Ijalr,Op.Jal)		{out.pipe.res := ExuRes.Snpc}
				is(Op.Ului,Op.Icsr)		{out.pipe.res := ExuRes.Imm}
				is(Op.Branch)	{out.pipe.res := ExuRes.Null}
			}
			when(opEnum === Op.Branch){
				val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
				bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
				when(bfuValid){out.pipe.bfu := bfuEnum}
			}
			switch(opEnum){//best
				is(Op.Store){out.pipe.lsuOp := LsuOp.Store}
				is(Op.Iload){out.pipe.lsuOp := LsuOp.Load}
			}
			when(opEnum === Op.Iload || opEnum === Op.Store){
				val (lsuEnum,lsuValidinside) = LsuAddr.safe(funct3)
				lsuValid := lsuValidinside
				when(lsuValidinside){out.pipe.lsuAddr := lsuEnum}
			}
			switch(opEnum){
				is(Op.Store)	{out.pipe.rdAddr := 0.U}
				is(Op.Branch)	{out.pipe.rdAddr := 0.U}
				// is(Op.Icsr)		{out.pipe.rdAddr := Mux(funct3 === 0.U(3.W),0.U(5.W),rdAddr)}
			}
			// in.imme.r1Addr := r1Addr//反选
			// switch(opEnum){//best
			//     is(Op.Ului)		{in.imme.r1Addr := 0.U}
			// 	is(Op.Uauipc)	{in.imme.r1Addr := 0.U}
			// 	is(Op.Jal)		{in.imme.r1Addr := 0.U}
			// }
			// switch(opEnum){//best
			// 	is(Op.Store)	{in.imme.r2Addr := r2Addr}
			// 	is(Op.Branch)	{in.imme.r2Addr := r2Addr}
			// 	is(Op.Ralu)		{in.imme.r2Addr := r2Addr}
			// }
			when(opEnum === Op.Icsr){
				switch(funct3){
					is(0b000.U){
						out.pipe.csr := ExuCsr.Null
						when(Cat(pipeInstr(31,15),pipeInstr(11,7)) === 0b0011000_00010_00000_00000.U)
									{in.imme.csrAddr := CsrAddr.Mepc.asUInt	}
						.otherwise	{in.imme.csrAddr := CsrAddr.Mtvec.asUInt}
						}
					is(0b001.U){out.pipe.csr := ExuCsr.Write;	in.imme.csrAddr := pipeInstr(31,20)}
					is(0b010.U){out.pipe.csr := ExuCsr.Read;	in.imme.csrAddr := pipeInstr(31,20)}
				}
				csrValid := false.B
				switch(funct3){
					is(0b000.U){switch(Cat(pipeInstr(31,15),pipeInstr(11,7))){
						is(0b0000000_00000_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0xbL.U}
						is(0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0x3L.U}
						is(0b0011000_00010_00000_00000.U){csrOp := CsrOp.Mret;csrValid := true.B;}
					}}
					is(0b001.U){csrOp := CsrOp.Write;csrValid := true.B}
					is(0b010.U){csrOp := Mux(rdAddr === 0.U,CsrOp.Null,CsrOp.Write);csrValid := true.B}
					// out.pipe.csrAddr := pipeInstr(31,20);
					// out.pipe.csrAddr := pipeInstr(31,20);
				}
			}
		}
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			out.pipe.valid	:= in.imme.valid
			out.pipe.csrOp	:= csrOp
			out.pipe.csrMesg:= csrMesg
		}
		.otherwise{
			out.pipe.csrOp	:= CsrOp.Trap
			out.pipe.csrMesg:= 2.U//非法指令
			// out.pipe.csrAddr:= pipeInstr//mtval
		}
		}
		is(IfuRes.Un4b){out.pipe.csrMesg:= 0.U;}//Instruction address misaligned
		is(IfuRes.Fall){out.pipe.csrMesg:= 1.U;}//Instruction access fault
// out.pipe.csrAddr := Cat(pipePc,0.U(2.W))
// out.pipe.csrAddr := Cat(pipePc,0.U(2.W))
	}

	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.ready	:= (in.imme.ready && in.imme.valid) || pipeRes === IfuRes.Null

	out.imme.reloca	:= in.imme.reloca
	out.imme.update	:= in.imme.update

	if(Yosys == false){
		dontTouch(pipeReset)
	}

}