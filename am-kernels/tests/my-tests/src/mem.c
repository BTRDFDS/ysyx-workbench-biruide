#include <trap.h>
#include <klib.h>

#include <limits.h>
int main() {
	uintptr_t start =0x0f000000;
	uintptr_t end   =0x0f001fff;
	for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)*p=(uint8_t)((uintptr_t)p&0xFF);
	for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)if(*p != (uint8_t)((uintptr_t)p&0xFF))return -1;
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)*p=(uint16_t)((uintptr_t)p&0xFFFF);
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)if(*p != (uint16_t)((uintptr_t)p&0xFFFF))return -2;
	for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)*p=(uint32_t)((uintptr_t)p);
	for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)if(*p != (uint32_t)((uintptr_t)p))return -3;
	return 0;
}