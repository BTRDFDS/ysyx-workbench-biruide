#include "Vex3.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vex3* top = new Vex3{contextp};
	int a=0XFF;
	nvboard_bind_pin(&top->code,3,SW15,SW14,SW13);
	nvboard_bind_pin(&top->code,3,LD15,LD14,LD13);
	nvboard_bind_pin(&top->in1,4,SW11,SW10,SW9,SW8);
	nvboard_bind_pin(&top->in1,4,LD11,LD10,LD9,LD8);
	nvboard_bind_pin(&top->in2,4,SW7,SW6,SW5,SW4);
	nvboard_bind_pin(&top->in2,4,LD7,LD6,LD5,LD4);
	nvboard_bind_pin(&top->out,4,LD3,LD2,LD1,LD0);
	nvboard_bind_pin(&top->cin,1,DEC1P);
	nvboard_bind_pin((&top->cin),1,LD12);
	nvboard_bind_pin(&top->seg1,8,SEG6A,SEG6B,SEG6C,SEG6D,SEG6E,SEG6F,SEG6G,SEG7G);
	nvboard_bind_pin(&top->seg2,8,SEG3A,SEG3B,SEG0C,SEG3D,SEG3E,SEG3F,SEG3G,SEG4G);
	nvboard_bind_pin(&top->seg3,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,SEG1G);
    nvboard_bind_pin(&a,6,SEG7A,SEG7B,SEG7C,SEG7D,SEG7E,SEG7F);
    nvboard_bind_pin(&a,6,SEG4A,SEG4B,SEG4C,SEG4D,SEG4E,SEG4F);
    nvboard_bind_pin(&a,6,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F);
    nvboard_bind_pin(&a,7,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G);
    nvboard_bind_pin(&a,7,SEG5A,SEG5B,SEG5C,SEG5D,SEG5E,SEG5F,SEG5G);
    nvboard_bind_pin(&a,7,DEC0P,DEC2P,DEC3P,DEC4P,DEC5P,DEC6P,DEC7P);

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