#include <am.h>
#include <klib-macros.h>

static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {asm volatile("sb %0, 0(%1)" : : "r"(ch), "r"(0x10000000));}
void halt(int code) {asm volatile("mv a0, %0; ebreak" : :"r"(code));while (1);}
int main(const char *args);
extern char _data_start_,_data_size_,_data_begin_;
extern char _bss_start_,_bss_size_;
void _trm_init() {
    // putstr("Hello, AM!\n");
    // putch('H');
    // putch((char)_data_size_);
    // putch('H');
    for(uint8_t i=0;i<_data_size_;i++){((char*)(uintptr_t)_data_begin_)[i]=((char*)(uintptr_t)_data_start_)[i];}
    for(uint8_t i=0;i<_bss_size_  ;i++){((char*)(uintptr_t)_bss_start_)[i]=0;}
    halt(main(mainargs));
}
