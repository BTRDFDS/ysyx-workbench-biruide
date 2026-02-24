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
    $display("en=%o Reg[%d](0x%x)<=0x%x",eRd,cRd,gpr[cRd],iRd);
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
