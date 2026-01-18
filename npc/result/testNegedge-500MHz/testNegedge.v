//Generate the verilog at 2026-01-18T18:06:33 by iSTA.
module testNegedge (
clk,
rst,
in,
out
);

input clk ;
input rst ;
input in ;
output out ;

wire clk ;
wire rst ;
wire in ;
wire out ;
wire in_NOR2BX1H7L_AN_Z ;
wire out_reg_n_D ;
wire \r1.dout_0_ ;
wire \r2.dout_0_ ;
wire \r2.dout_0__reg_n_D ;


NOR2BX1H7L in_NOR2BX1H7L_AN ( .AN(in ), .B(rst ), .Z(in_NOR2BX1H7L_AN_Z ) );
DFFNQX2H7L out_reg_n ( .CKN(clk ), .D(out_reg_n_D ), .Q(out ) );
NOR2BX0P5H7L \r1.dout_0__NOR2BX0P5H7L_AN ( .AN(\r1.dout_0_ ), .B(rst ), .Z(\r2.dout_0__reg_n_D ) );
DFFNQX2H7L \r1.dout_0__reg_n ( .CKN(clk ), .D(in_NOR2BX1H7L_AN_Z ), .Q(\r1.dout_0_ ) );
NOR2BX0P5H7L \r2.dout_0__NOR2BX0P5H7L_AN ( .AN(\r2.dout_0_ ), .B(rst ), .Z(out_reg_n_D ) );
DFFNQX2H7L \r2.dout_0__reg_n ( .CKN(clk ), .D(\r2.dout_0__reg_n_D ), .Q(\r2.dout_0_ ) );

endmodule
