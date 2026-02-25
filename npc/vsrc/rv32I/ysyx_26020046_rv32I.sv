package rv32iBasis;
	parameter REG_NUMBER = 5;
	parameter DATA_WIDTH = 32;
endpackage

module ysyx_260020046_rv32I(clk,reset,code,pc);
    import rv32iBasis::*;
    input logic clk,reset;
    input logic [DATA_WIDTH-1,0]code;
    output logic [DATA_WIDTH-1,0]pc;

endmodule

module ysyx_260020046_rv32iIDC();
    input logic code;
endmodule
module ysyx_260020046_rv32iALU();
	import "DPI-C" function void ebreak(input bit eb);
endmodule
module ysyx_260020046_rv32iLSU();
    import "DPI-C" function int pmem_read(input int addr);
    import "DPI-C" function void pmem_write(input int addr, input int data, input byte mask);

endmodule
module ysyx_260020046_rv32iGPR();
	export "DPI-C" function getReg;
endmodule