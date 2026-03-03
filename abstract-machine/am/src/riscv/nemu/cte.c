#include <am.h>
#include <riscv/riscv.h>
#include <klib.h>

static Context* (*user_handler)(Event, Context*) = NULL;

Context* __am_irq_handle(Context *c) {
  putch('P');putch('\n');
  if (user_handler) {
  putch('Q'+32);putch('\n');
    Event ev = {0};
    switch (c->mcause) {
      default: ev.event = EVENT_ERROR; break;
    }

    c = user_handler(ev, c);
    assert(c != NULL);
    printf("mcause 0x%x\n",c->mcause);
    printf("mstatus 0x%x\n",c->mstatus);
    printf("mepc 0x%x\n",c->mepc);
    printf("s\n");
  }
  return c;
}

extern void __am_asm_trap(void);

bool cte_init(Context*(*handler)(Event, Context*)) {
  // initialize exception entry
  asm volatile("csrw mtvec, %0" : : "r"(__am_asm_trap));

  // register event handler
  user_handler = handler;

  return true;
}

Context *kcontext(Area kstack, void (*entry)(void *), void *arg) {

uintptr_t stack_top = (uintptr_t)kstack.end;
stack_top &= ~0xF;
  Context *c = (Context *)(stack_top - sizeof(Context));
if ((void *)c < kstack.start) {
    return NULL; // 栈空间不足，返回空指针
}
  memset(c, 0, sizeof(Context));
  c->gpr[1] = 0;
  c->gpr[2] = stack_top;
  c->gpr[10] = (uintptr_t)arg;
  c->mepc = (uintptr_t)entry;
  c->mcause  = 0;
  c->mstatus = 0x1800;
  c->pdir = NULL;
  return c;
  // return NULL;
}

void yield() {
#ifdef __riscv_e
  asm volatile("li a5, -1; ecall");
#else
  asm volatile("li a7, -1; ecall");
#endif
}

bool ienabled() {
  return false;
}

void iset(bool enable) {
}
