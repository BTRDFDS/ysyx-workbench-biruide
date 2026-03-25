#ifndef _NPC_TRACE_H_
#define _NPC_TRACE_H_
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>

#include <capstone/capstone.h>

// #define NPC_I_TRACE
// #define NPC_M_TRACE
#define NPC_F_TRACE
#define NPC_E_TRACE

#define npcTraceIringSize 256
#define npcTraceIringMax 16

extern FILE *npctraceIringsFp;
extern FILE *npctraceMtraceFp;
extern FILE *npctraceFtraceFp;
extern FILE *npctraceEtraceFp;

extern void NpcTraceInit(char *argv);
extern void NpcTraceClose();
extern void NpcTraceWrite(uint32_t pc,uint32_t incode,uint32_t dnpc);
extern void NpcTraceMtrace(const char *format, ...);

extern void NpcTraceInitElf(char *img_file);
extern char *getFuncName(uint32_t addr);
#endif