#include <am.h>
#include <klib-macros.h>

#define STACK_SIZE (4096 * 8)
typedef union {
	uint8_t stack[STACK_SIZE];
	struct { Context *cp; };
} PCB;
static PCB pcb[2], pcb_boot, *current = &pcb_boot;
static uint8_t cnt = 0;
static uint8_t nextstatus = 0;
static void f(void *arg) {
	if((uintptr_t)arg == nextstatus){
		nextstatus = ((uintptr_t)arg == 0 ? 1 : 0);
		cnt++;
		yield();
	}
	halt(2);
}

static Context *schedule(Event ev, Context *prev) {
	if(cnt==10){halt(0);}
	current->cp = prev;
	current = (current == &pcb[0] ? &pcb[1] : &pcb[0]);
	return current->cp;
}

int main() {
	cte_init(schedule);
	pcb[0].cp = kcontext((Area) { pcb[0].stack, &pcb[0] + 1 }, f, (void *)0L);
	pcb[1].cp = kcontext((Area) { pcb[1].stack, &pcb[1] + 1 }, f, (void *)1L);
	yield();
	halt(-1);
}
