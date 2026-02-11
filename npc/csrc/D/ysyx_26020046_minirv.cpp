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
    0x108093,
    0x108093,
    0x108093,
    0x108093,    
  };
	// while (!contextp->gotFinish()) {
	// 	top->clk = 1;
  //   top->eval();
	// 	top->clk = 0;
  //   top->eval();

	// }
  for(int i=0;i<5;i++){}
	delete top;
	delete contextp;
	return 0;
}