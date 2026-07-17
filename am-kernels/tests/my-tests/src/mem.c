#include <trap.h>
#include <klib.h>

#include <limits.h>
const uintptr_t start =0x0f000000;
const uintptr_t end   =0x0f001fff;
void test1(){
	for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)*p=(uint8_t)((uintptr_t)p&0xFF);
	for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)if(*p != (uint8_t)((uintptr_t)p&0xFF))halt((uint32_t)((uintptr_t)p)|0x000A0000);
}
void test2(){
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)*p=(uint16_t)((uintptr_t)p&0xFFFF);
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)if(*p != (uint16_t)((uintptr_t)p&0xFFFF))halt((uint32_t)((uintptr_t)p)|0x000B0000);
}
void test4(){
	for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)*p=(uint32_t)((uintptr_t)p);
	for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)if(*p != (uint32_t)((uintptr_t)p))halt((uint32_t)((uintptr_t)p)|0x000C0000);
}
int main() {
	// for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)*p=(uint8_t)((uintptr_t)p&0xFF);
	// for(uint8_t *p=(uint8_t*)start;p<=(uint8_t*)end;p++)if(*p != (uint8_t)((uintptr_t)p&0xFF))return ((uint32_t)((uintptr_t)p)|0x000A0000);
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)*p=(uint16_t)((uintptr_t)p&0xFFFF);
	for(uint16_t *p=(uint16_t*)start;p<=(uint16_t*)end;p++)if(*p != (uint16_t)((uintptr_t)p&0xFFFF))return ((uint32_t)((uintptr_t)p)|0x000B0000);
	// for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)*p=(uint32_t)((uintptr_t)p);
	// for(uint32_t *p=(uint32_t*)start;p<=(uint32_t*)end;p++)if(*p != (uint32_t)((uintptr_t)p))return ((uint32_t)((uintptr_t)p)|0x000C0000);
	test1();
	// test2();
	// test4();
	return 0;
}