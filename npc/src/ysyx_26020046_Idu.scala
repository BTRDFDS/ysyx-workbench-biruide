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
	val pipeRes		= PipeReg(pipeReset	,IfuRes.Null			,out.imme.ready||pipeReset,in.pipe.res)
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

	out.pipe.update := IfuUpdate.Null
	out.pipe.fenceI := pipeInstr === 0x0000100F.U
	out.pipe.jump	:= false.B

	out.pipe.alu	:= ExuAlu.Null
	out.pipe.bfu	:= ExuBfu.Null
	out.pipe.csr	:= ExuCsr.Null
	out.pipe.res	:= ExuRes.Alu
	out.pipe.in1	:= ExuIn1.R1
	out.pipe.in2	:= ExuIn2.R2

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
	out.pipe.rdAddr:= Mux(opEnum===Op.Store || opEnum===Op.Branch,0.U,pipeInstr( 6+RegWidth, 7))

	out.pipe.update := Mux(opEnum === Op.Jal || opEnum === Op.Ijalr || opEnum === Op.Branch,
		Mux1H(Seq(
			(opEnum === Op.Jal)		-> IfuUpdate.Jal,
			(opEnum === Op.Ijalr)	-> IfuUpdate.Jalr,
			(opEnum === Op.Branch)	-> IfuUpdate.Branch,
		)),IfuUpdate.Null)
	out.pipe.result := Mux1H(Seq(
		(opEnum === Op.Ului)	-> Cat(pipeInstr(31,12),0.U(12.W)),
		(opEnum === Op.Uauipc)	-> Cat(pipeInstr(31,12),0.U(12.W)),
		(opEnum === Op.Store)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,25),pipeInstr(11,7)),
		(opEnum === Op.Ialu)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Ijalr)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Iload)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(31,20)),
		(opEnum === Op.Branch)	-> Cat(Fill(20,pipeInstr(31)),pipeInstr(7),pipeInstr(30,25),pipeInstr(11,8),0.U(1.W)),
		(opEnum === Op.Jal)		-> Cat(Fill(12,pipeInstr(31)),pipeInstr(19,12),pipeInstr(20),pipeInstr(30,21),0.U(1.W)),
		(opEnum === Op.Icsr)	-> in.imme.csrOut,
		(opEnum === Op.Fence)	-> 0.U,
		(opEnum === Op.Ralu)	-> 0.U,
	))
	out.pipe.jump := opEnum === Op.Jal || opEnum === Op.Ijalr || Cat(pipeInstr(14,12),pipeInstr(6,0))===0x73.U(10.W)
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
						is(0b0000000.U){out.pipe.alu := ExuAlu.Srl}
						is(0b0100000.U){out.pipe.alu := ExuAlu.Sra}
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
	out.pipe.in1 := Mux(opEnum === Op.Branch || opEnum === Op.Uauipc || opEnum === Op.Jal,ExuIn1.Pc,ExuIn1.R1)
	out.pipe.in2 := MuxCase(ExuIn2.R2,Seq(//best//TODO
		(opEnum===Op.Iload)	-> ExuIn2.Imm,
		(opEnum===Op.Ialu)	-> ExuIn2.Imm,
		(opEnum===Op.Store)	-> ExuIn2.Imm,
		(opEnum===Op.Uauipc)-> ExuIn2.Imm,
	))
	switch(opEnum){//best
		is(Op.Branch)			{out.pipe.res := ExuRes.Null}
		is(Op.Ijalr,Op.Jal)		{out.pipe.res := ExuRes.Snpc}
		is(Op.Ului,Op.Icsr)		{out.pipe.res := ExuRes.Imm}
	}
	when(opEnum === Op.Branch){
		val (bfuEnum,bfuValidAll) = ExuBfu.safe(funct3)
		bfuValid := bfuValidAll & funct3 =/= ExuBfu.Null.asUInt
		when(bfuValid){out.pipe.bfu := bfuEnum}
	}
	switch(opEnum){//best
		is(Op.Iload){out.pipe.lsuOp := LsuOp.Load}
		is(Op.Store){out.pipe.lsuOp := LsuOp.Store}
	}
		val (lsuEnum,lsuValidinside) = LsuAddr.safe(funct3)
	when(opEnum === Op.Iload || opEnum === Op.Store){
		lsuValid := lsuValidinside
		when(lsuValidinside){out.pipe.lsuAddr := lsuEnum}
	}
	when(opEnum === Op.Icsr){
		switch(funct3){
			is(0b000.U){
				out.pipe.csr := ExuCsr.Null
				when(Cat(pipeInstr(21,20)) === 0b10.U)
							{in.imme.csrAddr := CsrAddr.Mepc.asUInt	}
				.otherwise	{in.imme.csrAddr := CsrAddr.Mtvec.asUInt}
				}
			is(0b001.U){out.pipe.csr := ExuCsr.Write;	in.imme.csrAddr := pipeInstr(31,20)}
			is(0b010.U){out.pipe.csr := ExuCsr.Read;	in.imme.csrAddr := pipeInstr(31,20)}
		}
		csrValid := false.B
		switch(funct3){
			is(0b000.U){switch(Cat(pipeInstr(21,20))){
				is(0b00.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0xbL.U}
				is(0b01.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0x3L.U}
				is(0b10.U){csrOp := CsrOp.Mret;csrValid := true.B;}
			}}
			is(0b001.U){csrOp := CsrOp.Write;csrValid := true.B}
			is(0b010.U){csrOp := Mux(rdAddr === 0.U,CsrOp.Null,CsrOp.Write);csrValid := true.B}
		}
	}
	switch(pipeRes){is(IfuRes.Valid){
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			out.pipe.valid := in.imme.valid
			out.pipe.csrOp	:= csrOp
			out.pipe.csrMesg:= csrMesg
		}.otherwise{
			out.pipe.csrOp	:= CsrOp.Trap
			out.pipe.csrMesg:= 2.U//非法指令
		}
		}
		is(IfuRes.Un4b){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 0.U}//地址对齐
		is(IfuRes.Fall){out.pipe.csrOp	:= CsrOp.Trap;out.pipe.csrMesg:= 1.U}//读错
	}
	in.imme.r1Addr := Mux(opEnum === Op.Ului || opEnum === Op.Uauipc || opEnum === Op.Fence || opEnum === Op.Jal,0.U,r1Addr)
	in.imme.r2Addr := Mux(opEnum === Op.Ralu || opEnum === Op.Branch || opEnum === Op.Store,r2Addr,0.U)

	out.imme.addr	:= in.imme.addr
	out.imme.pc		:= in.imme.pc
	out.imme.ready	:= (in.imme.ready && in.imme.valid) || pipeRes === IfuRes.Null

	out.imme.reloca	:= in.imme.reloca
	out.imme.update	:= in.imme.update

	if(Yosys == false){
		dontTouch(pipeReset)
	}

}