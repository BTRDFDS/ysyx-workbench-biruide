#include "Vysyx_26020046_minirv.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	Vysyx_26020046_minirv* top = new Vysyx_26020046_minirv{contextp};
  uint32_t M[32]={
    0x01400513,
    0x010000e7,
    0x00c000e7,
    0x00c00067,
	0x00a50513,
	0x00008067,
  };
  uint32_t pc=0;
	pc=top->pc;
	top->code=M[pc>>2];
  for(int i=0;(pc<0x20)&&(i<40);i++){
	top->clk=1;
	pc=top->pc;
	top->code=M[pc>>2];
	top->eval();

	top->clk=0;
	top->eval();

	printf("i=%d\n\n",i);
  }
	delete top;
	delete contextp;
	return 0;
}