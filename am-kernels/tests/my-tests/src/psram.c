#include "trap.h"
int main(){
    // *(volatile uint32_t*)0x80000000 = 0x76543210;
	// return *(volatile uint32_t*)0x80000000;
    *(volatile uint8_t*)0x80ffffff = 0x12;
    return *(volatile uint8_t*)0x80ffffff;
}