#include "trap.h"
	const uint32_t Addr = 0x10001000;
	const uint32_t RTx0	= Addr;
	const uint32_t RTx1	= Addr+0x04;
	const uint32_t Ctrl = Addr+0x10;
	const uint32_t Div	= Addr+0x14;
	const uint32_t SS   = Addr+0x18;
// void checkBitrev(uint8_t x){
// 	*(volatile uint32_t*)(Addr) = x;
// 	*(volatile uint32_t*)(Ctrl) = 0b10100100010000;
// 	while(((*(volatile uint32_t*)(Ctrl)>>8)&0b1)==1);
// 	// return *(volatile uint32_t*)(Addr);
// 	uint8_t y = (*(volatile uint32_t*)(Addr)>>8)&0xff;
// 	for(int i=0;i<8;i++){
// 		if(((y>>i)&0b1)!=((x>>(7-i))&0b1)){
// 			halt(0xf0000|(y<<8)|x);
// 		}
// 	}
// }
uint32_t bitrev(uint32_t x){
    uint32_t r=0;
    for(int i=0;i<32;i++){
        r<<=1;
        r|=(x&1);
        x>>=1;
    }
    return r;
}
uint32_t wordrev(uint32_t x){
    uint32_t r=0;
    for(int i=0;i<4;i++){
        r<<=8;
        r|=(x&0xff);
        x>>=8;
    }
    return r;
}
int main(){
	*(volatile uint32_t*)(Ctrl) = 0b10100001000000;
	//CHAR_LEN=64 01000000
	//Rx_NEG=1
	//Tx_NEG=0
	//LSB=1
	//ASS=1
	*(volatile uint32_t*)(Div) = 0;//除数为0，计算结果为主频的1/2
	*(volatile uint32_t*)(SS) = 0b1;//SS=0 flash
	// for(uint8_t i=0;i<0xff;i++) checkBitrev(i);
    *(volatile uint32_t*)(RTx0) = bitrev(0x030000fc);//需要反写
	*(volatile uint32_t*)(Ctrl) = 0b10100101000000;
	while(((*(volatile uint32_t*)(Ctrl)>>8)&0b1)==1);
	// return wordrev(*(volatile uint32_t*)(RTx1)>>1);
	return wordrev(bitrev(*(volatile uint32_t*)(RTx0+4)));
}