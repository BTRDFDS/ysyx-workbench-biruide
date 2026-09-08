#ifndef _NPC_DIFFTESS_
#define _NPC_DIFFTESS_

#include <stdint.h>
#include <cstdio>
#include <cstring>
#include <stdlib.h>
#include "npcConfig.h"
#define NPC_DIFFTEST //仅限给vscode找语法错误用
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

// extern void NpcDifftestInit8 (uint32_t memSize,uint8_t  *M,uint32_t pcReset,const char *nemuLib);
// extern bool NpcDifftestCheck(uint32_t pc);

extern void NpcDifftestGetGpr(uint32_t *gpr);//与PC无关
#endif

#ifdef NPC_DIFFTEST
static bool difftest_enabled = false;
static void *difftestHandle = NULL;

void (*ref_difftest_memcpy)(paddr_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;
typedef struct {
    uint32_t gpr[32];
    uint32_t pc;
} riscv32_CPU_state;

const char *npcDifftestRegs[32] = {//注意：0号寄存器替代为pc
  "pc", "ra",  "sp",  "gp", "tp", "t0", "t1", "t2",
  "s0", "s1",  "a0",  "a1", "a2", "a3", "a4", "a5",
  "a6", "a7",  "s2",  "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

#endif

inline bool NpcDifftestCheck(uint32_t pc){
#ifdef NPC_DIFFTEST
    dftDebug(printf("NpcDifftestCheck\n"););

    if (difftest_enabled==false||ref_difftest_exec==NULL){
        printf("difftest_enabled or ref_difftest_exec is NULL\n");
        return true;
    }
    riscv32_CPU_state npc_state;
    NpcDifftestGetGpr(npc_state.gpr);
    npc_state.pc = pc;//这个是下一个的PC
    npc_state.gpr[0] = 0;

    ref_difftest_exec(1);
    riscv32_CPU_state ref_state;
    ref_difftest_regcpy(&ref_state, DIFFTEST_TO_DUT);
    ref_state.gpr[0] = 0;

    bool match = true;
    if (npc_state.pc != ref_state.pc) {
        printf("[NPC_DIFFTEST] dutNextPc=0x %08x refNextPc=0x %08x\n",npc_state.pc, ref_state.pc);
        difftest_enabled = false;
    }

    for (int i = 1; i < 32; i++) {
        if (npc_state.gpr[i] != ref_state.gpr[i]) {
            printf("[NPC_DIFFTEST] nextPc=0x %08x reg[%d:%s] dut=0x %08x, ref= %08x\n",pc,i,npcDifftestRegs[i], npc_state.gpr[i], ref_state.gpr[i]);
            difftest_enabled = false;
        }
    }
    // if(difftest_enabled==false)exit(-1);
    return !difftest_enabled;
#endif
    return false;
}

inline void NpcDifftestInit8(uint32_t memSize,uint8_t *mem,uint32_t pcReset,const char *nemuLib){
#ifdef NPC_DIFFTEST
    if(mem==NULL){printf("mem==NULL\n");exit(-1);}
    uint32_t *mem32=NULL;//转位宽
    mem32=(uint32_t*)malloc((memSize/4)*sizeof(uint32_t));
    if(mem32==NULL){printf("M==NULL\n");exit(-1);}
    memcpy(mem32,mem,(memSize/4)*sizeof(uint32_t));
    if(mem32==NULL){printf("M==NULL\n");exit(-1);}
    difftestHandle = dlopen(nemuLib, RTLD_LAZY);
    if (!difftestHandle) {
        printf("[NPC_DIFFTEST] NEMU err: %s\n", dlerror());
        exit(-1);
    }
    dftDebug(printf("文件读取完成\n"););
    // 获取函数指针
    ref_difftest_memcpy = (void (*)(uint32_t, void*, size_t, bool))dlsym(difftestHandle, "difftest_memcpy");
    ref_difftest_regcpy = (void (*)(void*, bool))dlsym(difftestHandle, "difftest_regcpy");
    ref_difftest_exec = (void (*)(uint64_t))dlsym(difftestHandle, "difftest_exec");ref_difftest_raise_intr = (void (*)(uint64_t))dlsym(difftestHandle, "difftest_raise_intr");
    void (*ref_difftest_init)(int) = (void (*)(int))dlsym(difftestHandle, "difftest_init");

    if (ref_difftest_memcpy==NULL||ref_difftest_regcpy==NULL||ref_difftest_exec==NULL||ref_difftest_raise_intr==NULL||ref_difftest_init==NULL) {
        printf("[NPC_DIFFTEST] *fun err\n");
        dlclose(difftestHandle);
        exit(-1);
    }
    dftDebug(printf("函数指针获取完成\n"););

    ref_difftest_init(0);
    uint32_t mem_size = (memSize/4) * sizeof(uint32_t);
    ref_difftest_memcpy(pcReset, mem32, mem_size/4, DIFFTEST_TO_REF);
    dftDebug(printf("内存转移完成\n"););
    // 同步初始寄存器状态
    riscv32_CPU_state init_state;
    memset(&init_state, 0, sizeof(riscv32_CPU_state));
    init_state.pc = pcReset;
    ref_difftest_regcpy(&init_state, DIFFTEST_TO_REF);
    dftDebug(printf("寄存器同步完成\n"););
    difftest_enabled = true;
    // printf("[NPC_DIFFTEST] NEMU初始化完成\n");
    if(mem32!=NULL){free(mem32);}
	printf("\033[1;34m DIFFTEST8\t\033[0m");
#endif
}