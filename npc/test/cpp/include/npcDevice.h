#ifndef _NPC_DEVICE_
#define _NPC_DEVICE_

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include <npcDifftest.h>//我只需要difftest
////////////////////////////////////////////////////////////////////////////////////////
bool stop=false;
uint32_t returnCode=1;
void NpcFinish(const char* msg,int code){
	printf("%s\n",msg);
	returnCode=code;
	stop=true;
}
////////////////////////////////////////////////////////////////////////////////////////
uint64_t numCycle		=0;
uint64_t numInst		=0;
uint64_t numIchHit		=0;
uint64_t numIchMiss		=0;
uint64_t numIfuInst		=0;
uint64_t numIfuStall 	=0;
uint64_t numIfuJbHit	=0;
uint64_t numIfuJbMiss	=0;
uint64_t numIduCal		=0;
uint64_t numIduJump		=0;
uint64_t numIduImm		=0;
uint64_t numIduLs		=0;
uint64_t numIduCsr		=0;
uint64_t numIduBr		=0;
uint64_t numIduMiss		=0;
uint64_t numLsuLoad		=0;
uint64_t numLsuLoadWait	=0;
uint64_t numLsuStore	=0;
uint64_t numLsuStoreWait=0;

extern "C" void ichHit()		{numIchHit++;		}
extern "C" void ichMiss()		{numIchMiss++;		}
extern "C" void ifuInst()		{numIfuInst++;		}
extern "C" void ifuStall()		{numIfuStall++;		}
extern "C" void ifuJbHit()		{numIfuJbHit++;		}
extern "C" void ifuJbMiss()		{numIfuJbMiss++;	}
extern "C" void iduCal()		{numIduCal++;		}
extern "C" void iduJump()		{numIduJump++;		}
extern "C" void iduImm()		{numIduImm++;		}
extern "C" void iduLs()			{numIduLs++;		}
extern "C" void iduCsr()		{numIduCsr++;		}
extern "C" void iduBr()			{numIduBr++;		}
extern "C" void iduMiss()		{numIduMiss++;		}
extern "C" void lsuLoad()		{numLsuLoad++;		}
extern "C" void lsuLoadWait()	{numLsuLoadWait++;	}
extern "C" void lsuStore()		{numLsuStore++;		}
extern "C" void lsuStoreWait()	{numLsuStoreWait++;	}

void printCounter(){
	printf("cycle= %ld inst= %ld IPC= %f CPI= %f\n",numCycle,numInst,((float)numInst)/((float)numCycle),((float)numCycle)/((float)numInst));//实质上是已经是next pc了
	numIchHit=numIfuInst-numIchMiss;
	printf("ich hit= %ld[%f] miss= %ld[%f] sum= %ld\n",
		numIchHit ,numIchHit /(float)numIfuInst,
		numIchMiss,numIchMiss/(float)numIfuInst,
		numIchHit+numIchMiss);
	numIfuJbHit-=numIfuJbMiss;
	printf("ifu inst = %ld wait= %ld AMAT= %f jbHit= %ld[%f] jbMiss= %ld[%f]\n",
		numIfuInst,numIfuStall,(float)((float)numIfuStall)/((float)numIfuInst),
		numIfuJbHit ,numIfuJbHit /(float)(numIfuJbHit+numIfuJbMiss),
		numIfuJbMiss,numIfuJbMiss/(float)(numIfuJbHit+numIfuJbMiss)
	);
	printf("idu cal= %ld jump= %ld imm= %ld ls= %ld csr= %ld br= %ld sum= %ld miss= %ld\n",
		numIduCal,numIduJump,numIduImm,numIduLs,numIduCsr,numIduBr,
		numIduCal+numIduJump+numIduImm+numIduLs+numIduCsr+numIduBr,
		numIduMiss
	);
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
#if defined(NPC_I_CACHE_TRACE)
	std::fstream iCacheTraceFile;//输出日志文件：
	#endif
void iCacheTraceFileInit(){
	#if defined(NPC_I_CACHE_TRACE)
		iCacheTraceFile.open("./bin/iCacheTrace.bin",std::ios::out | std::ios::binary);
		printf("./bin/iCacheTrace.bin\n");
		if(!iCacheTraceFile.is_open()) {
		printf("Failed to open iCacheTrace file!\n");
		exit(-1);
	}
	#endif
	}
void iCacheTraceFileWrite(uint32_t pc){
	#if defined(NPC_I_CACHE_TRACE)
		// logFile<<"write pc=0x"<<std::hex<<pc<<"\n";
		iCacheTraceFile.write((const char*)&pc, 4);
	#endif
	}
void iCacheTraceFileClose(){
	#if defined(NPC_I_CACHE_TRACE)
		iCacheTraceFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_D_CACHE_TRACE)
	std::fstream dCacheTraceFile;//输出日志文件：
	#endif
void dCacheTraceFileInit(){
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
void dCacheTraceFileClose(){
	#if defined(NPC_D_CACHE_TRACE)
		dCacheTraceFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_BRACHE_TRACE)
	std::fstream branchTraceFile;//输出日志文件：
	#endif
void branchTraceFileInit(){
	#if defined(NPC_BRACHE_TRACE)
	branchTraceFile.open("./bin/branchTrace.bin",std::ios::out | std::ios::binary);
	printf("./bin/branchTrace.bin\n");
	if(!branchTraceFile.is_open()) {
	printf("Failed to open branchTrace file!\n");
	exit(-1);
	}
	#endif
	}
void exuBnTrace(int pc,char state){
	#if defined(NPC_BRACHE_TRACE)
	branchTraceFile.write((const char*)&pc,		4);
	branchTraceFile.write((const char*)&state,	1);
	#endif
	}
void exuBiTrace(int pc,char state,int addr){
	#if defined(NPC_BRACHE_TRACE)
	branchTraceFile.write((const char*)&pc,		4);
	branchTraceFile.write((const char*)&state,	1);
	branchTraceFile.write((const char*)&addr,	4);
	#endif
	}
void branchTraceFileClose(){
	#if defined(NPC_BRACHE_TRACE)
		branchTraceFile.close();
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
	#include "verilated_fst_c.h"
	VerilatedFstC* tfp;//波形文件
	#endif
////////////////////////////////////////////////////////////////////////////////////////
void TraceInit(){
	iCacheTraceFileInit();
	dCacheTraceFileInit();
	branchTraceFileInit();
	}
void printOver(){
	#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
		tfp->close();
	#endif
	#ifdef NPC_NVBroad
		nvboard_quit();
	#endif
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
	iCacheTraceFileClose();
	dCacheTraceFileClose();
	branchTraceFileClose();
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

void NpcRun(uint32_t times);
void NpcWave();
////////////////////////////////////////////////////////////////////////////////////////
extern "C" void flash_read(int32_t addr, int32_t *data) {
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	#ifdef NPC_M_TRACE
	logFile<<"flash	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<numCycle;
	#endif
	// if(addrX-flashAddr>=flashSize|addrX<flashAddr){return NpcFinish("flash read error",addrX);}
	if(addrX>=flashSize)return NpcFinish("flash read error",addrX);
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
	if(addrX-mromAddr>=mromSize|addrX<mromAddr){return NpcFinish("mrom read",-2);}
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
	if(addrX>=psramSize){NpcFinish("psram read error",addrX);return 0;}
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
	if(addrX>=sdramSize){NpcFinish("sdram read error",addrX);return 0;}
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
extern "C" int getRegPc(int addr);
extern "C" int getNextPc();
extern "C" void ebreak(){
	// numInst++;
	iCacheTraceFileWrite(getRegPc(0));
	return NpcFinish("ebreak",getRegPc(10)!=0);
	}
extern "C" void wbuCheck(){
	numInst++;
	iCacheTraceFileWrite(getRegPc(0));
	if(NpcDifftestCheck(getRegPc(0)))return NpcFinish("difftest end",-1);
	}
void NpcDifftestGetGpr(uint32_t *gpr){
	if(gpr){
		for(uint32_t i=1;i<32;i++){gpr[i]=getRegPc(i);}
		gpr[0]=0;
	}else{
		printf("difftest *gpr=Null");
		stop=true;
	}
	}
////////////////////////////////////////////////////////////////////////////////////////
#endif