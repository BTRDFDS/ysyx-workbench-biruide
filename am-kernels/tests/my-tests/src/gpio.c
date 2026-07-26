#include "trap.h"
int main(){
	const uint32_t* addr = 0x10002000;
    *(addr+0x0) = 0b1010101010101010;
    *(addr+0x8) = 0x76543210;
    while(1);
	return 0;
}