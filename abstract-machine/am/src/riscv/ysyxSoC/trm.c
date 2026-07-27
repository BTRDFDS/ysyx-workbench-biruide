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
		*(volatile char *)(0x10000000L)=0x01;//nvboard的除数是16
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
// char getch(){
// 	if(((*(volatile char *)(0x10000005L))&0b00000001)==1)return (*(volatile char *)(0x10000000L))&0xff;
// 	return 0xff;
// }
void halt(int code) {asm volatile("mv a0, %0; ebreak" : :"r"(code));while (1);}
int main(const char *args);
extern char _load_start_,_load_size_,_load_begin_[];
extern char _imag_start_,_imag_size_,_imag_begin_[];
extern char _base_start_,_base_size_;

void _bootloader() {//SSLB
	// uint8_t* load=(uint8_t*)&_load_start_;
	// while((load-(uint8_t*)&_load_start_)<=(size_t)&_load_size_){
	// 	*load = *(&_load_begin_ + (load - (uint8_t*)&_load_start_));
	// 	load++;
	// }
	// asm volatile("nop");
	uint32_t* data=(uint32_t*)&_imag_start_;
	while((data-(uint32_t*)&_imag_start_)<=(size_t)&_imag_size_){
		*data = *((uint32_t*)&_imag_begin_ + (data - (uint32_t*)&_imag_start_));
		data=data+1;
	}
	// asm volatile("nop");
	uint32_t* bss=(uint32_t*)&_base_start_;
	while((bss-(uint32_t*)&_base_start_)<=(size_t)&_base_size_){
		*bss=0;
		bss=bss+1;
	}
	halt(main(mainargs));
}
void _trm_init() {//FSLB
	uint32_t* load=(uint32_t*)&_load_start_;
	while((load-(uint32_t*)&_load_start_)<=(size_t)&_load_size_){
		*load = *((uint32_t*)&_load_begin_ + (load - (uint32_t*)&_load_start_));
		load=load+1;
	}
	_bootloader();
}