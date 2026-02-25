#include <npcDifftest.h>

#include <dlfcn.h>
#include <nemu/include/cpu/difftest.h>
// DiffTest函数指针
typedef void (*difftest_memcpy_t)(uint32_t addr, void* buf, size_t n, bool direction);
typedef void (*difftest_regcpy_t)(void* dut, bool direction);
typedef void (*difftest_exec_t)(uint64_t n);
typedef void (*difftest_raise_intr_t)(uint32_t NO);
typedef void (*difftest_init_t)(int port);

static void* difftest_handle = NULL;
static difftest_memcpy_t ref_difftest_memcpy = NULL;
static difftest_regcpy_t ref_difftest_regcpy = NULL;
static difftest_exec_t ref_difftest_exec = NULL;
static difftest_raise_intr_t ref_difftest_raise_intr = NULL;

static bool difftest_enabled = false;
static bool difftest_initialized = false;
// CPU状态结构（必须与NEMU完全一致）
typedef struct {
	uint32_t gpr[32];  // 32个通用寄存器 x0-x31
	uint32_t pc;	   // 程序计数器
} CPU_state;

// 每指令检查函数
void difftest_step(uint32_t pc) {
	if (!difftest_enabled || !difftest_initialized) return;

	// 获取NPC当前状态
	CPU_state npc_state;
	difftest_getregs(&npc_state);
	npc_state.pc = pc;

	// 执行一条指令
	ref_difftest_exec(1);

	// 获取REF执行后的状态
	CPU_state ref_state;
	ref_difftest_regcpy(&ref_state, DIFFTEST_TO_DUT);

	// 比较状态（注意：x0寄存器硬连线为0）
	npc_state.gpr[0] = 0;

	if (memcmp(&npc_state, &ref_state, sizeof(CPU_state)) != 0) {
		difftest_report(&npc_state, &ref_state);
		difftest_enabled = false; // 停止DiffTest
	}
}

// 获取NPC寄存器状态
void difftest_getregs(CPU_state *state) {
	for (int i = 1; i < 32; i++) {
		state->gpr[i] =NpcsdbGetReg(i);
	}
	state->gpr[0] = 0;
}

// static bool load_difftest_library(const char* so_path) {
//     difftest_handle = dlopen(so_path, RTLD_LAZY);
//     if (!difftest_handle) {
//         printf("Failed to load DiffTest library: %s\n", dlerror());
//         return false;
//     }

//     // 获取函数指针
//     ref_difftest_memcpy = (difftest_memcpy_t)dlsym(difftest_handle, "difftest_memcpy");
//     ref_difftest_regcpy = (difftest_regcpy_t)dlsym(difftest_handle, "difftest_regcpy");
//     ref_difftest_exec = (difftest_exec_t)dlsym(difftest_handle, "difftest_exec");
//     ref_difftest_raise_intr = (difftest_raise_intr_t)dlsym(difftest_handle, "difftest_raise_intr");
//     difftest_init_t ref_difftest_init = (difftest_init_t)dlsym(difftest_handle, "difftest_init");

//     if (!ref_difftest_memcpy || !ref_difftest_regcpy ||
//         !ref_difftest_exec || !ref_difftest_raise_intr || !ref_difftest_init) {
//         printf("Failed to get DiffTest function pointers\n");
//         dlclose(difftest_handle);
//         return false;
//     }

//     // 初始化REF
//     ref_difftest_init(0);
//     return true;
// }
// void init_difftest(const char* so_path, uint32_t mem_base, size_t mem_size) {
//     extern uint32_t addrReset;
//     extern uint32_t* M;

//     if (!load_difftest_library(so_path)) {
//         return;
//     }

//     // 同步内存：将NPC内存复制到REF
//     for (size_t i = 0; i < mem_size; i += 4) {
//         uint32_t addr = mem_base + i;
//         uint32_t data = M[i >> 2];  // NPC内存数组
//         ref_difftest_memcpy(addr, &data, 4, DIFFTEST_TO_REF);
//     }

//     // 同步寄存器初始状态
//     CPU_state init_state;
//     memset(&init_state, 0, sizeof(CPU_state));
//     init_state.pc = addrReset;  // 初始PC
//     ref_difftest_regcpy(&init_state, DIFFTEST_TO_REF);

//     difftest_initialized = true;
//     difftest_enabled = true;
//     printf("DiffTest initialized with library: %s\n", so_path);
// }
// static void difftest_report(CPU_state *npc, CPU_state *ref) {
//     printf("DiffTest failed!\n");
//     printf("NPC PC: 0x%08x, REF PC: 0x%08x\n", npc->pc, ref->pc);

//     for (int i = 0; i < 32; i++) {
//         if (npc->gpr[i] != ref->gpr[i]) {
//             printf("x%2d: NPC=0x%08x, REF=0x%08x\n",
//                    i, npc->gpr[i], ref->gpr[i]);
//         }
//     }
// }
