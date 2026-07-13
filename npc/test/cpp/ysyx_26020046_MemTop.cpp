//ysyx_26020046_MemTop
#include "Vysyx_26020046_MemTop.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream.h>
#include <stdint.h>
#include "svdpi.h"
#include "Vysyx_26020046_MemTop__Dpi.h"
#include <time.h>
#include <npcDifftest.h>//我只需要difftest

VerilatedContext* contextp;//verilator上下文
Vysyx_26020046_MemTop* top;//顶层模块
svScope scope;//作用域
#define NPC_WAVE
#ifdef NPC_WAVE
	#include "verilated_fst_c.h"
	VerilatedFstC* tfp;//波形文件
#endif
////////////////////////////////////////////////////////////////////////////////////////
//输出日志文件：
std::fstream logFile("ysyx_26020046_MemTop.log");

////////////////////////////////////////////////////////////////////////////////////////


const uint32_t addrReset	=0x80000000;
const uint32_t addrPSRAM	=0x80000000;
const uint32_t addrTimer	=0x0200BFF8;
const uint32_t addrSerial	=0x10000000;
const uint32_t addrInput 	=0x10011000;
const uint32_t psRamSize	=0xffffff;

uint8_t psRam[psRamSize];
uint32_t runStep;
timespec startTime;//开始时间

void NpcEbreak(int returnCode);
void NpcRun(uint32_t times);
void NpcReturn(const char* msg,int returnCode);
void NpcWave();
////////////////////////////////////////////////////////////////////////////////////////
extern "C" int pmem_read(int raddr) {
	uint32_t raddrX=(uint32_t)raddr;
	if(raddrX==addrTimer){//返回毫秒数
		uint32_t time=0;
		timespec t;
		if(clock_gettime(CLOCK_MONOTONIC,&t)!=0){printf("time err\n");exit(-1);}
		time=(t.tv_sec*1000000+t.tv_nsec/1000)-(startTime.tv_sec*1000000+startTime.tv_nsec/1000);//微秒
		return time;
	}
	if(raddrX-addrPSRAM>=psRamSize|raddrX<addrPSRAM|raddrX==0){return 0;}
	uint32_t temp=
		((uint32_t)psRam[raddrX-addrPSRAM+0]<< 0)|
		((uint32_t)psRam[raddrX-addrPSRAM+1]<< 8)|
		((uint32_t)psRam[raddrX-addrPSRAM+2]<<16)|
		((uint32_t)psRam[raddrX-addrPSRAM+3]<<24);
	// printf("Read addr= %x at T=%d => %x\n",raddrX,runStep,temp);
	logFile<<"Read addr= "<<std::hex<<raddrX<<" at T="<<std::dec<<runStep<<" => "<<std::hex<<temp<<std::endl;
	return temp;
}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	uint32_t waddrX=(uint32_t)waddr;
	printf("write addr= %x at Times=%d %x => %x\n",waddrX,runStep,wdata,wmask);
	if(waddrX==0x10000000){
		printf("%c",wdata);
		return;
	}
	if((((waddrX-addrPSRAM)>>2)>psRamSize|waddrX<=addrPSRAM)|(waddrX==0)){
		return;
	}
	uint32_t mask1=0xffffffff;
	uint32_t data=wdata;
	switch(wmask&0x0f){
		case 0b0001:mask1=0xffffff00;data=data&0x00ff;data=data    ;break;
		case 0b0010:mask1=0xffff00ff;data=data&0x00ff;data=data<< 8;break;
		case 0b0100:mask1=0xff00ffff;data=data&0x00ff;data=data<<16;break;
		case 0b1000:mask1=0x00ffffff;data=data&0x00ff;data=data<<24;break;
		case 0b0011:mask1=0xffff0000;data=data&0xffff;data=data    ;break;
		case 0b1100:mask1=0x0000ffff;data=data&0xffff;data=data<<16;break;
		case 0b1111:mask1=0x00000000;data=data       ;data=data    ;break;
		default    :mask1=0xffffffff;data=data&0x0000;data=       0;break;
	}
	uint32_t temp=psRam[(waddr-addrPSRAM)>>2];
	temp&=mask1;
	temp|=data;
	psRam[(waddr-addrPSRAM)>>2]=temp;
}
extern "C" int getRegPc(int addr);
extern "C" void ebreak(){NpcReturn("ebreak",getRegPc(10)!=0);}
extern "C" void check(){
	if(NpcDifftestCheck(getRegPc(0)))NpcReturn("difftest",-1);
}
////////////////////////////////////////////////////////////////////////////////////////
void NpcInitDevice(int argc, char** argv){
	if(clock_gettime(CLOCK_MONOTONIC,&startTime)!=0){printf("time err\n");exit(-1);}
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_26020046_MemTop{contextp};
	scope=svGetScopeFromName("TOP.ysyx_26020046_MemTop.cpu.wbu.chk");
	svSetScope(scope);
#ifdef NPC_WAVE
    Verilated::traceEverOn(true);
	tfp = new VerilatedFstC;
	top->trace(tfp, 99);
	tfp->open("./wave/ysyx_26020046_MemTop.fst");
#endif
}
void NpcInitMem(int argc, char** argv){
    FILE *file;
	if(argc>1&&argv[1]!=NULL){
		printf("!!bin:%s ",argv[1]);
		file = fopen(argv[1],"rb");
	}else{
		printf("!!shuould input bin\n");
		exit(-1);
	}
	if(file==NULL){printf("can't open file\n");exit(-1);}

    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);
    size_t wordsRead = fread(psRam, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);
	printf("has open file\n");
	// for(int i=0;i<40;i+=4){//小段检查
	// 	printf("%02x%02x%02x%02x ",psRam[i+3],psRam[i+2],psRam[i+1],psRam[i]);
	// 	if(i%16==15)printf("\n");
	// }
	NpcDifftestInit8(psRamSize,psRam,addrPSRAM);
}
void NpcDifftestGetGpr(uint32_t *gpr){
	if(gpr==NULL){NpcReturn("difftest unable",-1);}
	for(uint32_t i=1;i<32;i++){gpr[i]=getRegPc(i);}
	gpr[0]=0;
}
void NpcWave(){
	#ifdef NPC_WAVE
		contextp->timeInc(1);
		tfp->dump(contextp->time());
	#endif
}
void NpcReturn(const char* msg,int returnCode){
	NpcWave();
#ifdef NPC_WAVE
	tfp->close();
#endif
	printf("%s runStep=%d pc=0x %x\n",msg,runStep,getRegPc(0)-4);//实质上是已经是next pc了
	for(int i=0;i<32;i++){
		printf("%2d:%8x ",i,getRegPc(i));
		if(i%8==7)printf("\n");
	}
	delete top;
	delete contextp;
	exit(returnCode);
}
////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
	NpcInitDevice(argc, argv);
	NpcInitMem(argc, argv);
	{//初始化
		for(int i=0;i<10;i++){
			top->clock=0;top->reset=1;top->eval();
			top->clock=1;top->reset=1;top->eval();
		}
		top->clock=0;top->reset=0;top->eval();
		runStep=0;
	}
	if(contextp->gotFinish()){
		printf("already finish\n");
		return 0;
	}
	printf("\033[1;32m Welcome to NPC[\033[1;36m%s %s\033[1;32m] \033[0m\n",__DATE__,__TIME__);
	for(int i=0;i<10000&(!contextp->gotFinish());i++){
		NpcWave();
		top->clock=1;top->eval();
		NpcWave();
		top->clock=0;top->eval();
		runStep++;
	}
	NpcReturn("error",-1);
}