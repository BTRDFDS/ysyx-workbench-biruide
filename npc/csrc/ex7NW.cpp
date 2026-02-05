#include "Vex7NW.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vex7NW* top = new Vex7NW{contextp};
	int a=0XFF;
    nvboard_bind_pin(&top->ps2_clk,1,PS2_CLK);
    nvboard_bind_pin(&top->ps2_data,1,PS2_DAT);
	nvboard_bind_pin(&top->clrn,1,BTNC);
	nvboard_bind_pin(&top->clrn,1,LD8);
    // nvboard_bind_pin(&top->data,8,LD0,LD1,LD2,LD3,LD4,LD5,LD6,LD7);
    nvboard_bind_pin(&top->data,8,LD7,LD6,LD5,LD4,LD3,LD2,LD1,LD0);
    nvboard_bind_pin(&top->segD0,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
    nvboard_bind_pin(&top->segD1,8,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F,SEG1G,DEC1P);
    nvboard_bind_pin(&top->segA0,8,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G,DEC2P);
    nvboard_bind_pin(&top->segA1,8,SEG3A,SEG3B,SEG3C,SEG3D,SEG3E,SEG3F,SEG3G,DEC3P);
    nvboard_bind_pin(&a,8,SEG4A,SEG4B,SEG4C,SEG4D,SEG4E,SEG4F,SEG4G,DEC4P);
    nvboard_bind_pin(&a,8,SEG5A,SEG5B,SEG5C,SEG5D,SEG5E,SEG5F,SEG5G,DEC5P);
    nvboard_bind_pin(&top->segT0,8,SEG6A,SEG6B,SEG6C,SEG6D,SEG6E,SEG6F,SEG6G,DEC6P);
    nvboard_bind_pin(&top->segT1,8,SEG7A,SEG7B,SEG7C,SEG7D,SEG7E,SEG7F,SEG7G,DEC7P);

	nvboard_init();
	top->nextdata_n=1;
	while (!contextp->gotFinish()) {
  		nvboard_update();
		top->clk=1;
		if(top->overflow==1){
			top->nextdata_n=0;
		}else if(top->ready==1){
			top->nextdata_n=0;
		}else{
			top->nextdata_n=1;
		}
        top->eval();

  		nvboard_update();
		top->clk=0;
		if(top->overflow==1){
			top->nextdata_n=0;
		}else if(top->ready==1){
			top->nextdata_n=0;
		}else{
			top->nextdata_n=1;
		}
        top->eval();
	}
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}