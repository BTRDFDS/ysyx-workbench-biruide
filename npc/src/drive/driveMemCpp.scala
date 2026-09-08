import chisel3._
import chisel3.util._
import chisel3.util.experimental._
import WidthConsts._
class driveMemCpp extends ExtModule{
    val read = IO(new Bundle{
		val valid	= Input(Bool())
		val addr	= Input(UInt(32.W))
		val data	= Output(UInt(32.W))
	})
	val write  = IO(new Bundle{
		val valid	= Input(Bool())
		val addr	= Input(UInt(32.W))
		val strb	= Input(UInt(4.W))
		val data	= Input(UInt(32.W))
	})
	setInline("driveMemCpp.sv",
	"""
	module driveMemCpp(
		input logic read_valid,
		input logic[31:0] read_addr,
		output logic[31:0] read_data,
		input logic write_valid,
		input logic[31:0] write_addr,
		input logic[3:0] write_strb,
		input logic[31:0] write_data
	);
	import "DPI-C" function int psram_read(input int addr);
	import "DPI-C" function void psram_write(input int addr, input int data);
	assign read_data = read_valid?psram_read({5'd0,read_addr[26:2],2'b00}):0;
	always_ff@(posedge write_valid) if(write_addr[31:28]==4'b1000)begin
		if(write_strb[0])psram_write({5'b0,write_addr[26:2],2'b00},{24'd0,write_data[ 7: 0]});
		if(write_strb[1])psram_write({5'b0,write_addr[26:2],2'b01},{24'd0,write_data[15: 8]});
		if(write_strb[2])psram_write({5'b0,write_addr[26:2],2'b10},{24'd0,write_data[23:16]});
		if(write_strb[3])psram_write({5'b0,write_addr[26:2],2'b11},{24'd0,write_data[31:24]});
	end else if(write_addr==32'h10000000)$write("%c",write_data[ 7: 0]);
	endmodule
	"""
	)
}