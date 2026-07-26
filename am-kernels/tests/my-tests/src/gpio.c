#include "trap.h"
int main(){
	const uint32_t addr = 0x10002000;
	*(volatile uint32_t*)(addr+0x0) = 0b1010101010101010;
	*(volatile uint32_t*)(addr+0x8) = 0x76543210;
	uint32_t water = 0x0f0f0f0f;
	while(1){
		for(int i=0;i<200000;i++);
		if(*(volatile uint32_t*)(addr+0x4) == 0b0001011011101111){
			*(volatile uint32_t*)(addr+0x0) = water;
			uint32_t temp = water>>31;
			water = water << 1;
			water = water | (temp & 0b1);
		}
	}
	return 0;
}