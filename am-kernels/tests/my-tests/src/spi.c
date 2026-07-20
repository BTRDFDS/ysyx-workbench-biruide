#include "trap.h"
// uint32_t bitrev(uint32_t x){
// 	uint32_t r=0;
// 	for(int i=0;i<32;i++){
// 		r<<=1;
// 		r|=(x&1);
// 		x>>=1;
// 	}
// 	return r;
// }
// uint32_t wordrev(uint32_t x){
// 	uint32_t r=0;
// 	for(int i=0;i<4;i++){
// 		r<<=8;
// 		r|=(x&0xff);
// 		x>>=8;
// 	}
// 	return r;
// }
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
int main(){//仅仅适用于cpp未修改能加载程序的情况
	// *(volatile uint32_t*)(Ctrl) = 0b10100001000000;
	//CHAR_LEN=64 01000000
	//Rx_NEG=1
	//Tx_NEG=0
	//LSB=1
	//ASS=1
	// *(volatile uint32_t*)(Div) = 0;//除数为0，计算结果为主频的1/2
	// *(volatile uint32_t*)(SS) = 0b1;//SS=0 flash

	// *(volatile uint32_t*)(RTx0) = bitrev(0x03000000);//需要反写
	// *(volatile uint32_t*)(Ctrl) = 0b10100101000000;
	// while(((*(volatile uint32_t*)(Ctrl)>>8)&0b1)==1);
	// return wordrev(bitrev(*(volatile uint32_t*)(RTx1)));//需要字节内和字节分别取反
	// for(uint32_t i=0;i<0x100;i++){
	// 	*(volatile uint32_t*)(RTx0) = bitrev(0x03000000+i);
	// 	*(volatile uint32_t*)(Ctrl) = 0b10100101000000;
	// 	while(((*(volatile uint32_t*)(Ctrl)>>8)&0b1)==1);
	// 	uint8_t p = wordrev(bitrev(*(volatile uint32_t*)(RTx1))) & 0xff;
	// 	if(p!=(i&0xff))return (p)|((i&0xff)<<16)|0x0a000000;
	// }
	// for(uint32_t i=0;i+1<0x100;i+=2){
	// 	*(volatile uint32_t*)(RTx0) = bitrev(0x03000000+i);
	// 	*(volatile uint32_t*)(Ctrl) = 0b10100101000000;
	// 	while(((*(volatile uint32_t*)(Ctrl)>>8)&0b1)==1);
	// 	uint16_t p = wordrev(bitrev(*(volatile uint32_t*)(RTx1))) & 0xffff;
	// 	if(p!=(((i+1)<<8)|i))return p|0x0b000000;
	// }
	// for(uint32_t i=0;i+3<0x100;i+=4){
	// 	*(volatile uint32_t*)(RTx0) = bitrev(0x03000000+i);
	// 	*(volatile uint32_t*)(Ctrl) = 0b10100101000000;
	// 	while(((*(volatile uint32_t*)(Ctrl)>>8)&0b1)==1);
	// 	uint32_t p = wordrev(bitrev(*(volatile uint32_t*)(RTx1)));
	// 	if(p!=(((i+3)<<24)|((i+2)<<16)|((i+1)<<8)|i))return p;
	// }

	// return flash_read(0x000000);
	for(uint32_t i=0;i<0x100;i+=4){
		if(flash_read(i)!=i)return i;
	}
	return 0;
}