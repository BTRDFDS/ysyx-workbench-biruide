#include <am.h>
#include <klib-macros.h>

static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
	while(((*(volatile char *)(0x10000005L))&0b00100000)==0);
	asm volatile("sb %0, 0(%1)" : : "r"(ch), "r"(0x10000000L));
}
void halt(int code) {asm volatile("mv a0, %0; ebreak" : :"r"(code));while (1);}
int main(const char *args);
extern char _data_start_,_data_size_,_data_begin_;
extern char _bss_start_,_bss_size_;
void _trm_init() {
	asm volatile("nop");
	// uint8_t* data=(uint8_t*)&_data_start_;
	// while((data-(uint8_t*)&_data_start_)<(size_t)&_data_size_){
	// 	*data = *(&_data_begin_ + (data - (uint8_t*)&_data_start_));
	// 	data++;
	// }
	size_t i=0;
	while(i<((size_t)&_data_size_)){
		*(((uint8_t*)&_data_start_)+i)=*(((uint8_t*)&_data_begin_)+i);
		i++;
	}
	asm volatile("nop");
	uint8_t* bss=(uint8_t*)&_bss_start_;
	while((bss-(uint8_t*)&_bss_start_)<(size_t)&_bss_size_){
		*bss=0;
		bss++;
	}
	// //波特率
	// *(volatile char *)(0x10000003L)=0b10000011;
	// *(volatile char *)(0x10000000L)=0x00;
	// *(volatile char *)(0x10000001L)=0x90;
	// //115200*16==50MHz/36864(0x9000)
	// *(volatile char *)(0x10000003L)=0b00000011;
	// //复位FIFO
	// *(volatile char *)(0x10000002L)=0b11000110;
	halt(main(mainargs));
}
