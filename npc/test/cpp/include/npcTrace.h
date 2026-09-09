#ifndef _NPC_TRACE_H_
#define _NPC_TRACE_H_
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <string.h>
#include "capstone/capstone.h"

#include "npcConfig.h"
#include "npcDrive.h"

// #define NPC_I_TRACE
// #define NPC_M_TRACE
// #define NPC_F_TRACE
// #define NPC_E_TRACE

#define npcTraceIringSize 256
#define npcTraceIringMax 16

// extern FILE *npctraceIringsFp;
// extern FILE *npctraceFtraceFp;
// extern FILE *npctraceEtraceFp;

extern void NpcTraceInit(char *argv);
extern void NpcTraceClose();
extern void NpcTraceWrite(uint32_t pc,uint32_t incode,uint32_t dnpc);
extern void NpcTraceDtrace(const char *format, ...);

extern void NpcTraceInitElf(char *img_file);
extern char *getFuncName(uint32_t addr);



////////////////////////////////////////////////////////////////////////////////////////
#ifdef NPC_M_TRACE
	inline std::fstream logFile;//输出日志文件：
	#endif
inline void logFileInit(const char* logFileName){
	#if defined(NPC_M_TRACE)
		logFile.open(logFileName,std::ios::out);
		if(!logFile.is_open()) {
		printf("Failed to open log file!\n");
		exit(-1);
	}
	#endif
	}
inline void logFileClose(){
	#if defined(NPC_M_TRACE)
		logFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_I_CACHE_TRACE)
	std::fstream iCacheTraceFile;//输出日志文件：
	#endif
inline void iCacheTraceFileInit(){
	#if defined(NPC_I_CACHE_TRACE)
		iCacheTraceFile.open("./bin/iCacheTrace.bin",std::ios::out | std::ios::binary);
		printf("./bin/iCacheTrace.bin\n");
		if(!iCacheTraceFile.is_open()) {
		printf("Failed to open iCacheTrace file!\n");
		exit(-1);
	}
	#endif
	}
inline void iCacheTraceFileWrite(uint32_t pc){
	#if defined(NPC_I_CACHE_TRACE)
		// logFile<<"write pc=0x"<<std::hex<<pc<<"\n";
		iCacheTraceFile.write((const char*)&pc, 4);
	#endif
	}
inline void iCacheTraceFileClose(){
	#if defined(NPC_I_CACHE_TRACE)
		iCacheTraceFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_D_CACHE_TRACE)
	std::fstream dCacheTraceFile;//输出日志文件：
	#endif
inline void dCacheTraceFileInit(){
	#if defined(NPC_D_CACHE_TRACE)
		dCacheTraceFile.open("./bin/dCacheTrace.bin",std::ios::out | std::ios::binary);
		printf("./bin/dCacheTrace.bin\n");
		if(!dCacheTraceFile.is_open()) {
		printf("Failed to open dCacheTrace file!\n");
		exit(-1);
	}
	#endif
	}
extern "C" void lsuTrace(int addr){
	#if defined(NPC_D_CACHE_TRACE)
	uint32_t addrX=(uint32_t)addr;
		dCacheTraceFile.write((const char*)&addrX, 4);
	#endif
	}
inline void dCacheTraceFileClose(){
	#if defined(NPC_D_CACHE_TRACE)
		dCacheTraceFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_BRACHE_TRACE)
	std::fstream branchTraceFile;//输出日志文件：
	#endif
inline void branchTraceFileInit(){
	#if defined(NPC_BRACHE_TRACE)
	branchTraceFile.open("./bin/branchTrace.bin",std::ios::out | std::ios::binary);
	printf("./bin/branchTrace.bin\n");
	if(!branchTraceFile.is_open()) {
	printf("Failed to open branchTrace file!\n");
	exit(-1);
	}
	#endif
	}
extern "C" void exuBnTrace(int pc,char state){
	#if defined(NPC_BRACHE_TRACE)
	branchTraceFile.write((const char*)&pc,		4);
	branchTraceFile.write((const char*)&state,	1);
	#endif
	}
extern "C" void exuBiTrace(int pc,char state,int addr){
	#if defined(NPC_BRACHE_TRACE)
	branchTraceFile.write((const char*)&pc,		4);
	branchTraceFile.write((const char*)&state,	1);
	branchTraceFile.write((const char*)&addr,	4);
	#endif
	}
inline void branchTraceFileClose(){
	#if defined(NPC_BRACHE_TRACE)
		branchTraceFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
inline void TraceInit(){
	iCacheTraceFileInit();
	dCacheTraceFileInit();
	branchTraceFileInit();
	}
#endif