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
