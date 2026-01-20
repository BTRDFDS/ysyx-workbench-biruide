#include "Vex8.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vex8* top = new Vex8{contextp};
	int a=0XFF;
    nvboard_bind_pin(&top->reset,1,BTNC);
    nvboard_bind_pin(&top->vgaHsync,1,VGA_HSYNC);
    nvboard_bind_pin(&top->vgaVsync,1,VGA_VSYNC);
    nvboard_bind_pin(&top->vgaBlank,1,VGA_BLANK_N);
    nvboard_bind_pin(&top->vgaR,8,VGA_R7,VGA_R6,VGA_R5,VGA_R4,VGA_R3,VGA_R2,VGA_R1,VGA_R0);
    nvboard_bind_pin(&top->vgaG,8,VGA_G7,VGA_G6,VGA_G5,VGA_G4,VGA_G3,VGA_G2,VGA_G1,VGA_G0);
    nvboard_bind_pin(&top->vgaB,8,VGA_B7,VGA_B6,VGA_B5,VGA_B4,VGA_B3,VGA_B2,VGA_B1,VGA_B0);


    int h,v,i,max;
    max = 800*35;
	nvboard_init();
	while (!contextp->gotFinish()) {
        // v=top->vAddr;
        // h=top->hAddr;
        // top->vgaLocate=v*640+h;
        top->clk=1;top->eval();

        // v=top->vAddr;
        // h=top->hAddr;
        // top->vgaLocate=v*640+h;
        top->clk=0;top->eval();
        // usleep(1);
        
        // if(i>max){
        //     getchar();
        //     max+=800;
        // }else i++;
  		nvboard_update();
        
	}
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}