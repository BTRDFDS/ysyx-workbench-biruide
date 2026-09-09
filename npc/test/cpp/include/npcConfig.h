#include <cstdint>
#ifndef _NPC_CONFIG_
#define _NPC_CONFIG_

#define NPC_SDB
/* 几乎不使用
#define NPC_I_TRACE
#define NPC_F_TRACE
#define NPC_E_TRACE
#define NPC_D_TRACE
#define NPC_I_CACHE_TRACE
#define NPC_D_CACHE_TRACE
#define NPC_BRACHE_TRACE
*/
// #define NPC_NVBroad
#define NPC_M_TRACE
#define NPC_DIFFTEST
#define NPC_WAVE

const uint64_t RunstopTime = 0000;//非0时运行到该时间后停止

#endif