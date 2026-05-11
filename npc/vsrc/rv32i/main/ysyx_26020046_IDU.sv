`include "ysyx_26020046_config.svh"
module ysyx_26020046_IDU(
	input  IfId_t  nIfId,
	output upBk_t  iIdIf,
	output valcl_t vIdAl,
	output IdAl_t  nIdAl,
	input  upBk_t  iAlId
	);
	//OP宏定义
		parameter OP_I_J	= 7'b1100111;//jalr
		parameter OP_I_A	= 7'b0010011;//i运算
		parameter OP_I_L	= 7'b0000011;//l系列
		parameter OP_U_I	= 7'b0110111;//lui
		parameter OP_U_P	= 7'b0010111;//auipc
		parameter OP_S__	= 7'b0100011;//s系列
		parameter OP_B__	= 7'b1100011;//b比较系列
		parameter OP_J__	= 7'b1101111;//jal
		parameter OP_R__ 	= 7'b0110011;//r运算
		parameter OP_CSR	= 7'b1110011;//CSR系列

		parameter OP_CSR_ECALL_	= 32'h00000073;
		parameter OP_CSR_EBREAK	= 32'h00100073;
		parameter OP_CSR_MRET__	= 32'h30200073;
	IfId_t oIfId;
	CSRop_t op;word_t mesg;

	always_comb oIfId=nIfId;
	always_comb iIdIf=iAlId;
	always_comb begin : ID
		//译码
			nIdAl.in1=IR1;nIdAl.in2=IR2;
			nIdAl.adr=NAD;nIdAl.cal=NCAL;nIdAl.bfu=NBFU;
			nIdAl.cCsr=NACSR;nIdAl.cIrd=NCHO;
			nIdAl.LSop=NM;nIdAl.enS=0;nIdAl.enL=0;
			nIdAl.SRop=NCSR_;nIdAl.SRmesg='0;
			{vIdAl.cR1,vIdAl.cR2,nIdAl.cRd,nIdAl.enJcod,nIdAl.imm}='0;
			vIdAl.SRaddr='0;
			op=NCSR_;mesg=32'd2;
			if(oIfId.valid) begin
				`ifdef RV32I_DEBUG $fdisplay(logFile,"IDU:op=%x fun3=%x fun7=%x r1=%x r2=%x rd=%x",oIfId.code.op,oIfId.code.fun3,oIfId.code.fun7,oIfId.code.r1,oIfId.code.r2,oIfId.code.rd);`endif
				unique case(oIfId.code.op)
					OP_U_I	:nIdAl.imm={oIfId.code[31:12],12'b0 };
					OP_U_P	:nIdAl.imm={oIfId.code[31:12],12'b0 };
					OP_S__	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:25],oIfId.code[11:7] };
					OP_I_A	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
					OP_I_J	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
					OP_I_L	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[31:20]};
					OP_B__	:nIdAl.imm={{20{oIfId.code[31]}},oIfId.code[7],oIfId.code[30:25],oIfId.code[11:8], 1'b0 };
					OP_J__	:nIdAl.imm={{12{oIfId.code[31]}},oIfId.code[19:12],oIfId.code[20],oIfId.code[30:21], 1'b0 };
					default	:nIdAl.imm='0;
				endcase
				unique case(oIfId.code.op)
					OP_U_P	:nIdAl.in1=PC_;
					default	:nIdAl.in1=IR1;
				endcase
				unique case(oIfId.code.op)
					OP_U_P	:nIdAl.in2=IMM;
					OP_I_A	:nIdAl.in2=IMM;
					default	:nIdAl.in2=IR2;
				endcase
				unique case(oIfId.code.op)
					OP_J__	:nIdAl.enJcod=1;
					OP_I_J	:nIdAl.enJcod=1;
					OP_CSR	:nIdAl.enJcod=(oIfId.code.fun3==3'b000);
					default	:nIdAl.enJcod=0;
				endcase

				unique case(oIfId.code.op)//选ALU cal
					OP_U_P	:nIdAl.cal=ADD_;
					OP_I_A	:begin unique case(oIfId.code.fun3)
							3'b001:begin unique case(oIfId.code.fun7)
									7'b0000000:nIdAl.cal=SLL_;
									default:begin `ifndef RV32I_STA $display("slli fun7(%x)!=0",oIfId.code.fun7);stop(0);`endif end
								endcase end
							3'b101:begin unique case(oIfId.code.fun7)
									7'b0000000:nIdAl.cal=SRL_;
									7'b0100000:nIdAl.cal=SRA_;
									default:begin `ifndef RV32I_STA $display("srai/srli fun7(%x)!=0/20",oIfId.code.fun7);stop(0);`endif end
								endcase end
							default:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
						endcase end
					OP_R__	:begin unique case(oIfId.code.fun7)
							7'b0000000:nIdAl.cal=ALUopCal_t'(oIfId.code.fun3);
							7'b0100000:begin unique case(oIfId.code.fun3)
									3'b000:nIdAl.cal=SUB_;
									3'b101:nIdAl.cal=SRA_;
									default:begin op=ERROR;`ifndef RV32I_STA $display("R fun7==20 fun3(%x)!=1/5",oIfId.code.fun3);	`endif end endcase end
							default:		begin op=ERROR;`ifndef RV32I_STA $display("R fun7(%x)!=0/20",oIfId.code.fun7);			`endif end
						endcase end
					default	:nIdAl.cal=NCAL;
				endcase

				if(oIfId.code.op==OP_B__)begin//b系列
					nIdAl.bfu=ALUopBfu_t'(oIfId.code.fun3);
				end else nIdAl.bfu=NBFU;

				unique case(oIfId.code.op)//选ALU cho
					OP_U_I	:nIdAl.cIrd=IMM_;
					OP_U_P	:nIdAl.cIrd=CAL_;
					OP_J__	:nIdAl.cIrd=SNPC;
					OP_I_J	:nIdAl.cIrd=SNPC;
					OP_I_A	:nIdAl.cIrd=CAL_;
					OP_R__	:nIdAl.cIrd=CAL_;
					OP_CSR	:nIdAl.cIrd=CCSR;
					default	:nIdAl.cIrd=NCHO;
				endcase
				unique case(oIfId.code.op)//选ALU addr
					OP_J__	:nIdAl.adr=PCI;
					OP_I_J	:nIdAl.adr=R1I;
					OP_I_L	:nIdAl.adr=R1I;
					OP_CSR	:nIdAl.adr=ECJ;
					OP_B__	:nIdAl.adr=PCI;
					OP_S__	:nIdAl.adr=R1I;
					default	:nIdAl.adr=NAD;
				endcase

				unique case(oIfId.code.op)//选LSU op
					OP_I_L	:nIdAl.LSop=LSUop_t'(oIfId.code.fun3);
					OP_S__	:nIdAl.LSop=LSUop_t'(oIfId.code.fun3);
					default	:nIdAl.LSop=NM;
				endcase
				nIdAl.enL=(oIfId.code.op==OP_I_L);
				nIdAl.enS=(oIfId.code.op==OP_S__);

				if(oIfId.code.op==OP_CSR)begin unique case(oIfId.code.fun3)
					3'b000	:nIdAl.cCsr=JUMP_;
					3'b001	:nIdAl.cCsr=WACSR;						
					3'b010	:nIdAl.cCsr=(oIfId.code.r1=='0)?NACSR:RACSR;
					default	:nIdAl.cCsr=NACSR;						
				endcase  unique case(oIfId.code.fun3)
					3'b000	:begin unique case(oIfId.code)
							OP_CSR_MRET__	:begin nIdAl.SRaddr=CSR_ADDR_MEPC;		end
							OP_CSR_ECALL_	:begin nIdAl.SRaddr=CSR_ADDR_MTVEC;		end
							OP_CSR_EBREAK	:begin nIdAl.SRaddr='0;mesg=32'd3;		end
							default			:begin nIdAl.SRaddr='0;mesg=32'd2;		end endcase end
					3'b001					:begin nIdAl.SRaddr={oIfId.code[31:20]};end
					3'b010					:begin nIdAl.SRaddr={oIfId.code[31:20]};end
					default					:begin nIdAl.SRaddr='0;					end
				endcase  unique case(oIfId.code.fun3)
					3'b000	:begin unique case(oIfId.code)
							OP_CSR_MRET__	:nIdAl.SRop=MRET_;
							OP_CSR_ECALL_	:nIdAl.SRop=ERROR;
							OP_CSR_EBREAK	:nIdAl.SRop=ERROR;
							default			:nIdAl.SRop=NCSR_;endcase end
					3'b001					:nIdAl.SRop=WCCSR;
					3'b010					:nIdAl.SRop=(oIfId.code.r1=='0)?NCSR_:WCCSR;
					default					:nIdAl.SRop=NCSR_;
				endcase end else begin nIdAl.cCsr=NACSR;nIdAl.SRaddr='0;nIdAl.SRop=NCSR_;end
				vIdAl.SRaddr=nIdAl.SRaddr;

				unique case(oIfId.code.op)//选cR1 这里7/10就反选
					OP_U_I	:vIdAl.cR1='0;
					OP_U_P	:vIdAl.cR1='0;
					OP_J__	:vIdAl.cR1='0;
					default	:vIdAl.cR1=oIfId.code.r1;
				endcase
				// $fdisplay(logFile,"cR1=%x opR1=%b code=%b",val.cR1,oIfId.code.r1,oIfId.code);
				unique case(oIfId.code.op)//选cR2
					OP_S__	:vIdAl.cR2=oIfId.code.r2;
					OP_R__	:vIdAl.cR2=oIfId.code.r2;
					OP_B__	:vIdAl.cR2=oIfId.code.r2;
					default	:vIdAl.cR2='0;
				endcase
				unique case(oIfId.code.op)//选cRd 也是反选
					OP_B__	:nIdAl.cRd='0;
					OP_S__	:nIdAl.cRd='0;
					OP_CSR	:nIdAl.cRd=(oIfId.code.fun3==3'b000)?'0:oIfId.code.rd;
					default	:nIdAl.cRd=oIfId.code.rd;
				endcase
			end
		//传递流水
			nIdAl.valid	=oIfId.valid;
			nIdAl.pc	=oIfId.pc;
			nIdAl.error	=oIfId.error|error;
			nIdAl.cause	=error?cause:oIfId.cause;
		end
    endmodule
