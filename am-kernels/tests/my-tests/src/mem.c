#include <trap.h>
#include <klib.h>

#include <limits.h>
int main() {
	uintptr_t start =0x0f000000;
	uintptr_t end   =0x0f001fff;
	for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)*p=(uint8_t)((uintptr_t)p&0xFF);
	for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)if(*p != (uint8_t)((uintptr_t)p&0xFF))halt((uint32_t)((uintptr_t)p)|0x000A0000);
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)*p=(uint16_t)((uintptr_t)p&0xFFFF);
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)if(*p != (uint16_t)((uintptr_t)p&0xFFFF))halt((uint32_t)((uintptr_t)p)|0x000B0000);
	for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)*p=(uint32_t)((uintptr_t)p);
	for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)if(*p != (uint32_t)((uintptr_t)p))halt((uint32_t)((uintptr_t)p)|0x000C0000);
	return 0;
}