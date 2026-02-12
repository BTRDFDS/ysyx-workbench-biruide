module ysyx_26020046_minirv_LSU #(DATA_WIDTH=32)(clk,s,w,l,jalr,adr,oR2,iRAM,pc,oRAM,ramAddr,wRAM,rAdr);//,we,he,oe
input clk,s,w,l,jalr;
input [DATA_WIDTH-1:0] adr,oR2,iRAM;
output reg [DATA_WIDTH-1:0] pc,oRAM,wRAM;
output [DATA_WIDTH-1:0] ramAddr,rAdr;
// output we,he,oe;


//s模块
assign ramAddr=w?{adr[31:2],2'b0}:adr;
// ysyx_26020046_mux2nM #(1,DATA_WIDTH) muxSw(.out(wRAM),.addr(s&w),.in({{1'b0,{4{oR2[7:0]}}},{1'b1,oR2}}));
always@(*)begin
    case(s&w)
        1'b0:wRAM={4{oR2[7:0]}};
        1'b1:wRAM=oR2;
    endcase
end

//l模块
wire [DATA_WIDTH-1:0] oRamB;
assign oRamB={24'b0,iRAM[7:0]};
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
    pc<=dnpc;
    $display("pc=0x%x,dnpc=0x%x,snpc=0x%x",pc,dnpc,snpc);
end
endmodule
