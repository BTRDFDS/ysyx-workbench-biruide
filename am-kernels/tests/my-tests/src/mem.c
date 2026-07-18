#include <trap.h>
#include <klib.h>

#include <limits.h>
const uintptr_t start =0x0f000000;
const uintptr_t end   =0x0f001fff;
int main() {
	// for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)*p=(uint16_t)((uintptr_t)p&0xFFFF);
	// for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)if(*p != (uint16_t)((uintptr_t)p&0xFFFF))return ((uint32_t)((uintptr_t)p)|0x000B0000);
	// for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)*p=(uint32_t)((uintptr_t)p);
	// for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)if(*p != (uint32_t)((uintptr_t)p))return ((uint32_t)((uintptr_t)p)|0x000C0000);
	// for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)*p=(uint8_t)((uintptr_t)p&0xFF);
	// for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)if(*p != (uint8_t)((uintptr_t)p&0xFF))return ((uint32_t)((uintptr_t)p)|0x000A0000);
	// return 0;
	//手动测试
	// (*(uint32_t*)start)=0x76543210;
	(*(uint8_t*)0x0f000000)=0x10;
	(*(uint8_t*)0x0f000001)=0x32;
	(*(uint8_t*)0x0f000002)=0x54;
	(*(uint8_t*)0x0f000003)=0x76;
	// (*(uint16_t*)(0x0f000000))=0x3210;
	// (*(uint16_t*)(0x0f000002))=0x7654;
	volatile uint32_t p=(*(uint8_t*)(0x0f000001));
	if(p==0){return p;}
	// return (*(uint16_t*)(0x0f000002));
	// return (*(uint32_t*)(0x0f000000));
}