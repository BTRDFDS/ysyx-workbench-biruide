module netlist;
logic clock,reset;
always #5 clock = ~clock;
ysyx_26020046_netlist cpu(clock, reset);
initial begin
	// $dumpfile("wave/netlist.fst");
	// $dumpvars(0,cpu);
	#0  clock = 0;
	#0  reset = 1;
	#10 reset = 0;
	// #10000 $finish();
end
endmodule