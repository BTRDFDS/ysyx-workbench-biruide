// define this macro to enable fast behavior simulation
// for flash by skipping SPI transfers
//`define FAST_FLASH

module spi_top_apb #(
	parameter flash_addr_start = 32'h30000000,
	parameter flash_addr_end   = 32'h3fffffff,
	parameter spi_ss_num       = 8
) (
	input  logic        clock,
	input  logic        reset,
	input  logic [31:0] in_paddr,
	input  logic        in_psel,		//wb_stb_i
	input  logic        in_penable,	//wb_cyc_i
	input  logic [2:0]  in_pprot,		//NULL
	input  logic        in_pwrite,	//wb_we_i
	input  logic [31:0] in_pwdata,
	input  logic [3:0]  in_pstrb,		//wb_sel_i
	output logic        in_pready,	//wb_ack_o
	output logic [31:0] in_prdata,
	output logic        in_pslverr,	//wb_err_o

	output logic                  spi_sck,
	output logic [spi_ss_num-1:0] spi_ss,
	output logic                  spi_mosi,
	input  logic                  spi_miso,
	output logic                  spi_irq_out
);

`ifdef FAST_FLASH

wire [31:0] data;
parameter invalid_cmd = 8'h0;
flash_cmd flash_cmd_i(
	.clock(clock),
	.valid(in_psel && !in_penable),
	.cmd(in_pwrite ? invalid_cmd : 8'h03),
	.addr({8'b0, in_paddr[23:2], 2'b0}),
	.data(data)
);
assign spi_sck    = 1'b0;
assign spi_ss     = 8'b0;
assign spi_mosi   = 1'b1;
assign spi_irq_out= 1'b0;
assign in_pslverr = 1'b0;
assign in_pready  = in_penable && in_psel && !in_pwrite;
assign in_prdata  = data[31:0];

`else
	
typedef enum logic [3:0] {Idle,Wctrl,Wdiv,Wss,Waddr,Wenab,Get,Check,Back}Enum;
Enum state;
logic finish;assign finish = dat_o[8];
logic [4:0] adr_i;
logic [31:0] dat_i;
logic [31:0] dat_o;
logic valid;assign valid = in_penable&&in_psel&& !in_pwrite;
logic isFlash;assign isFlash = (in_paddr[31:24]==8'h30)&&valid;
always_ff @(posedge clock or posedge reset) begin
	if(reset | (~valid)) state <= Idle;
	else case(state)
		Idle	:state<=isFlash?Wctrl:Idle;
		Wctrl	:state<=Wdiv;
		Wdiv	:state<=Wss;
		Wss		:state<=Waddr;
		Waddr	:state<=Wenab;
		Wenab	:state<=Get;
		Get		:state<=Check;
		Check	:state<=finish?Back:Get;
		Back	:state<=Idle;
		default	:state<=Idle;
	endcase
end
always_comb case(state)
	Idle	:adr_i=in_paddr[4:0];
	Wctrl	:adr_i=5'h10;
	Wdiv	:adr_i=5'h14;
	Wss		:adr_i=5'h18;
	Waddr	:adr_i=5'h00;
	Wenab	:adr_i=5'h10;
	Get		:adr_i=5'h10;
	Check	:adr_i=5'h00;
	Back	:adr_i=5'h00;
	default	:adr_i=5'h00;
endcase
logic [31:0] revIn,revOut;
generate
    genvar i;
    for (i=0; i<32; i = i+1) begin
        assign revIn[i] = {8'h03,in_paddr[23:0]}[31-i];
    end
endgenerate
always_comb case(state)
	Idle	:dat_i=in_pwdata;
	Wctrl	:dat_i=32'b101_00_0_01000000;
	Wdiv	:dat_i=32'h0;
	Wss		:dat_i=32'h1;
	Waddr	:dat_i=revIn;
	Wenab	:dat_i=32'b101_00_1_01000000;
	default	:dat_i=32'h0;
endcase
generate
    genvar j;
    for (i=0; i<32; i = i+1) begin
        assign revOut[i] = dat_o[31-i];
    end
endgenerate
always_comb case(state)
	Idle	:in_prdata=dat_o;
	Back	:in_prdata={revOut[7:0],revOut[15:8],revOut[23:16],revOut[31:24]};
	default	:in_prdata=32'h0;
endcase
logic enable,ready;
always_comb begin
	case(state)
		Idle	:enable = isFlash?1'b0:in_penable;
		Wctrl	:enable = 1'b1;
		Wdiv	:enable = 1'b1;
		Wss		:enable = 1'b1;
		Waddr	:enable = 1'b1;
		Wenab	:enable = 1'b1;
		Get		:enable = 1'b1;
		Check	:enable = 1'b1;
		default	:enable = 1'b0;
	endcase
end
always_comb begin
	case(state)
		Idle	:in_pready = isFlash?1'b0:ready;
		Back	:in_pready = 1'b1;
		default	:in_pready = 1'b0;
	endcase
end
logic [3:0] strb;
logic write;
always_comb begin
	case(state)
		Idle	:write=in_pwrite;
		Wctrl	:write=1'b1;
		Wdiv	:write=1'b1;
		Wss		:write=1'b1;
		Waddr	:write=1'b1;
		Wenab	:write=1'b1;
		default	:write=1'b0;
	endcase
	case(state)
		Idle	:strb=in_pstrb;
		Wctrl	:strb=4'b1111;
		Wdiv	:strb=4'b1111;
		Wss		:strb=4'b1111;
		Waddr	:strb=4'b1111;
		Wenab	:strb=4'b1111;
		default	:strb=4'b0;
	endcase
end

spi_top u0_spi_top (
	.wb_clk_i(clock),
	.wb_rst_i(reset),
	.wb_adr_i(adr_i),
	.wb_dat_i(dat_i),
	.wb_dat_o(dat_o),
	.wb_sel_i(strb),
	.wb_we_i (write),
	.wb_stb_i(in_psel),
	.wb_cyc_i(enable),
	.wb_ack_o(ready),
	.wb_err_o(in_pslverr),
	.wb_int_o(spi_irq_out),

	.ss_pad_o(spi_ss),
	.sclk_pad_o(spi_sck),
	.mosi_pad_o(spi_mosi),
	.miso_pad_i(spi_miso)
);

`endif // FAST_FLASH

endmodule
