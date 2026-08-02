//icachesim
#include "Vicachesim.h"
#include "verilated.h"

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>

VerilatedContext* contextp;//verilator上下文
Vicachesim* top;//顶层模块
svScope scope;//作用域
////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vicachesim{contextp};
	{//初始化
	top->clock=0;top->reset=1;top->eval();
	top->clock=1;top->reset=1;top->eval();
	top->clock=0;top->reset=0;top->eval();
	}
	printf("\033[1;32m Welcome to icachesim[\033[1;36m%s %s\033[1;32m] \033[0m\n",__DATE__,__TIME__);
	std::fstream file("./bin/microbench-test.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint32_t pc;
	uint64_t hit;
	for(uint64_t cnt=0;(!contextp->gotFinish());cnt++){
		if(!file.read((char*)&pc, sizeof(pc))){
			printf("cnt= %ld hit= %ld\n"cnt,hit);
			break;
		}
		top->bar_ready	=1;
		top->bar_error	=0;

		top->ifu_valid	=1;
		top->ifu_addr	=(pc>>2)&0x3fffffff;
		top->clock=0;top->eval();
		if(!top->bar_valid)hit++;
		top->clock=1;top->eval();
	}
	delete top;
	delete contextp;
}