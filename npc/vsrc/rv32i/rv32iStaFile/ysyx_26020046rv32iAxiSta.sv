module ysyx_26020046rv32iAxiSta (
	clk,
	reset,
	arready,
	rvalid,
	awready,
	wready,
	bvalid,
	rdata,
	rresp,
	bresp,
	arvalid,
	rready,
	awvalid,
	wvalid,
	araddr,
	wdata,
	awaddr,
	wstrb
);
	input wire clk;
	input wire reset;
	input wire arready;
	input wire rvalid;
	input wire awready;
	input wire wready;
	input wire bvalid;
	localparam DATA_WIDTH = 32;
	input wire [31:0] rdata;
	input wire [1:0] rresp;
	input wire [1:0] bresp;
	output wire arvalid;
	output wire rready;
	output wire awvalid;
	output wire wvalid;
	output wire [31:0] araddr;
	output wire [31:0] wdata;
	output wire [31:0] awaddr;
	output wire [3:0] wstrb;
	generate
		if (1) begin : nIfId
			reg valid;
			reg ready;
			reg [31:0] code;
			localparam DATA_WIDTH = 32;
			reg [31:0] addr;
			reg enJfun;
		end
		if (1) begin : nIdAl
			reg valid;
			reg ready;
			reg [0:0] in1;
			reg [0:0] in2;
			reg enJcod;
			reg [3:0] cal;
			reg [2:0] bfu;
			reg [2:0] adr;
			reg [1:0] cCsr;
			reg [2:0] cIrd;
			reg enS;
			reg enL;
			reg [2:0] LSop;
			localparam REG_NUMBER = 5;
			reg [4:0] cRd;
			reg [11:0] SRaddr;
			reg [1:0] SRop;
			localparam DATA_WIDTH = 32;
			reg [31:0] oR1;
			reg [31:0] oR2;
			reg [31:0] oCsr;
			reg [31:0] imm;
			reg [31:0] pc;
			reg [31:0] addr;
			reg enJfun;
		end
		if (1) begin : nAlLs
			reg valid;
			reg ready;
			reg enS;
			reg enL;
			reg [2:0] LSop;
			localparam DATA_WIDTH = 32;
			reg [31:0] addr;
			reg [31:0] res;
			reg [31:0] iCsr;
			reg [31:0] oR2;
			reg [11:0] SRaddr;
			reg [1:0] SRop;
			localparam REG_NUMBER = 5;
			reg [4:0] cRd;
		end
		if (1) begin : nLsWb
			reg valid;
			wire ready;
			wire readySr;
			wire readyRg;
			localparam REG_NUMBER = 5;
			reg [4:0] cRd;
			reg [11:0] SRaddr;
			reg [1:0] SRop;
			localparam DATA_WIDTH = 32;
			reg [31:0] iRd;
			reg [31:0] iCsr;
			assign ready = readyRg & readySr;
		end
		if (1) begin : val
			localparam REG_NUMBER = 5;
			reg [4:0] cR1;
			reg [4:0] cR2;
			reg [11:0] SRaddr;
			localparam DATA_WIDTH = 32;
			wire [31:0] oR1;
			wire [31:0] oR2;
			reg [31:0] oCsr;
			reg [31:0] pc;
		end
		if (1) begin : sbIf
			reg arready;
			reg arvalid;
			localparam DATA_WIDTH = 32;
			reg [31:0] araddr;
			reg rready;
			reg rvalid;
			reg [31:0] rdata;
			reg [1:0] rresp;
			reg awready;
			reg awvalid;
			reg [31:0] awaddr;
			reg wvalid;
			reg wready;
			reg [3:0] wstrb;
			reg [31:0] wdata;
			reg bvalid;
			reg bready;
			reg [1:0] bresp;
		end
		if (1) begin : sbLs
			reg arready;
			reg arvalid;
			localparam DATA_WIDTH = 32;
			reg [31:0] araddr;
			reg rready;
			reg rvalid;
			reg [31:0] rdata;
			reg [1:0] rresp;
			reg awready;
			reg awvalid;
			reg [31:0] awaddr;
			reg wvalid;
			reg wready;
			reg [3:0] wstrb;
			reg [31:0] wdata;
			reg bvalid;
			reg bready;
			reg [1:0] bresp;
		end
		if (1) begin : axi4
			wire arready;
			reg arvalid;
			localparam DATA_WIDTH = 32;
			reg [31:0] araddr;
			reg rready;
			wire rvalid;
			wire [31:0] rdata;
			wire [1:0] rresp;
			wire awready;
			reg awvalid;
			reg [31:0] awaddr;
			reg wvalid;
			wire wready;
			reg [3:0] wstrb;
			reg [31:0] wdata;
			wire bvalid;
			reg bready;
			wire [1:0] bresp;
		end
		if (1) begin : ARB
			reg _sv2v_0;
			wire clk;
			wire reset;
			reg [1:0] s;
			reg [1:0] ns;
			always @(*) begin
				if (_sv2v_0)
					;
				(* full_case, parallel_case *)
				case (s)
					2'd0:
						if (ysyx_26020046_rv32iAxi.sbLs.arvalid & ysyx_26020046_rv32iAxi.axi4.arready)
							ns = 2'd2;
						else if (ysyx_26020046_rv32iAxi.sbLs.awvalid & ysyx_26020046_rv32iAxi.axi4.awready)
							ns = 2'd3;
						else if (ysyx_26020046_rv32iAxi.sbLs.wvalid & ysyx_26020046_rv32iAxi.axi4.wready)
							ns = 2'd3;
						else if (ysyx_26020046_rv32iAxi.sbIf.arvalid & ysyx_26020046_rv32iAxi.axi4.arready)
							ns = 2'd1;
						else
							ns = 2'd0;
					2'd2: ns = (ysyx_26020046_rv32iAxi.sbLs.rready & ysyx_26020046_rv32iAxi.axi4.rvalid ? 2'd0 : 2'd2);
					2'd3: ns = (ysyx_26020046_rv32iAxi.sbLs.bready & ysyx_26020046_rv32iAxi.axi4.bvalid ? 2'd0 : 2'd3);
					2'd1: ns = (ysyx_26020046_rv32iAxi.sbIf.rready & ysyx_26020046_rv32iAxi.axi4.rvalid ? 2'd0 : 2'd1);
					default: ns = 2'd0;
				endcase
			end
			always @(posedge clk)
				if (reset)
					s <= 2'd0;
				else
					s <= ns;
			localparam false = 0;
			always @(*) begin
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.axi4.araddr = 1'sb0;
				ysyx_26020046_rv32iAxi.axi4.arvalid = false;
				ysyx_26020046_rv32iAxi.axi4.rready = false;
				ysyx_26020046_rv32iAxi.axi4.awaddr = 1'sb0;
				ysyx_26020046_rv32iAxi.axi4.awvalid = false;
				ysyx_26020046_rv32iAxi.axi4.wdata = 1'sb0;
				ysyx_26020046_rv32iAxi.axi4.wstrb = 1'sb0;
				ysyx_26020046_rv32iAxi.axi4.wvalid = false;
				ysyx_26020046_rv32iAxi.axi4.bready = false;
				ysyx_26020046_rv32iAxi.sbLs.arready = false;
				ysyx_26020046_rv32iAxi.sbLs.rdata = 1'sb0;
				ysyx_26020046_rv32iAxi.sbLs.rresp = 2'd0;
				ysyx_26020046_rv32iAxi.sbLs.rvalid = false;
				ysyx_26020046_rv32iAxi.sbLs.awready = false;
				ysyx_26020046_rv32iAxi.sbLs.wready = false;
				ysyx_26020046_rv32iAxi.sbLs.bresp = 2'd0;
				ysyx_26020046_rv32iAxi.sbLs.bvalid = false;
				ysyx_26020046_rv32iAxi.sbIf.arready = false;
				ysyx_26020046_rv32iAxi.sbIf.rdata = 1'sb0;
				ysyx_26020046_rv32iAxi.sbIf.rresp = 2'd0;
				ysyx_26020046_rv32iAxi.sbIf.rvalid = false;
				ysyx_26020046_rv32iAxi.sbIf.awready = false;
				ysyx_26020046_rv32iAxi.sbIf.wready = false;
				ysyx_26020046_rv32iAxi.sbIf.bresp = 2'd0;
				ysyx_26020046_rv32iAxi.sbIf.bvalid = false;
				(* full_case, parallel_case *)
				case (s)
					2'd0:
						;
					2'd2: begin
						ysyx_26020046_rv32iAxi.axi4.araddr = ysyx_26020046_rv32iAxi.sbLs.araddr;
						ysyx_26020046_rv32iAxi.axi4.arvalid = ysyx_26020046_rv32iAxi.sbLs.arvalid;
						ysyx_26020046_rv32iAxi.sbLs.arready = ysyx_26020046_rv32iAxi.axi4.arready;
						ysyx_26020046_rv32iAxi.sbLs.rdata = ysyx_26020046_rv32iAxi.axi4.rdata;
						ysyx_26020046_rv32iAxi.sbLs.rresp = ysyx_26020046_rv32iAxi.axi4.rresp;
						ysyx_26020046_rv32iAxi.sbLs.rvalid = ysyx_26020046_rv32iAxi.axi4.rvalid;
						ysyx_26020046_rv32iAxi.axi4.rready = ysyx_26020046_rv32iAxi.sbLs.rready;
					end
					2'd3: begin
						ysyx_26020046_rv32iAxi.axi4.awaddr = ysyx_26020046_rv32iAxi.sbLs.awaddr;
						ysyx_26020046_rv32iAxi.axi4.awvalid = ysyx_26020046_rv32iAxi.sbLs.awvalid;
						ysyx_26020046_rv32iAxi.sbLs.awready = ysyx_26020046_rv32iAxi.axi4.awready;
						ysyx_26020046_rv32iAxi.axi4.wdata = ysyx_26020046_rv32iAxi.sbLs.wdata;
						ysyx_26020046_rv32iAxi.axi4.wstrb = ysyx_26020046_rv32iAxi.sbLs.wstrb;
						ysyx_26020046_rv32iAxi.axi4.wvalid = ysyx_26020046_rv32iAxi.sbLs.wvalid;
						ysyx_26020046_rv32iAxi.sbLs.wready = ysyx_26020046_rv32iAxi.axi4.wready;
						ysyx_26020046_rv32iAxi.sbLs.bresp = ysyx_26020046_rv32iAxi.axi4.bresp;
						ysyx_26020046_rv32iAxi.sbLs.bvalid = ysyx_26020046_rv32iAxi.axi4.bvalid;
						ysyx_26020046_rv32iAxi.axi4.bready = ysyx_26020046_rv32iAxi.sbLs.bready;
					end
					2'd1: begin
						ysyx_26020046_rv32iAxi.axi4.araddr = ysyx_26020046_rv32iAxi.sbIf.araddr;
						ysyx_26020046_rv32iAxi.axi4.arvalid = ysyx_26020046_rv32iAxi.sbIf.arvalid;
						ysyx_26020046_rv32iAxi.sbIf.arready = ysyx_26020046_rv32iAxi.axi4.arready;
						ysyx_26020046_rv32iAxi.sbIf.rdata = ysyx_26020046_rv32iAxi.axi4.rdata;
						ysyx_26020046_rv32iAxi.sbIf.rresp = ysyx_26020046_rv32iAxi.axi4.rresp;
						ysyx_26020046_rv32iAxi.sbIf.rvalid = ysyx_26020046_rv32iAxi.axi4.rvalid;
						ysyx_26020046_rv32iAxi.axi4.rready = ysyx_26020046_rv32iAxi.sbIf.rready;
					end
				endcase
			end
			initial _sv2v_0 = 0;
		end
	endgenerate
	assign ARB.clk = clk;
	assign ARB.reset = reset;
	generate
		if (1) begin : IFU
			reg _sv2v_0;
			wire clk;
			wire reset;
			wire nUse;
			reg [1:0] ns;
			reg [1:0] s;
			always @(*) begin
				if (_sv2v_0)
					;
				(* full_case, parallel_case *)
				case (s)
					2'd2: ns = (ysyx_26020046_rv32iAxi.nIfId.ready ? 2'd1 : 2'd2);
					2'd1: ns = (ysyx_26020046_rv32iAxi.sbIf.arready ? 2'd0 : 2'd1);
					2'd0: ns = (ysyx_26020046_rv32iAxi.sbIf.rvalid ? 2'd2 : 2'd0);
					default: ns = 2'd1;
				endcase
			end
			always @(posedge clk)
				if (reset)
					s <= 2'd1;
				else
					s <= ns;
			localparam false = 0;
			always @(*) begin : out
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.sbIf.araddr = ysyx_26020046_rv32iAxi.val.pc;
				ysyx_26020046_rv32iAxi.sbIf.arvalid = s == 2'd1;
				ysyx_26020046_rv32iAxi.sbIf.rready = s == 2'd0;
				ysyx_26020046_rv32iAxi.sbIf.awaddr = 1'sb0;
				ysyx_26020046_rv32iAxi.sbIf.awvalid = false;
				ysyx_26020046_rv32iAxi.sbIf.wdata = 1'sb0;
				ysyx_26020046_rv32iAxi.sbIf.wstrb = 1'sb0;
				ysyx_26020046_rv32iAxi.sbIf.wvalid = false;
				ysyx_26020046_rv32iAxi.sbIf.bready = false;
			end
			always @(posedge clk)
				if ((s == 2'd0) & (ns == 2'd2))
					ysyx_26020046_rv32iAxi.nIfId.code <= ysyx_26020046_rv32iAxi.sbIf.rdata;
			always @(*) begin : in
				if (_sv2v_0)
					;
				case (ysyx_26020046_rv32iAxi.sbIf.rresp)
					2'd0:
						;
					default:
						;
				endcase
				ysyx_26020046_rv32iAxi.nIfId.valid = s == 2'd2;
			end
			localparam PC_RESET = 32'h80000000;
			always @(posedge clk) begin : pc
				if (reset)
					ysyx_26020046_rv32iAxi.val.pc <= PC_RESET;
				else if ((s == 2'd2) & ysyx_26020046_rv32iAxi.nIfId.ready) begin
					if (ysyx_26020046_rv32iAxi.nIfId.enJfun)
						ysyx_26020046_rv32iAxi.val.pc <= ysyx_26020046_rv32iAxi.nIfId.addr & 32'hfffffffc;
					else
						ysyx_26020046_rv32iAxi.val.pc <= ysyx_26020046_rv32iAxi.val.pc + 4;
				end
			end
			initial _sv2v_0 = 0;
		end
	endgenerate
	assign IFU.clk = clk;
	assign IFU.reset = reset;
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	generate
		if (1) begin : IDU
			reg _sv2v_0;
			always @(*) begin
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.nIdAl.oR1 = ysyx_26020046_rv32iAxi.val.oR1;
				ysyx_26020046_rv32iAxi.nIdAl.oR2 = ysyx_26020046_rv32iAxi.val.oR2;
				ysyx_26020046_rv32iAxi.nIdAl.oCsr = ysyx_26020046_rv32iAxi.val.oCsr;
				ysyx_26020046_rv32iAxi.nIdAl.pc = ysyx_26020046_rv32iAxi.val.pc;
				ysyx_26020046_rv32iAxi.nIdAl.valid = ysyx_26020046_rv32iAxi.nIfId.valid;
				ysyx_26020046_rv32iAxi.nIfId.addr = ysyx_26020046_rv32iAxi.nIdAl.addr;
				ysyx_26020046_rv32iAxi.nIfId.enJfun = ysyx_26020046_rv32iAxi.nIdAl.enJfun;
				ysyx_26020046_rv32iAxi.nIfId.ready = ysyx_26020046_rv32iAxi.nIdAl.ready;
			end
			localparam CSR_ADDR_MEPC = 12'h341;
			localparam CSR_ADDR_MTVEC = 12'h305;
			localparam OP_B__ = 7'b1100011;
			localparam OP_CSR = 7'b1110011;
			localparam OP_CSR_EBREAK = 32'h00100073;
			localparam OP_CSR_ECALL_ = 32'h00000073;
			localparam OP_CSR_MRET__ = 32'h30200073;
			localparam OP_I_A = 7'b0010011;
			localparam OP_I_J = 7'b1100111;
			localparam OP_I_L = 7'b0000011;
			localparam OP_J__ = 7'b1101111;
			localparam OP_R__ = 7'b0110011;
			localparam OP_S__ = 7'b0100011;
			localparam OP_U_I = 7'b0110111;
			localparam OP_U_P = 7'b0010111;
			always @(*) begin : ID
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.nIdAl.in1 = 1'd0;
				ysyx_26020046_rv32iAxi.nIdAl.in2 = 1'd0;
				ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd4;
				ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd10;
				ysyx_26020046_rv32iAxi.nIdAl.bfu = 3'd2;
				ysyx_26020046_rv32iAxi.nIdAl.cCsr = 2'd3;
				ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd0;
				ysyx_26020046_rv32iAxi.nIdAl.LSop = 3'd3;
				ysyx_26020046_rv32iAxi.nIdAl.enS = 0;
				ysyx_26020046_rv32iAxi.nIdAl.enL = 0;
				ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd3;
				ysyx_26020046_rv32iAxi.nIdAl.SRaddr = 1'sb0;
				{ysyx_26020046_rv32iAxi.val.cR1, ysyx_26020046_rv32iAxi.val.cR2, ysyx_26020046_rv32iAxi.nIdAl.cRd, ysyx_26020046_rv32iAxi.nIdAl.enJcod, ysyx_26020046_rv32iAxi.nIdAl.imm} = 1'sb0;
				if (ysyx_26020046_rv32iAxi.nIfId.valid) begin
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_U_I: ysyx_26020046_rv32iAxi.nIdAl.imm = {ysyx_26020046_rv32iAxi.nIfId.code[31:12], 12'b000000000000};
						OP_U_P: ysyx_26020046_rv32iAxi.nIdAl.imm = {ysyx_26020046_rv32iAxi.nIfId.code[31:12], 12'b000000000000};
						OP_S__: ysyx_26020046_rv32iAxi.nIdAl.imm = {{20 {ysyx_26020046_rv32iAxi.nIfId.code[31]}}, ysyx_26020046_rv32iAxi.nIfId.code[31:25], ysyx_26020046_rv32iAxi.nIfId.code[11:7]};
						OP_I_A: ysyx_26020046_rv32iAxi.nIdAl.imm = {{20 {ysyx_26020046_rv32iAxi.nIfId.code[31]}}, ysyx_26020046_rv32iAxi.nIfId.code[31:20]};
						OP_I_J: ysyx_26020046_rv32iAxi.nIdAl.imm = {{20 {ysyx_26020046_rv32iAxi.nIfId.code[31]}}, ysyx_26020046_rv32iAxi.nIfId.code[31:20]};
						OP_I_L: ysyx_26020046_rv32iAxi.nIdAl.imm = {{20 {ysyx_26020046_rv32iAxi.nIfId.code[31]}}, ysyx_26020046_rv32iAxi.nIfId.code[31:20]};
						OP_B__: ysyx_26020046_rv32iAxi.nIdAl.imm = {{20 {ysyx_26020046_rv32iAxi.nIfId.code[31]}}, ysyx_26020046_rv32iAxi.nIfId.code[7], ysyx_26020046_rv32iAxi.nIfId.code[30:25], ysyx_26020046_rv32iAxi.nIfId.code[11:8], 1'b0};
						OP_J__: ysyx_26020046_rv32iAxi.nIdAl.imm = {{12 {ysyx_26020046_rv32iAxi.nIfId.code[31]}}, ysyx_26020046_rv32iAxi.nIfId.code[19:12], ysyx_26020046_rv32iAxi.nIfId.code[20], ysyx_26020046_rv32iAxi.nIfId.code[30:21], 1'b0};
						default: ysyx_26020046_rv32iAxi.nIdAl.imm = 1'sb0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_U_P: ysyx_26020046_rv32iAxi.nIdAl.in1 = 1'd1;
						default: ysyx_26020046_rv32iAxi.nIdAl.in1 = 1'd0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_U_P: ysyx_26020046_rv32iAxi.nIdAl.in2 = 1'd1;
						OP_I_A: ysyx_26020046_rv32iAxi.nIdAl.in2 = 1'd1;
						default: ysyx_26020046_rv32iAxi.nIdAl.in2 = 1'd0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_J__: ysyx_26020046_rv32iAxi.nIdAl.enJcod = 1;
						OP_I_J: ysyx_26020046_rv32iAxi.nIdAl.enJcod = 1;
						OP_CSR: ysyx_26020046_rv32iAxi.nIdAl.enJcod = ysyx_26020046_rv32iAxi.nIfId.code[14-:3] == 3'b000;
						default: ysyx_26020046_rv32iAxi.nIdAl.enJcod = 0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_U_P: ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd0;
						OP_I_A:
							(* full_case, parallel_case *)
							case (ysyx_26020046_rv32iAxi.nIfId.code[14-:3])
								3'b001:
									(* full_case, parallel_case *)
									case (ysyx_26020046_rv32iAxi.nIfId.code[31-:7])
										7'b0000000: ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd1;
										default:
											;
									endcase
								3'b101:
									(* full_case, parallel_case *)
									case (ysyx_26020046_rv32iAxi.nIfId.code[31-:7])
										7'b0000000: ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd5;
										7'b0100000: ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd9;
										default:
											;
									endcase
								default: ysyx_26020046_rv32iAxi.nIdAl.cal = sv2v_cast_4(ysyx_26020046_rv32iAxi.nIfId.code[14-:3]);
							endcase
						OP_R__:
							(* full_case, parallel_case *)
							case (ysyx_26020046_rv32iAxi.nIfId.code[31-:7])
								7'b0000000: ysyx_26020046_rv32iAxi.nIdAl.cal = sv2v_cast_4(ysyx_26020046_rv32iAxi.nIfId.code[14-:3]);
								7'b0100000:
									(* full_case, parallel_case *)
									case (ysyx_26020046_rv32iAxi.nIfId.code[14-:3])
										3'b000: ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd8;
										3'b101: ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd9;
										default:
											;
									endcase
								default:
									;
							endcase
						default: ysyx_26020046_rv32iAxi.nIdAl.cal = 4'd10;
					endcase
					if (ysyx_26020046_rv32iAxi.nIfId.code[6-:7] == OP_B__)
						ysyx_26020046_rv32iAxi.nIdAl.bfu = sv2v_cast_3(ysyx_26020046_rv32iAxi.nIfId.code[14-:3]);
					else
						ysyx_26020046_rv32iAxi.nIdAl.bfu = 3'd2;
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_U_I: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd2;
						OP_U_P: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd1;
						OP_J__: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd3;
						OP_I_J: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd3;
						OP_I_A: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd1;
						OP_R__: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd1;
						OP_CSR: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd4;
						default: ysyx_26020046_rv32iAxi.nIdAl.cIrd = 3'd0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_J__: ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd1;
						OP_I_J: ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd0;
						OP_I_L: ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd0;
						OP_CSR: ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd2;
						OP_B__: ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd1;
						OP_S__: ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd0;
						default: ysyx_26020046_rv32iAxi.nIdAl.adr = 3'd4;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_I_L: ysyx_26020046_rv32iAxi.nIdAl.LSop = sv2v_cast_3(ysyx_26020046_rv32iAxi.nIfId.code[14-:3]);
						OP_S__: ysyx_26020046_rv32iAxi.nIdAl.LSop = sv2v_cast_3(ysyx_26020046_rv32iAxi.nIfId.code[14-:3]);
						default: ysyx_26020046_rv32iAxi.nIdAl.LSop = 3'd3;
					endcase
					ysyx_26020046_rv32iAxi.nIdAl.enL = ysyx_26020046_rv32iAxi.nIfId.code[6-:7] == OP_I_L;
					ysyx_26020046_rv32iAxi.nIdAl.enS = ysyx_26020046_rv32iAxi.nIfId.code[6-:7] == OP_S__;
					if (ysyx_26020046_rv32iAxi.nIfId.code[6-:7] == OP_CSR) begin
						(* full_case, parallel_case *)
						case (ysyx_26020046_rv32iAxi.nIfId.code[14-:3])
							3'b000: ysyx_26020046_rv32iAxi.nIdAl.cCsr = 2'd2;
							3'b001: ysyx_26020046_rv32iAxi.nIdAl.cCsr = 2'd0;
							3'b010: ysyx_26020046_rv32iAxi.nIdAl.cCsr = (ysyx_26020046_rv32iAxi.nIfId.code[19-:5] == {5 {1'sb0}} ? 2'd3 : 2'd1);
							default: ysyx_26020046_rv32iAxi.nIdAl.cCsr = 2'd3;
						endcase
						(* full_case, parallel_case *)
						case (ysyx_26020046_rv32iAxi.nIfId.code[14-:3])
							3'b000:
								(* full_case, parallel_case *)
								case (ysyx_26020046_rv32iAxi.nIfId.code)
									OP_CSR_MRET__: ysyx_26020046_rv32iAxi.nIdAl.SRaddr = CSR_ADDR_MEPC;
									OP_CSR_ECALL_: ysyx_26020046_rv32iAxi.nIdAl.SRaddr = CSR_ADDR_MTVEC;
									OP_CSR_EBREAK: ysyx_26020046_rv32iAxi.nIdAl.SRaddr = 1'sb0;
									default: ysyx_26020046_rv32iAxi.nIdAl.SRaddr = 1'sb0;
								endcase
							3'b001: ysyx_26020046_rv32iAxi.nIdAl.SRaddr = {ysyx_26020046_rv32iAxi.nIfId.code[31:20]};
							3'b010: ysyx_26020046_rv32iAxi.nIdAl.SRaddr = {ysyx_26020046_rv32iAxi.nIfId.code[31:20]};
							default: ysyx_26020046_rv32iAxi.nIdAl.SRaddr = 1'sb0;
						endcase
						(* full_case, parallel_case *)
						case (ysyx_26020046_rv32iAxi.nIfId.code[14-:3])
							3'b000:
								(* full_case, parallel_case *)
								case (ysyx_26020046_rv32iAxi.nIfId.code)
									OP_CSR_MRET__: ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd0;
									OP_CSR_ECALL_: ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd1;
									OP_CSR_EBREAK: ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd3;
									default: ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd3;
								endcase
							3'b001: ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd2;
							3'b010: ysyx_26020046_rv32iAxi.nIdAl.SRop = (ysyx_26020046_rv32iAxi.nIfId.code[19-:5] == {5 {1'sb0}} ? 2'd3 : 2'd2);
							default: ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd3;
						endcase
					end
					else begin
						ysyx_26020046_rv32iAxi.nIdAl.cCsr = 2'd3;
						ysyx_26020046_rv32iAxi.nIdAl.SRaddr = 1'sb0;
						ysyx_26020046_rv32iAxi.nIdAl.SRop = 2'd3;
					end
					ysyx_26020046_rv32iAxi.val.SRaddr = ysyx_26020046_rv32iAxi.nIdAl.SRaddr;
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_U_I: ysyx_26020046_rv32iAxi.val.cR1 = 1'sb0;
						OP_U_P: ysyx_26020046_rv32iAxi.val.cR1 = 1'sb0;
						OP_J__: ysyx_26020046_rv32iAxi.val.cR1 = 1'sb0;
						default: ysyx_26020046_rv32iAxi.val.cR1 = ysyx_26020046_rv32iAxi.nIfId.code[19-:5];
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_S__: ysyx_26020046_rv32iAxi.val.cR2 = ysyx_26020046_rv32iAxi.nIfId.code[24-:5];
						OP_R__: ysyx_26020046_rv32iAxi.val.cR2 = ysyx_26020046_rv32iAxi.nIfId.code[24-:5];
						OP_B__: ysyx_26020046_rv32iAxi.val.cR2 = ysyx_26020046_rv32iAxi.nIfId.code[24-:5];
						default: ysyx_26020046_rv32iAxi.val.cR2 = 1'sb0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIfId.code[6-:7])
						OP_B__: ysyx_26020046_rv32iAxi.nIdAl.cRd = 1'sb0;
						OP_S__: ysyx_26020046_rv32iAxi.nIdAl.cRd = 1'sb0;
						OP_CSR: ysyx_26020046_rv32iAxi.nIdAl.cRd = (ysyx_26020046_rv32iAxi.nIfId.code[14-:3] == 3'b000 ? {5 {1'sb0}} : ysyx_26020046_rv32iAxi.nIfId.code[11-:5]);
						default: ysyx_26020046_rv32iAxi.nIdAl.cRd = ysyx_26020046_rv32iAxi.nIfId.code[11-:5];
					endcase
				end
			end
			initial _sv2v_0 = 0;
		end
		if (1) begin : ALU
			reg _sv2v_0;
			reg enBfun;
			localparam DATA_WIDTH = 32;
			reg [31:0] result;
			reg [31:0] in1;
			reg [31:0] in2;
			always @(*) begin
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.nAlLs.oR2 = ysyx_26020046_rv32iAxi.nIdAl.oR2;
				ysyx_26020046_rv32iAxi.nAlLs.enS = ysyx_26020046_rv32iAxi.nIdAl.enS;
				ysyx_26020046_rv32iAxi.nAlLs.enL = ysyx_26020046_rv32iAxi.nIdAl.enL;
				ysyx_26020046_rv32iAxi.nAlLs.LSop = ysyx_26020046_rv32iAxi.nIdAl.LSop;
				ysyx_26020046_rv32iAxi.nAlLs.cRd = ysyx_26020046_rv32iAxi.nIdAl.cRd;
				ysyx_26020046_rv32iAxi.nAlLs.SRaddr = ysyx_26020046_rv32iAxi.nIdAl.SRaddr;
				ysyx_26020046_rv32iAxi.nAlLs.SRop = ysyx_26020046_rv32iAxi.nIdAl.SRop;
				ysyx_26020046_rv32iAxi.nAlLs.valid = ysyx_26020046_rv32iAxi.nIdAl.valid;
				ysyx_26020046_rv32iAxi.nIdAl.ready = ysyx_26020046_rv32iAxi.nAlLs.ready;
			end
			always @(*) begin
				if (_sv2v_0)
					;
				if (ysyx_26020046_rv32iAxi.nIdAl.valid) begin
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIdAl.in1)
						1'd0: in1 = ysyx_26020046_rv32iAxi.nIdAl.oR1;
						1'd1: in1 = ysyx_26020046_rv32iAxi.nIdAl.pc;
						default: in1 = 1'sb0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIdAl.in2)
						1'd0: in2 = ysyx_26020046_rv32iAxi.nIdAl.oR2;
						1'd1: in2 = ysyx_26020046_rv32iAxi.nIdAl.imm;
						default: in2 = 1'sb0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIdAl.cal)
						4'd0: result = in1 + in2;
						4'd1: result = in1 << in2[4:0];
						4'd2: result = ($signed(in1) < $signed(in2) ? 1 : 0);
						4'd3: result = ($unsigned(in1) < $unsigned(in2) ? 1 : 0);
						4'd4: result = in1 ^ in2;
						4'd5: result = $unsigned(in1) >> in2[4:0];
						4'd6: result = in1 | in2;
						4'd7: result = in1 & in2;
						4'd8: result = in1 - in2;
						4'd9: result = $signed(in1) >>> in2[4:0];
						4'd10: result = 1'sb0;
						default: result = 1'sb0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIdAl.cIrd)
						3'd1: ysyx_26020046_rv32iAxi.nAlLs.res = result;
						3'd2: ysyx_26020046_rv32iAxi.nAlLs.res = ysyx_26020046_rv32iAxi.nIdAl.imm;
						3'd4: ysyx_26020046_rv32iAxi.nAlLs.res = ysyx_26020046_rv32iAxi.nIdAl.oCsr;
						3'd3: ysyx_26020046_rv32iAxi.nAlLs.res = ysyx_26020046_rv32iAxi.nIdAl.pc + 4;
						3'd0: ysyx_26020046_rv32iAxi.nAlLs.res = 1'sb0;
						default: begin
							ysyx_26020046_rv32iAxi.nAlLs.res = 1'sb0;
							$display("Error [%0t] in.sv:572:31 - ysyx_26020046_rv32iALU.<unnamed_block>.<unnamed_block>.<unnamed_block>\n msg: ", $time, "unknown cho==0x%x", ysyx_26020046_rv32iAxi.nIdAl.cIrd);
							$stop;
						end
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIdAl.cCsr)
						2'd0: ysyx_26020046_rv32iAxi.nAlLs.iCsr = ysyx_26020046_rv32iAxi.nIdAl.oR1;
						2'd1: ysyx_26020046_rv32iAxi.nAlLs.iCsr = ysyx_26020046_rv32iAxi.nIdAl.oR1 | ysyx_26020046_rv32iAxi.nIdAl.oCsr;
						2'd2: ysyx_26020046_rv32iAxi.nAlLs.iCsr = ysyx_26020046_rv32iAxi.nIdAl.pc;
						2'd3: ysyx_26020046_rv32iAxi.nAlLs.iCsr = 1'sb0;
						default: begin
							ysyx_26020046_rv32iAxi.nAlLs.iCsr = 1'sb0;
							$display("Error [%0t] in.sv:579:32 - ysyx_26020046_rv32iALU.<unnamed_block>.<unnamed_block>.<unnamed_block>\n msg: ", $time, "unknown csr==0x%x", ysyx_26020046_rv32iAxi.nIdAl.cCsr);
							$stop;
						end
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIdAl.bfu)
						3'd0: enBfun = ysyx_26020046_rv32iAxi.nIdAl.oR1 == ysyx_26020046_rv32iAxi.nIdAl.oR2;
						3'd1: enBfun = ysyx_26020046_rv32iAxi.nIdAl.oR1 != ysyx_26020046_rv32iAxi.nIdAl.oR2;
						3'b100: enBfun = $signed(ysyx_26020046_rv32iAxi.nIdAl.oR1) < $signed(ysyx_26020046_rv32iAxi.nIdAl.oR2);
						3'd5: enBfun = $signed(ysyx_26020046_rv32iAxi.nIdAl.oR1) >= $signed(ysyx_26020046_rv32iAxi.nIdAl.oR2);
						3'b110: enBfun = $unsigned(ysyx_26020046_rv32iAxi.nIdAl.oR1) < $unsigned(ysyx_26020046_rv32iAxi.nIdAl.oR2);
						3'd7: enBfun = $unsigned(ysyx_26020046_rv32iAxi.nIdAl.oR1) >= $unsigned(ysyx_26020046_rv32iAxi.nIdAl.oR2);
						3'd2: enBfun = 1'sb0;
						default: enBfun = 1'sb0;
					endcase
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nIdAl.adr)
						3'd0: ysyx_26020046_rv32iAxi.nAlLs.addr = ysyx_26020046_rv32iAxi.nIdAl.oR1 + ysyx_26020046_rv32iAxi.nIdAl.imm;
						3'd1: ysyx_26020046_rv32iAxi.nAlLs.addr = ysyx_26020046_rv32iAxi.nIdAl.pc + ysyx_26020046_rv32iAxi.nIdAl.imm;
						3'd2: ysyx_26020046_rv32iAxi.nAlLs.addr = ysyx_26020046_rv32iAxi.nIdAl.oCsr;
						3'd3: ysyx_26020046_rv32iAxi.nAlLs.addr = ysyx_26020046_rv32iAxi.nIdAl.oCsr;
						3'd4: ysyx_26020046_rv32iAxi.nAlLs.addr = 1'sb0;
						default: ysyx_26020046_rv32iAxi.nAlLs.addr = 1'sb0;
					endcase
					ysyx_26020046_rv32iAxi.nIdAl.enJfun = ysyx_26020046_rv32iAxi.nIdAl.enJcod | enBfun;
					ysyx_26020046_rv32iAxi.nIdAl.addr = ysyx_26020046_rv32iAxi.nAlLs.addr;
				end
			end
			initial _sv2v_0 = 0;
		end
		if (1) begin : LSU
			reg _sv2v_0;
			wire clk;
			wire reset;
			reg [3:0] mask;
			localparam DATA_WIDTH = 32;
			reg [31:0] iRAM;
			reg [31:0] data;
			reg hasAddr;
			reg hasData;
			reg [1:0] Rs;
			reg [1:0] nRs;
			reg [1:0] Ws;
			reg [1:0] nWs;
			reg Rfinish;
			reg Wfinish;
			always @(*) begin
				if (_sv2v_0)
					;
				case (Rs)
					2'd2: nRs = (ysyx_26020046_rv32iAxi.nAlLs.enL & ~Rfinish ? 2'd1 : 2'd2);
					2'd1: nRs = (ysyx_26020046_rv32iAxi.sbLs.arready ? 2'd0 : 2'd1);
					2'd0: nRs = (ysyx_26020046_rv32iAxi.sbLs.rvalid ? 2'd2 : 2'd0);
					default: nRs = 2'd2;
				endcase
			end
			always @(posedge clk)
				if (reset)
					Rs <= 2'd2;
				else
					Rs <= nRs;
			localparam false = 0;
			localparam true = 1;
			always @(posedge clk) begin
				iRAM <= ((Rs == 2'd0) & (nRs == 2'd2) ? ysyx_26020046_rv32iAxi.sbLs.rdata : {32 {1'sb0}});
				if ((Rs == 2'd0) & (nRs == 2'd2))
					Rfinish <= true;
				if (ysyx_26020046_rv32iAxi.nAlLs.ready & ysyx_26020046_rv32iAxi.nLsWb.valid)
					Rfinish <= false;
			end
			always @(*) begin
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.sbLs.araddr = ysyx_26020046_rv32iAxi.nAlLs.addr;
				ysyx_26020046_rv32iAxi.sbLs.arvalid = Rs == 2'd1;
				ysyx_26020046_rv32iAxi.sbLs.rready = Rs == 2'd0;
				case (ysyx_26020046_rv32iAxi.sbLs.rresp)
					2'd0:
						;
					default:
						;
				endcase
			end
			always @(*) begin
				if (_sv2v_0)
					;
				case (Ws)
					2'd2: nWs = (ysyx_26020046_rv32iAxi.nAlLs.enS & ~Wfinish ? 2'd1 : 2'd2);
					2'd1: nWs = (hasAddr & hasData ? 2'd0 : 2'd1);
					2'd0: nWs = (ysyx_26020046_rv32iAxi.sbLs.bvalid ? 2'd2 : 2'd0);
					default: nWs = 2'd2;
				endcase
			end
			always @(posedge clk)
				if (reset & ~ysyx_26020046_rv32iAxi.nAlLs.valid)
					Ws <= 2'd2;
				else
					Ws <= nWs;
			always @(posedge clk) begin
				if ((Ws == 2'd1) & ysyx_26020046_rv32iAxi.sbLs.awready)
					hasAddr <= true;
				if ((Ws == 2'd0) | (Ws == 2'd2))
					hasAddr <= false;
				if ((Ws == 2'd1) & ysyx_26020046_rv32iAxi.sbLs.wready)
					hasData <= true;
				if ((Ws == 2'd0) | (Ws == 2'd2))
					hasData <= false;
				if ((Ws == 2'd0) & (nWs == 2'd2))
					Wfinish <= true;
				if (ysyx_26020046_rv32iAxi.nAlLs.ready & ysyx_26020046_rv32iAxi.nLsWb.valid)
					Wfinish <= false;
			end
			always @(*) begin
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.sbLs.awaddr = ysyx_26020046_rv32iAxi.nAlLs.addr;
				ysyx_26020046_rv32iAxi.sbLs.awvalid = Ws == 2'd1;
				ysyx_26020046_rv32iAxi.sbLs.wdata = ysyx_26020046_rv32iAxi.nAlLs.oR2;
				ysyx_26020046_rv32iAxi.sbLs.wstrb = mask;
				ysyx_26020046_rv32iAxi.sbLs.wvalid = Ws == 2'd1;
				ysyx_26020046_rv32iAxi.sbLs.bready = Ws == 2'd0;
				case (ysyx_26020046_rv32iAxi.sbLs.bresp)
					2'd0:
						;
					default:
						;
				endcase
			end
			always @(*) begin
				if (_sv2v_0)
					;
				ysyx_26020046_rv32iAxi.nLsWb.iRd = (ysyx_26020046_rv32iAxi.nAlLs.enS | ysyx_26020046_rv32iAxi.nAlLs.enL ? data : ysyx_26020046_rv32iAxi.nAlLs.res);
				ysyx_26020046_rv32iAxi.nLsWb.cRd = ysyx_26020046_rv32iAxi.nAlLs.cRd;
				ysyx_26020046_rv32iAxi.nLsWb.iCsr = ysyx_26020046_rv32iAxi.nAlLs.iCsr;
				ysyx_26020046_rv32iAxi.nLsWb.SRaddr = ysyx_26020046_rv32iAxi.nAlLs.SRaddr;
				ysyx_26020046_rv32iAxi.nLsWb.SRop = ysyx_26020046_rv32iAxi.nAlLs.SRop;
				ysyx_26020046_rv32iAxi.nLsWb.valid = (~(ysyx_26020046_rv32iAxi.nAlLs.enL ^ Rfinish) & ~(ysyx_26020046_rv32iAxi.nAlLs.enS ^ Wfinish)) & ysyx_26020046_rv32iAxi.nAlLs.valid;
				ysyx_26020046_rv32iAxi.nAlLs.ready = (~(ysyx_26020046_rv32iAxi.nAlLs.enL ^ Rfinish) & ~(ysyx_26020046_rv32iAxi.nAlLs.enS ^ Wfinish)) & ysyx_26020046_rv32iAxi.nLsWb.ready;
			end
			always @(*) begin
				if (_sv2v_0)
					;
				if (ysyx_26020046_rv32iAxi.nAlLs.enS & ysyx_26020046_rv32iAxi.nAlLs.valid)
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nAlLs.LSop)
						3'd0: mask = 4'b0001;
						3'd1: mask = 4'b0011;
						3'd2: mask = 4'b1111;
						3'd3: mask = 4'b0000;
						default: mask = 4'b0000;
					endcase
				else
					mask = 4'b0000;
				if (ysyx_26020046_rv32iAxi.nAlLs.enL & ysyx_26020046_rv32iAxi.nAlLs.valid)
					(* full_case, parallel_case *)
					case (ysyx_26020046_rv32iAxi.nAlLs.LSop)
						3'd0: data = {{24 {iRAM[7]}}, iRAM[7:0]};
						3'd1: data = {{16 {iRAM[15]}}, iRAM[15:0]};
						3'd2: data = iRAM;
						3'd4: data = {{24 {1'b0}}, iRAM[7:0]};
						3'd5: data = {{16 {1'b0}}, iRAM[15:0]};
						default: data = 0;
					endcase
				else
					data = 1'sb0;
			end
			initial _sv2v_0 = 0;
		end
	endgenerate
	assign LSU.clk = clk;
	assign LSU.reset = reset;
	generate
		if (1) begin : GPR
			wire clk;
			wire reset;
			localparam REG_NUMBER = 5;
			localparam DATA_WIDTH = 32;
			reg [31:0] gpr [31:1];
			assign ysyx_26020046_rv32iAxi.nLsWb.readyRg = 1;
			always @(posedge clk) begin : reg_write
				if (reset) begin : sv2v_autoblock_1
					reg signed [31:0] i;
					for (i = 1; i < 32; i = i + 1)
						gpr[i] <= 1'sb0;
				end
				else if (ysyx_26020046_rv32iAxi.nLsWb.valid) begin
					if (ysyx_26020046_rv32iAxi.nLsWb.cRd != 0)
						gpr[ysyx_26020046_rv32iAxi.nLsWb.cRd] <= ysyx_26020046_rv32iAxi.nLsWb.iRd;
				end
			end
			assign ysyx_26020046_rv32iAxi.val.oR1 = (ysyx_26020046_rv32iAxi.val.cR1 == 0 ? {32 {1'sb0}} : gpr[ysyx_26020046_rv32iAxi.val.cR1]);
			assign ysyx_26020046_rv32iAxi.val.oR2 = (ysyx_26020046_rv32iAxi.val.cR2 == 0 ? {32 {1'sb0}} : gpr[ysyx_26020046_rv32iAxi.val.cR2]);
		end
	endgenerate
	assign GPR.clk = clk;
	assign GPR.reset = reset;
	generate
		if (1) begin : CSR
			reg _sv2v_0;
			wire clk;
			wire reset;
			localparam DATA_WIDTH = 32;
			reg [31:0] mepc;
			reg [31:0] mstatus;
			reg [31:0] mtvec;
			reg [31:0] mcause;
			reg [31:0] mcycle;
			reg [31:0] mcycleh;
			reg [31:0] marchid;
			reg [31:0] mvendorid;
			assign ysyx_26020046_rv32iAxi.nLsWb.readySr = 1;
			localparam CSR_ADDR_MARCHID = 12'hf12;
			localparam CSR_ADDR_MCAUSE = 12'h342;
			localparam CSR_ADDR_MCYCLE = 12'hb00;
			localparam CSR_ADDR_MCYCLEH = 12'hb80;
			localparam CSR_ADDR_MEPC = 12'h341;
			localparam CSR_ADDR_MSTAUS = 12'h300;
			localparam CSR_ADDR_MTVEC = 12'h305;
			localparam CSR_ADDR_MVENDORID = 12'hf11;
			localparam MSTATUS_RESET = 32'h00001800;
			localparam PC_RESET = 32'h80000000;
			always @(posedge clk) begin : csr_write
				if (reset) begin
					mepc <= PC_RESET;
					mstatus <= MSTATUS_RESET;
					mtvec <= PC_RESET;
					mcause <= 1'sb0;
					mcycle <= 1'sb0;
					mcycleh <= 1'sb0;
					marchid <= 32'h018d08ce;
					mvendorid <= 32'h79737978;
				end
				else begin
					{mcycleh, mcycle} <= {mcycleh, mcycle} + 1;
					if (ysyx_26020046_rv32iAxi.nLsWb.valid)
						(* full_case, parallel_case *)
						case (ysyx_26020046_rv32iAxi.nLsWb.SRop)
							2'd1: begin
								mepc <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
								mcause <= 11;
							end
							2'd0: begin
								mstatus <= MSTATUS_RESET;
								mcause <= 1'sb0;
							end
							2'd2:
								(* full_case, parallel_case *)
								case (ysyx_26020046_rv32iAxi.nLsWb.SRaddr)
									CSR_ADDR_MEPC: mepc <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									CSR_ADDR_MSTAUS: mstatus <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									CSR_ADDR_MTVEC: mtvec <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									CSR_ADDR_MCAUSE: mcause <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									CSR_ADDR_MCYCLE: mcycle <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									CSR_ADDR_MCYCLEH: mcycleh <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									CSR_ADDR_MARCHID: marchid <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									CSR_ADDR_MVENDORID: mvendorid <= ysyx_26020046_rv32iAxi.nLsWb.iCsr;
									default:
										;
								endcase
							2'd3:
								;
							default:
								;
						endcase
				end
			end
			always @(*) begin : choose_csr
				if (_sv2v_0)
					;
				(* full_case, parallel_case *)
				case (ysyx_26020046_rv32iAxi.val.SRaddr)
					CSR_ADDR_MEPC: ysyx_26020046_rv32iAxi.val.oCsr = mepc;
					CSR_ADDR_MSTAUS: ysyx_26020046_rv32iAxi.val.oCsr = mstatus;
					CSR_ADDR_MTVEC: ysyx_26020046_rv32iAxi.val.oCsr = mtvec;
					CSR_ADDR_MCAUSE: ysyx_26020046_rv32iAxi.val.oCsr = mcause;
					CSR_ADDR_MCYCLE: ysyx_26020046_rv32iAxi.val.oCsr = mcycle;
					CSR_ADDR_MCYCLEH: ysyx_26020046_rv32iAxi.val.oCsr = mcycleh;
					CSR_ADDR_MARCHID: ysyx_26020046_rv32iAxi.val.oCsr = marchid;
					CSR_ADDR_MVENDORID: ysyx_26020046_rv32iAxi.val.oCsr = mvendorid;
					default: ysyx_26020046_rv32iAxi.val.oCsr = 1'sb0;
				endcase
			end
			initial _sv2v_0 = 0;
		end
	endgenerate
	assign CSR.clk = clk;
	assign CSR.reset = reset;
	assign axi4.arready = arready;
	assign axi4.rdata = rdata;
	assign axi4.rresp = rresp;
	assign axi4.rvalid = rvalid;
	assign axi4.awready = awready;
	assign axi4.wready = wready;
	assign axi4.bresp = bresp;
	assign axi4.bvalid = bvalid;
	assign araddr = axi4.araddr;
	assign arvalid = axi4.arvalid;
	assign rready = axi4.rready;
	assign awaddr = axi4.awaddr;
	assign awvalid = axi4.awvalid;
	assign wdata = axi4.wdata;
	assign wstrb = axi4.wstrb;
	assign wvalid = axi4.wvalid;
endmodule