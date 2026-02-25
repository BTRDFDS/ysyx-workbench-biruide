#ifndef _NPC_DIFFTESS_
#define _NPC_DIFFTESS_

#include <stdint.h>

// #define DIFFTEST //仅限给vscode找语法错误用
#ifdef DIFFTEST
#include <dlfcn.h>
#include <cpu/difftest.h>
#include <common.h>//需要NEMU_HOME
#endif

extern void NpcDifftestInit(uint32_t memSize,uint32_t *M);
extern void NpcDifftestCheck(uint32_t pc);

extern void NpcDifftestGetGpr(uint32_t *gpr);//与PC无关
#endif