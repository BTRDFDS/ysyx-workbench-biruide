#include "Vex7O.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vex7O* top = new Vex7O{contextp};
	int a=0XFF;
    nvboard_bind_pin(&top->clk,1,PS2_CLK);
    nvboard_bind_pin(&top->ps2_data,1,PS2_DAT);
    nvboard_bind_pin(&top->key0,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
    nvboard_bind_pin(&top->key1,8,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F,SEG1G,DEC1P);
    nvboard_bind_pin(&top->ascll0,8,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G,DEC2P);
    nvboard_bind_pin(&top->ascll1,8,SEG3A,SEG3B,SEG3C,SEG3D,SEG3E,SEG3F,SEG3G,DEC3P);
    nvboard_bind_pin(&top->number0,8,SEG4A,SEG4B,SEG4C,SEG4D,SEG4E,SEG4F,SEG4G,DEC4P);
    nvboard_bind_pin(&top->number1,8,SEG5A,SEG5B,SEG5C,SEG5D,SEG5E,SEG5F,SEG5G,DEC5P);
    nvboard_bind_pin(&top->number2,8,SEG6A,SEG6B,SEG6C,SEG6D,SEG6E,SEG6F,SEG6G,DEC6P);
    nvboard_bind_pin(&top->number3,8,SEG7A,SEG7B,SEG7C,SEG7D,SEG7E,SEG7F,SEG7G,DEC7P);

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