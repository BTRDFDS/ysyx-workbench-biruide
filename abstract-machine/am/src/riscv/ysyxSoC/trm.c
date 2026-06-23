#include <am.h>
#include <klib-macros.h>

static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
    // char sta;do{asm volatile("lbu %0, 0(%1)" :"=r"(sta):"r"(0x10000005L));}while((sta&0b100000)==0);
    asm volatile("sb %0, 0(%1)" : : "r"(ch), "r"(0x10000000L));
}
void halt(int code) {asm volatile("mv a0, %0; ebreak" : :"r"(code));while (1);}
int main(const char *args);
extern char _data_start_,_data_size_,_data_begin_;
extern char _bss_start_,_bss_size_;
void _trm_init() {
    uint8_t* data=(uint8_t*)&_data_start_;
    while((data-(uint8_t*)&_data_start_)<(size_t)&_data_size_){
        *data = *(&_data_begin_ + (data - (uint8_t*)&_data_start_));
        data++;
    }
    uint8_t* bss=(uint8_t*)&_bss_start_;
    while((bss-(uint8_t*)&_bss_start_)<(size_t)&_bss_size_){
        *bss=0;
        bss++;
    }
    // *(volatile char *)(0x10000003L)=0b10000011;
    // *(volatile char *)(0x10000001L)=0x0;
    // *(volatile char *)(0x10000000L)=0x1;
    // *(volatile char *)(0x10000003L)=0b00000011;
    // *(volatile char *)(0x10000004L)=0b00000011;
    // *(volatile char *)(0x10000002L)=0x7;
    halt(main(mainargs));
}
