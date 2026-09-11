#ifndef _NPC_DEVICE_
#define _NPC_DEVICE_

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <string>
#include <stdint.h>
////////////////////////////////////////////////////////////////////////////////////////
inline uint32_t regs[32]{};
#include "npcCounter.h"
#include "npcTrace.h"
#include "npcMem.h"
#include "npcDifftest.h"//我只需要difftest
#include "npcSdb.h"
#include "npcSdbTrace.h"
////////////////////////////////////////////////////////////////////////////////////////
inline bool stop=false;
inline uint32_t returnCode=1;
inline void NpcFinish(const char* msg,int code){
	printf("%s\n",msg);
	returnCode=code;
	stop=true;
	}
inline void printOver(){
	printCounter();
	const char *regsName[] = {
	"pc", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
	"a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
	"s8", "s9", "sA", "sB", "t3", "t4", "t5", "t6"
	};//A=10 B=11
	if(returnCode!=0){
		for(int i=0;i<32;i++){
			printf("[%2d %s]%8x ",i,regsName[i],regs[i]);
			if(i%8==7)printf("\n");
		}
	}
	logFileClose();
	iCacheTraceFileClose();
	dCacheTraceFileClose();
	branchTraceFileClose();
	}


extern void NpcRun();
void NpcToDrive(const char* logFileName,char *argv){
	logFileInit(logFileName);
	TraceInit();
	NpcTraceInit(argv);
	printf("\033[1;32m begin \033[0m\n");
	#ifdef NPC_SDB
		NpcSdbInit();
		NpcSdbMainloop();
	#else
		for(numCycle=0;(numCycle<RunstopTime||RunstopTime==0)&&(!stop);numCycle++){NpcRun();}
	#endif
	NpcTraceClose();
	printOver();
}
void NpcsdbRun(uint32_t times){
	for(uint32_t i=0;(i<times||times==0)&&(!stop)&&NpcsdbCheck();i++){NpcRun();numCycle++;}
}
////////////////////////////////////////////////////////////////////////////////////////
extern "C" void ebreakStop(){
	iCacheTraceFileWrite(regs[0]);
	return NpcFinish("ebreak",regs[10]!=0);
	}
extern "C" void wbuCheck(int dnpc,int pc,char addr,int value){
	numInst++;
	regs[addr]=value;
	regs[0]=pc;
	NpcTraceWrite(pc,NpcsdbReadMem(pc),dnpc);
	iCacheTraceFileWrite(regs[0]);
	if(NpcDifftestCheck(dnpc))return NpcFinish("difftest end",-1);
	}
////////////////////////////////////////////////////////////////////////////////////////
#endif