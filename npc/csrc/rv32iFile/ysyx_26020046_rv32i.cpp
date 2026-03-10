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

#define ADDR_RESET 0x80000000
#define timeADDR   0x0200BFF8
#define serialADDR 0x10000000

// #define DEBUG

#ifdef DEBUG
    #define IfDebug(...) do { __VA_ARGS__; } while(0)
#else
    #define IfDebug(...) ((void)0)
#endif

#define memSize 0x8000000
uint8_t mem[memSize];
uint32_t runStep,pc,code;//运行步数
timespec startTime;//开始时间
bool hasEbreak=false;//是否遇到ebreak
int result=-1;//返回值
enum memReadMode{memReadRESET,memReadSTEP,memReadREAD,memReadWRITE,memReadSDB};

uint32_t MemRead(uint32_t addr,memReadMode mode){//读取4个字节
	if(addr<ADDR_RESET|((addr-ADDR_RESET+3)>=memSize)){printf("err addr=%x@%x %x at %x\n",addr,pc,(addr-ADDR_RESET),mode);exit(-1);}
	uint32_t temp=	((uint32_t)mem[addr-ADDR_RESET])|
					(((uint32_t)mem[addr-ADDR_RESET+1])<<8)|
					(((uint32_t)mem[addr-ADDR_RESET+2])<<16)|
					(((uint32_t)mem[addr-ADDR_RESET+3])<<24);
	return temp;
}

extern "C" int getReg(int addr);//注意：0号寄存器替代为pc
void minirvClose();
void minirvRun(uint32_t times);

void NpcsdbGetGpr(){
	for(uint32_t i=0;i<32;i++){
		npcsdbGpr[i]=getReg(i);
	}
}
uint32_t NpcsdbGetReg(uint32_t addr){
    return getReg(addr);
}
uint32_t NpcsdbReadMem(uint32_t addr){
	return MemRead(addr,memReadSDB);
}
void NpcsdbRun(uint32_t times){
	minirvRun(times);
}
void NpcDifftestGetGpr(uint32_t *gpr){
	if(gpr==NULL){exit(-1);}
	for(uint32_t i=1;i<32;i++){gpr[i]=getReg(i);}
	gpr[0]=0;
}

extern "C" int pmem_read(int raddr) {//TODO
	IfDebug(printf("pmem_read : "););
	uint32_t raddrX=(uint32_t)raddr;
	// if(raddrX==0){return 0;}
	if(raddrX==timeADDR){//返回毫秒数
		NpcTraceMtrace("0x%8x r 0x%x T=",pc,raddrX);
		uint32_t time=0;
		timespec t;
		if(clock_gettime(CLOCK_MONOTONIC,&t)!=0){printf("time err\n");exit(-1);}
		time=(t.tv_sec*1000000+t.tv_nsec/1000)-(startTime.tv_sec*1000000+startTime.tv_nsec/1000);//微秒
		NpcTraceMtrace("%d\n",time);
		return time;
	}
	if(raddrX<ADDR_RESET|((raddrX-ADDR_RESET+3)>=memSize)){//超出mem
		IfDebug(printf("\033[1;31merr x%x %d when x%x %d\033[0m\n",raddrX,raddr,pc,runStep););
		return 0;
	}

	NpcTraceMtrace("0x%8x r 0x%x M=0x",pc,raddrX);
	NpcTraceMtrace("%x\n",MemRead(raddrX,memReadREAD));//TODO
	IfDebug(printf("0x%x(0x%x) >> 0x%x(0x%x):%x\n",raddr,raddr>>2,(raddrX-ADDR_RESET),(raddrX-ADDR_RESET)>>2,mem[(raddrX-ADDR_RESET)>>2]););
	return MemRead(raddrX,memReadREAD);//TODO
}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	IfDebug(printf("pmem_write : "););
	uint32_t waddrX=(uint32_t)waddr;
	if(waddrX==0x10000000){
		printf("%c",wdata);
		fflush(stdout);
		// printf("1");exit(-1);
		NpcTraceMtrace("0x%8x w 0x%x S=%c\n",pc,waddrX,wdata);
		return;
	}
	if(waddrX<ADDR_RESET|((waddrX-ADDR_RESET+3)>=memSize)){
		IfDebug(printf("\033[1;31merr x%x %d when x%x %d (x%x,x%x)\033[0m\n",waddrX,waddr,pc,runStep,ADDR_RESET,memSize+ADDR_RESET););
		printf("\033[1;31merr x%x %d when x%x %d (x%x,x%x)\033[0m\n",waddrX,waddr,pc,runStep,ADDR_RESET,memSize+ADDR_RESET);exit(-1);
		return;
	}
	IfDebug(printf("0x%x(0x%x) >> 0x%x(0x%x):%x<=%x with 0x%x ",waddr,waddr>>2,(waddr-ADDR_RESET),(waddr-ADDR_RESET)>>2,mem[(waddr-ADDR_RESET)>>2],wdata,wmask););//TODO

	NpcTraceMtrace("0x%8x w 0x%x M=0x%x [%x]",pc,waddrX,MemRead(waddrX,memReadWRITE),wmask);
	for(int i=0;i<4;i++){
		if((wmask&0x1)==1){
			uint32_t addr=(waddrX-ADDR_RESET+i);
			if(addr>=memSize){printf("err addr waddrX=%x addr=%x @%x %d\n",waddrX,addr,pc,runStep);exit(-1);}
			mem[addr]=wdata&0xff;
			wdata=wdata>>8;
			wmask=wmask>>1;
		}
	}
	NpcTraceMtrace(" become 0x%x\n",MemRead(waddrX,memReadWRITE));
	IfDebug(printf("become 0x%x(0x%x) >> 0x%x(0x%x):%x\n",waddr,waddr>>2,(waddr-ADDR_RESET),(waddr-ADDR_RESET)>>2,mem[(waddr-ADDR_RESET)>>2]););
}
extern "C" void stop(unsigned char eb){
	printf("ebreak:");
	// printf("%x\n",getReg(0));
	// printf("%x\n",getReg(10));
	// minirvClose();
	if(eb){
		if(getReg(10)==0){
			printf("\033[1;32mHIT GOOD TRAP\033[0m\n");
			hasEbreak=true;
			result=0;
			return;
		}else{
			printf("\033[1;31mHIT BAD TRAP\033[0m\n");
			hasEbreak=true;
			result=-1;
			return;
		}
	}
	printf("\033[1;31merror!!\033[0m@0x%x==%x\n",pc,code);
	hasEbreak=true;
	result=-1;
}


void initMem(int argc, char** argv){
    FILE *file;
	if(argc>1&&argv[1]!=NULL){
		printf("!!bin:%s ",argv[1]);
		file = fopen(argv[1],"rb");
	}else{printf("!!shuould input bin\n");exit(-1);}
	if(file==NULL){printf("can't open file\n");exit(-1);}
    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);
    size_t wordsRead = fread(mem, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);
	// for(int i=0;i<16;i++){printf("M[%d]=0x%x\n",i,M[i]);}
	printf("has open file\n");
}

void initDevice(int argc, char** argv){
	// IfDebug(printf("initDevice begin\n"););

	if(clock_gettime(CLOCK_MONOTONIC,&startTime)!=0){printf("time err\n");exit(-1);}

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_26020046_rv32i{contextp};
	scope=svGetScopeFromName("TOP.ysyx_26020046_rv32i.GPR");
	svSetScope(scope);

	NpcSdbInit();
	NpcTraceInit(argv[1]);
	NpcDifftestInit8(memSize,mem);//TODO

}

void minirvReset(){
	runStep=0;

	top->clk=0;top->reset=1;top->eval();
	top->clk=1;top->reset=1;top->eval();

	pc=top->pc;
	code=MemRead(pc,memReadRESET);
	top->code=code;
	top->clk=0;top->reset=0;top->eval();

	// printf("pc=%x\n",pc);
	// printf("初始化完成\n");
	// printf("code=%x\n",top->code);
	IfDebug(printf("\n!! reset finish ");printf("pc=%d M[0]=0x%x\n\n",pc,MemRead(pc,memReadRESET)););
}

void minirvStep(){
	pc=top->pc;
	code=MemRead(pc,memReadSTEP);
	top->code=code;
	uint32_t nPc=pc;
	uint32_t nCode=top->code;

	// printf("%x\n",code);
	top->clk=1;top->eval();
	IfDebug(printf("clk up finish,npc=0x%x\n",(top->pc-ADDR_RESET)>>2););

	pc=top->pc;
	// printf("step begin 3\n");
	// printf("pc=%x\n",pc);
	code=MemRead(pc,memReadSTEP);
	top->code=code;
	// printf("step begin 2\n");
	top->clk=0;top->eval();
	// printf("step begin\n");
	IfDebug(printf("clk down finish\n");printf("runStep=%d pc=%x(%x)\n\n",runStep,pc,(pc-ADDR_RESET)>>2););
	runStep++;

	// printf("step finish\n");
	NpcTraceWrite(nPc,nCode,pc);
	NpcDifftestCheck(pc);
}
void minirvRun(uint32_t times){
	// printf("times=%d\n",times);
	if(hasEbreak){printf("has ebreak.ues 'q' to exit\n");}
    else if(times==0){while(!hasEbreak){
		// printf("into while\n");
		minirvStep();
		if(NpcsdbCheck()!=0){return;}
	}}
    else for(int i=0;i<times;i++){
		minirvStep();
		if(NpcsdbCheck()!=0){return;}
	}
}

void minirvClose(){

	NpcTraceClose();

	delete top;
	delete contextp;
}

void minirvBegin(){
#ifdef DEBUG_SDB
	NpcSdbMainloop();
#else
	minirvRun(0);
#endif
}

int main(int argc, char** argv) {
	initMem(argc, argv);
	initDevice(argc, argv);
	minirvReset();

	minirvBegin();

	minirvClose();

	return hasEbreak?result:-1;
}