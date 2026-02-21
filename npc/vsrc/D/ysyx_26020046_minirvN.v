module ysyx_26020046_minirvN #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (clk,reset,code,pcReset,pc);
//pcReset应该改成固定值
input clk,reset;
input [DATA_WIDTH-1:0] code,pcReset;
output reg [DATA_WIDTH-1:0] pc;

wire [ADDR_WIDTH-1:0] cR1,cR2,cRd;
wire [DATA_WIDTH-1:0] adr,iRd,oR1,oR2,oRAM,imm,imi,rAdr,ramAddr,wRAM,a0,im0,im1,adder,snpc;
reg  [DATA_WIDTH-1:0] iRAM,in2,lmer,Ler,dnpc,oRamB;
reg  [DATA_WIDTH-1:0] gpr [2**ADDR_WIDTH-1:1];
wire [3:0] wmask;
reg  [3:0] hot;
wire [6:0] fc7,opc;
wire [2:0] fc3;
wire add,addi,lui,l,s,jalr,w,eRd,stop,eb;//,lw,sw,sb,lbu

import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);
import "DPI-C" function void ebreak(input bit eb);

//=======================IDC=======================
	assign fc7=code[31:25];
	assign cR2=code[24:20];
	assign cR1=code[19:15];
	assign fc3=code[14:12];
	assign cRd=code[11:07];
	assign opc=code[06:00];

	assign im0={{20{fc7[6]}},fc7,cRd};
	assign im1={{20{fc7[6]}},fc7,cR2};

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
	assign imi = {fc7,cR2,cR1,fc3,12'b0};

	always@(*)begin
		case(s)
			1'b0: imm=im1;
			1'b1: imm=im0;
		endcase
	end

	always@(*)begin
		if(code==32'h100073)begin
			stop=1'b1;
			eb=(a0==32'b0);
		end else begin
			stop=~(|{add,addi,lui,l,s,jalr});
			eb=1'b0;
		end
	end

//=======================ALU=======================

	always@(*)begin
		case(add)
			1'b0:in2=imm;
			1'b1:in2=oR2;
		endcase
	end

	assign adder=oR1+in2;
	assign adr=adder;

	always@(*)begin
		case(lui)
			1'b0:lmer=adder;
			1'b1:lmer=imi;
		endcase
	end

	always@(*)begin
		case(l)
			1'b0:Ler=lmer;
			1'b1:Ler=oRAM;
		endcase
	end

	always@(*)begin
		case(jalr)
			1'b0:iRd=Ler;
			1'b1:iRd=rAdr;
		endcase
	end

//=======================Reg=======================

	always @(posedge clk) begin
		if(reset)begin
			gpr[ 1]<=0;gpr[ 2]<=0;gpr[ 3]<=0;gpr[ 4]<=0;gpr[ 5]<=0;gpr[ 6]<=0;gpr[ 7]<=0;
			gpr[ 8]<=0;gpr[ 9]<=0;gpr[10]<=0;gpr[11]<=0;gpr[12]<=0;gpr[13]<=0;gpr[14]<=0;gpr[15]<=0;
			gpr[16]<=0;gpr[17]<=0;gpr[18]<=0;gpr[19]<=0;gpr[20]<=0;gpr[21]<=0;gpr[22]<=0;gpr[23]<=0;
			gpr[24]<=0;gpr[25]<=0;gpr[26]<=0;gpr[27]<=0;gpr[28]<=0;gpr[29]<=0;gpr[30]<=0;gpr[31]<=0;
		end else begin
			if (en&&cRd!=0) gpr[cRd] <= iRd;
    	end
	end

	assign oR1 = (cR1==0)?0:gpr[cR1];
	assign oR2 = (cR2==0)?0:gpr[cR2];
	assign a0 = gpr[10];

//=======================LSU=======================

//s处理
	assign ramAddr={adr[31:2],2'b0};

	always@(*)begin
		case(s&w)
			1'b0:wRAM={4{oR2[7:0]}};
			1'b1:wRAM=oR2;
		endcase
	end

	always@(*)begin
		case(adr[1:0])
			2'b00:hot=4'b0001;
			2'b01:hot=4'b0010;
			2'b10:hot=4'b0100;
			2'b11:hot=4'b1000;
		endcase
	end

	assign wmask=w?4'b1111:hot;

//l处理
	always@(*)begin
		case(adr[1:0])
			2'b00:oRamB={24'b0,iRAM[7:0]};
			2'b01:oRamB={24'b0,iRAM[15:8]};
			2'b10:oRamB={24'b0,iRAM[23:16]};
			2'b11:oRamB={24'b0,iRAM[31:24]};
		endcase
	end

	always@(*)begin
		case(l&w)
			1'b0:oRAM=oRamB;
			1'b1:oRAM=iRAM;
		endcase
	end

//pc处理

	assign snpc=pc+4;
	assign rAdr=snpc;

	always@(*)begin
		case(jalr)
			1'b0:dnpc=snpc;
			1'b1:dnpc=adr;
		endcase
	end

	always@(posedge clk)begin
		pc<=reset?pcReset:dnpc;
	end

	assign iRAM = l&clk?pmem_read(ramAddr):0;
	assign iRAM = l&(~clk)?pmem_read(ramAddr):0;
	always @(posedge clk) begin
		// if (l) begin // 有读请求时
		if(code[6:0]==7'b0000011)begin
			iRAM <= pmem_read(ramAddr);
		end
		// iRAM<=l?pmem_read(ramAddr):0;
	end

	always @(posedge clk) begin
		if (s) begin // 有写请求时
			pmem_write(ramAddr, wRAM, {4'b0,wmask});
		end
	end

	always@(*)begin
	    if(stop&(~reset)) ebreak(eb);
	end

//=======================DEBUG=======================

`ifdef DEBUG
	always@(clk) begin
    	$display("pc=0x%x,dnpc=0x%x,snpc=0x%x reset=%d",pc,dnpc,snpc,reset);
		$display("code=%x",code);
		$display("cR1=%x oR1=%x cR2=%x oR2=%x cRd=%x imm=%x imi=%x", cR1,oR1,cR2,oR2,cRd,imm,imi);
		$display("add=%x lui=%x l=%x s=%x jalr=%x w=%x eRd=%x", add,lui,l,s,jalr,w,eRd);
		$display("adr=%x oRAM=%x pc=%x ramAddr=%x wRAM=%x", adr,oRAM,pc,ramAddr,wRAM);
		$display("iRd=%x rAdr=%x iRAM=%x wmask=%x a0=%x reset=%x", iRd,rAdr,iRAM,wmask,a0,reset);
		$display("en=%o Reg[%d](0x%x)<=0x%x",en,cRd,gpr[cRd],iRd);
		$display(" $0:x%8x  ra:x%8x  sp:x%8x  gp:x%8x  tp:x%8x  t0:x%8x  t1:x%8x  t2:x%8x",      0,gpr[ 1],gpr[ 2],gpr[ 3],gpr[ 4],gpr[ 5],gpr[ 6],gpr[ 7]);
		$display(" s0:x%8x  s1:x%8x  a0:x%8x  a1:x%8x  a2:x%8x  a3:x%8x  a4:x%8x  a5:x%8x",gpr[ 8],gpr[ 9],gpr[10],gpr[11],gpr[12],gpr[13],gpr[14],gpr[15]);
		$display(" a6:x%8x  a7:x%8x  s2:x%8x  s3:x%8x  s4:x%8x  s5:x%8x  s6:x%8x  s7:x%8x",gpr[16],gpr[17],gpr[18],gpr[19],gpr[20],gpr[21],gpr[22],gpr[23]);
		$display(" s8:x%8x  s9:x%8x s10:x%8x s11:x%8x  t3:x%8x  t4:x%8x  t5:x%8x  t6:x%8x",gpr[24],gpr[25],gpr[26],gpr[27],gpr[28],gpr[29],gpr[30],gpr[31]);
		$strobe("Reg[%d]=%x", cRd, gpr[cRd]);
	end
`endif

endmodule
