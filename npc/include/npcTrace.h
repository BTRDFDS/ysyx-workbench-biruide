#ifndef _NPC_TRACE_H_
#define _NPC_TRACE_H_
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>

#include <capstone/capstone.h>

#define NPC_I_TRACE
#define NPC_M_TRACE
#define NPC_F_TRACE



extern FILE *npctraceIringsFp;
extern FILE *npctraceMtraceFp;
extern FILE *npctraceFtraceFp;

extern void NpcTraceInit();
extern void NpcTraceClose();

#endif