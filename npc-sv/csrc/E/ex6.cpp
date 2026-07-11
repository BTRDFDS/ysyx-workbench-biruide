#include "Vex6.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vex6* top = new Vex6{contextp};
	int a=0XFF;
    nvboard_bind_pin(&top->clk,1,BTNC);
    nvboard_bind_pin(&top->seg0,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
    nvboard_bind_pin(&top->seg1,8,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F,SEG1G,DEC1P);
    nvboard_bind_pin(&top->out,8,LD7,LD6,LD5,LD4,LD3,LD2,LD1,LD0);
    nvboard_bind_pin(&a,8,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G,DEC2P);

	nvboard_init();
	while (!contextp->gotFinish()) {
  		nvboard_update();
        top->eval();

	}
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}