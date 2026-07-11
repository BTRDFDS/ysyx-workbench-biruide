module ysyx_26020046_minirv_LSU #(DATA_WIDTH=32)(clk,reset,s,w,l,jalr,pcReset,adr,oR2,iRAM,pc,oRAM,ramAddr,wRAM,rAdr,wmask);
input clk,reset,s,w,l,jalr;
input [DATA_WIDTH-1:0] pcReset,adr,oR2,iRAM;
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
    pc<=reset?pcReset:dnpc;

`ifdef DEBUG
    $display("pc=0x%x,dnpc=0x%x,snpc=0x%x reset=%d",pc,dnpc,snpc,reset);
`endif

end
endmodule
