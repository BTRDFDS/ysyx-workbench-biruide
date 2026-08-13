import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._

class ysyx_26020046(val PcInit:UInt=0x30000000L.U,val Yosys:Boolean=false) extends Module {
	val io = IO(new Bundle {
		val interrupt = Input(Bool())
		val master = new Axi4MasterOut()
		val slave = Flipped(new Axi4MasterOut())
	})
	val ich = Module(new ysyx_26020046_Ich(Yosys))
	val ifu = Module(new ysyx_26020046_Ifu(PcInit,Yosys))
	val idu = Module(new ysyx_26020046_Idu(Yosys))
	val exu = Module(new ysyx_26020046_Exu(Yosys))
	val lsu = Module(new ysyx_26020046_Lsu(Yosys))
	val wbu = Module(new ysyx_26020046_Wbu(Yosys))
	val clt = Module(new ysyx_26020046_Clt)
	val bar = Module(new ysyx_26020046_Bar(Yosys))
	//流水线
	ifu.out.pipe <> idu.in.pipe
	idu.out.pipe <> exu.in.pipe
	exu.out.pipe <> lsu.in.pipe
	lsu.out.pipe <> wbu.in.pipe
	// //立即线
	wbu.out.imme <> lsu.in.imme
	lsu.out.imme <> exu.in.imme
	exu.out.imme <> idu.in.imme
	idu.out.imme <> ifu.in.imme

	//axi4
	ich.lsu <> lsu.ich
	ich.ifu <> ifu.ich
	bar.ifu <> ich.bar
	bar.lsu <> lsu.bar
	bar.clt	<> clt.axi4

	io.master.arvalid	<> bar.out.arvalid
	io.master.araddr	<> bar.out.araddr
	io.master.arid		:= 0.U
	io.master.arlen		:= bar.out.arlen
	io.master.arsize	:= bar.out.arsize
	io.master.arburst	:= bar.out.arburst
	io.master.arready	<> bar.out.arready

	io.master.rvalid	<> bar.out.rvalid
	io.master.rdata		<> bar.out.rdata
	io.master.rresp		<> bar.out.rresp
	// io.master.rid		:= 0.U //Input
	io.master.rlast		<> bar.out.rlast
	io.master.rready	<> bar.out.rready

	io.master.awvalid	<> bar.out.awvalid
	io.master.awaddr	<> bar.out.awaddr
	io.master.awid		:= 0.U
	io.master.awlen		:= 0.U
	io.master.awsize	:= 0.U
	io.master.awburst	:= 0.U
	io.master.awready	<> bar.out.awready

	io.master.wvalid	<> bar.out.wvalid
	io.master.wdata		<> bar.out.wdata
	io.master.wstrb		<> bar.out.wstrb
	io.master.wlast		:= true.B
	io.master.wready	<> bar.out.wready

	io.master.bvalid	<> bar.out.bvalid
	io.master.bresp		<> bar.out.bresp
	// io.master.bid		:= 0.U //Input
	io.master.bready	<> bar.out.bready


	io.slave.arready:= false.B
	io.slave.rvalid	:= false.B
	io.slave.rdata	:= 0.U
	io.slave.rresp	:= 0.U
	io.slave.rid	:= 0.U
	io.slave.rlast	:= false.B
	io.slave.awready:= false.B
	io.slave.wready	:= false.B
	io.slave.bvalid	:= false.B
	io.slave.bresp	:= 0.U
	io.slave.bid	:= 0.U

	dontTouch(io.master)
	dontTouch(io.slave)
	dontTouch(io.interrupt)
	if(Yosys == false){
		val chkInstIfu = Mux(Get(ifu.out.pipe.res) === IfuRes.Valid,	Get(ifu.out.pipe.instr)	,0.U(32.W));dontTouch(chkInstIfu)
		val chkInstIdu = Mux(Get(idu.pipeRes) === IfuRes.Valid,			Get(idu.pipeInstr) 		,0.U(32.W));dontTouch(chkInstIdu)
		val chkPcIfu = Mux(Get(ifu.out.pipe.res) === IfuRes.Valid,	Cat(Get(ifu.pipePc),0.U(2.W)),0.U(32.W));dontTouch(chkPcIfu)
		val chkPcIdu = Mux(Get(idu.pipeRes) === IfuRes.Valid,		Cat(Get(idu.pipePc),0.U(2.W)),0.U(32.W));dontTouch(chkPcIdu)
		val chkPcExu = Mux(Get(exu.pipeValid),						Cat(Get(exu.pipePc),0.U(2.W)),0.U(32.W));dontTouch(chkPcExu)
		val chkPcLsu = Mux(Get(lsu.pipeValid),						Cat(Get(lsu.pipePc),0.U(2.W)),0.U(32.W));dontTouch(chkPcLsu)
		val chkPcWbu = Mux(Get(wbu.pipeValid),						Cat(Get(wbu.pipePc),0.U(2.W)),0.U(32.W));dontTouch(chkPcWbu)


		val chk = Module(new ysyx_26020046_Chk)
		chk.clock	:= clock

		val noEbreak = RegInit(true.B);when(Get(ifu.ich.ready) && Get(ifu.out.pipe.res) === IfuRes.Valid && Get(ifu.in.imme.ready) && Get(ifu.out.pipe.instr) === 0x00100073L.U && ~Get(ifu.in.imme.jump)){noEbreak := false.B}
		chk.inst	:= noEbreak && Get(ifu.ich.ready) && Get(ifu.out.pipe.res) === IfuRes.Valid && (Get(ifu.in.imme.ready) || Get(ifu.in.imme.jump))
		chk.stall	:= noEbreak && Get(ifu.out.pipe.res) === IfuRes.Null
		chk.jbMiss	:= noEbreak && Get(ifu.in.imme.jump)
		chk.jbHit	:= false.B

		chk.cal		:= Get(idu.in.imme.ready) && (~Get(idu.in.imme.jump)) && Get(idu.out.pipe.valid) && (Get(idu.opEnum) === Op.Ialu	|| Get(idu.opEnum) === Op.Ralu	)
		chk.jump	:= Get(idu.in.imme.ready) && (~Get(idu.in.imme.jump)) && Get(idu.out.pipe.valid) && (Get(idu.opEnum) === Op.Jal		|| Get(idu.opEnum) === Op.Ijalr	)
		chk.imm		:= Get(idu.in.imme.ready) && (~Get(idu.in.imme.jump)) && Get(idu.out.pipe.valid) && (Get(idu.opEnum) === Op.Uauipc	|| Get(idu.opEnum) === Op.Ului	)
		chk.ls		:= Get(idu.in.imme.ready) && (~Get(idu.in.imme.jump)) && Get(idu.out.pipe.valid) && (Get(idu.opEnum) === Op.Store	|| Get(idu.opEnum) === Op.Iload	)
		chk.csr		:= Get(idu.in.imme.ready) && (~Get(idu.in.imme.jump)) && Get(idu.out.pipe.valid) && (Get(idu.opEnum) === Op.Icsr	)
		chk.br		:= Get(idu.in.imme.ready) && (~Get(idu.in.imme.jump)) && Get(idu.out.pipe.valid) && (Get(idu.opEnum) === Op.Branch	)
		chk.miss	:= noEbreak && Get(idu.in.imme.jump) && Get(idu.pipeRes) === IfuRes.Valid
		chk.ifuMiss	:= noEbreak && Get(idu.out.imme.jump) && Get(idu.in.pipe.res) === IfuRes.Valid
		
		chk.load		:= Get(lsu.pipeValid) && Get(lsu.pipeLsuOp) === LsuOp.Load	&& Get(lsu.bar.ready)
		chk.loadWait	:= Get(lsu.pipeValid) && Get(lsu.pipeLsuOp) === LsuOp.Load
		chk.store		:= Get(lsu.pipeValid) && Get(lsu.pipeLsuOp) === LsuOp.Store	&& Get(lsu.bar.ready)
		chk.storeWait	:= Get(lsu.pipeValid) && Get(lsu.pipeLsuOp) === LsuOp.Store
		chk.addr		:= Get(lsu.pipeResult)

		chk.ebreak := (Get(wbu.pipeCsrOp) === CsrOp.Trap)&(Get(wbu.pipeValid))&(Get(wbu.pipeCsrMesg) === 0x3L.U) ||Get(wbu.error)
		chk.check := Get(wbu.pipeValid)
		chk.rdAddr	:= Get(wbu.pipeRdAddr)
		chk.rdValue	:= Get(wbu.pipeRdValue)
		chk.dnpc := 0.U(32.W)
		when(Get(lsu.pipeValid)){chk.dnpc := Cat(Get(lsu.pipePc),0.U(2.W))}
		.elsewhen(Get(exu.pipeValid)){chk.dnpc := Cat(Get(exu.pipePc),0.U(2.W))}
		.elsewhen(Get(idu.pipeRes)===IfuRes.Valid){chk.dnpc := Cat(Get(idu.pipePc),0.U(2.W))}
		.otherwise{chk.dnpc := Cat(Get(ifu.pipePc),0.U(2.W))}
	}
}
class ysyx_26020046_Chk extends ExtModule{
	val inst	= IO(Input(Bool()))
	val stall	= IO(Input(Bool()))
	val jbMiss	= IO(Input(Bool()))
	val jbHit	= IO(Input(Bool()))
	
	val cal		= IO(Input(Bool()))
	val jump	= IO(Input(Bool()))
	val imm		= IO(Input(Bool()))
	val ls		= IO(Input(Bool()))
	val csr		= IO(Input(Bool()))
	val br		= IO(Input(Bool()))
	val miss	= IO(Input(Bool()))
	val ifuMiss = IO(Input(Bool()))

	val load		= IO(Input(Bool()))
	val loadWait	= IO(Input(Bool()))
	val store		= IO(Input(Bool()))
	val storeWait	= IO(Input(Bool()))
	val addr		= IO(Input(UInt(32.W)))

	val rdAddr	= IO(Input(UInt(8.W)))
	val rdValue	= IO(Input(UInt(BitWidth.W)))
	val pc		= IO(Input(UInt(BitWidth.W)))
	val dnpc	= IO(Input(UInt(BitWidth.W)))
	val ebreak	= IO(Input(Bool()))
	val check	= IO(Input(Bool()))

	val clock	= IO(Input(Clock()))
	setInline("ysyx_26020046_Chk.sv",
	"""
	module ysyx_26020046_Chk(
		input logic inst,
		input logic stall,
		input logic jbMiss,
		input logic jbHit,

		input logic cal,
		input logic jump,
		input logic imm,
		input logic ls,
		input logic csr,
		input logic br,
		input logic miss,
		input logic ifuMiss,
	
		input logic load,
		input logic loadWait,
		input logic store,
		input logic storeWait,
		input logic [31:0] addr,

		output logic [7:0] rdAddr,
		input logic [31:0] rdValue,
		input logic [31:0] dnpc,
		input logic ebreak,
		input logic check,
		input logic clock
	);
	import "DPI-C" function void ifuInst();
	import "DPI-C" function void ifuStall();
	import "DPI-C" function void ifuJbMiss();
	import "DPI-C" function void ifuJbHit();
	
	import "DPI-C" function void iduCal();
	import "DPI-C" function void iduJump();
	import "DPI-C" function void iduImm();
	import "DPI-C" function void iduLs();
	import "DPI-C" function void iduCsr();
	import "DPI-C" function void iduBr();
	import "DPI-C" function void iduMiss();

	import "DPI-C" function void lsuLoad();
	import "DPI-C" function void lsuLoadWait();
	import "DPI-C" function void lsuStore();
	import "DPI-C" function void lsuStoreWait();
	import "DPI-C" function void lsuTrace(int addr);

	import "DPI-C" function void ebreakStop();
	import "DPI-C" function void wbuCheck(int dnpc,int pc,byte addr,int value);

	always_ff@(posedge clock)begin
		if(stall)	ifuStall();
		if(inst)	ifuInst();
		if(jbMiss)	ifuJbMiss();
		if(jbHit)	ifuJbHit();
		
		if(cal)		iduCal();
		if(jump)	iduJump();
		if(imm)		iduImm();
		if(ls)		iduLs();
		if(csr)		iduCsr();
		if(br)		iduBr();
		if(miss)	iduMiss();
		if(ifuMiss)	iduMiss();
		
		if(load)		lsuLoad();
		if(loadWait)	lsuLoadWait();
		if(store)		lsuStore();
		if(storeWait)	lsuStoreWait();

		if(ebreak)	ebreakStop();
		if(check)	wbuCheck(dnpc,pc,rdAddr,rdValue);
	end
	always_ff@(posedge load or posedge store)lsuTrace(addr);

	endmodule
	"""
	)
}