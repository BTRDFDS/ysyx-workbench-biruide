module ysyx_26020046_IDC #(ADDR_WIDTH = 5, DATA_WIDTH = 32) (
  input [DATA_WIDTH-1:0]  code,
  output [DATA_WIDTH-1:0] imm,
  output [ADDR_WIDTH-1:0] r1,r2,rd,
  output wen
);
  wire [DATA_WIDTH-1:0] isjb,immI,immS,immJ,immB,immU;
  wire i,s,j,b,u,r,uR1,uR2;
  wire [2:0] funct3;
  wire [6:0] opcode,funct7;
  wire [2:0] con;


  assign r=(opcode==7'b0110011);
  assign i=(opcode==7'b0000011)|(opcode==7'b0010011)|(opcode==7'b1100111);
  assign s=(opcode==7'b0100011);
  assign b=(opcode==7'b1100011);
  assign u=(opcode==7'b0110111)|(opcode==7'b0010111);
  assign j=(opcode==7'b1101111);

  assign wen = r|i|u|j;
  assign uR1 = r|i|s|b;
  assign uR2 = r|s|b;

  assign funct7 = code[31:25];
  assign r2 = uR2?code[24:20]:0;
  assign r1 = uR1?code[19:15]:0;
  assign funct3 = code[14:12];
  assign rd = code[11:7];
  assign opcode = code[6:0];

  assign immI = {{20{code[31]}},code[31:20]};
  assign immS = {{20{code[31]}},code[31:25],code[11:7]};
  assign immB = {{20{code[31]}},code[7],code[30:25],code[11:8],12'b0};
  assign immU = {code[31:12],12'b0};
  assign immJ = {{12{code[31]}},code[19:12],code[20],code[30:21],12'b0};

  ysyx_26020046_mux2nM #(2,DATA_WIDTH) mux0(isjb,con[1:0],{{2'b00,immI},{2'b01,immS},{2'b10,immJ},{2'b11,immB}});
  ysyx_26020046_mux2nM #(1,DATA_WIDTH) mux1(imm ,con[2]  ,{{1'b0,isjb},{1'b1,immU}});
endmodule
