module ex8N(
    input clk,
    input reset,
    // input [18:0]vgaLocate,
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

integer logFile=$fopen("ex8Log.txt", "w");
final begin
    $fclose(logFile);
end

initial begin
    // vgaData 
    x = 1;
    y = 1;
    // $readmemh("picture.hex", vgaData);
    // $readmemh("nuaa.hex", vgaData);
    $readmemh("hex/NUAA.hex", vgaData);
end
// always @(posedge clk) begin
//     if(reset == 1'b1) begin
//         x <= 1;
//         y <= 1;
//         $fseek(logFile,0,0);
//         // vgaBlank <=0;
//     end
//     else begin
//         if(x == hTotal)begin
//             x <= 1;
//             if(y == vTotal) y <= 1;
//             if(y == vTotal)begin
//                 // y <= y;
//                 // x <=x;
//                 x <= 1;
//                 y <= 1;
//             end else begin
//                 y<= y + 1;
//                 x <=1;
//             end
//         end
//         else begin
//             x <= x + 1;
//         end
//     end
// end
  always @(posedge reset or posedge clk) //行像素计数
      if (reset == 1'b1)
        x <= 1;
      else
      begin
        if (x == hTotal)
            x <= 1;
        else
            x <= x + 10'd1;
      end

  always @(posedge clk)  //列像素计数
      if (reset == 1'b1)
        y <= 1;
        $fseek(logFile,0,0);
      else
      begin
        if (y == vTotal & x == hTotal)
            y <= 1;
        else if (x == hTotal)
            y <= y + 10'd1;
      end
// always@(posedge clk) if(((vgaBlank)|(x==hActive&vValid))&(x <= hBackporch)) $fstrobe(logFile,"xy",x,y," hv",hAddr,vAddr," ",locate," %x%x%x",vgaR, vgaG, vgaB);
//同步
assign vgaHsync = (x>hFrontporch);
assign vgaVsync = (y>vFrontporch);
//生成消隐信号
assign hValid = (x>hActive)&(x <= hBackporch);
assign vValid = (y>vActive)&(y <= vBackporch);
assign vgaBlank = hValid&vValid;
//设置输出的颜色值
assign hAddr = hValid?(x-10'd145):10'd0;
assign vAddr = vValid?(y-10'd36) :10'd0;
// assign hAddr = x-10'd145;
// assign vAddr = y-10'd036;
wire [18:0] locate;
assign locate={vAddr,9'b0}+{2'b0,vAddr,7'b0}+{9'b0,hAddr};
assign {vgaR, vgaG, vgaB} = vgaBlank?vgaData[locate]:24'd0;
endmodule
