#include "trap.h"
int main(){
	// return 0;
	*(volatile uint32_t*)(0x10001000) = 0b01010011;
	*(volatile uint32_t*)(0x10001010) = 0b10100000010000;//0b10100100010000
	*(volatile uint32_t*)(0x10001014) = 0;//除数为0，计算结果为主频的1/2
	*(volatile uint32_t*)(0x10001018) = 0b1<<7;//SS=7
	//CHAR_LEN=16
	//Rx_NEG=0 上升沿
	//Tx_NEG=0 上升沿
	//LSB=1
	//ASS=1
	*(volatile uint32_t*)(0x10001010) = 0b10100100010000;
	while(((*(volatile uint32_t*)(0x10001010)>>8)&0b1)==1);
	return *(volatile uint32_t*)(0x10001000);
}