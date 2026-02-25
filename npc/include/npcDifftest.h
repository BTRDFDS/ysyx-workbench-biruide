#ifndef _NPC_DIFFTEST_H_
#define _NPC_DIFFTEST_H_
// #include <difftest-def.h>

// #define DIFFTEST

#include <npcSdb.h>
#ifdef DIFFTEST
extern void init_difftest(const char* so_path, uint32_t mem_base, size_t mem_size);
extern void difftest_step(uint32_t pc);
#endif
#endif