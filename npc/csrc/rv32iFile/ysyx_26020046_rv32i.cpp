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
const uint32_t addrTime		=0x0200BFF8;
const uint32_t addrSerial	=0x10000000;

const uint32_t memSize		=0x80000000;


uint8_t mem[memSize];
uint32_t runStep,pc,code;//运行步数
timespec startTime;//开始时间
bool hasEbreak=false;//是否遇到ebreak
int result=-1;//返回值
enum memReadMode{memReadRESET,memReadSTEP,memReadREAD,memReadWRITE,memReadSDB};

uint32_t MemRead(uint32_t addr,memReadMode mode){//读取4个字节
	if(addr<addrReset|((addr-addrReset+3)>=memSize)){printf("err addr=%x@%x %x at %x\n",addr,pc,(addr-addrReset),mode);exit(-1);}
	uint32_t temp=	( (uint32_t)mem[addr-addrReset+0]		)|
					(((uint32_t)mem[addr-addrReset+1])<<8	)|
					(((uint32_t)mem[addr-addrReset+2])<<16	)|
					(((uint32_t)mem[addr-addrReset+3])<<24	);
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

extern "C" int pmem_read(int raddr) {
	uint32_t raddrX=(uint32_t)raddr;
	if(raddrX==addrTime){//返回毫秒数
		NpcTraceMtrace("0x%8x r 0x%x T=",pc,raddrX);
		uint32_t time=0;
		timespec t;
		if(clock_gettime(CLOCK_MONOTONIC,&t)!=0){printf("time err\n");exit(-1);}
		time=(t.tv_sec*1000000+t.tv_nsec/1000)-(startTime.tv_sec*1000000+startTime.tv_nsec/1000);//微秒
		NpcTraceMtrace("%d\n",time);
		return time;
	}else if(raddrX<addrReset|((raddrX-addrReset+3)>=memSize)){return 0;
	}else{
		NpcTraceMtrace("0x%8x r 0x%x M=0x",pc,raddrX);
		NpcTraceMtrace("%x\n",MemRead(raddrX,memReadREAD));
		return MemRead(raddrX,memReadREAD);
	}
}

extern "C" void pmem_write(int waddr, int wData, char wMask) {
	uint32_t waddrX=(uint32_t)waddr;
	if(waddrX==0x10000000){
		printf("%c",wData);
		fflush(stdout);
		NpcTraceMtrace("0x%8x w 0x%x S=%c\n",pc,waddrX,wData);
		return;
	}
	if(waddrX<addrReset||((waddrX-addrReset+3)>=memSize)){
		printf("\033[1;31m pmem_write:err x%x %d when x%x %d (x%x,x%x)\033[0m\n",waddrX,waddr,pc,runStep,addrReset,memSize+addrReset);
		exit(-1);
	}

	NpcTraceMtrace("0x%8x w 0x%x M=0x%x [%x]",pc,waddrX,MemRead(waddrX,memReadWRITE),wMask);
	for(int i=0;i<4;i++){
		if((wMask&0x1)==1){
			mem[(waddrX-addrReset+i)]=wData&0xff;
			wData=wData>>8;
			wMask=wMask>>1;
		}
	}
	NpcTraceMtrace(" become 0x%x\n",MemRead(waddrX,memReadWRITE));
}
extern "C" void stop(unsigned char eb){
	printf("ebreak:");
	// printf("%x\n",getReg(0));
	// printf("%x\n",getReg(10));
	// minirvClose();
	if(eb){
		if(getReg(10)==0){
			printf("\033[1;32mHIT GOOD TRAP\033[0mat 0x%x %d\n",pc,runStep);
			hasEbreak=true;
			result=0;
			return;
		}else{
			printf("\033[1;31mHIT BAD TRAP\033[0mat 0x%x %d\n",pc,runStep);
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
	top->code=code;//IFU
	top->clk=0;top->reset=0;top->eval();

	// printf("pc=%x\n",pc);
	// printf("初始化完成\n");
	// printf("code=%x\n",top->code);
}

void minirvStep(){
	pc=top->pc;
	// printf("pc=%x\n",pc);
	code=MemRead(pc,memReadSTEP);
	top->code=code;//IFU
	uint32_t nPc=pc;
	uint32_t nCode=code;

	// printf("%x\n",code);
	top->clk=1;top->eval();

	pc=top->pc;
	// printf("step begin 3\n");
	// printf("pc=%x\n",pc);
	code=MemRead(pc,memReadSTEP);
	top->code=code;//IFU
	// printf("step begin 2\n");
	top->clk=0;top->eval();
	// printf("step begin\n");
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
	printf("\033[1;32m Init and Reset Finish Welcome to NPC \033[0m\n");

	minirvBegin();

	minirvClose();

	return hasEbreak?result:-1;
}