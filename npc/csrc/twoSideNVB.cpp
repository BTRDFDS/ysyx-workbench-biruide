#include "VtwoSideNVB.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <nvboard.h>
// #include "verilated_vcd_c.h"
#define time 100
int a,b;
int main(int argc, char** argv) {
	VerilatedContext* contextp = new VerilatedContext;
    // Verilated::traceEverOn(true);
	contextp->commandArgs(argc, argv);
	VtwoSideNVB* top = new VtwoSideNVB{contextp};
	
	
	nvboard_bind_pin(&top->a,1,SW0);
	nvboard_bind_pin(&top->b,1,SW1);
	nvboard_bind_pin(&top->f,1,LD0);
	nvboard_init();

    // VerilatedVcdC* tfp = new VerilatedVcdC;
    // top->trace(tfp, 99);
    // tfp->open("wave/twoSide.vcd");
	// while (contextp->time() < time &&!contextp->gotFinish()) {
	while (!contextp->gotFinish()) {
        // contextp->timeInc(1);
  		nvboard_update();

		// a = rand() & 1;
		// b = rand() & 1;
		// top->a = a;
		// top->b = b;


		top->eval();
		// printf("a = %d, b = %d, f = %d\n", a, b, top->f);
        // assert(top->f == (a ^ b));
		//sleep(1);
        // tfp->dump(contextp->time());
	}
    // tfp->close();
	delete top;
	delete contextp;
	nvboard_quit();
	return 0;
}