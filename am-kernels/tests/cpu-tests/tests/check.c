#include "trap.h"
int main(){
  // #include <stdio.h>
  //先csrrs出来一系列mcycle和mcycleh，然后读出mvendorid和marchid，然后再读出一系列mcycle和mcycleh。每读出一个
  uint32_t temp;
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycleh"   : "=r"(temp));printf("mcycleh:  %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycleh"   : "=r"(temp));printf("mcycleh:  %x\n", temp);
  asm volatile("csrr %0, mvendorid" : "=r"(temp));printf("mvendorid:%x\n", temp);
  asm volatile("csrr %0, marchid"   : "=r"(temp));printf("marchid:  %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycleh"   : "=r"(temp));printf("mcycleh:  %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
  asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
}