module iverilog;
logic clock,reset;
always #5 clock = ~clock;
driveTop cpu(clock, reset);
initial begin
	// $dumpfile("wave/iverilog.fst");
	// $dumpvars(0,cpu);
	#0  clock = 0;
	#0  reset = 1;
	#10 reset = 0;
	// #100 $display("100 pc:%x",{cpu.cpu.ifu.pipePc,2'b0});
	// #200 $display("200 pc:%x",{cpu.cpu.ifu.pipePc,2'b0});
	// #300 $display("300 pc:%x",{cpu.cpu.ifu.pipePc,2'b0});
	// #400 $display("400 pc:%x",{cpu.cpu.ifu.pipePc,2'b0});
	// #500 $display("500 pc:%x",{cpu.cpu.ifu.pipePc,2'b0});
	// #300 $finish();
end
endmodule