module ysyx_26020046_StaIdu(
input  logic        	clock,reset,
input  logic [1:0]  	in_pipe_res_sta,
input  logic [31:0] 	in_pipe_pc_sta,
						in_pipe_instr_sta,
input  logic [1:0]  	in_imme_back_sta,
input  logic [31:0] 	in_imme_addr_sta,
input  logic [31:0] 	in_imme_r1Out_sta,
						in_imme_r2Out_sta,
input  logic [31:0] 	in_imme_csrOut_sta,

output logic [4:0]  	in_imme_r1Addr_sta,
						in_imme_r2Addr_sta,
output logic [11:0] 	in_imme_csrAddr_sta,
output logic        	out_pipe_valid_sta,
output logic [4:0]  	out_pipe_rdAddr_sta,
output logic [31:0] 	out_pipe_result_sta,
						out_pipe_pc_sta,
output logic [1:0]  	out_pipe_csrOp_sta,
output logic [31:0] 	out_pipe_csrAddr_sta,
						out_pipe_csrMesg_sta,
output logic [1:0]  	out_pipe_lsuOp_sta,
output logic [2:0]  	out_pipe_lsuAddr_sta,
output logic [31:0] 	out_pipe_r2_sta,
output logic [3:0]  	out_pipe_alu_sta,
output logic [2:0]  	out_pipe_bfu_sta,
output logic [1:0]  	out_pipe_csr_sta,
						out_pipe_res_sta,
output logic        	out_pipe_In1_sta,
						out_pipe_In2_sta,
						out_pipe_enJcod_sta,
output logic [31:0] 	out_pipe_r1_sta,
output logic [1:0]  	out_imme_back_sta,
output logic [31:0] 	out_imme_addr_sta
);
logic [1:0]  	in_pipe_res;
logic [31:0] 	in_pipe_pc,
				in_pipe_instr;
logic [1:0]  	in_imme_back;
logic [31:0] 	in_imme_addr;
logic [31:0] 	in_imme_r1Out,
				in_imme_r2Out;
logic [31:0] 	in_imme_csrOut;



logic [4:0]  	in_imme_r1Addr,
				in_imme_r2Addr;
logic [11:0] 	in_imme_csrAddr;
logic        	out_pipe_valid;
logic [4:0]  	out_pipe_rdAddr;
logic [31:0] 	out_pipe_result,
				out_pipe_pc;
logic [1:0]  	out_pipe_csrOp;
logic [31:0] 	out_pipe_csrAddr,
				out_pipe_csrMesg;
logic [1:0]  	out_pipe_lsuOp;
logic [2:0]  	out_pipe_lsuAddr;
logic [31:0] 	out_pipe_r2;
logic [3:0]  	out_pipe_alu;
logic [2:0]  	out_pipe_bfu;
logic [1:0]  	out_pipe_csr,
				out_pipe_res;
logic        	out_pipe_In1,
				out_pipe_In2,
				out_pipe_enJcod;
logic [31:0] 	out_pipe_r1;
logic [1:0]  	out_imme_back;
logic [31:0] 	out_imme_addr;
always_ff@(posedge clock) if(reset)begin
	in_pipe_res		<= in_pipe_res_sta;
	in_pipe_pc		<= in_pipe_pc_sta;
	in_pipe_instr	<= in_pipe_instr_sta;
	in_imme_back	<= in_imme_back_sta;
	in_imme_addr	<= in_imme_addr_sta;
	in_imme_r1Out	<= in_imme_r1Out_sta;
	in_imme_r2Out	<= in_imme_r2Out_sta;
	in_imme_csrOut	<= in_imme_csrOut_sta;


	in_imme_r1Addr_sta	 <= in_imme_r1Addr;
	in_imme_r2Addr_sta	 <= in_imme_r2Addr;
	in_imme_csrAddr_sta	 <= in_imme_csrAddr;
	out_pipe_valid_sta	 <= out_pipe_valid;
	out_pipe_rdAddr_sta	 <= out_pipe_rdAddr;
	out_pipe_result_sta	 <= out_pipe_result;
	out_pipe_pc_sta		 <= out_pipe_pc;
	out_pipe_csrOp_sta	 <= out_pipe_csrOp;
	out_pipe_csrAddr_sta <= out_pipe_csrAddr;
	out_pipe_csrMesg_sta <= out_pipe_csrMesg;
	out_pipe_lsuOp_sta	 <= out_pipe_lsuOp;
	out_pipe_lsuAddr_sta <= out_pipe_lsuAddr;
	out_pipe_r2_sta		 <= out_pipe_r2;
	out_pipe_alu_sta	 <= out_pipe_alu;
	out_pipe_bfu_sta	 <= out_pipe_bfu;
	out_pipe_csr_sta	 <= out_pipe_csr;
	out_pipe_res_sta	 <= out_pipe_res;
	out_pipe_In1_sta	 <= out_pipe_In1;
	out_pipe_In2_sta	 <= out_pipe_In2;
	out_pipe_enJcod_sta	 <= out_pipe_enJcod;
	out_pipe_r1_sta		 <= out_pipe_r1;
	out_imme_back_sta	 <= out_imme_back;
	out_imme_addr_sta	 <= out_imme_addr;
end
ysyx_26020046_Idu Idu(.*);
endmodule