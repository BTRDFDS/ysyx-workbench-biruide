#include "trap.h"
int main(){
	// *(volatile uint32_t*)0xa0000000 = 0x76543210;
	// return *(volatile uint32_t*)0xa0000000;
	const uint32_t size = 0x2000000;
	const uint32_t addr = 0xa0000000;
	// for(uint32_t i = 0; i < size; i++)		*(volatile uint8_t*)	(addr+i)  = i&0xff;
	// for(uint32_t i = 0; i < size; i+=1)if(	*(volatile uint8_t*)	(addr+i) != (i&0xff))return i;
	// for(uint32_t i = 0; i < size; i+=2)if(	*(volatile uint16_t*)	(addr+i) != (((i+1)&0xff)<<8|(i&0xff)))return i;
	// for(uint32_t i = 0; i < size; i+=4)if(	*(volatile uint32_t*)	(addr+i) != (((i+3)&0xff)<<24|((i+2)&0xff)<<16|((i+1)&0xff)<<8|(i&0xff)))return i;
	
	for(uint32_t i = 0; i < size; i+=4){
		*(volatile uint8_t*)(addr+i+0) = i&0xff;
		*(volatile uint8_t*)(addr+i+1) = (i+1)&0xff;
		*(volatile uint8_t*)(addr+i+2) = (i+2)&0xff;
		*(volatile uint8_t*)(addr+i+3) = (i+3)&0xff;
		if(*(volatile uint32_t*)(addr+i) != (((i+3)&0xff)<<24|((i+2)&0xff)<<16|((i+1)&0xff)<<8|(i&0xff)))return 1;
		if(*(volatile uint16_t*)(addr+i+0) != (((i+1)&0xff)<<8|((i+0)&0xff)))return 2;
		if(*(volatile uint16_t*)(addr+i+2) != (((i+3)&0xff)<<8|((i+2)&0xff)))return 3;
		if(*(volatile uint8_t*)(addr+i+0) != ((i+0)&0xff))return 4;
		if(*(volatile uint8_t*)(addr+i+1) != ((i+1)&0xff))return 5;
		if(*(volatile uint8_t*)(addr+i+2) != ((i+2)&0xff))return 6;
		if(*(volatile uint8_t*)(addr+i+3) != ((i+3)&0xff))return 7;
	}
	return 0;
}