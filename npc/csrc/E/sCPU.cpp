#include "VsCPU.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	VsCPU* top = new VsCPU{contextp};
	int a=0XFF;
    nvboard_bind_pin(&top->seg0,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
    nvboard_bind_pin(&top->seg1,8,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F,SEG1G,DEC1P);
    nvboard_bind_pin(&a,8,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G,DEC2P);

	nvboard_init();
    int i=0;
	while (!contextp->gotFinish()) {
        top->clk=1;top->eval();
        top->clk=0;top->eval();
  		nvboard_update();
        // if(i>100){break;}else{i++;}
	}
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}