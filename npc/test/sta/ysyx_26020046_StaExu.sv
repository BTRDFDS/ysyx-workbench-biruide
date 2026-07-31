module ysyx_26020046_StaExu(
input 	logic       	clock,
input 	logic [1:0] 	in_imme_back,
input 	logic [31:0]	in_imme_addr,
input 	logic [31:0]	in_imme_r1Out,
						in_imme_r2Out,
input 	logic [31:0]	in_imme_csrOut,
input 	logic       	in_pipe_valid,
input 	logic [4:0] 	in_pipe_rdAddr,
input 	logic [31:0]	in_pipe_result,
						in_pipe_pc,
input 	logic [1:0] 	in_pipe_csrOp,
input 	logic [31:0]	in_pipe_csrAddr,
						in_pipe_csrMesg,
input 	logic [1:0] 	in_pipe_lsuOp,
input 	logic [2:0] 	in_pipe_lsuAddr,
input 	logic [31:0]	in_pipe_r2,	
input 	logic [3:0] 	in_pipe_alu,
input 	logic [2:0] 	in_pipe_bfu,
input 	logic [1:0] 	in_pipe_csr,
						in_pipe_res,
input 	logic       	in_pipe_In1,
						in_pipe_In2,
						in_pipe_enJcod,
input 	logic [31:0]	in_pipe_r1,
input 	logic [4:0] 	out_imme_r1Addr,
						out_imme_r2Addr,
input 	logic [11:0]	out_imme_csrAddr,
output	logic [4:0] 	in_imme_r1Addr_sta,
						in_imme_r2Addr_sta,
output	logic [11:0]	in_imme_csrAddr_sta,
output	logic [1:0] 	out_imme_back_sta,
output	logic [31:0]	out_imme_addr_sta,
output	logic [31:0]	out_imme_r1Out_sta,
						out_imme_r2Out_sta,
output	logic [31:0]	out_imme_csrOut_sta,
output	logic       	out_pipe_valid_sta,
output	logic [4:0] 	out_pipe_rdAddr_sta,
output	logic [31:0]	out_pipe_result_sta,
						out_pipe_pc_sta,
output	logic [1:0] 	out_pipe_csrOp_sta,
output	logic [31:0]	out_pipe_csrAddr_sta,
						out_pipe_csrMesg_sta,
output	logic [1:0] 	out_pipe_lsuOp_sta,
output	logic [2:0] 	out_pipe_lsuAddr_sta,
output	logic [31:0]	out_pipe_r2_sta
);
logic [4:0] 	in_imme_r1Addr,
				in_imme_r2Addr;
logic [11:0]	in_imme_csrAddr;
logic [1:0] 	out_imme_back;
logic [31:0]	out_imme_addr;
logic [31:0]	out_imme_r1Out,
				out_imme_r2Out;
logic [31:0]	out_imme_csrOut;
logic       	out_pipe_valid;
logic [4:0] 	out_pipe_rdAddr;
logic [31:0]	out_pipe_result,
				out_pipe_pc;
logic [1:0] 	out_pipe_csrOp;
logic [31:0]	out_pipe_csrAddr,
				out_pipe_csrMesg;
logic [1:0] 	out_pipe_lsuOp;
logic [2:0] 	out_pipe_lsuAddr;
logic [31:0]	out_pipe_r2;
always_ff@(posedge clock)begin
	in_imme_r1Addr_sta	 <= in_imme_r1Addr_sta	;
	in_imme_r2Addr_sta	 <= in_imme_r2Addr_sta	;
	in_imme_csrAddr_sta	 <= in_imme_csrAddr_sta	;
	out_imme_back_sta	 <= out_imme_back_sta	;
	out_imme_addr_sta	 <= out_imme_addr_sta	;
	out_imme_r1Out_sta	 <= out_imme_r1Out_sta	;
	out_imme_r2Out_sta	 <= out_imme_r2Out_sta	;
	out_imme_csrOut_sta	 <= out_imme_csrOut_sta	;
	out_pipe_valid_sta	 <= out_pipe_valid_sta	;
	out_pipe_rdAddr_sta	 <= out_pipe_rdAddr_sta	;
	out_pipe_result_sta	 <= out_pipe_result_sta	;
	out_pipe_pc_sta		 <= out_pipe_pc_sta		;
	out_pipe_csrOp_sta	 <= out_pipe_csrOp_sta	;
	out_pipe_csrAddr_sta <= out_pipe_csrAddr_sta;
	out_pipe_csrMesg_sta <= out_pipe_csrMesg_sta;
	out_pipe_lsuOp_sta	 <= out_pipe_lsuOp_sta	;
	out_pipe_lsuAddr_sta <= out_pipe_lsuAddr_sta;
	out_pipe_r2_sta		 <= out_pipe_r2_sta		;
end
ysyx_26020046_Exu exu(.*);
endmodule