#include <trap.h>
#include <klib.h>

#include <limits.h>
int main() {
	uint8_t *start =(uint8_t *)0x0f000000;
	uint8_t *end   =(uint8_t *)0x0f001fff;
	for(uint8_t *p = start; p < end; p++)*p=(uint8_t)((uintptr_t)p & 0xFF);
	for(uint8_t *p = start; p < end; p++)if(*p != (uint8_t)((uintptr_t)p & 0xFF))panic("mem error\n");
	return 0;
}