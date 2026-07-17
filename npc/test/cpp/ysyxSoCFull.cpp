//ysyxSoCFull
#include "VysyxSoCFull.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include "svdpi.h"
#include "VysyxSoCFull__Dpi.h"
#include <npcDifftest.h>//我只需要difftest

VerilatedContext* contextp;//verilator上下文
VysyxSoCFull* top;//顶层模块
svScope scope;//作用域
#ifdef NPC_WAVE
	#include "verilated_fst_c.h"
	VerilatedFstC* tfp;//波形文件
#endif
////////////////////////////////////////////////////////////////////////////////////////
//输出日志文件：
std::fstream logFile;

////////////////////////////////////////////////////////////////////////////////////////


const uint32_t addrSerial	=0x10000000;
const uint32_t addrInput 	=0x10011000;

// const uint32_t addrPSRAM	=0x80000000;
// const uint32_t psRamSize	=0xfffffff;//psram极限地址是bfff_ffff
// uint8_t psRam[psRamSize];

const uint32_t addrMrom	=0x20000000;//mrom起始地址
const uint32_t mromSize	=0xfff;
uint8_t mrom[mromSize];

uint32_t runStep;

void NpcEbreak(int returnCode);
void NpcRun(uint32_t times);
void NpcReturn(const char* msg,int returnCode);
void NpcWave();
////////////////////////////////////////////////////////////////////////////////////////
/*
extern "C" int pmem_read(int raddr) {
	uint32_t raddrX=(uint32_t)raddr;
	if(raddrX-addrPSRAM>=psRamSize|raddrX<addrPSRAM|raddrX==0){return 0;}
	uint32_t temp=
		((uint32_t)psRam[raddrX-addrPSRAM+0]<< 0)|
		((uint32_t)psRam[raddrX-addrPSRAM+1]<< 8)|
		((uint32_t)psRam[raddrX-addrPSRAM+2]<<16)|
		((uint32_t)psRam[raddrX-addrPSRAM+3]<<24);
	// printf("Read addr= %x at T=%d => %x\n",raddrX,runStep,temp);
	#ifdef NPC_WAVE
	logFile<<"Read addr= "<<std::hex<<raddrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" => "<<std::hex<<temp<<std::endl;
	#endif
	return temp;
}
extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	uint32_t waddrX=(uint32_t)waddr;
	#ifdef NPC_WAVE
		logFile<<"write addr= "<<std::hex<<waddrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" "<<std::hex<<wdata<<" ="<<std::bitset<4>(wmask)<<"> ";
	#endif
	if(waddrX==0x10000000){
		printf("%c",wdata);
		fflush(stdout);
		return;
	}
	if((((waddrX-addrPSRAM)>>2)>psRamSize|waddrX<=addrPSRAM)|(waddrX==0)){
		return;
	}
	uint32_t index = (waddrX-addrPSRAM) & 0xfffffffc;
	if(wmask&0b1000)psRam[index+3]=(uint8_t)(wdata>>24);
	if(wmask&0b0100)psRam[index+2]=(uint8_t)(wdata>>16);
	if(wmask&0b0010)psRam[index+1]=(uint8_t)(wdata>> 8);
	if(wmask&0b0001)psRam[index+0]=(uint8_t)(wdata    );
	uint32_t temp=
		((uint32_t)psRam[index+0]<< 0)|
		((uint32_t)psRam[index+1]<< 8)|
		((uint32_t)psRam[index+2]<<16)|
		((uint32_t)psRam[index+3]<<24);
	#ifdef NPC_WAVE
		logFile<<std::hex<<temp<<std::endl;
	#endif
}
*/
extern "C" int getRegPc(int addr);
extern "C" void ebreak(){NpcReturn("\nebreak",getRegPc(10)!=0);}
extern "C" void check(){
	if(NpcDifftestCheck(getRegPc(0)))NpcReturn("difftest",-1);
}
extern "C" void flash_read(int32_t addr, int32_t *data) {assert(0);}
extern "C" void mrom_read(int32_t addr, int32_t *data) {
	uint32_t addrX=(uint32_t)addr;
	if(addrX-addrMrom>=mromSize|addrX<addrMrom){NpcReturn("mrom read",-2);}
	uint32_t temp=
		((uint32_t)mrom[addrX-addrMrom+0]<< 0)|
		((uint32_t)mrom[addrX-addrMrom+1]<< 8)|
		((uint32_t)mrom[addrX-addrMrom+2]<<16)|
		((uint32_t)mrom[addrX-addrMrom+3]<<24);
	*data=temp;
	#ifdef NPC_WAVE
	logFile<<"Read addr= "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" => "<<std::hex<<temp<<std::endl;
	#endif
}
////////////////////////////////////////////////////////////////////////////////////////
void NpcInitDevice(int argc, char** argv){
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VysyxSoCFull{contextp};
	scope=svGetScopeFromName("TOP.ysyxSoCFull.asic.cpu.cpu.wbu.chk");
	svSetScope(scope);
#ifdef NPC_WAVE
    Verilated::traceEverOn(true);
	tfp = new VerilatedFstC;
	top->trace(tfp, 99);
	tfp->open("./wave/ysyxSoCFull.fst");
#endif
	logFile.open("./log/ysyxSoCFull.log",std::ios::out);
	if(!logFile.is_open()) {
    printf("Failed to open log file!\n");
    exit(-1);
	}
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
    size_t wordsRead = fread(mrom, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);
	printf("has open file\n");
	// for(int i=0;i<40;i+=4){//小段检查
	// 	printf("%02x%02x%02x%02x ",mrom[i+3],mrom[i+2],mrom[i+1],mrom[i]);
	// 	if(i%16==15)printf("\n");
	// }
	NpcDifftestInit8(mromSize,mrom,addrMrom,"/home/biruide/ysyx-workbench/npc/test/cpp/lib/riscv32-nemu-interpreter-so-mrom");
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
	const char *regsName[] = {
	"pc", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
	"a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
	"s8", "s9", "sA", "sB", "t3", "t4", "t5", "t6"
	};//A=10 B=11
	for(int i=0;i<32;i++){
		printf("%s %2d:%8x ",regsName[i],i,getRegPc(i));
		if(i%8==7)printf("\n");
	}
	delete top;
	delete contextp;
	logFile.close();
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
	for(int i=0;(!contextp->gotFinish());i++){
	// for(int i=0;i<500L&(!contextp->gotFinish());i++){
		NpcWave();
		top->clock=1;top->eval();
		NpcWave();
		top->clock=0;top->eval();
		runStep++;
	}
	NpcReturn("ending",-1);
}