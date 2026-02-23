package minirvPackage;
	parameter ADDR_WIDTH = 5;
	parameter DATA_WIDTH = 32;

	logic inClk,inReset;
	logic [DATA_WIDTH-1:0] inPcReset,inCode,inPc;

	logic [ADDR_WIDTH-1:0] cR1,cR2,cRd;
	logic [DATA_WIDTH-1:0] adr,oR1,oR2,oRAM,imi,rAdr,ramAddr,wRAM,addRes,snpc,iRAM,dnpc,oRamB,imm,iRd;
	logic [DATA_WIDTH-1:0] gpr [2**ADDR_WIDTH-1:1];
	logic [3:0] wmask,hot;
	logic [6:0] fc7,opc;
	logic [2:0] fc3;
	logic add,addi,lui,l,s,jalr,w,eRd,stop,eb;//,lw,sw,sb,lbu


endpackage
module ysyx_26020046_minirv(clk,reset,code,pcReset,pc);
import minirvPackage::*;
input  logic clk,reset;
input  logic [DATA_WIDTH-1:0] code,pcReset;
output logic [DATA_WIDTH-1:0] pc;


assign inClk=clk;
assign inReset=reset;
assign inCode=code;
assign inPcReset=pcReset;
assign pc=inPc;

ysyx_26020046_minirvIDC IDC();
ysyx_26020046_minirvALU ALU();
ysyx_26020046_minirvReg REG();
ysyx_26020046_minirvLSU LSU();
ysyx_26020046_minirvDebug DEBUG();

endmodule

module ysyx_26020046_minirvIDC;
	import minirvPackage::*;

	assign fc7=inCode[31:25];
	assign cR2=inCode[24:20];
	assign cR1=inCode[19:15];
	assign fc3=inCode[14:12];
	assign cRd=inCode[11:07];
	assign opc=inCode[06:00];


	assign add =(opc==7'b0110011);
	assign addi=(opc==7'b0010011);
	assign lui =(opc==7'b0110111);
	assign l   =(opc==7'b0000011);
	assign s   =(opc==7'b0100011);
	assign jalr=(opc==7'b1100111);

	assign w   =(fc3==3'b010);
	assign eRd=add|addi|lui|l|jalr;
	// assign lbu=l&(~w);
	// assign lw =l&w;
	// assign sb =s&(~w);
	// assign sw =s&w;

	// assign im0={{20{fc7[6]}},fc7,cRd};
	// assign im1={{20{fc7[6]}},fc7,cR2};
	// assign imm = s?im0:im1;
	assign imi = {fc7,cR2,cR1,fc3,12'b0};
	assign imm[31:5]={{20{fc7[6]}},fc7};
	assign imm[ 4:0]=s?cRd:cR2;


	always_comb begin:check_code_or_ebreak
		if(inCode==32'h100073)begin
			stop=1'b1;
			eb=(gpr[10]==32'b0);
		end else begin
			stop=~(|{add,addi,lui,l,s,jalr});
			eb=1'b0;
		end
	end
endmodule

module ysyx_26020046_minirvALU;
	import minirvPackage::*;

	logic [1:0]resChoose;
	assign resChoose[0]=jalr|lui;
	assign resChoose[1]=jalr|l;

	always_comb begin:res_choose
		case(resChoose)
			2'b00:iRd=addRes;
			2'b01:iRd=imi;
			2'b10:iRd=oRAM;
			2'b11:iRd=rAdr;
			default: iRd = addRes;
		endcase
	end


	always_comb begin:add_choose
		case(add)
			1'b0:addRes=oR1+imm;
			1'b1:addRes=oR1+oR2;
		endcase
	end
	assign adr=addRes;

endmodule

module ysyx_26020046_minirvReg;
	import minirvPackage::*;

	always_ff@(posedge inClk) begin:reg_write
		if(inReset)begin
			gpr[ 1]<=0;gpr[ 2]<=0;gpr[ 3]<=0;gpr[ 4]<=0;gpr[ 5]<=0;gpr[ 6]<=0;gpr[ 7]<=0;
			gpr[ 8]<=0;gpr[ 9]<=0;gpr[10]<=0;gpr[11]<=0;gpr[12]<=0;gpr[13]<=0;gpr[14]<=0;gpr[15]<=0;
			gpr[16]<=0;gpr[17]<=0;gpr[18]<=0;gpr[19]<=0;gpr[20]<=0;gpr[21]<=0;gpr[22]<=0;gpr[23]<=0;
			gpr[24]<=0;gpr[25]<=0;gpr[26]<=0;gpr[27]<=0;gpr[28]<=0;gpr[29]<=0;gpr[30]<=0;gpr[31]<=0;
		end else begin
			if (eRd&&cRd!=0) gpr[cRd] <= iRd;
    	end
	end

	assign oR1 = (cR1==0)?0:gpr[cR1];
	assign oR2 = (cR2==0)?0:gpr[cR2];
	// assign a0 = gpr[10];
endmodule

module ysyx_26020046_minirvLSU;
import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);

	import minirvPackage::*;

//s处理
	assign ramAddr={adr[31:2],2'b0};
	assign wRAM=(s&w)?oR2:{4{oR2[7:0]}};

	always_comb begin:get_hot
		case(adr[1:0])
			2'b00:hot=4'b0001;
			2'b01:hot=4'b0010;
			2'b10:hot=4'b0100;
			2'b11:hot=4'b1000;
			default:hot=4'b00;
		endcase
	end

	assign wmask=w?4'b1111:hot;

//l处理
	always_comb begin:control_RAM_output
		case(adr[1:0])
			2'b00:oRamB={24'b0,iRAM[7:0]};
			2'b01:oRamB={24'b0,iRAM[15:8]};
			2'b10:oRamB={24'b0,iRAM[23:16]};
			2'b11:oRamB={24'b0,iRAM[31:24]};
		endcase
	end

	assign oRAM=(l&w)?iRAM:oRamB;

//pc处理

	assign snpc=inPc+4;
	assign rAdr=snpc;
	assign dnpc=jalr?adr:snpc;

	always_ff@(posedge inClk) begin:pc_write
		inPc<=inReset?inPcReset:dnpc;
	end

	assign iRAM = l&inClk?pmem_read(ramAddr):0;
	
	// assign iRAM = l&(~inClk)?pmem_read(ramAddr):0;
	// always_ff@(posedge inClk) begin:control_read
	// 	if (l) begin // 有读请求时
	// 	// if(inCode[6:0]==7'b0000011)begin
	// 		iRAM <= pmem_read(ramAddr);
	// 	end
	// 	// iRAM<=l?pmem_read(ramAddr):0;
	// end

	always_ff@(posedge inClk) begin:control_write
		if (s) begin // 有写请求时
			pmem_write(ramAddr, wRAM, {4'b0,wmask});
		end
	end

endmodule


module ysyx_26020046_minirvDebug();
	import minirvPackage::*;

	import "DPI-C" function void ebreak(input bit eb);
	always_comb begin:en_or_reset
	    if(stop&(~inReset)) ebreak(eb);
	end
	export "DPI-C" function getReg;
	function int getReg(input int addr);
		// $display("getReg addr");
	    return (addr == 0) ? inPc : gpr[addr];
	endfunction

`ifdef DEBUG
	always@(inClk) begin
    	$display("> pc=x%x dn=x%x sn=x%x reset= %x code=x%x",inPc,dnpc,snpc,inReset,inCode);
		$display("cR1=x%x oR1 =x%x cR2=x%x oR2=x%x imi=x%x imm=x%x",cR1,oR1,cR2,oR2, imm,imi);
		$display("adr=x%x oRAM=x%x ramAddr=x%x wRAM=x%x", adr,oRAM,ramAddr, wRAM);
		$display("add=%x lui =%x l=%x s=%x jalr=%x w=%x",add,lui,  l,  s,jalr,  w);
		$display("rAdr=x%x iRAM=x%x eb=%x wmask=x%x",rAdr,iRAM,eb,  wmask);
		$display("eRd=%x Reg[%d](0x%x)<=0x%x",eRd,cRd,gpr[cRd],iRd);
		$display(" $0:x%8x ra:x%8x  sp:x%8x  gp:x%8x tp:x%8x t0:x%8x t1:x%8x t2:x%8x",      0,gpr[ 1],gpr[ 2],gpr[ 3],gpr[ 4],gpr[ 5],gpr[ 6],gpr[ 7]);
		$display(" s0:x%8x s1:x%8x  a0:x%8x  a1:x%8x a2:x%8x a3:x%8x a4:x%8x a5:x%8x",gpr[ 8],gpr[ 9],gpr[10],gpr[11],gpr[12],gpr[13],gpr[14],gpr[15]);
		$display(" a6:x%8x a7:x%8x  s2:x%8x  s3:x%8x s4:x%8x s5:x%8x s6:x%8x s7:x%8x",gpr[16],gpr[17],gpr[18],gpr[19],gpr[20],gpr[21],gpr[22],gpr[23]);
		$display(" s8:x%8x s9:x%8x s10:x%8x s11:x%8x t3:x%8x t4:x%8x t5:x%8x t6:x%8x",gpr[24],gpr[25],gpr[26],gpr[27],gpr[28],gpr[29],gpr[30],gpr[31]);
		$strobe("Reg[%d]=%x", cRd, gpr[cRd]);
	end
`endif
endmodule

