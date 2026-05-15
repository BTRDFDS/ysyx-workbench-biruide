#include <am.h>
#include <klib-macros.h>

static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {asm volatile("sb %0, 0(%1)" : : "r"(ch), "r"(0x10000000));}
void halt(int code) {asm volatile("mv a0, %0; ebreak" : :"r"(code));while (1);}
int main(const char *args);
extern char _data_start_,_data_size_,_data_begin_;
extern char _bss_start_,_bss_size_;
void _trm_init() {
    uint32_t* data=(uint32_t*)&_data_start_;
    while((data-(uint32_t*)&_data_start_)<(size_t)&_data_size_){
        *data=*(uint32_t*)(&_data_begin_+(data-(uint32_t*)&_data_start_));
        data++;
    }
    uint32_t* bss=(uint32_t*)&_bss_start_;
    while((bss-(uint32_t*)&_bss_start_)<(size_t)&_bss_size_){
        *bss=0;
        bss++;
    }
    // for(size_t i=0;i<(size_t)&_data_size_;i++){((char *)&_data_start_)[i]=((char *)&_data_begin_)[i];}
    // for(size_t i=0;i<(size_t)&_bss_size_;i++){((char *)&_bss_start_)[i]=0;}
    halt(main(mainargs));
}
