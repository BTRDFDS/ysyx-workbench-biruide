#include <cstdint>
#ifndef _NPC_CONFIG_
#define _NPC_CONFIG_

/* 几乎不使用
#define NPC_SDB
这4个trace是从sv版本的npc中继承过来的，但是我在chisel版本全程没有使用他们，也把相关的接口给断开了
#define NPC_I_TRACE
#define NPC_F_TRACE
#define NPC_E_TRACE
#define NPC_D_TRACE
这三个是新加的用于给各个sim获取相关的元数据的
#define NPC_I_CACHE_TRACE
#define NPC_D_CACHE_TRACE
#define NPC_BRACHE_TRACE
*/
// #define NPC_NVBroad
// #define NPC_M_TRACE
// #define NPC_DIFFTEST
// #define NPC_WAVE

const uint64_t RunstopTime = 0000;//非0时运行到该时间后停止

#endif