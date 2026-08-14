#include <trap.h>
int main(){
    asm volatile("fence.i");
    asm volatile("addi a0, zero, 1");
    asm volatile("ebreak");
    halt(0);
}