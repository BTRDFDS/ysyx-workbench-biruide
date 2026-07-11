#include "Vex7Nout.h"
#include "verilated.h"
#include <nvboard.h>
#include <stdio.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vex7Nout* top = new Vex7Nout{contextp};
    nvboard_bind_pin(&top->ps2_clk,1,PS2_CLK);
    nvboard_bind_pin(&top->ps2_data,1,PS2_DAT);
	nvboard_init();
	while (!contextp->gotFinish()) {
  		nvboard_update();top->clk=1;top->eval();
  		nvboard_update();top->clk=0;top->eval();
		if(top->ascll!=0){printf("%02X\n",top->ascll);}
		
	}
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}