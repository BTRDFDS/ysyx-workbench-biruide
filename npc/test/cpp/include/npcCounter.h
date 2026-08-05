#ifndef _NPC_COUNTER_
#define _NPC_COUNTER_

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include <npcDifftest.h>//我只需要difftest
////////////////////////////////////////////////////////////////////////////////////////
uint64_t numCycle		=0;
uint64_t numInst		=0;
uint64_t numIchHit		=0;
uint64_t numIchWait		=0;
uint64_t numIchMiss		=0;
uint64_t numIchAccess	=0;
uint64_t numIchReady	=0;
uint64_t numIchPenalty	=0;
uint64_t numIfuInst		=0;
uint64_t numIfuStall 	=0;
uint64_t numIfuForward	=0;
uint64_t numIfuBackward	=0;
uint64_t numIfuJump		=0;
uint64_t numIduCal		=0;
uint64_t numIduJump		=0;
uint64_t numIduImm		=0;
uint64_t numIduLs		=0;
uint64_t numIduCsr		=0;
uint64_t numIduBr		=0;
uint64_t numExuDone		=0;
uint64_t numLsuLoad		=0;
uint64_t numLsuLoadWait	=0;
uint64_t numLsuStore	=0;
uint64_t numLsuStoreWait=0;

extern "C" void ichHit()		{numIchHit++;		}
extern "C" void ichWait()		{numIchWait++;		}
extern "C" void ichMiss()		{numIchMiss++;		}
extern "C" void ichAccess()		{numIchAccess++;	}
extern "C" void ichReady()		{numIchReady++;		}
extern "C" void ichPenalty()	{numIchPenalty++;	}
extern "C" void ifuInst()		{numIfuInst++;		}
extern "C" void ifuStall()		{numIfuStall++;		}
extern "C" void ifuForward()	{numIfuForward++;	}
extern "C" void ifuBackward()	{numIfuBackward++;	}
extern "C" void ifuJump()		{numIfuJump++;		}
extern "C" void iduCal()		{numIduCal++;		}
extern "C" void iduJump()		{numIduJump++;		}
extern "C" void iduImm()		{numIduImm++;		}
extern "C" void iduLs()			{numIduLs++;		}
extern "C" void iduCsr()		{numIduCsr++;		}
extern "C" void iduBr()			{numIduBr++;		}
extern "C" void exuDone()		{numExuDone++;		}
extern "C" void lsuLoad()		{numLsuLoad++;		}
extern "C" void lsuLoadWait()	{numLsuLoadWait++;	}
extern "C" void lsuStore()		{numLsuStore++;		}
extern "C" void lsuStoreWait()	{numLsuStoreWait++;	}

void printCounter(){
	printf("cycle= %ld inst= %ld IPC= %f CPI= %f\n",numCycle,numInst,((float)numInst)/((float)numCycle),((float)numCycle)/((float)numInst));//实质上是已经是next pc了
	printf("ich hit= %ld wait= %ld miss= %ld Hp= %f Mp= %f Access= %ld Ready= %ld Penalty= %ld ApH= %f PpM= %f AMAT =%f\n",numIchHit,numIchWait,numIchMiss,
	((float)numIchHit)/((float)numIfuInst),((float)numIchMiss)/((float)numIfuInst),
	numIchAccess,numIchReady,numIchPenalty,
	((float)numIchAccess)/((float)numIchHit),((float)numIchPenalty)/((float)numIchMiss),
	(numIchAccess+numIchPenalty)/((float)numIfuInst)
	);
	printf("ich ture hit= %ld miss= %ld Hp= %f Mp= %f Access= %ld Penalty= %ld \n",
		numIchHit-numIchWait,numIchMiss+numIchWait,
	((float)(numIchHit-numIchWait))/((float)numIfuInst),((float)(numIchMiss+numIchWait))/((float)numIfuInst),
	numIchAccess-numIchWait,numIchPenalty+numIchWait
	);
	printf("ifu inst = %ld wait= %ld WpI= %f jump= %ld for= %ld back= %ld fpj= %f bpj= %f\n",
		numIfuInst,numIfuStall,(float)((float)numIfuStall)/((float)numIfuInst),
		numIfuJump,numIfuForward,numIfuBackward,
		((float)numIfuForward)/(float)(numIfuJump),
		((float)numIfuBackward)/(float)(numIfuJump)
	);
	printf("idu cal= %ld jump= %ld imm= %ld ls= %ld csr= %ld br= %ld sum= %ld\n",
		numIduCal,numIduJump,numIduImm,numIduLs,numIduCsr,numIduBr,
		numIduCal+numIduJump+numIduImm+numIduLs+numIduCsr+numIduBr
	);
	printf("exu done= %ld\n",numExuDone);
	printf("lsu load= %ld loadWait= %ld WpL= %f\n",numLsuLoad,numLsuLoadWait,(float)((float)numLsuLoadWait)/((float)numLsuLoad));
	printf("lsu store= %ld storeWait= %ld WpS= %f\n",numLsuStore,numLsuStoreWait,(float)((float)numLsuStoreWait)/((float)numLsuStore));
}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_M_TRACE) || defined(NPC_MIN_TRACE)
	std::fstream logFile;//输出日志文件：
	#endif
void logFileInit(const char* logFileName){
	#if defined(NPC_M_TRACE) || defined(NPC_MIN_TRACE)
		logFile.open(logFileName,std::ios::out);
		if(!logFile.is_open()) {
		printf("Failed to open log file!\n");
		exit(-1);
	}
	#endif
	}
void logFileClose(){
	#if defined(NPC_M_TRACE) || defined(NPC_MIN_TRACE)
		logFile.close();
	#endif
}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_I_PC_TRACE)
	std::fstream iPcTraceFile;//输出日志文件：
	#endif
void iPcTraceFileInit(){
	#if defined(NPC_I_PC_TRACE)
		iPcTraceFile.open("./bin/iPcTrace.bin",std::ios::out | std::ios::binary);
		printf("./bin/iPcTrace.bin\n");
		if(!iPcTraceFile.is_open()) {
		printf("Failed to open iPcTrace file!\n");
		exit(-1);
	}
	#endif
	}
void iPcTraceFileWrite(uint32_t pc){
	#if defined(NPC_I_PC_TRACE)
		// logFile<<"write pc=0x"<<std::hex<<pc<<"\n";
		iPcTraceFile.write((const char*)&pc, 4);
	#endif
	}
void iPcTraceFileClose(){
	#if defined(NPC_I_PC_TRACE)
		iPcTraceFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
	#include "verilated_fst_c.h"
	VerilatedFstC* tfp;//波形文件
	#endif
////////////////////////////////////////////////////////////////////////////////////////
void printOver(const char* msg,int returnCode){
	#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
		tfp->close();
	#endif
	#ifdef NPC_NVBroad
		nvboard_quit();
	#endif
	printf("%s pc=0x %x\n",msg,getRegPc(0)-4);//实质上是已经是next pc了
	printCounter();

	const char *regsName[] = {
	"pc", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
	"a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
	"s8", "s9", "sA", "sB", "t3", "t4", "t5", "t6"
	};//A=10 B=11
	if(returnCode!=0){
		for(int i=0;i<32;i++){
			printf("[%2d %s]%8x ",i,regsName[i],getRegPc(i));
			if(i%8==7)printf("\n");
		}
	}
	logFileClose();
	iPcTraceFileClose();
}
////////////////////////////////////////////////////////////////////////////////////////
const uint32_t psramAddr	=0x80000000;
const uint32_t psramSize	=0x00ffffff;//psram极限地址是bfff_ffff
uint8_t psram[psramSize];

const uint32_t sdramAddr	=0xa0000000;
const uint32_t sdramSize	=0x07ffffff;//2+12+10+2
uint8_t sdram[sdramSize];

const uint32_t mromAddr		=0x20000000;//mrom起始地址
const uint32_t mromSize		=0xfff;
uint8_t mrom[mromSize];


const uint32_t flashAddr	=0x30000000;
const uint32_t flashSize	=0x00ffffff;//flash极限地址是bfff_ffff
uint8_t flash[flashSize];

void NpcEbreak(int returnCode);
void NpcRun(uint32_t times);
void NpcReturn(const char* msg,int returnCode);
void NpcWave();
////////////////////////////////////////////////////////////////////////////////////////
extern "C" void flash_read(int32_t addr, int32_t *data) {
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	#ifdef NPC_M_TRACE
	logFile<<"flash	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle;
	#endif
	// if(addrX-flashAddr>=flashSize|addrX<flashAddr){NpcReturn("flash read error",addrX);}
	if(addrX>=flashSize)NpcReturn("flash read error",addrX);
	uint32_t temp=
		((uint32_t)flash[addrX+0]<< 0)|
		((uint32_t)flash[addrX+1]<< 8)|
		((uint32_t)flash[addrX+2]<<16)|
		((uint32_t)flash[addrX+3]<<24);
	*data=temp;
	#ifdef NPC_M_TRACE
		logFile<<" => "<<std::hex<<temp<<std::endl;
	#endif
	}
extern "C" void mrom_read(int32_t addr, int32_t *data) {
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	if(addrX-mromAddr>=mromSize|addrX<mromAddr){NpcReturn("mrom read",-2);}
	uint32_t temp=
		((uint32_t)mrom[addrX-mromAddr+0]<< 0)|
		((uint32_t)mrom[addrX-mromAddr+1]<< 8)|
		((uint32_t)mrom[addrX-mromAddr+2]<<16)|
		((uint32_t)mrom[addrX-mromAddr+3]<<24);
	*data=temp;
	#ifdef NPC_M_TRACE
	logFile<<"mrom	R "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle<<" => "<<std::hex<<temp<<std::endl;
	#endif
	}
extern "C" int psram_read(int32_t addr){
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	#if defined(NPC_M_TRACE)
		logFile<<"psram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle;
	#elif defined(NPC_MIN_TRACE)
		// if(numCycle >= NpcMinTraceBegin)logFile<<std::hex<<getRegPc(0)<<"\n";
		// if((addr&0xfffffff0) == (0xa00164b4&0xfffffff0))logFile<<"psram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle;
	#endif
	if(addrX>=psramSize)NpcReturn("psram read error",addrX);
	uint32_t temp=
		((uint32_t)psram[addrX+0]<< 0)|
		((uint32_t)psram[addrX+1]<< 8)|
		((uint32_t)psram[addrX+2]<<16)|
		((uint32_t)psram[addrX+3]<<24);
	#ifdef NPC_M_TRACE
		logFile<<" => "<<std::hex<<temp<<std::endl;
	#endif
	return temp;
	}
extern "C" void psram_write(int addr,int data){
	uint32_t addrX=(uint32_t)addr;
	#if defined(NPC_M_TRACE)
		logFile<<"Psram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle<<" "<<std::hex<<data<<" => ";
	#elif defined(NPC_MIN_TRACE)
		// if((addr&0x00fffff0) == (0xa00164b4&0x00fffff0))logFile<<"Psram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle<<" "<<std::hex<<data<<" => ";
	#endif
	psram[addrX+0]=(uint8_t)(data&0xff);
	#if defined(NPC_M_TRACE)
		logFile<<std::hex<<(uint32_t)psram[addrX+0]<<std::endl;
	#elif defined(NPC_MIN_TRACE)
		// if((addr&0x00fffff0) == (0xa00164b4&0x00fffff0))logFile<<std::hex<<(uint32_t)psram[addrX+0]<<"\n";
	#endif
	}
extern "C" int sdram_read(int32_t addr){
	uint32_t addrX=((uint32_t)addr);
	#if defined(NPC_M_TRACE)
		logFile<<"sdram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle;
	#elif defined(NPC_MIN_TRACE)
		if(numCycle >= NpcMinTraceBegin)logFile<<"sdram	R "<<std::hex<<getRegPc(0)<<"\n";
		if((addr&0x00fffff0) == (0xa00164b4&0x00fffff0) || numCycle >= NpcMinTraceBegin)logFile<<"sdram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle;
	#endif
	if(addrX>=sdramSize)NpcReturn("sdram read error",addrX);
	uint32_t temp=
		((uint32_t)sdram[addrX+0]<< 0)|
		((uint32_t)sdram[addrX+1]<< 8)|
		((uint32_t)sdram[addrX+2]<<16)|
		((uint32_t)sdram[addrX+3]<<24);
	#ifdef NPC_M_TRACE
		logFile<<" => "<<std::hex<<temp<<std::endl;
	#elif defined(NPC_MIN_TRACE)
		if((addr&0x00fffff0) == (0xa00164b4&0x00fffff0) || numCycle >= NpcMinTraceBegin)logFile<<" => "<<std::hex<<temp<<std::endl;
	#endif
	return temp;
	}
extern "C" void sdram_write(int addr,int data){
	uint32_t addrX=(uint32_t)addr;
	#if defined(NPC_M_TRACE)
		logFile<<"sdram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle<<" "<<std::hex<<data<<" => ";
	#elif defined(NPC_MIN_TRACE)
		if((addr&0x00fffff0) == (0xa00164b4&0x00fffff0) || numCycle >= NpcMinTraceBegin)logFile<<"sdram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle<<" "<<std::hex<<data<<" => ";
	#endif
	sdram[addrX+0]=(uint8_t)(data&0xff);
	#if defined(NPC_M_TRACE)
		logFile<<std::hex<<(uint32_t)sdram[addrX+0]<<std::endl;
	#elif defined(NPC_MIN_TRACE)
		if((addr&0x00fffff0) == (0xa00164b4&0x00fffff0) || numCycle >= NpcMinTraceBegin)logFile<<std::hex<<(uint32_t)sdram[addrX+0]<<std::endl;
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
extern void NpcReturn(const char* msg,int returnCode);
extern "C" int getRegPc(int addr);
extern "C" void ebreak(){
	numInst++;numIduCsr++;
	iPcTraceFileWrite(getRegPc(0));
	NpcReturn("\nebreak",getRegPc(10)!=0);
	}
extern "C" void wbuCheck(){
	numInst++;
	iPcTraceFileWrite(getRegPc(0));
	if(NpcDifftestCheck(getRegPc(0)))NpcReturn("difftest",-1);
	}
////////////////////////////////////////////////////////////////////////////////////////
#endif