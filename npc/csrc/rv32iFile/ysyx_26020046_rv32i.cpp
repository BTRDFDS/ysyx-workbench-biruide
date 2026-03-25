//ysyx_26020046_rv32i
#include "Vysyx_26020046_rv32i.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include "svdpi.h"
#include "Vysyx_26020046_rv32i__Dpi.h"
#include <time.h>

#include <npcSdb.h>
#include <npcTrace.h>
#include <npcDifftest.h>

VerilatedContext* contextp;//verilator上下文
Vysyx_26020046_rv32i* top;//顶层模块
svScope scope;//作用域

const uint32_t addrReset	=0x80000000;
const uint32_t addrtimer	=0x10000000;
const uint32_t addrSerial	=0x10000000;

const uint32_t memSize=0x8000000;

uint8_t mem[memSize];
uint32_t runStep,pc;
timespec startTime;//开始时间
bool npcFinishHad=false;
int npcFinishCode=-1;
enum memReadMode{memReadRESET,memReadSTEP,memReadREAD,memReadWRITE,memReadSDB};

void NpcError();
void NpcEbreak(int returnCode);
void NpcReturn(int returnCode);
void NpcRun(uint32_t times);
uint32_t NpcMemRead(uint32_t addr,memReadMode mode);

////////////////////////////////////////////////////////////////////////////////////////
extern "C" int getReg(int addr);//注意：0号寄存器替代为pc
extern "C" int pmem_read(uint32_t raddr) {
	if(raddr==addrtimer){//返回毫秒数
		NpcTraceMtrace("0x%8x r 0x%x T=",pc,raddr);
		uint32_t time=0;
		timespec t;
		if(clock_gettime(CLOCK_MONOTONIC,&t)!=0){printf("time err\n");NpcError();}
		time=(t.tv_sec*1000000+t.tv_nsec/1000)-(startTime.tv_sec*1000000+startTime.tv_nsec/1000);//微秒
		NpcTraceMtrace("%d\n",time);
		return time;
	}else if(raddr<addrReset|((raddr-addrReset+3)>=memSize)){//超出mem
		// printf("\033[1;31merr x%x %d when x%x %d\033[0m\n",raddr,raddr,pc,runStep);NpcError();
		return 0;
	}else{
		NpcTraceMtrace("0x%8x r 0x%x M=0x",pc,raddr);
		NpcTraceMtrace("%x\n",NpcMemRead(raddr,memReadREAD));
		return NpcMemRead(raddr,memReadREAD);
	}
}
extern "C" void pmem_write(uint32_t wAddr, uint32_t wData, char wMask) {
	if(wAddr==0x10000000){
		NpcTraceMtrace("0x%8x w 0x%x S=%c\n",pc,wAddr,wData);
		printf("%c",wData);
		fflush(stdout);
		return;
	}else if(wAddr<addrReset|((wAddr-addrReset+3)>=memSize)){
		printf("\033[1;31merr x%x %d when x%x %d (x%x,x%x)\033[0m\n",wAddr,wAddr,pc,runStep,addrReset,memSize+addrReset);
		NpcError();
	}else{
		NpcTraceMtrace("0x%8x w 0x%x M=0x%x [%x]",pc,wAddr,NpcMemRead(wAddr,memReadWRITE),wMask);
		for(int i=0;i<4;i++){
			if((wMask&0x1)==1){
				mem[wAddr-addrReset+i]=wData&0xff;
				wData=wData>>8;
				wMask=wMask>>1;
			}
		}
		NpcTraceMtrace(" become 0x%x\n",NpcMemRead(wAddr,memReadWRITE));
	}
}
extern "C" void stop(unsigned char eb){
	printf("ebreak:");
	if(eb){
		if(getReg(10)==0){
			printf("\033[1;32m HIT GOOD TRAP \033[0m at 0x %x %d\n",pc,runStep);
			NpcEbreak(0);
		}else{
			printf("\033[1;31m HIT BAD TRAP \033[0m at 0x %x %d\n",pc,runStep);
			NpcEbreak(-1);
		}
	}else{
		printf("\033[1;31m error!! \033[0m at 0x %x\n",pc);
		NpcEbreak(-1);
	}
}
////////////////////////////////////////////////////////////////////////////////////////
void NpcsdbGetGpr(){
	for(uint32_t i=0;i<32;i++){
		npcsdbGpr[i]=getReg(i);
	}
}
uint32_t NpcsdbGetReg(uint32_t addr){
    return getReg(addr);
}
uint32_t NpcsdbReadMem(uint32_t addr){
	return NpcMemRead(addr,memReadSDB);
}
void NpcsdbRun(uint32_t times){
	NpcRun(times);
}
void NpcDifftestGetGpr(uint32_t *gpr){
	if(gpr==NULL){NpcError();}
	for(uint32_t i=1;i<32;i++){gpr[i]=getReg(i);}
	gpr[0]=0;
}
////////////////////////////////////////////////////////////////////////////////////////
uint32_t NpcMemRead(uint32_t addr,memReadMode mode){//读取4个字节
	if(addr<addrReset|((addr-addrReset+3)>=memSize)){
		printf("err addr=%x@%x %x at %x\n",addr,pc,(addr-addrReset),mode);
		NpcError();
		return 0;
	}else{
		uint32_t temp=
		((uint32_t)mem[addr-addrReset+0]<< 0)|
		((uint32_t)mem[addr-addrReset+1]<< 8)|
		((uint32_t)mem[addr-addrReset+2]<<16)|
		((uint32_t)mem[addr-addrReset+3]<<24);
		return temp;
	}
}
void NpcInitMem(int argc, char** argv){
    FILE *file;
	if(argc>1&&argv[1]!=NULL){
		printf("!!bin:%s ",argv[1]);
		file = fopen(argv[1],"rb");
	}else{
		printf("!!shuould input bin\n");
		NpcError();
	}
	if(file==NULL){printf("can't open file\n");NpcError();}

    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);
    size_t wordsRead = fread(mem, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);
	// for(int i=0;i<16;i++){printf("M[%d]=0x%x\n",i,M[i]);}
	printf("has open file\n");
}
void NpcInitDevice(int argc, char** argv){
	if(clock_gettime(CLOCK_MONOTONIC,&startTime)!=0){printf("time err\n");NpcError();}

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_26020046_rv32i{contextp};
	scope=svGetScopeFromName("TOP.ysyx_26020046_rv32i.GPR");
	svSetScope(scope);

	NpcSdbInit();
	NpcTraceInit(argv[1]);
	NpcDifftestInit8(memSize,mem);
}
void NpcReset(){
	top->clk=0;top->reset=1;top->eval();
	top->clk=1;top->reset=1;top->eval();

	pc=top->pc;
	top->code=NpcMemRead(pc,memReadRESET);
	top->clk=0;top->reset=0;top->eval();
	runStep=0;
}
void NpcStep(){
	pc=top->pc;
	top->code=NpcMemRead(pc,memReadSTEP);
	uint32_t nPc=top->pc;
	uint32_t nCode=top->code;
	top->clk=1;top->eval();

	pc=top->pc;
	top->code=NpcMemRead(pc,memReadSTEP);
	top->clk=0;top->eval();
	runStep++;

	NpcTraceWrite(nPc,nCode,pc);
	NpcDifftestCheck(pc);
}
void NpcRun(uint32_t times){
	if(npcFinishHad){printf("has ebreak.ues 'q' to exit\n");}
    else if(times==0){
		while(!npcFinishHad){
			NpcStep();
			if(NpcsdbCheck()!=0){return;}
		}
	}else for(int i=0;i<times;i++){
		NpcStep();
		if(NpcsdbCheck()!=0){return;}
	}
}
void NpcError(){
	NpcReturn(-1);
}
void NpcEbreak(int returnCode){
#ifdef NPC_SDB
	npcFinishCode=returnCode;
	npcFinishHad=1;
#else
	NpcReturn(returnCode);
#endif
}
void NpcReturn(int returnCode){
	NpcTraceClose();
	delete top;
	delete contextp;
	exit(returnCode);
}
void NpcBegin(){
	printf("\033[1;32m Welcome to NPC[\033[1;36m%s %s\033[1;32m] \033[0m\n",__DATE__,__TIME__);
#ifdef NPC_SDB
	NpcSdbMainloop();
	if(npcFinishHad==false){
		printf("\033[1;33m NPC hasn't ebreak,return 0 \033[0m\n");
		NpcReturn(0);
	}else{
		NpcReturn(npcFinishCode);
	}
#else
	NpcRun(0);
#endif
}
////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
	NpcInitMem(argc, argv);
	NpcInitDevice(argc, argv);
	NpcReset();
	NpcBegin();
	NpcReturn(-1);
	return -1;
}