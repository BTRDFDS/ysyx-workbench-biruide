#include "Vwater.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vwater* top = new Vwater{contextp};
	
	nvboard_bind_pin(&top->out,10,LD0,LD1,LD2,LD3,LD4,LD5,LD6,LD7,LD8,LD9);
	nvboard_bind_pin(&top->reset,1,BTNC);
	nvboard_init();
	while (!contextp->gotFinish()) {
        // sleep(1);
  		nvboard_update();
        
		top->clk = 1;top->eval();
        // sleep(1);
		top->clk = 0;top->eval();
    	//sleep(1);

	}
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}