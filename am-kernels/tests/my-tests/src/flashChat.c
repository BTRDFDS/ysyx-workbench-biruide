#include "trap.h"
int main(){
	const uint32_t flashAddr	=0x30000000;
	const uint32_t sramAddr		=0x0f000000;
	for(uint32_t i=0;i<0x40;i+=4){
		*(uint32_t*)(sramAddr+i)=*((uint32_t*)(flashAddr+i));
	}
	asm volatile("mv t0, %0; jalr t0" : : "r"(sramAddr));
	return 0;
}