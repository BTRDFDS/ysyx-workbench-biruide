#include "trap.h"
int main(){
	const uint32_t addr = 0x10002000;
	*(volatile uint32_t*)(addr+0x0) = 0b1010101010101010;
	uint32_t id;
	asm volatile("csrr %0, marchid" : "=r"(id));

	*(volatile uint32_t*)(addr+0x8) = id;
	uint32_t water = 0x00ff00ff;

	const char *fmt ="Hello, AbstractMachine!\n";
	for(const char *p = fmt; *p; p++) putch(*p);

	while(1){
		if(*(volatile uint32_t*)(addr+0x4) == 0b1){
		for(int i=0;i<20000;i++);
		*(volatile uint32_t*)(addr+0x0) = water;
		uint32_t temp = water>>31;
		water = water << 1;
		water = water | (temp & 0b1);
		}
	}
	return 0;
}