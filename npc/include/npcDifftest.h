#ifndef _NPC_DIFFTESS_
#define _NPC_DIFFTESS_

#include <stdint.h>
#include <npcConfig.h>
// #define NPC_DIFFTEST //仅限给vscode找语法错误用
#ifdef NPC_DIFFTEST
#include <dlfcn.h>
#include <cpu/difftest.h>
#include <common.h>//需要NEMU_HOME
#endif

// #define NPC_DIFFTEST_DEBUG

#ifdef NPC_DIFFTEST_DEBUG
    #define dftDebug(...) do { __VA_ARGS__; } while(0)
#else
    #define dftDebug(...) ((void)0)
#endif

extern void NpcDifftestInit32(uint32_t memSize,uint32_t *M);
extern void NpcDifftestInit8 (uint32_t memSize,uint8_t  *M);
extern void NpcDifftestCheck(uint32_t pc);

extern void NpcDifftestGetGpr(uint32_t *gpr);//与PC无关
#endif