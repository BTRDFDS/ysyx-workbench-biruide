#include "VtwoSide.h"
#include "verilated.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include "verilated_vcd_c.h"
#define max 100
int main(int argc, char** argv) {

	VerilatedContext* contextp = new VerilatedContext;
    Verilated::traceEverOn(true);
	contextp->commandArgs(argc, argv);
	VtwoSide* top = new VtwoSide{contextp};
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("wave/twoSide.vcd");
	while (contextp->time() < max &&!contextp->gotFinish()) {
        contextp->timeInc(1);
		int a = rand() & 1;
		int b = rand() & 1;
		top->a = a;
		top->b = b;
		top->eval();
		printf("a = %d, b = %d, f = %d\n", a, b, top->f);
        assert(top->f == (a ^ b));
		//sleep(1);
        tfp->dump(contextp->time());
	}
    tfp->close();
	delete top;
	delete contextp;
	return 0;
}