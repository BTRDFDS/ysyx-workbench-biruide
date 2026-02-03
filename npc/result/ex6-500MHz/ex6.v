//Generate the verilog at 2026-02-03T17:03:05 by iSTA.
module ex6 (
clk,
out_0_,
out_1_,
out_2_,
out_3_,
out_4_,
out_5_,
out_6_,
out_7_,
seg0_0_,
seg0_1_,
seg0_2_,
seg0_3_,
seg0_4_,
seg0_5_,
seg0_6_,
seg0_7_,
seg1_0_,
seg1_1_,
seg1_2_,
seg1_3_,
seg1_4_,
seg1_5_,
seg1_6_,
seg1_7_
);

input clk ;
output out_0_ ;
output out_1_ ;
output out_2_ ;
output out_3_ ;
output out_4_ ;
output out_5_ ;
output out_6_ ;
output out_7_ ;
output seg0_0_ ;
output seg0_1_ ;
output seg0_2_ ;
output seg0_3_ ;
output seg0_4_ ;
output seg0_5_ ;
output seg0_6_ ;
output seg0_7_ ;
output seg1_0_ ;
output seg1_1_ ;
output seg1_2_ ;
output seg1_3_ ;
output seg1_4_ ;
output seg1_5_ ;
output seg1_6_ ;
output seg1_7_ ;

wire clk ;
wire out_0_ ;
wire out_1_ ;
wire out_2_ ;
wire out_3_ ;
wire out_4_ ;
wire out_5_ ;
wire out_6_ ;
wire out_7_ ;
wire seg0_0_ ;
wire seg0_1_ ;
wire seg0_2_ ;
wire seg0_3_ ;
wire seg0_4_ ;
wire seg0_5_ ;
wire seg0_6_ ;
wire seg0_7_ ;
wire seg1_0_ ;
wire seg1_1_ ;
wire seg1_2_ ;
wire seg1_3_ ;
wire seg1_4_ ;
wire seg1_5_ ;
wire seg1_6_ ;
wire seg1_7_ ;
wire \out[0]_reg_p_D ;
wire \out[0]_reg_p_D_AO21X1H7L_Y_A0 ;
wire \out[0]_reg_p_D_AO21X1H7L_Y_A0_OR2X1P4H7L_B_Y ;
wire \out[0]_reg_p_D_AO21X1H7L_Y_A1 ;
wire \out[0]_reg_p_D_AO21X1H7L_Y_B0 ;
wire \out[1]_reg_p_D ;
wire \out[1]_reg_p_D_BUFX1H7L_Y_A ;
wire \out[1]_reg_p_D_BUFX1H7L_Y_A_XNOR2X4H7L_A_Y ;
wire \out[2]_reg_p_D ;
wire \out[2]_reg_p_D_BUFX1H7L_Y_A ;
wire \out[3]_reg_p_D ;
wire \out[3]_reg_p_D_BUFX1H7L_Y_A ;
wire \out[3]_reg_p_D_BUFX1H7L_Y_A_XOR2X0P7H7L_A_Y ;
wire \out[4]_reg_p_D ;
wire \out[5]_reg_p_D ;
wire \out[6]_reg_p_D ;
wire \out[6]_reg_p_D_BUFX1H7L_Y_A ;
wire \out[7]_reg_p_D ;
wire \out[7]_reg_p_D_BUFX16H7L_Y_A ;
wire \seg0[1]_reg_p_D ;
wire \seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_A1 ;
wire \seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_C0 ;
wire \seg0[2]_reg_p_D ;
wire \seg0[2]_reg_p_D_AOI211X1P4H7L_Y_B0 ;
wire \seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0 ;
wire \seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0_AOI21X1P4H7L_Y_A0 ;
wire \seg0[3]_reg_p_D ;
wire \seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_A1N ;
wire \seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_B0 ;
wire \seg0[4]_reg_p_D ;
wire \seg0[4]_reg_p_D_NAND2X1P4H7L_Y_A ;
wire \seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B ;
wire \seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_A1 ;
wire \seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_B0 ;
wire \seg0[5]_reg_p_D ;
wire \seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A ;
wire \seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A_NAND2X0P5H7L_Y_B ;
wire \seg0[5]_reg_p_D_NAND2X0P5H7L_Y_B ;
wire \seg0[5]_reg_p_D_NAND2X0P5H7L_Y_B_AOAI211X0P5H7L_Y_B0 ;
wire \seg0[6]_reg_p_D ;
wire \seg0[6]_reg_p_D_NAND2X0P5H7L_Y_A ;
wire \seg0[6]_reg_p_D_NAND2X0P5H7L_Y_B ;
wire \seg0[7]_reg_p_D ;
wire \seg0[7]_reg_p_D_OAI211X1H7L_Y_A0 ;
wire \seg0[7]_reg_p_D_OAI211X1H7L_Y_A1 ;
wire \seg0[7]_reg_p_D_OAI211X1H7L_Y_B0 ;
wire \seg1[1]_reg_p_D ;
wire \seg1[1]_reg_p_D_AOAI211X1H7L_Y_A0 ;
wire \seg1[1]_reg_p_D_AOAI211X1H7L_Y_C0 ;
wire \seg1[2]_reg_p_D ;
wire \seg1[2]_reg_p_D_OAI21X1P4H7L_Y_A1 ;
wire \seg1[3]_reg_p_D ;
wire \seg1[3]_reg_p_D_OAI21X1P4H7L_Y_A1 ;
wire \seg1[3]_reg_p_D_OAI21X1P4H7L_Y_B0 ;
wire \seg1[4]_reg_p_D ;
wire \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_A ;
wire \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B ;
wire \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B_NAND2X0P5H7L_Y_B ;
wire \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C ;
wire \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C ;
wire \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_D ;
wire \seg1[5]_reg_p_D ;
wire \seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ;
wire \seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_B0 ;
wire \seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_C0 ;
wire \seg1[6]_reg_p_D ;
wire \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN ;
wire \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN_NOR4X2H7L_Y_C ;
wire \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_B ;
wire \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_C ;
wire \seg1[7]_reg_p_D ;
wire \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A ;
wire \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A_NAND3X1H7L_Y_C ;
wire \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D ;
wire \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D_NAND3X0P5H7L_Y_C ;

assign seg0_0_ = seg1_0_ ;

DFFQX1H7L \out[0]_reg_p ( .CK(clk ), .D(\out[0]_reg_p_D ), .Q(out_0_ ) );
AO21X1H7L \out[0]_reg_p_D_AO21X1H7L_Y ( .A0(\out[0]_reg_p_D_AO21X1H7L_Y_A0 ), .A1(\out[0]_reg_p_D_AO21X1H7L_Y_A1 ), .B0(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .Y(\out[0]_reg_p_D ) );
NOR4X1P4H7L \out[0]_reg_p_D_AO21X1H7L_Y_A0_NOR4X1P4H7L_Y ( .A(out_5_ ), .B(out_6_ ), .C(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .D(out_0_ ), .Y(\out[0]_reg_p_D_AO21X1H7L_Y_A0 ) );
OR2X1P4H7L \out[0]_reg_p_D_AO21X1H7L_Y_A0_OR2X1P4H7L_B ( .A(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .B(\out[0]_reg_p_D_AO21X1H7L_Y_A0 ), .Y(\out[0]_reg_p_D_AO21X1H7L_Y_A0_OR2X1P4H7L_B_Y ) );
NAND2X1P4H7L \out[0]_reg_p_D_AO21X1H7L_Y_A1_NAND2X1P4H7L_B ( .A(\out[0]_reg_p_D_AO21X1H7L_Y_A0_OR2X1P4H7L_B_Y ), .B(\out[0]_reg_p_D_AO21X1H7L_Y_A1 ), .Y(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_A ) );
NOR2X0P5H7L \out[0]_reg_p_D_AO21X1H7L_Y_A1_NOR2X0P5H7L_Y ( .A(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .B(\seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .Y(\out[0]_reg_p_D_AO21X1H7L_Y_A1 ) );
BUFX1P4H7L \out[0]_reg_p_D_AO21X1H7L_Y_B0_BUFX1P4H7L_Y ( .A(out_1_ ), .Y(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ) );
DFFQX1H7L \out[1]_reg_p ( .CK(clk ), .D(\out[1]_reg_p_D ), .Q(out_1_ ) );
BUFX1H7L \out[1]_reg_p_D_BUFX1H7L_Y ( .A(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .Y(\out[1]_reg_p_D ) );
BUFX3P5H7L \out[1]_reg_p_D_BUFX1H7L_Y_A_BUFX3P5H7L_Y ( .A(out_2_ ), .Y(\out[1]_reg_p_D_BUFX1H7L_Y_A ) );
XNOR2X4H7L \out[1]_reg_p_D_BUFX1H7L_Y_A_XNOR2X4H7L_A ( .A(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .Y(\out[1]_reg_p_D_BUFX1H7L_Y_A_XNOR2X4H7L_A_Y ) );
DFFQX1H7L \out[2]_reg_p ( .CK(clk ), .D(\out[2]_reg_p_D ), .Q(out_2_ ) );
BUFX1H7L \out[2]_reg_p_D_BUFX1H7L_Y ( .A(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .Y(\out[2]_reg_p_D ) );
BUFX7H7L \out[2]_reg_p_D_BUFX1H7L_Y_A_BUFX7H7L_Y ( .A(out_3_ ), .Y(\out[2]_reg_p_D_BUFX1H7L_Y_A ) );
DFFQX1H7L \out[3]_reg_p ( .CK(clk ), .D(\out[3]_reg_p_D ), .Q(out_3_ ) );
BUFX1H7L \out[3]_reg_p_D_BUFX1H7L_Y ( .A(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .Y(\out[3]_reg_p_D ) );
BUFX5H7L \out[3]_reg_p_D_BUFX1H7L_Y_A_BUFX5H7L_Y ( .A(out_4_ ), .Y(\out[3]_reg_p_D_BUFX1H7L_Y_A ) );
XOR2X0P7H7L \out[3]_reg_p_D_BUFX1H7L_Y_A_XOR2X0P7H7L_A ( .A(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .B(out_0_ ), .Y(\out[3]_reg_p_D_BUFX1H7L_Y_A_XOR2X0P7H7L_A_Y ) );
DFFQX1H7L \out[4]_reg_p ( .CK(clk ), .D(\out[4]_reg_p_D ), .Q(out_4_ ) );
BUFX1H7L \out[4]_reg_p_D_BUFX1H7L_Y ( .A(out_5_ ), .Y(\out[4]_reg_p_D ) );
DFFQX1H7L \out[5]_reg_p ( .CK(clk ), .D(\out[5]_reg_p_D ), .Q(out_5_ ) );
BUFX1H7L \out[5]_reg_p_D_BUFX1H7L_Y ( .A(out_6_ ), .Y(\out[5]_reg_p_D ) );
DFFQX1H7L \out[6]_reg_p ( .CK(clk ), .D(\out[6]_reg_p_D ), .Q(out_6_ ) );
BUFX1H7L \out[6]_reg_p_D_BUFX1H7L_Y ( .A(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .Y(\out[6]_reg_p_D ) );
BUFX3P5H7L \out[6]_reg_p_D_BUFX1H7L_Y_A_BUFX3P5H7L_Y ( .A(out_7_ ), .Y(\out[6]_reg_p_D_BUFX1H7L_Y_A ) );
DFFQX1H7L \out[7]_reg_p ( .CK(clk ), .D(\out[7]_reg_p_D ), .Q(out_7_ ) );
BUFX16H7L \out[7]_reg_p_D_BUFX16H7L_Y ( .A(\out[7]_reg_p_D_BUFX16H7L_Y_A ), .Y(\out[7]_reg_p_D ) );
XNOR2X4H7L \out[7]_reg_p_D_BUFX16H7L_Y_A_XNOR2X4H7L_Y ( .A(\out[3]_reg_p_D_BUFX1H7L_Y_A_XOR2X0P7H7L_A_Y ), .B(\out[1]_reg_p_D_BUFX1H7L_Y_A_XNOR2X4H7L_A_Y ), .Y(\out[7]_reg_p_D_BUFX16H7L_Y_A ) );
DFFQX1H7L \seg0[1]_reg_p ( .CK(clk ), .D(\seg0[1]_reg_p_D ), .Q(seg0_1_ ) );
AOAI211X1P4H7L \seg0[1]_reg_p_D_AOAI211X1P4H7L_Y ( .A0(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A ), .A1(\seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .B0(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .C0(\seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_C0 ), .Y(\seg0[1]_reg_p_D ) );
NOR2X0P5H7L \seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_A1_NOR2X0P5H7L_B ( .A(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .B(\seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .Y(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_B_AOAI211X0P5H7L_Y_B0 ) );
OR2X1P4H7L \seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_A1_OR2X1P4H7L_Y ( .A(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_A1 ) );
NAND4BX0P5H7L \seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_C0_NAND4BX0P5H7L_Y ( .AN(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .C(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .D(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[1]_reg_p_D_AOAI211X1P4H7L_Y_C0 ) );
DFFQX1H7L \seg0[2]_reg_p ( .CK(clk ), .D(\seg0[2]_reg_p_D ), .Q(seg0_2_ ) );
AOI211X1P4H7L \seg0[2]_reg_p_D_AOI211X1P4H7L_Y ( .A0(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .A1(\seg0[7]_reg_p_D_OAI211X1H7L_Y_A0 ), .B0(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_B0 ), .C0(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0 ), .Y(\seg0[2]_reg_p_D ) );
NOR2BX0P5H7L \seg0[2]_reg_p_D_AOI211X1P4H7L_Y_B0_NOR2BX0P5H7L_Z ( .AN(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .Z(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_B0 ) );
AOI21X1P4H7L \seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0_AOI21X1P4H7L_Y ( .A0(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0_AOI21X1P4H7L_Y_A0 ), .A1(\out[0]_reg_p_D_AO21X1H7L_Y_A0_OR2X1P4H7L_B_Y ), .B0(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0 ) );
NAND2BX0P5H7L \seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0_AOI21X1P4H7L_Y_A0_NAND2BX0P5H7L_Y ( .AN(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_C0_AOI21X1P4H7L_Y_A0 ) );
DFFQX1H7L \seg0[3]_reg_p ( .CK(clk ), .D(\seg0[3]_reg_p_D ), .Q(seg0_3_ ) );
OAI2BB1X0P5H7L \seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y ( .A0N(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .A1N(\seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_A1N ), .B0(\seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_B0 ), .Y(\seg0[3]_reg_p_D ) );
OAI21X0P5H7L \seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_A1N_OAI21X0P5H7L_Y ( .A0(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .A1(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .B0(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_A1N ) );
OAI21X0P5H7L \seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_B0_OAI21X0P5H7L_Y ( .A0(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .A1(\out[0]_reg_p_D_AO21X1H7L_Y_A0 ), .B0(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_A1 ), .Y(\seg0[3]_reg_p_D_OAI2BB1X0P5H7L_Y_B0 ) );
DFFQX1H7L \seg0[4]_reg_p ( .CK(clk ), .D(\seg0[4]_reg_p_D ), .Q(seg0_4_ ) );
NAND2X1P4H7L \seg0[4]_reg_p_D_NAND2X1P4H7L_Y ( .A(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_A ), .B(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B ), .Y(\seg0[4]_reg_p_D ) );
AOI22X0P5H7L \seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y ( .A0(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_B0 ), .A1(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_A1 ), .B0(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_B0 ), .B1(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B ) );
NOR2X0P5H7L \seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_A1_NOR2X0P5H7L_Y ( .A(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_A1 ) );
MUX2X0P5H7L \seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_B0_MUX2X0P5H7L_Y ( .A(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A_NAND2X0P5H7L_Y_B ), .B(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .S0(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_B0 ) );
DFFQX1H7L \seg0[5]_reg_p ( .CK(clk ), .D(\seg0[5]_reg_p_D ), .Q(seg0_5_ ) );
NAND2X0P5H7L \seg0[5]_reg_p_D_NAND2X0P5H7L_Y ( .A(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A ), .B(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_B ), .Y(\seg0[5]_reg_p_D ) );
NAND2X0P5H7L \seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A_NAND2X0P5H7L_Y ( .A(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .B(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A_NAND2X0P5H7L_Y_B ), .Y(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A ) );
NOR2BX1P4H7L \seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A_NAND2X0P5H7L_Y_B_NOR2BX1P4H7L_Z ( .AN(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .Z(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A_NAND2X0P5H7L_Y_B ) );
AOAI211X0P5H7L \seg0[5]_reg_p_D_NAND2X0P5H7L_Y_B_AOAI211X0P5H7L_Y ( .A0(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .A1(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .B0(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_B_AOAI211X0P5H7L_Y_B0 ), .C0(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_B ) );
DFFQX1H7L \seg0[6]_reg_p ( .CK(clk ), .D(\seg0[6]_reg_p_D ), .Q(seg0_6_ ) );
NAND2X0P5H7L \seg0[6]_reg_p_D_NAND2X0P5H7L_Y ( .A(\seg0[6]_reg_p_D_NAND2X0P5H7L_Y_A ), .B(\seg0[6]_reg_p_D_NAND2X0P5H7L_Y_B ), .Y(\seg0[6]_reg_p_D ) );
AOAI211X0P5H7L \seg0[6]_reg_p_D_NAND2X0P5H7L_Y_A_AOAI211X0P5H7L_Y ( .A0(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .A1(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .B0(\seg0[2]_reg_p_D_AOI211X1P4H7L_Y_B0 ), .C0(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[6]_reg_p_D_NAND2X0P5H7L_Y_A ) );
AOAI211X0P5H7L \seg0[6]_reg_p_D_NAND2X0P5H7L_Y_B_AOAI211X0P5H7L_Y ( .A0(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .A1(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_B_AOI22X0P5H7L_Y_A1 ), .B0(\seg0[5]_reg_p_D_NAND2X0P5H7L_Y_A_NAND2X0P5H7L_Y_B ), .C0(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[6]_reg_p_D_NAND2X0P5H7L_Y_B ) );
DFFQX1H7L \seg0[7]_reg_p ( .CK(clk ), .D(\seg0[7]_reg_p_D ), .Q(seg0_7_ ) );
OAI211X1H7L \seg0[7]_reg_p_D_OAI211X1H7L_Y ( .A0(\seg0[7]_reg_p_D_OAI211X1H7L_Y_A0 ), .A1(\seg0[7]_reg_p_D_OAI211X1H7L_Y_A1 ), .B0(\seg0[7]_reg_p_D_OAI211X1H7L_Y_B0 ), .C0(\seg0[4]_reg_p_D_NAND2X1P4H7L_Y_A ), .Y(\seg0[7]_reg_p_D ) );
NAND2BX0P5H7L \seg0[7]_reg_p_D_OAI211X1H7L_Y_A0_NAND2BX0P5H7L_Y ( .AN(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[7]_reg_p_D_OAI211X1H7L_Y_A0 ) );
XOR2X0P5H7L \seg0[7]_reg_p_D_OAI211X1H7L_Y_A1_XOR2X0P5H7L_Y ( .A(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .Y(\seg0[7]_reg_p_D_OAI211X1H7L_Y_A1 ) );
NAND4BX0P5H7L \seg0[7]_reg_p_D_OAI211X1H7L_Y_B0_NAND4BX0P5H7L_Y ( .AN(\out[2]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[3]_reg_p_D_BUFX1H7L_Y_A ), .C(\out[0]_reg_p_D_AO21X1H7L_Y_B0 ), .D(\out[1]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg0[7]_reg_p_D_OAI211X1H7L_Y_B0 ) );
TIEHIH7L seg0_TIEHIH7L_Z ( .Z(seg0_0_ ) );
DFFQX1H7L \seg1[1]_reg_p ( .CK(clk ), .D(\seg1[1]_reg_p_D ), .Q(seg1_1_ ) );
AOAI211X1H7L \seg1[1]_reg_p_D_AOAI211X1H7L_Y ( .A0(\seg1[1]_reg_p_D_AOAI211X1H7L_Y_A0 ), .A1(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_A ), .B0(\out[7]_reg_p_D ), .C0(\seg1[1]_reg_p_D_AOAI211X1H7L_Y_C0 ), .Y(\seg1[1]_reg_p_D ) );
NAND2X0P5H7L \seg1[1]_reg_p_D_AOAI211X1H7L_Y_A0_NAND2X0P5H7L_Y ( .A(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .B(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN_NOR4X2H7L_Y_C ), .Y(\seg1[1]_reg_p_D_AOAI211X1H7L_Y_A0 ) );
NAND4X1P4H7L \seg1[1]_reg_p_D_AOAI211X1H7L_Y_C0_NAND4X1P4H7L_Y ( .A(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C ), .B(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .C(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .D(\out[7]_reg_p_D ), .Y(\seg1[1]_reg_p_D_AOAI211X1H7L_Y_C0 ) );
DFFQX1H7L \seg1[2]_reg_p ( .CK(clk ), .D(\seg1[2]_reg_p_D ), .Q(seg1_2_ ) );
OAI21X1P4H7L \seg1[2]_reg_p_D_OAI21X1P4H7L_Y ( .A0(\out[7]_reg_p_D ), .A1(\seg1[2]_reg_p_D_OAI21X1P4H7L_Y_A1 ), .B0(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A ), .Y(\seg1[2]_reg_p_D ) );
AOI21X0P5H7L \seg1[2]_reg_p_D_OAI21X1P4H7L_Y_A1_AOI21X0P5H7L_Y ( .A0(out_5_ ), .A1(\seg1[3]_reg_p_D_OAI21X1P4H7L_Y_A1 ), .B0(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D_NAND3X0P5H7L_Y_C ), .Y(\seg1[2]_reg_p_D_OAI21X1P4H7L_Y_A1 ) );
DFFQX1H7L \seg1[3]_reg_p ( .CK(clk ), .D(\seg1[3]_reg_p_D ), .Q(seg1_3_ ) );
OAI21X1P4H7L \seg1[3]_reg_p_D_OAI21X1P4H7L_Y ( .A0(\out[7]_reg_p_D ), .A1(\seg1[3]_reg_p_D_OAI21X1P4H7L_Y_A1 ), .B0(\seg1[3]_reg_p_D_OAI21X1P4H7L_Y_B0 ), .Y(\seg1[3]_reg_p_D ) );
NAND2X0P5H7L \seg1[3]_reg_p_D_OAI21X1P4H7L_Y_A1_NAND2X0P5H7L_Y ( .A(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .B(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg1[3]_reg_p_D_OAI21X1P4H7L_Y_A1 ) );
OAI2BB1X1P4H7L \seg1[3]_reg_p_D_OAI21X1P4H7L_Y_B0_OAI2BB1X1P4H7L_Y ( .A0N(\seg1[1]_reg_p_D_AOAI211X1H7L_Y_A0 ), .A1N(\out[7]_reg_p_D ), .B0(out_5_ ), .Y(\seg1[3]_reg_p_D_OAI21X1P4H7L_Y_B0 ) );
DFFQX1H7L \seg1[4]_reg_p ( .CK(clk ), .D(\seg1[4]_reg_p_D ), .Q(seg1_4_ ) );
NAND4X1P4H7L \seg1[4]_reg_p_D_NAND4X1P4H7L_Y ( .A(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_A ), .B(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B ), .C(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C ), .D(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_D ), .Y(\seg1[4]_reg_p_D ) );
NAND3X0P5H7L \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_A_NAND3X0P5H7L_Y ( .A(out_5_ ), .B(out_6_ ), .C(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_A ) );
NAND2X0P5H7L \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B_NAND2X0P5H7L_Y ( .A(\out[7]_reg_p_D ), .B(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B_NAND2X0P5H7L_Y_B ), .Y(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B ) );
NOR3X0P5H7L \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B_NAND2X0P5H7L_Y_B_NOR3X0P5H7L_Y ( .A(out_5_ ), .B(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .C(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B_NAND2X0P5H7L_Y_B ) );
NAND4BX2H7L \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y ( .AN(\out[7]_reg_p_D ), .B(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .C(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C ), .D(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C ) );
INVX1H7L \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C_INVX1H7L_Y ( .A(out_5_ ), .Y(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C ) );
NAND3BX1P4H7L \seg1[4]_reg_p_D_NAND4X1P4H7L_Y_D_NAND3BX1P4H7L_Y ( .AN(\out[7]_reg_p_D ), .B(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A_NAND3X1H7L_Y_C ), .C(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN_NOR4X2H7L_Y_C ), .Y(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_D ) );
DFFQX1H7L \seg1[5]_reg_p ( .CK(clk ), .D(\seg1[5]_reg_p_D ), .Q(seg1_5_ ) );
AOAI211X1P4H7L \seg1[5]_reg_p_D_AOAI211X1P4H7L_Y ( .A0(out_5_ ), .A1(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .B0(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_B0 ), .C0(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_C0 ), .Y(\seg1[5]_reg_p_D ) );
INVX1P4H7L \seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1_INVX1P4H7L_Y ( .A(out_6_ ), .Y(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ) );
NAND2X0P5H7L \seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_B0_NAND2X0P5H7L_Y ( .A(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[7]_reg_p_D ), .Y(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_B0 ) );
NAND2BX1P4H7L \seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_C0_NAND2BX1P4H7L_Y ( .AN(\out[7]_reg_p_D ), .B(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_B_NAND2X0P5H7L_Y_B ), .Y(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_C0 ) );
DFFQX1H7L \seg1[6]_reg_p ( .CK(clk ), .D(\seg1[6]_reg_p_D ), .Q(seg1_6_ ) );
NAND3BX1P4H7L \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y ( .AN(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN ), .B(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_B ), .C(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_C ), .Y(\seg1[6]_reg_p_D ) );
NOR4X2H7L \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN_NOR4X2H7L_Y ( .A(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C ), .B(out_6_ ), .C(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN_NOR4X2H7L_Y_C ), .D(\out[7]_reg_p_D ), .Y(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN ) );
INVX0P5H7L \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN_NOR4X2H7L_Y_C_INVX0P5H7L_Y ( .A(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_AN_NOR4X2H7L_Y_C ) );
NAND3X0P5H7L \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_B_NAND3X0P5H7L_Y ( .A(out_5_ ), .B(out_6_ ), .C(\out[7]_reg_p_D ), .Y(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_B ) );
OAI211X1P4H7L \seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_C_OAI211X1P4H7L_Y ( .A0(out_6_ ), .A1(\out[7]_reg_p_D ), .B0(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .C0(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C ), .Y(\seg1[6]_reg_p_D_NAND3BX1P4H7L_Y_C ) );
DFFQX1H7L \seg1[7]_reg_p ( .CK(clk ), .D(\seg1[7]_reg_p_D ), .Q(seg1_7_ ) );
NAND4X1P4H7L \seg1[7]_reg_p_D_NAND4X1P4H7L_Y ( .A(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A ), .B(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C ), .C(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_D ), .D(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D ), .Y(\seg1[7]_reg_p_D ) );
NAND3X1H7L \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A_NAND3X1H7L_Y ( .A(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .B(\out[7]_reg_p_D ), .C(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A_NAND3X1H7L_Y_C ), .Y(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A ) );
NOR2X0P5H7L \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A_NAND3X1H7L_Y_C_NOR2X0P5H7L_Y ( .A(\seg1[4]_reg_p_D_NAND4X1P4H7L_Y_C_NAND4BX2H7L_Y_C ), .B(out_6_ ), .Y(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_A_NAND3X1H7L_Y_C ) );
NAND3X0P5H7L \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D_NAND3X0P5H7L_Y ( .A(out_5_ ), .B(\out[7]_reg_p_D ), .C(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D_NAND3X0P5H7L_Y_C ), .Y(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D ) );
NOR2X0P5H7L \seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D_NAND3X0P5H7L_Y_C_NOR2X0P5H7L_Y ( .A(\seg1[5]_reg_p_D_AOAI211X1P4H7L_Y_A1 ), .B(\out[6]_reg_p_D_BUFX1H7L_Y_A ), .Y(\seg1[7]_reg_p_D_NAND4X1P4H7L_Y_D_NAND3X0P5H7L_Y_C ) );

endmodule
