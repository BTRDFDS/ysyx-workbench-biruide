
module testCase #(ADDR_WIDTH = 4, DATA_WIDTH = 32)(out,addr,in);
	input  logic [ADDR_WIDTH-1:0] addr;
	input  logic [(2**ADDR_WIDTH)*(DATA_WIDTH)-1:0] in;
	output logic [DATA_WIDTH-1:0] out;
	always_comb begin
		unique case(addr)
			4'h0: out = in[ 31:  0];
			4'h1: out = in[ 63: 32];
			4'h2: out = in[ 95: 64];
			4'h3: out = in[127: 96];
			4'h4: out = in[159:128];
			4'h5: out = in[191:160];
			4'h6: out = in[223:192];
			4'h7: out = in[255:224];
			4'h8: out = in[287:256];
			4'h9: out = in[319:288];
			4'ha: out = in[351:320];
			// 4'hb: out = in[383:352];
			// 4'hc: out = in[415:384];
			// 4'hd: out = in[447:416];
			// 4'he: out = in[479:448];
			// 4'hf: out = in[511:480];
			default:out='0;
		endcase
	end
endmodule