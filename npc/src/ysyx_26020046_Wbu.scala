import chisel3._
import chisel3.util._
import WidthConsts._

class ysyx_26020046_Wbu(val Yosys:Boolean=false) extends Module {
	val PcReset:UInt=0x80000000L.U(BitWidth.W)
	val RegWidth = log2Ceil(RegNum)
	val MstatuseReset = 0x1800.U(BitWidth.W)
	val ErrorMesg = 2.U(BitWidth.W)

	val in = IO(new Bundle {
		val pipe = Flipped(new PipeLsWb())
	})
	val out = IO(new Bundle {
		val imme = new ImmeAfter()
	})
	val gpr = Reg(Vec(RegNum, UInt(BitWidth.W)))

	val mepc		= RegInit(PcReset)
	val mstatus		= RegInit(MstatuseReset)
	val mtvec		= RegInit(PcReset)
	val mcause		= RegInit(0xffffffffL.U(BitWidth.W))
	val mcycle		= RegInit(0.U(BitWidth.W))
	val mcycleh		= RegInit(0.U(BitWidth.W))
	val marchid		= RegInit(0x018D08CE.U(BitWidth.W))
	val mvendorid	= RegInit(0x79737978.U(BitWidth.W))

	val error = WireInit(false.B)
	val nextMcycle	= Wire(UInt(BitWidth.W))
	val nextMcycleh	= Wire(UInt(BitWidth.W))
	nextMcycle	:= mcycle + 1.U
	nextMcycleh	:= Mux(mcycleh === (Fill(BitWidth,1.U)),mcycleh,mcycleh + 1.U)
	
	out.imme.back := Back.Ready

	when(in.pipe.valid){//合法处理
		switch(in.pipe.csrOp){
			is(CsrOp.Mret){mstatus := MstatuseReset}//TODO
			is(CsrOp.Trap){//TODO:ecall有问题
				mcause	:= in.pipe.csrMesg
				mepc 	:= in.pipe.pc
				//TODO:mstatus
			}
			is(CsrOp.Write){
				val (csrWriteAddr,csrWriteValid)=CsrAddr.safe(in.pipe.csrAddr(CsrWidth-1,0))
				when(csrWriteValid){
					switch(csrWriteAddr){
						is(CsrAddr.Mcycle)		{nextMcycle	:= in.pipe.csrMesg}
						is(CsrAddr.Mcycleh)		{nextMcycleh:= in.pipe.csrMesg}
						is(CsrAddr.Mepc)		{mepc		:= in.pipe.csrMesg}
						is(CsrAddr.Mtvec)		{mtvec		:= in.pipe.csrMesg}
						is(CsrAddr.Mcause)		{mcause		:= in.pipe.csrMesg}
						is(CsrAddr.Mstatus)		{mstatus	:= in.pipe.csrMesg}
						is(CsrAddr.Marchid)		{marchid	:= in.pipe.csrMesg}
						is(CsrAddr.Mvendorid)	{mvendorid	:= in.pipe.csrMesg}
					}
				}otherwise{
					error	:= true.B
					mcause	:= ErrorMesg
					mepc	:= in.pipe.pc
					//TODO:mstatus
				}
			}
			is(CsrOp.Null){}//空，这里4个全覆盖了
		}
		when((in.pipe.rdAddr =/= 0.U)&(error === false.B)){gpr(in.pipe.rdAddr) := in.pipe.result}
	}
	when((in.pipe.valid === false.B & in.pipe.csrOp === CsrOp.Trap) || error){
		mcause			:= in.pipe.csrMesg
		mepc 			:= in.pipe.pc
		out.imme.back	:= Back.Error
		out.imme.addr	:= mtvec
		if(Yosys == false){
			printf("error,stop!!! %x tval: %x ",in.pipe.csrMesg,in.pipe.csrAddr)//tval
			when(in.pipe.csrMesg===3.U	){printf("ebreak\n")}
			when(in.pipe.csrMesg===11.U	){printf("ecall\n")}
			when(in.pipe.csrMesg===0.U	){printf("ifuN4\n")}
			when(in.pipe.csrMesg===1.U	){printf("ifuErr\n")}
			when(in.pipe.csrMesg===2.U	){printf("instr\n")}
			when(in.pipe.csrMesg===4.U	){printf("laddr\n")}
			when(in.pipe.csrMesg===5.U	){printf("lerror\n")}
			when(in.pipe.csrMesg===6.U	){printf("sAddr\n")}
			when(in.pipe.csrMesg===7.U	){printf("sError\n")}
			stop()
		}
	}otherwise{
		out.imme.back := Back.Ready
		out.imme.addr	:= 0.U
	}
	mcycle	:= nextMcycle
	mcycleh	:= nextMcycleh

	{//提供数据
		out.imme.r1Out := Mux(out.imme.r1Addr === 0.U, 0.U, gpr(out.imme.r1Addr))
		out.imme.r2Out := Mux(out.imme.r2Addr === 0.U, 0.U, gpr(out.imme.r2Addr))
		val (csrReadAddr,csrReadValid)=CsrAddr.safe(out.imme.csrAddr)
		out.imme.csrOut := 0.U
		when(csrReadValid){
			switch(csrReadAddr){
				is(CsrAddr.Mcycle)		{out.imme.csrOut := mcycle}
				is(CsrAddr.Mcycleh)		{out.imme.csrOut := mcycleh}
				is(CsrAddr.Mepc)		{out.imme.csrOut := mepc}
				is(CsrAddr.Mtvec)		{out.imme.csrOut := mtvec}
				is(CsrAddr.Mcause)		{out.imme.csrOut := mcause}
				is(CsrAddr.Mstatus)		{out.imme.csrOut := mstatus}
				is(CsrAddr.Marchid)		{out.imme.csrOut := marchid}
				is(CsrAddr.Mvendorid)	{out.imme.csrOut := mvendorid}
			}
		}otherwise{out.imme.csrOut := 0.U}
	}

	if(Yosys == false){
		val wbuChk = Module(new ysyx_26020046_WbuChk)
		wbuChk.io.reg := gpr
		wbuChk.io.ebreak := 
			(in.pipe.csrOp === CsrOp.Trap)&(in.pipe.valid)&(in.pipe.csrMesg === 0x3L.U) ||
			(in.pipe.valid === false.B & in.pipe.csrOp === CsrOp.Trap) ||
			error
		wbuChk.io.pc := in.pipe.pc
		val check = Reg(Bool())
		check := in.pipe.valid === true.B
		wbuChk.io.check := check
		wbuChk.clock := clock
	}
}
class ysyx_26020046_WbuChk extends ExtModule{
	val io = IO(new Bundle{
		val reg		= Input(Vec(RegNum, UInt(BitWidth.W)))
		val ebreak	= Input(Bool())
		val pc		= Input(UInt(BitWidth.W))
		val check	= Input(Bool())
	})
	val clock = IO(Input(Clock()))
	setInline("ysyx_26020046_WbuChk.sv",
	"""
	module ysyx_26020046_WbuChk(
		input logic io_ebreak,
		input logic [31:0]  io_reg_0, io_reg_1, io_reg_2, io_reg_3, io_reg_4, io_reg_5, io_reg_6, io_reg_7,
		input logic [31:0]  io_reg_8, io_reg_9,io_reg_10,io_reg_11,io_reg_12,io_reg_13,io_reg_14,io_reg_15,
		input logic [31:0] io_reg_16,io_reg_17,io_reg_18,io_reg_19,io_reg_20,io_reg_21,io_reg_22,io_reg_23,
		input logic [31:0] io_reg_24,io_reg_25,io_reg_26,io_reg_27,io_reg_28,io_reg_29,io_reg_30,io_reg_31,
		input logic [31:0] io_pc,
		input logic io_check,
		input logic clock
	);
	import "DPI-C" function void ebreak();
	always_ff@(posedge clock) if(io_ebreak)ebreak();
	export "DPI-C" function getRegPc;
	function int getRegPc(input int addr);
		case(addr)
			32'd00:return io_pc;
			32'd01:return io_reg_1;
			32'd02:return io_reg_2;
			32'd03:return io_reg_3;
			32'd04:return io_reg_4;
			32'd05:return io_reg_5;
			32'd06:return io_reg_6;
			32'd07:return io_reg_7;
			32'd08:return io_reg_8;
			32'd09:return io_reg_9;
			32'd10:return io_reg_10;
			32'd11:return io_reg_11;
			32'd12:return io_reg_12;
			32'd13:return io_reg_13;
			32'd14:return io_reg_14;
			32'd15:return io_reg_15;
			32'd16:return io_reg_16;
			32'd17:return io_reg_17;
			32'd18:return io_reg_18;
			32'd19:return io_reg_19;
			32'd20:return io_reg_20;
			32'd21:return io_reg_21;
			32'd22:return io_reg_22;
			32'd23:return io_reg_23;
			32'd24:return io_reg_24;
			32'd25:return io_reg_25;
			32'd26:return io_reg_26;
			32'd27:return io_reg_27;
			32'd28:return io_reg_28;
			32'd29:return io_reg_29;
			32'd30:return io_reg_30;
			32'd31:return io_reg_31;
			default: return 0;
		endcase
	endfunction
	import "DPI-C" function void wbuCheck();
	always_ff@(posedge clock) if(io_check)wbuCheck();

	initial $display("%m");
	endmodule
	"""
	)
}