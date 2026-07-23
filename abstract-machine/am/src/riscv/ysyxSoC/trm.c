#include <am.h>
#include <klib-macros.h>

static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

extern char _heap_start,_heap_end;
Area heap = RANGE(&_heap_start, &_heap_end);





void putch(char ch) {
	static bool init=false;
	if(!init){
		// //波特率
		*(volatile char *)(0x10000003L)=0b10000011;
		*(volatile char *)(0x10000000L)=0x01;//直接最快
		*(volatile char *)(0x10000001L)=0x00;
		//115200*16==50MHz/27(0x1B)
		*(volatile char *)(0x10000003L)=0b00000011;
		//复位FIFO
		// *(volatile char *)(0x10000002L)=0b11000110;//应该不需要，因为手册上写了会自动复位
		init=true;
	}
	while(((*(volatile char *)(0x10000005L))&0b00100000)==0);
	asm volatile("sb %0, 0(%1)" : : "r"(ch), "r"(0x10000000L));
}
void halt(int code) {asm volatile("mv a0, %0; ebreak" : :"r"(code));while (1);}
int main(const char *args);
extern char _load_start_,_load_size_,_load_begin_;
extern char _data_start_,_data_size_,_data_begin_;
extern char _bss_start_,_bss_size_;

void _bootloader() {//SSLB
	// uint8_t* load=(uint8_t*)&_load_start_;
	// while((load-(uint8_t*)&_load_start_)<=(size_t)&_load_size_){
	// 	*load = *(&_load_begin_ + (load - (uint8_t*)&_load_start_));
	// 	load++;
	// }
	// asm volatile("nop");
	uint32_t* data=(uint32_t*)&_data_start_;
	while((data-(uint32_t*)&_data_start_)<=(size_t)&_data_size_){
		*data = *(&_data_begin_ + (data - (uint32_t*)&_data_start_));
		data+=4;
	}
	// asm volatile("nop");
	uint32_t* bss=(uint32_t*)&_bss_start_;
	while((bss-(uint32_t*)&_bss_start_)<=(size_t)&_bss_size_){
		*bss=0;
		bss+=4;
	}
	halt(main(mainargs));
}
void _trm_init() {//FSLB
	uint32_t* load=(uint32_t*)&_load_start_;
	while((load-(uint32_t*)&_load_start_)<=(size_t)&_load_size_){
		// uint32_t temp = 
		*load = *(uint32_t*)(&_load_begin_ + (load - (uint32_t*)&_load_start_));
		load++;
	}
	_bootloader();
}