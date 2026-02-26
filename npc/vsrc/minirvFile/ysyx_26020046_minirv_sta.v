module ysyx_26020046_minirv_sta #(ADDR_WIDTH = 5, DATA_WIDTH = 32,PC_RESET=32'h80000000) (clk,reset,code,iRAM,ramAddr,wRAM,pc,wmask,rEn,wEn,stop,eb);
//32'h80000000
input clk,reset;
input [DATA_WIDTH-1:0] code,iRAM;
output [DATA_WIDTH-1:0] ramAddr,wRAM,pc;
output [3:0] wmask;
output rEn,wEn,stop,eb;
// output we,he,oe;

wire [ADDR_WIDTH-1:0] cR1,cR2,cRd;
wire add,lui,l,s,jalr,w,eRd;
wire [DATA_WIDTH-1:0] adr,iRd,oR1,oR2,oRAM,imm,imi,rAdr,a0;

ysyx_26020046_minirv_IDC #(ADDR_WIDTH,DATA_WIDTH) ysyx_26020046_IDC(
    .code(code),
    .a0(a0),
    .cR1(cR1),
    .cR2(cR2),
    .cRd(cRd),
    .imm(imm),
    .imi(imi),
    .add(add),
    .lui(lui),
    .l(l),
    .s(s),
    .jalr(jalr),
    .w(w),
    .eRd(eRd),
    .stop(stop),
    .eb(eb)
);
ysyx_26020046_minirv_ALU #(DATA_WIDTH) ysyx_26020046_ALU(
    .oR1(oR1),
    .oR2(oR2),
    .imm(imm),
    .imi(imi),
    .lui(lui),
    .add(add),
    .adr(adr),
    .oRAM(oRAM),
    .l(l),
    .rAdr(rAdr),
    .jalr(jalr),
    .iRd(iRd)
);
ysyx_26020046_minirv_Reg #(ADDR_WIDTH,DATA_WIDTH) ysyx_26020046_Reg(
    .clk(clk),
    .reset(reset),
    .iRd(iRd),
    .cRd(cRd),
    .cR1(cR1),
    .cR2(cR2),
    .eRd(eRd),
    .oR1(oR1),
    .oR2(oR2),
    .a0(a0)
);
ysyx_26020046_minirv_LSU #(DATA_WIDTH,PC_RESET) ysyx_26020046_LSU(
    .clk(clk),
    .reset(reset),
    .s(s),
    .w(w),
    .l(l),
    .jalr(jalr),
    .adr(adr),
    .oR2(oR2),
    .iRAM(iRAM),
    .pc(pc),
    .oRAM(oRAM),
    .ramAddr(ramAddr),
    .wRAM(wRAM),
    .rAdr(rAdr),
    .wmask(wmask)
);
    assign rEn=l;
    assign wEn=s;
endmodule
module ysyx_26020046_minirv_Reg #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (clk,reset,eRd,iRd,cRd,cR1,cR2,oR1,oR2,a0);
  input clk,reset,eRd;
  input [DATA_WIDTH-1:0] iRd;
  input [ADDR_WIDTH-1:0] cRd,cR1,cR2;
  output [DATA_WIDTH-1:0] oR1,oR2,a0;

  reg [DATA_WIDTH-1:0] gpr [2**ADDR_WIDTH-1:1];
  always @(posedge clk) begin
    if(reset)begin
      gpr[ 1]<=0;gpr[ 2]<=0;gpr[ 3]<=0;gpr[ 4]<=0;gpr[ 5]<=0;gpr[ 6]<=0;gpr[ 7]<=0;
      gpr[ 8]<=0;gpr[ 9]<=0;gpr[10]<=0;gpr[11]<=0;gpr[12]<=0;gpr[13]<=0;gpr[14]<=0;gpr[15]<=0;
      gpr[16]<=0;gpr[17]<=0;gpr[18]<=0;gpr[19]<=0;gpr[20]<=0;gpr[21]<=0;gpr[22]<=0;gpr[23]<=0;
      gpr[24]<=0;gpr[25]<=0;gpr[26]<=0;gpr[27]<=0;gpr[28]<=0;gpr[29]<=0;gpr[30]<=0;gpr[31]<=0;
    end else begin
      if (eRd&&cRd!=0) gpr[cRd] <= iRd;
    end
  end
`ifdef DEBUG
  always @(clk) begin
    $display("eRd=%o Reg[%d](0x%x)<=0x%x",eRd,cRd,gpr[cRd],iRd);
    $strobe("Reg[%d]=%x", cRd, gpr[cRd]);
    // $strobe("00:0x%8x 01:0x%8x 02:0x%8x 03:0x%8x 04:0x%8x 05:0x%8x 06:0x%8x 07:0x%8x",0,gpr[01],gpr[02],gpr[03],gpr[04],gpr[05],gpr[06],gpr[07]);
    // $strobe("08:0x%8x 09:0x%8x 10:0x%8x 11:0x%8x 12:0x%8x 13:0x%8x 14:0x%8x 15:0x%8x",gpr[08],gpr[09],gpr[10],gpr[11],gpr[12],gpr[13],gpr[14],gpr[15]);
    // $strobe("16:0x%8x 17:0x%8x 18:0x%8x 19:0x%8x 20:0x%8x 21:0x%8x 22:0x%8x 23:0x%8x",gpr[16],gpr[17],gpr[18],gpr[19],gpr[20],gpr[21],gpr[22],gpr[23]);
    // $strobe("24:0x%8x 25:0x%8x 26:0x%8x 27:0x%8x 28:0x%8x 29:0x%8x 30:0x%8x 31:0x%8x",gpr[24],gpr[25],gpr[26],gpr[27],gpr[28],gpr[29],gpr[30],gpr[31]);
    $display(" $0:x%8x  ra:x%8x  sp:x%8x  gp:x%8x  tp:x%8x  t0:x%8x  t1:x%8x  t2:x%8x",      0,gpr[ 1],gpr[ 2],gpr[ 3],gpr[ 4],gpr[ 5],gpr[ 6],gpr[ 7]);
    $display(" s0:x%8x  s1:x%8x  a0:x%8x  a1:x%8x  a2:x%8x  a3:x%8x  a4:x%8x  a5:x%8x",gpr[ 8],gpr[ 9],gpr[10],gpr[11],gpr[12],gpr[13],gpr[14],gpr[15]);
    $display(" a6:x%8x  a7:x%8x  s2:x%8x  s3:x%8x  s4:x%8x  s5:x%8x  s6:x%8x  s7:x%8x",gpr[16],gpr[17],gpr[18],gpr[19],gpr[20],gpr[21],gpr[22],gpr[23]);
    $display(" s8:x%8x  s9:x%8x s10:x%8x s11:x%8x  t3:x%8x  t4:x%8x  t5:x%8x  t6:x%8x",gpr[24],gpr[25],gpr[26],gpr[27],gpr[28],gpr[29],gpr[30],gpr[31]);
  end
`endif

  assign oR1 = (cR1==0)?0:gpr[cR1];
  assign oR2 = (cR2==0)?0:gpr[cR2];
  assign a0 = gpr[10];
endmodule

module ysyx_26020046_minirv_LSU #(DATA_WIDTH=32,PC_RESET=32'h80000000)(clk,reset,s,w,l,jalr,adr,oR2,iRAM,pc,oRAM,ramAddr,wRAM,rAdr,wmask);
input clk,reset,s,w,l,jalr;
input [DATA_WIDTH-1:0] adr,oR2,iRAM;
output reg [DATA_WIDTH-1:0] pc,oRAM,wRAM;
output [DATA_WIDTH-1:0] ramAddr,rAdr;
output [3:0] wmask;
// output we,he,oe;

//s处理
// assign ramAddr=w?{adr[31:2],2'b0}:adr;
assign ramAddr={adr[31:2],2'b0};
// ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxSw(.out(wRAM),.addr(s&w),.in({{1'b0,{4{oR2[7:0]}}},{1'b1,oR2}}));
always@(*)begin
    case(s&w)
        1'b0:wRAM={4{oR2[7:0]}};
        1'b1:wRAM=oR2;
    endcase
end
reg [3:0] hot;
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
reg [DATA_WIDTH-1:0] oRamB;
// assign oRamB={24'b0,iRAM[7:0]};
always@(*)begin
    case(adr[1:0])
        2'b00:oRamB={24'b0,iRAM[7:0]};
        2'b01:oRamB={24'b0,iRAM[15:8]};
        2'b10:oRamB={24'b0,iRAM[23:16]};
        2'b11:oRamB={24'b0,iRAM[31:24]};
    endcase
end
// ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxLw(.out(oRAM),.addr(l&w),.in({{1'b0,oRamB},{1'b1,iRAM}}));
always@(*)begin
    case(l&w)
        1'b0:oRAM=oRamB;
        1'b1:oRAM=iRAM;
    endcase
end

//pc处理
wire [DATA_WIDTH-1:0] snpc;
reg [DATA_WIDTH-1:0] dnpc;
assign snpc=pc+4;
assign rAdr=snpc;
// ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxJalr(.out(dnpc),.addr(jalr),.in({{1'b0,snpc},{1'b1,oR2}}));
always@(*)begin
    case(jalr)
        1'b0:dnpc=snpc;
        1'b1:dnpc=adr;
    endcase
end

always@(posedge clk)begin
    pc<=reset?PC_RESET:dnpc;

`ifdef DEBUG
    $display("pc=0x%x,dnpc=0x%x,snpc=0x%x reset=%d",pc,dnpc,snpc,reset);
`endif

end
endmodule
module ysyx_26020046_minirv_IDC #(ADDR_WIDTH = 5, DATA_WIDTH = 32)(code,a0,cR1,cR2,cRd,imm,imi,add,lui,l,s,jalr,w,eRd,stop,eb);
  input [DATA_WIDTH-1:0] code,a0;
  output [ADDR_WIDTH-1:0] cR1,cR2,cRd;
  output reg [DATA_WIDTH-1:0] imm;
  output [DATA_WIDTH-1:0] imi;
  output add,lui,l,s,jalr,w,eRd;
  output reg stop,eb;

  wire addi;
  // wire lw,sw,sb,lbu;
  wire [6:0] opc;
  wire [2:0] fc3;
  wire [6:0] fc7;
  wire [DATA_WIDTH-1:0] im0,im1;

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

  // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxS(.out(imm),.addr(s),.in({{1'b0,im1},{1'b1,im0}}));
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
      // stop=0;
      eb=1'b0;
    end
  end
endmodule
module ysyx_26020046_minirv_ALU #(DATA_WIDTH=32)(oR1,oR2,imm,imi,lui,add,adr,oRAM,l,rAdr,jalr,iRd);
    input [DATA_WIDTH-1:0] oR1,oR2,imm,imi,oRAM,rAdr;
    input add,lui,l,jalr;
    output [DATA_WIDTH-1:0] adr;
    output reg [DATA_WIDTH-1:0] iRd;

    wire [DATA_WIDTH-1:0] adder;
    reg [DATA_WIDTH-1:0] in2,lmer,Ler;
    
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxAdd(.out(in2),.addr(add),.in({{1'b0,imm},{1'b1,oR2}}));
    always@(*)begin
        case(add)
            1'b0:in2=imm;
            1'b1:in2=oR2;
        endcase
    end
    assign adder=oR1+in2;
    assign adr=adder;
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxLui(.out(lmer),.addr(lui),.in({{1'b0,adder},{1'b1,imi}}));
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxI(.out(Ler),.addr(l),.in({{1'b0,lmer},{1'b1,oRAM}}));
    // ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxJalr(.out(iRd),.addr(jalr),.in({{1'b0,Ler},{1'b1,rAdr}}));
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
endmodule
