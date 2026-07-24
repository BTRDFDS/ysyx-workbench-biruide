#include "trap.h"
int main(){
	*(volatile uint32_t*)0xa0000000 = 0x76543210;
	return *(volatile uint32_t*)0xa0000000;
	return 0;
}