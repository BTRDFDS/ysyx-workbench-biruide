#include "trap.h"
int main(){
	const uint32_t flashAddr	=0x30000000;
	for(uint32_t i=0;i<0x100;i++){
		uint8_t p=*((uint8_t*)(flashAddr+i));
		if(p!=(i&0xff))return (p)|((i&0xff)<<8|0xa0000000);
	}
	for(uint32_t i=0;i+1<0x100;i+=2){
		uint16_t p=*((uint16_t*)(flashAddr+i));
		if(p!=(((i+1)<<8)|i))return p;
	}
	for(uint32_t i=0;i+3<0x100;i+=4){
		uint32_t p=*((uint32_t*)(flashAddr+i));
		if(p!=(((i+3)<<24)|((i+2)<<16)|((i+1)<<8)|i))return p;
	}
	// return *((uint8_t*)(flashAddr+1));
	return 0;
}