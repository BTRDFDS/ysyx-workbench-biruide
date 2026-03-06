#include <am.h>
#include <klib.h>
#include <rtthread.h>

static rt_ubase_t contextFrom;
static rt_ubase_t contextTo;
static Context* ev_handler(Event e, Context *c) {
  // assert(0);
  switch (e.event) {
    case EVENT_YIELD:
      if (contextFrom!=0) {*(Context**)contextFrom = c;}
      c=*((Context**)contextTo);
      break;
    case EVENT_IRQ_TIMER:break;
    default: printf("Unhandled event ID = %d\n", e.event); assert(0);
  }
  // printf("c=%p contextTo(%p)=%x contextFrom(%p)=%x\n",c,contextTo,contextTo,contextFrom,contextFrom);
  // assert(0);
  return c;
}

void __am_cte_init() {
  cte_init(ev_handler);
}

void rt_hw_context_switch_to(rt_ubase_t to) {
  // assert(0);
  contextFrom=0;
  contextTo=to;
  yield();
  // assert(0);
}

void rt_hw_context_switch(rt_ubase_t from, rt_ubase_t to) {
  // assert(0);
  contextFrom=from;
  contextTo=to;
  yield();
}

void rt_hw_context_switch_interrupt(void *context, rt_ubase_t from, rt_ubase_t to, struct rt_thread *to_thread) {
  assert(0);
}

typedef struct {
  void (*tentry)(void*);
  void (*texit )(void);
  void *parameter;
}contextUseArg;
void contextUseFun(void *arg) {
  contextUseArg *args = (contextUseArg *)arg;
  args->tentry(args->parameter);
  args->texit();
}
rt_uint8_t *rt_hw_stack_init(void *tentry, void *parameter, rt_uint8_t *stack_addr, void *texit) {
  // assert(0);
  uintptr_t stack_aligned = (uintptr_t)stack_addr & ~0xf;
  uintptr_t stack_top = stack_aligned;
  stack_top -= sizeof(contextUseArg);
  // contextUseArg arg;
  contextUseArg *arg = (contextUseArg *)stack_top;
  arg->tentry = tentry;
  arg->parameter = parameter;
  arg->texit = texit;
  Area kstack;
  kstack.start  = (void*)stack_aligned;
  kstack.end    = (void*)stack_top;
  return (rt_uint8_t *)kcontext(kstack, contextUseFun, arg);
}
