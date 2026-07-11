//ysyx_26020046_minirv
#include "Vysyx_26020046_minirv.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include "svdpi.h"
#include "Vysyx_26020046_minirv__Dpi.h"
#include <time.h>

#include <npcSdb.h>
#include <npcTrace.h>

VerilatedContext* contextp;//verilator上下文
Vysyx_26020046_minirv* top;//顶层模块
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

#define memSize 2048000
uint32_t M[memSize];
uint32_t runStep,pc;//运行步数
timespec startTime;//开始时间
uint32_t addrReset;//pc复位地址，用于区分0开始的内置程序和ADDR_RESET开始的外部程序
bool hasEbreak=false;//是否遇到ebreak

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
    return M[(addr-addrReset)>>2];
}
void NpcsdbRun(uint32_t times){
	minirvRun(times);
}


extern "C" int pmem_read(int raddr) {
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
	if(((((raddrX-addrReset)>>2)>=memSize)|raddrX<addrReset)|(raddrX==0)){//超出mem
		IfDebug(printf("\033[1;31merr x%x %d when x%x %d\033[0m\n",raddrX,raddr,pc,runStep););
		return 0;
	}

	NpcTraceMtrace("0x%8x r 0x%x M=0x",pc,raddrX);
	NpcTraceMtrace("%x\n",M[(raddrX-addrReset)>>2]);
	IfDebug(printf("0x%x(0x%x) >> 0x%x(0x%x):%x\n",raddr,raddr>>2,(raddrX-addrReset),(raddrX-addrReset)>>2,M[(raddrX-addrReset)>>2]););
	return M[(raddrX-addrReset) >> 2];
}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	IfDebug(printf("pmem_write : "););
	uint32_t waddrX=(uint32_t)waddr;
	if(waddrX==0x10000000){
		printf("%c",wdata);
		NpcTraceMtrace("0x%8x w 0x%x S=%c\n",pc,waddrX,wdata);
		return;
	}
	if((((waddrX-addrReset)>>2)>memSize|waddrX<=addrReset)|(waddrX==0)){
		IfDebug(printf("\033[1;31merr x%x %d when x%x %d (x%x,x%x)\033[0m\n",waddrX,waddr,pc,runStep,addrReset,memSize+addrReset););
		return;
	}
	IfDebug(printf("0x%x(0x%x) >> 0x%x(0x%x):%x<=%x with 0x%x ",waddr,waddr>>2,(waddr-addrReset),(waddr-addrReset)>>2,M[(waddr-addrReset)>>2],wdata,wmask););
	
	NpcTraceMtrace("0x%8x w 0x%x M=0x%x",pc,waddrX,wdata);
	if((wmask&0b1111)==0b1111){
		IfDebug(printf("all\n"););
		NpcTraceMtrace(" all\n");
    	M[(waddr-addrReset)>>2]=wdata;
	}else{
		IfDebug(printf("part\n"););
		NpcTraceMtrace(" part\n");
		uint32_t mask1=0xffffffff;
		uint32_t data=wdata&0xff;
		switch(wmask&0x0f){
			case 0b0001:mask1=0xffffff00;data=data    ;break;
			case 0b0010:mask1=0xffff00ff;data=data<< 8;break;
			case 0b0100:mask1=0xff00ffff;data=data<<16;break;
			case 0b1000:mask1=0x00ffffff;data=data<<24;break;
			default    :mask1=0xffffffff;data=       0;break;
		}
		uint32_t temp=M[(waddr-addrReset)>>2];
		temp&=mask1;
		temp|=data;
		M[(waddr-addrReset)>>2]=temp;
	}
	IfDebug(printf("become 0x%x(0x%x) >> 0x%x(0x%x):%x\n",waddr,waddr>>2,(waddr-addrReset),(waddr-addrReset)>>2,M[(waddr-addrReset)>>2]););
}
extern "C" void ebreak(unsigned char eb){
	printf("ebreak:");
	// printf("%x\n",getReg(0));
	// printf("%x\n",getReg(10));
	// minirvClose();
	if(eb){printf("\033[1;32mHIT GOOD TRAP\033[0m\n");hasEbreak=true;}
	else  {printf("\033[1;31mHIT BAD  TRAP\033[0m\n");hasEbreak=true;}
}


void initMem(int argc, char** argv){
	const char *defaultBin={"hex/sum.bin"};const uint32_t defaultEbAdder=0x8A;
	// const char *p={"hex/mem.bin"};const uint32_t defaultEbAdder=0x488;
    FILE *file;
	if(argc>1&&argv[1]!=NULL){
		printf("!!bin:%s ",argv[1]);
		addrReset=ADDR_RESET;
		file = fopen(argv[1],"rb");
	}else{
		printf("!!defaultBin:%s ",defaultBin);
		addrReset=0;
		file = fopen(defaultBin,"rb");
	}
	if(file==NULL){printf("can't open file\n");}
    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);
    size_t wordsRead = fread(M, sizeof(uint32_t), fileSize/sizeof(uint32_t), file);
	if(wordsRead!=fileSize/sizeof(uint32_t)){printf("can't read file\n");}
	fclose(file);
	// for(int i=0;i<16;i++){printf("M[%d]=0x%x\n",i,M[i]);}
	if(argc>1&&argv[1]!=NULL){
		if(argc>2&&argv[2]!=NULL){
			printf("ebreak at 0x%lx ",strtoul(argv[2], NULL,0));
			M[strtoul(argv[2],NULL,0)]=0x00100073;
		}
		printf("has open file\n");
	}else{
		printf("ebreak at 0x%x\n",defaultEbAdder);
    	M[defaultEbAdder] = 0x00100073;//sum
	}
}

void initDevice(int argc, char** argv){
	// IfDebug(printf("initDevice begin\n"););

	if(clock_gettime(CLOCK_MONOTONIC,&startTime)!=0){printf("time err\n");exit(-1);}

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_26020046_minirv{contextp};
	// scope=svGetScopeFromName("TOP.ysyx_26020046_minirv");
	scope=svGetScopeFromName("TOP.ysyx_26020046_minirv.DEBUG");
	svSetScope(scope);

	NpcSdbInit();
	NpcTraceInit(argv[1]);
}

void minirvReset(){
	runStep=0;
	top->pcReset=addrReset;

	top->clk=0;top->reset=1;top->eval();
	top->clk=1;top->reset=1;top->eval();

	pc=top->pc;
	top->code=M[(pc-addrReset)>>2];
	top->clk=0;top->reset=0;top->eval();
	IfDebug(printf("\n!! reset finish ");printf("pc=%d M[0]=0x%x\n\n",(pc-addrReset)>>2,M[(pc-addrReset)>>2]););
}

void minirvStep(){

	pc=top->pc;
	top->code=M[(pc-addrReset)>>2];

	uint32_t nPc=pc;
	uint32_t code=top->code;


	top->clk=1;top->eval();
	IfDebug(printf("clk up finish,npc=0x%x\n",(top->pc-addrReset)>>2););

	pc=top->pc;
	top->code=M[(pc-addrReset)>>2];
	top->clk=0;top->eval();
	IfDebug(printf("clk down finish\n");printf("runStep=%d pc=%x(%x)\n\n",runStep,pc,(pc-addrReset)>>2););
	runStep++;

	// printf("-");
	NpcTraceWrite(nPc,code,pc);

}
void minirvRun(uint32_t times){
	if(hasEbreak){printf("has ebreak.ues 'q' to exit\n");}
    else if(times==0){while(!hasEbreak){
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
#ifdef NPC_SDB
	NpcSdbMainloop();
#else
	minirvRun(0);
#endif
}

int main(int argc, char** argv) {
	initMem(argc, argv);
	initDevice(argc, argv);
	printf("\033[1;32m Init and Reset Finish Welcome to NPC \033[0m\n");
	minirvReset();

	minirvBegin();

	minirvClose();

	return hasEbreak?0:-1;
}