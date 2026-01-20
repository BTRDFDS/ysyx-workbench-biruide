module ex8(
    input clk,
    input reset,
    input [18:0]vgaLocate,
    output vgaHsync,
    output vgaVsync,
    output vgaBlank,
    output [9:0] vAddr,
    output [9:0] hAddr,
    output [7:0] vgaR,
    output [7:0] vgaG,
    output [7:0] vgaB
);
parameter hFrontporch = 96;
parameter hActive = 144;
parameter hBackporch = 784;
parameter hTotal = 800;

parameter vFrontporch = 2;
parameter vActive = 35;
parameter vBackporch = 515;
parameter vTotal = 525;

reg [9:0] x;
reg [9:0] y;
// reg [23:0] vgaData= 24'hffFF00;
wire vValid,hValid;
// wire [9:0] hAddr;
// wire [9:0] vAddr;
reg [23:0] vgaData [307200:0];
initial begin
    // vgaData 
    x = 1;
    y = 1;
    // $readmemh("picture.hex", vgaData);
    $readmemh("nuaa.hex", vgaData);
end
always @(posedge clk) begin
    if(reset == 1'b1) begin
        x <= 1;
        y <= 1;
        // vgaBlank <=0;
    end
    else begin
        if(x == hTotal)begin
            x <= 1;
            if(y == vTotal) y <= 1;
            else y <= y + 1;
        end
        else x <= x + 1;
    end
end
//生成同步信号    
assign vgaHsync = (x > hFrontporch);
assign vgaVsync = (y > vFrontporch);
//生成消隐信号
assign hValid = (x > hActive) & (x <= hBackporch);
assign vValid = (y > vActive) & (y <= vBackporch);
assign vgaBlank = hValid & vValid;
//设置输出的颜色值
// assign hAddr = hValid ? (x-10'd145):10'd0;
// assign vAddr = vValid ? (y-10'd36) :10'd0;
assign hAddr = x-10'd145;
assign vAddr = y-10'd036;
assign {vgaR, vgaG, vgaB} = vgaData[vgaLocate];
endmodule
