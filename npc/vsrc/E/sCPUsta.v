module sCPUsta(
    input clk,
    input [7:0] rom,
    output reg [3:0] pc,
    output reg [7:0] seg0,
    output reg [7:0] seg1
);

// (* synthesis, rom_block *)reg [7:0] rom[0:15];
reg [3:0] im;
reg [7:0] code;
reg [7:0] gpr [0:3];
reg [1:0] rd,r1,r2;


always@(*)begin
    code = rom;
    rd = code[5:4];
    r1 = code[3:2];
    r2 = code[1:0];
    im = code[3:0];
end

always @(posedge clk) begin
    //$display(pc," %x %x %x %x %x",code,gpr[0],gpr[1],gpr[2],gpr[3]);
    case(code[7:6])
        2'b00:begin
            //$display("ADD r%x<=r%x+r%x",rd,r1,r2);
            gpr[rd]<= gpr[r1]+gpr[r2];
            pc <= pc+1;
            seg0<= seg0;
            seg1<= seg1;
        end
        2'b10:begin
            //$display("LIM r%x<=%x",rd,im);
            gpr[rd]<= {4'b0,im};
            pc <= pc+1;
            seg0<= seg0;
            seg1<= seg1;
        end
        2'b11:begin
            //$display("JMP r%x(%x) r0(%x) pc<=%x",r2,gpr[r2],gpr[0],im);
            pc <= gpr[r2]==gpr[0]?pc+1:code[5:2];
            seg0<= seg0;
            seg1<= seg1;
        end
        2'b01:begin
            //$display("OUT r%x(%x)",r2,gpr[r2]);
            case(gpr[r2][3:0])
                4'h0:seg0 <= 8'b00000011;
                4'h1:seg0 <= 8'b10011111;
                4'h2:seg0 <= 8'b00100101;
                4'h3:seg0 <= 8'b00001101;
                4'h4:seg0 <= 8'b10011001;
                4'h5:seg0 <= 8'b01001001;
                4'h6:seg0 <= 8'b01000001;
                4'h7:seg0 <= 8'b00011111;
                4'h8:seg0 <= 8'b00000001;
                4'h9:seg0 <= 8'b00001001;
                4'ha:seg0 <= 8'b00010001;
                4'hb:seg0 <= 8'b11000001;
                4'hc:seg0 <= 8'b01100011;
                4'hd:seg0 <= 8'b10000101;
                4'he:seg0 <= 8'b01100001;
                4'hf:seg0 <= 8'b01110001;
            default :seg0 <= 8'b11111111;
            endcase
            case(gpr[r2][7:4])
                4'h0:seg1 <= 8'b00000011;
                4'h1:seg1 <= 8'b10011111;
                4'h2:seg1 <= 8'b00100101;
                4'h3:seg1 <= 8'b00001101;
                4'h4:seg1 <= 8'b10011001;
                4'h5:seg1 <= 8'b01001001;
                4'h6:seg1 <= 8'b01000001;
                4'h7:seg1 <= 8'b00011111;
                4'h8:seg1 <= 8'b00000001;
                4'h9:seg1 <= 8'b00001001;
                4'ha:seg1 <= 8'b00010001;
                4'hb:seg1 <= 8'b11000001;
                4'hc:seg1 <= 8'b01100011;
                4'hd:seg1 <= 8'b10000101;
                4'he:seg1 <= 8'b01100001;
                4'hf:seg1 <= 8'b01110001;
            default :seg1 <= 8'b11111111;
            endcase
            pc <= pc+1;
        end
    endcase
end
endmodule
