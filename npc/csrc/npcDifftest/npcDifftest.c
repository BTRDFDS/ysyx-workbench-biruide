#include <npcDifftest.h>

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

void NpcDifftestCheck(uint32_t pc){
#ifdef NPC_DIFFTEST
    dftDebug(printf("NpcDifftestCheck\n"););

    if (difftest_enabled==false||ref_difftest_exec==NULL) return;
    riscv32_CPU_state npc_state;
    // for (int i = 0; i < 32; i++) {
    //     npc_state.gpr[i] = getReg(i);//TODO:处理获取寄存器的逻辑
    // }
    NpcDifftestGetGpr(npc_state.gpr);
    npc_state.pc = pc;
    npc_state.gpr[0] = 0;

    ref_difftest_exec(1);
    riscv32_CPU_state ref_state;
    ref_difftest_regcpy(&ref_state, DIFFTEST_TO_DUT);
    ref_state.gpr[0] = 0;

    bool match = true;
    if (npc_state.pc != ref_state.pc) {
        printf("[NPC_DIFFTEST] dutPc=0x%08x refPc=0x%08x\n",npc_state.pc, ref_state.pc);
        difftest_enabled = false;
    }

    for (int i = 1; i < 32; i++) {
        if (npc_state.gpr[i] != ref_state.gpr[i]) {
            printf("[NPC_DIFFTEST] pc=0x%08x reg[%s] dut=0x%08x, ref=0x%08x\n",pc,npcDifftestRegs[i], npc_state.gpr[i], ref_state.gpr[i]);
            difftest_enabled = false;
        }
    }
    if(difftest_enabled==false)exit(-1);
#endif
}

void NpcDifftestInit8(uint32_t memSize,uint8_t *mem){
#ifdef NPC_DIFFTEST
    if(mem==NULL){printf("mem==NULL\n");exit(-1);}
    uint32_t *M=NULL;
    M=(uint32_t*)malloc((memSize/4)*sizeof(uint32_t));
    if(M==NULL){printf("M==NULL\n");exit(-1);}
    memcpy(M,mem,(memSize/4)*sizeof(uint32_t));
    if(M==NULL){printf("M==NULL\n");exit(-1);}
    const char *nemuLib = "/home/biruide/ysyx-workbench/npc/lib/riscv32-nemu-interpreter-so";
    difftestHandle = dlopen(nemuLib, RTLD_LAZY);
    if (!difftestHandle) {
        printf("[NPC_DIFFTEST] NEMU err: %s\n", dlerror());
        return;
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
        return;
    }
    dftDebug(printf("函数指针获取完成\n"););

    ref_difftest_init(0);
    uint32_t mem_size = (memSize/4) * sizeof(uint32_t);
    ref_difftest_memcpy(0x80000000, M, mem_size/4, DIFFTEST_TO_REF);
    dftDebug(printf("内存转移完成\n"););
    // 同步初始寄存器状态
    riscv32_CPU_state init_state;
    memset(&init_state, 0, sizeof(riscv32_CPU_state));
    init_state.pc = 0x80000000;
    ref_difftest_regcpy(&init_state, DIFFTEST_TO_REF);
    dftDebug(printf("寄存器同步完成\n"););
    difftest_enabled = true;
    // printf("[NPC_DIFFTEST] NEMU初始化完成\n");
    if(M!=NULL){free(M);}
	printf("\033[1;34m DIFFTEST8\t\033[0m");
#endif
}

void NpcDifftestInit32(uint32_t memSize,uint32_t *M){
#ifdef NPC_DIFFTEST
    if(M==NULL){printf("M==NULL\n");}
    const char *nemuLib = "/home/biruide/ysyx-workbench/npc/lib/riscv32-nemu-interpreter-so";
    difftestHandle = dlopen(nemuLib, RTLD_LAZY);
    if (!difftestHandle) {
        printf("[NPC_DIFFTEST] NEMU err: %s\n", dlerror());
        return;
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
        return;
    }
    dftDebug(printf("函数指针获取完成\n"););

    ref_difftest_init(0);
    uint32_t mem_size = memSize * sizeof(uint32_t);
    ref_difftest_memcpy(0x80000000, M, mem_size, DIFFTEST_TO_REF);
    dftDebug(printf("内存转移完成\n"););
    // 同步初始寄存器状态
    riscv32_CPU_state init_state;
    memset(&init_state, 0, sizeof(riscv32_CPU_state));
    init_state.pc = 0x80000000;
    ref_difftest_regcpy(&init_state, DIFFTEST_TO_REF);
    dftDebug(printf("寄存器同步完成\n"););
    difftest_enabled = true;
    // printf("[NPC_DIFFTEST] NEMU初始化完成\n");
	printf("\033[1;34m DIFFTEST32\t\033[0m");
#endif
}
