#include "VsCpu.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <nvboard.h>
#include <fstream>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	VsCpu* top = new VsCpu{contextp};
	// int a=0XFF;
	int a=0b00011111;
    nvboard_bind_pin(&top->io_seg0,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
    nvboard_bind_pin(&top->io_seg1,8,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F,SEG1G,DEC1P);
    nvboard_bind_pin(&a,8,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G,DEC2P);
	nvboard_bind_pin(&top->reset,1,BTNC);

	nvboard_init();
    int i=0;
	uint32_t m[10000];
	std::ifstream in("hex/sCPU.hex");
	for (int i = 0; i < 10000; i++) {
		in >> std::hex >> m[i];
		if(in.eof()) break;
	}
	while (!contextp->gotFinish()) {
	// for(int i=0;i<10;i++){
		top->io_code=m[top->io_pc];
        top->clock=0;top->eval();
		top->io_code=m[top->io_pc];
        top->clock=1;top->eval();
		if(top->io_code!=0x42&&top->io_code!=0xdb&&(!top->reset))printf("pc:%x code:%x\n",top->io_pc,top->io_code);
  		nvboard_update();
        // if(i>100){break;}else{i++;}
	}
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}