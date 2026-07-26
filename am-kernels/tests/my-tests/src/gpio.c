#include "trap.h"
int main(){
	const uint32_t addr = 0x10002000;
	*(volatile uint32_t*)(addr+0x0) = 0b1010101010101010;
	*(volatile uint32_t*)(addr+0x8) = 0x76543210;
	uint32_t water = 0b1010101010101010;
	while(1){
		for(int i=0;i<500000;i++);
		*(volatile uint32_t*)(addr+0x0) = water;
		water = water << 1;
	}
	return 0;
}