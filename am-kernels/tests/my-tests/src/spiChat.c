#include "trap.h"

uint32_t flash_read(uint32_t addr){
	if(addr>>24!=0x00)halt(-1);//error,虽然寻址空间是到3f，但是实际上用不了因为就24位
	const uint32_t Addr = 0x10001000;
	const uint32_t RTx0	= Addr;
	const uint32_t RTx1	= Addr+0x04;
	const uint32_t Ctrl = Addr+0x10;
	const uint32_t Div	= Addr+0x14;
	const uint32_t SS   = Addr+0x18;
	//CHAR_LEN=64 01000000
	//Rx_NEG=1
	//Tx_NEG=0
	//LSB=1
	//ASS=1
	*(volatile uint32_t*)(Ctrl)	= 0b10100001000000;
	*(volatile uint32_t*)(Div)	= 0;
	*(volatile uint32_t*)(SS)	= 0b1;//SS=0 flash
	uint32_t code = 0x03000000|(addr&0xffffff);
	uint32_t rev=0;
	for(int i=0;i<32;i++){
		rev<<=1;
		rev|=(code&1);
		code>>=1;
	}
	*(volatile uint32_t*)(RTx0) = rev;
	*(volatile uint32_t*)(Ctrl) = 0b10100101000000;
	while(((*(volatile uint32_t*)(Ctrl)>>8)&0b1)==1);
	code=*(volatile uint32_t*)(RTx1);
	for(int i=0;i<32;i++){
		rev<<=1;
		rev|=(code&1);
		code>>=1;
	}
	for(int i=0;i<4;i++){
		code<<=8;
		code|=(rev&0xff);
		rev>>=8;
	}
	return code;
}
int main(){
	const uint32_t start	=0x0f000000;
	for(uint32_t i=0;i<0x40;i+=4){
		*(uint32_t*)(start+i)=flash_read(i);
	}
	asm volatile("mv t0, %0; jalr t0" : : "r"(start));
	return 0;
}