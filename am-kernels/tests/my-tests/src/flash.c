#include "trap.h"
int main(){
	const uint32_t flashAddr	=0x30000000;
	for(uint32_t i=0;i<0x10;i++){
		uint8_t p=*((uint8_t*)(flashAddr+i));
		if(p!=(i&0xff))return (p)|((i&0xff)<<16);
	}
	return 0;
}