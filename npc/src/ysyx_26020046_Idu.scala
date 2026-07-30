import chisel3._
import chisel3.util._
import WidthConsts._
class ysyx_26020046_Idu extends Module{
	val in = IO(new Bundle{
		val pipe	= Flipped(new PipeIfId())
		val imme	= Flipped(new ImmeAfter())
	})
	val out = IO(new Bundle{
		val pipe	= new PipeIdEx()
		val imme	= new ImmeBefore()
	})
	//默认值
	out.pipe.valid	:= false.B
	out.pipe.rdAddr	:= 0.U
	out.pipe.result	:= 0.U
	out.pipe.pc		:= in.pipe.pc
	out.pipe.csrOp	:= CsrOp.Null
	out.pipe.csrAddr:= 0.U//Illegal Instruction
	out.pipe.lsuAddr:= LsuAddr.B//000
	out.pipe.lsuOp	:= LsuOp.Null
	out.pipe.r2		:= in.imme.r2Out
	out.pipe.r1		:= in.imme.r1Out
	out.pipe.csrMesg:= in.imme.csrOut
	out.pipe.enJcod	:= false.B
	out.pipe.alu	:= ExuAlu.Null
	out.pipe.bfu	:= ExuBfu.Null
	out.pipe.csr	:= ExuCsr.Null
	out.pipe.res	:= ExuRes.Alu
	out.pipe.In1	:= ExuIn1.R1
	out.pipe.In2	:= ExuIn2.R2

	out.imme.back	:= in.imme.back
	out.imme.addr	:= in.imme.addr

	in.imme.r1Addr	:= 0.U
	in.imme.r2Addr	:= 0.U
	in.imme.csrAddr	:= 0.U

	val opCode	= in.pipe.instr( 6, 0)
	val rdAddr	= in.pipe.instr(11, 7)
	val funct3	= in.pipe.instr(14,12)
	val r1Addr	= in.pipe.instr(19,15)
	val r2Addr	= in.pipe.instr(24,20)
	val funct7	= in.pipe.instr(31,25)

	val bfuValid = WireInit(true.B)
	val lsuValid = WireInit(true.B)
	val aluValid = WireInit(true.B)
	val csrValid = WireInit(true.B)

	val csrOp	= WireInit(CsrOp.Null)
	val csrMesg = WireInit(in.imme.csrOut)
	
	val (opEnum,opValid) = Op.safe(opCode)

	switch(in.pipe.res){is(IfuRes.Valid){
		when(opValid){
			switch(opEnum){
				is(Op.Ului)		{out.pipe.result := Cat(in.pipe.instr(31,12),0.U(12.W))}
				is(Op.Uauipc)	{out.pipe.result := Cat(in.pipe.instr(31,12),0.U(12.W))}
				is(Op.Store)	{out.pipe.result := Cat(Fill(20,in.pipe.instr(31)),in.pipe.instr(31,25),in.pipe.instr(11,7))}
				is(Op.Ialu)		{out.pipe.result := Cat(Fill(20,in.pipe.instr(31)),in.pipe.instr(31,20))}
				is(Op.Ijalr)	{out.pipe.result := Cat(Fill(20,in.pipe.instr(31)),in.pipe.instr(31,20))}
				is(Op.Iload)	{out.pipe.result := Cat(Fill(20,in.pipe.instr(31)),in.pipe.instr(31,20))}
				is(Op.Branch)	{out.pipe.result := Cat(Fill(20,in.pipe.instr(31)),in.pipe.instr(7),in.pipe.instr(30,25),in.pipe.instr(11,8),0.U(1.W))}
				is(Op.Jal)		{out.pipe.result := Cat(Fill(12,in.pipe.instr(31)),in.pipe.instr(19,12),in.pipe.instr(20),in.pipe.instr(30,21),0.U(1.W))}
				is(Op.Icsr)		{out.pipe.result := in.imme.csrOut}
			}
			when(
				opEnum === Op.Jal || opEnum === Op.Ijalr ||
				(opEnum === Op.Icsr & funct3 === 0.U(3.W))
			){out.pipe.enJcod := true.B}
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
				is(Op.Uauipc)	{out.pipe.In1 := ExuIn1.Pc}
				is(Op.Jal)		{out.pipe.In1 := ExuIn1.Pc}
				is(Op.Branch)	{out.pipe.In1 := ExuIn1.Pc}
			}
			switch(opEnum){
				is(Op.Uauipc)	{out.pipe.In2 := ExuIn2.Imm}
				is(Op.Ului)		{out.pipe.In2 := ExuIn2.Imm}
				is(Op.Ialu)		{out.pipe.In2 := ExuIn2.Imm}
				is(Op.Jal)		{out.pipe.In2 := ExuIn2.Imm}
				is(Op.Ijalr)	{out.pipe.In2 := ExuIn2.Imm}
				is(Op.Iload)	{out.pipe.In2 := ExuIn2.Imm}
				is(Op.Branch)	{out.pipe.In2 := ExuIn2.Imm}
				is(Op.Store)	{out.pipe.In2 := ExuIn2.Imm}
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
				is(Op.Store)	{out.pipe.rdAddr := 0.U(5.W)}
				is(Op.Branch)	{out.pipe.rdAddr := 0.U(5.W)}
				is(Op.Icsr)		{out.pipe.rdAddr := Mux(funct3 === 0.U(3.W),0.U(5.W),rdAddr)}
			}
			in.imme.r1Addr := r1Addr
			switch(opEnum){//反选
			    is(Op.Ului)		{in.imme.r1Addr := 0.U(5.W)}
				is(Op.Uauipc)	{in.imme.r1Addr := 0.U(5.W)}
				is(Op.Jal)		{in.imme.r1Addr := 0.U(5.W)}
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
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00000_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0xbL.U}//ECALL from M-mode
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0000000_00001_00000_00000.U){csrOp := CsrOp.Trap;csrValid := true.B;csrMesg := 0x3L.U}//Breakpoint
					when(Cat(funct7,r2Addr,r1Addr,rdAddr) === 0b0011000_00010_00000_00000.U){csrOp := CsrOp.Mret;csrValid := true.B;}
					}
					is(0b001.U){out.pipe.csrAddr := Cat(0.U(8.W),funct7,r2Addr);csrOp := CsrOp.Write;csrValid := true.B}
					is(0b010.U){out.pipe.csrAddr := Cat(0.U(8.W),funct7,r2Addr);csrOp := Mux(r1Addr === 0.U(5.W),CsrOp.Null,CsrOp.Write);csrValid := true.B}
				}
			}
		}
		when(opValid & aluValid & lsuValid & bfuValid & csrValid){
			// out.pipe.valid	:= csrOp =/= CsrOp.Trap
			out.pipe.valid	:= true.B
			out.pipe.csrOp	:= csrOp
			out.pipe.csrMesg:= csrMesg
		}
		.otherwise{
			out.pipe.csrOp	:= CsrOp.Trap
			out.pipe.csrMesg:= 2.U//非法指令
			out.pipe.csrAddr:= in.pipe.instr//mtval
		}
		}
		is(IfuRes.Un4b){out.pipe.csrMesg:= 0.U;out.pipe.csrAddr := in.pipe.pc}//Instruction address misaligned
		is(IfuRes.Fall){out.pipe.csrMesg:= 1.U;out.pipe.csrAddr := in.pipe.pc}//Instruction access fault
	}

	val iduChk = Module(new ysyx_26020046_IduChk)
	iduChk.clock := clock
	iduChk.io.cal	:= in.pipe.res === IfuRes.Valid && (opEnum === Op.Ialu	|| opEnum === Op.Ralu	)
	iduChk.io.jump	:= in.pipe.res === IfuRes.Valid && (opEnum === Op.Jal	|| opEnum === Op.Ijalr	)
	iduChk.io.imm	:= in.pipe.res === IfuRes.Valid && (opEnum === Op.Uauipc|| opEnum === Op.Ului	)
	iduChk.io.ls	:= in.pipe.res === IfuRes.Valid && (opEnum === Op.Store	|| opEnum === Op.Iload	)
	iduChk.io.csr	:= in.pipe.res === IfuRes.Valid && (opEnum === Op.Icsr)
	iduChk.io.br	:= in.pipe.res === IfuRes.Valid && (opEnum === Op.Branch)

}
class ysyx_26020046_IduChk extends ExtModule{
	val io = IO(new Bundle{
		val cal	= Input(Bool())
		val jump= Input(Bool())
		val imm	= Input(Bool())
		val ls	= Input(Bool())
		val csr	= Input(Bool())
		val br	= Input(Bool())
	})
	val clock = IO(Input(Clock()))
	setInline("ysyx_26020046_IduChk.sv",
	"""
	module ysyx_26020046_IduChk(
		input logic io_cal,
		input logic io_jump,
		input logic io_imm,
		input logic io_ls,
		input logic io_csr,
		input logic io_br,
		input logic clock
	);
	import "DPI-C" function void iduCal();
	import "DPI-C" function void iduJump();
	import "DPI-C" function void iduImm();
	import "DPI-C" function void iduLs();
	import "DPI-C" function void iduCsr();
	import "DPI-C" function void iduBr();
	always_ff@(posedge clock)begin
		if(io_cal)	iduCal();
		if(io_jump)	iduJump();
		if(io_imm)	iduImm();
		if(io_ls)	iduLs();
		if(io_csr)	iduCsr();
		if(io_br)	iduBr();
	end
	endmodule
	"""
	)
}