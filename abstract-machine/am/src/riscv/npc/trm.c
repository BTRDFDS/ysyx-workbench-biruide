#include <am.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;
#define PMEM_SIZE (128 * 1024 * 1024)
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

Area heap = RANGE(&_heap_start, PMEM_END);
static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
  //往0x10000000处写入字符串，即往串口写入字符串
  asm volatile("sw %0, 0(%1)" : : "r"(ch), "r"(0x10000000));  
}

void halt(int code) {
  asm volatile("mv a0, %0; ebreak" : :"r"(code));//a0写入0，然后ebreak
  while (1);
}
void put_marchid(uint32_t in){
  if (in >= 10U){put_marchid(in / 10U);}
  putch((char)('0' + (in % 10U)));
}
void _trm_init() {
	uint32_t mcycle;  asm volatile ("csrrs %0, mcycle, x0" : "=r"(mcycle));
	uint32_t mcycleh; asm volatile ("csrrs %0, mcycleh,  x0" : "=r"(mcycleh));
	putch('[');
	put_marchid(mcycleh);
	put_marchid(mcycle);
	putch(']');
	putch(' ');
  uint32_t mvendorid;
  uint32_t marchid;
  asm volatile ("csrrs %0, mvendorid, x0" : "=r"(mvendorid));
  asm volatile ("csrrs %0, marchid,  x0" : "=r"(marchid));
  for(int32_t i=24;i>=0;i-=8){putch((mvendorid>>i)&0xff);}
  putch(' ');
  put_marchid(marchid);
  putch('\n');
  int ret = main(mainargs);
  halt(ret);
}
