#include "Vex2.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vex2* top = new Vex2{contextp};
	
	nvboard_bind_pin(&top->ld,4,LD3,LD2,LD1,LD0);
	nvboard_bind_pin(&top->sw,8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0);
	nvboard_bind_pin(&top->en,1,SW8);
	// nvboard_bind_pin(&top->seg,8,DEC0P,SEG0G,SEG0F,SEG0E,SEG0D,SEG0C,SEG0B,SEG0A);
	nvboard_bind_pin(&top->seg,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
    
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