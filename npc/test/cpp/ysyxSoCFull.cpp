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

#ifdef NPC_NVBroad
#include <nvboard.h>
#endif

VerilatedContext* contextp;//verilator上下文
VysyxSoCFull* top;//顶层模块
svScope scope;//作用域
#if defined(NPC_WAVE)
	#include "verilated_fst_c.h"
	VerilatedFstC* tfp;//波形文件
#endif
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_MIN_TRACE) || defined(NPC_M_TRACE)
	//输出日志文件：
	std::fstream logFile;
#endif
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

uint64_t runStep;

void NpcEbreak(int returnCode);
void NpcRun(uint32_t times);
void NpcReturn(const char* msg,int returnCode);
void NpcWave();
////////////////////////////////////////////////////////////////////////////////////////
/*
extern "C" int pmem_read(int raddr) {
	uint32_t raddrX=(uint32_t)raddr;
	if(raddrX-psramAddr>=psramSize|raddrX<psramAddr|raddrX==0){return 0;}
	uint32_t temp=
		((uint32_t)psram[raddrX-psramAddr+0]<< 0)|
		((uint32_t)psram[raddrX-psramAddr+1]<< 8)|
		((uint32_t)psram[raddrX-psramAddr+2]<<16)|
		((uint32_t)psram[raddrX-psramAddr+3]<<24);
	// printf("Read addr= %x at T=%d => %x\n",raddrX,runStep,temp);
	#ifdef NPC_WAVE
	logFile<<"Read addr= "<<std::hex<<raddrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" => "<<std::hex<<temp<<std::endl;
	#endif
	return temp;
}
extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	uint32_t addrX=(uint32_t)waddr;
	#ifdef NPC_M_TRACE
		logFile<<"write addr= "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" "<<std::hex<<wdata<<" ="<<std::bitset<4>(wmask)<<"> ";
	#endif
	if(addrX==0x10000000){
		printf("%c",wdata);
		fflush(stdout);
		return;
	}
	if((((addrX-psramAddr)>>2)>psramSize|addrX<=psramAddr)|(addrX==0)){
		return;
	}
	uint32_t index = (addrX-psramAddr) & 0xfffffffc;
	if(wmask&0b1000)psram[index+3]=(uint8_t)(wdata>>24);
	if(wmask&0b0100)psram[index+2]=(uint8_t)(wdata>>16);
	if(wmask&0b0010)psram[index+1]=(uint8_t)(wdata>> 8);
	if(wmask&0b0001)psram[index+0]=(uint8_t)(wdata    );
	uint32_t temp=
		((uint32_t)psram[index+0]<< 0)|
		((uint32_t)psram[index+1]<< 8)|
		((uint32_t)psram[index+2]<<16)|
		((uint32_t)psram[index+3]<<24);
	#ifdef NPC_M_TRACE
		logFile<<std::hex<<temp<<std::endl;
	#endif
}
*/
extern "C" int getRegPc(int addr);
extern "C" void ebreak(){NpcReturn("\nebreak",getRegPc(10)!=0);}
extern "C" void check(){
	if(NpcDifftestCheck(getRegPc(0)))NpcReturn("difftest",-1);
}
extern "C" void flash_read(int32_t addr, int32_t *data) {
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	#ifdef NPC_M_TRACE
	logFile<<"flash	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep;
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
	logFile<<"mrom	R "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" => "<<std::hex<<temp<<std::endl;
	#endif
}
extern "C" int psram_read(int32_t addr){
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	#if defined(NPC_M_TRACE)
		logFile<<"psram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep;
	#elif defined(NPC_MIN_TRACE)
		if(runStep >= NpcMinTraceBegin)logFile<<std::hex<<getRegPc(0)<<"\n";
		if((addr&0xfffffff0) == (0xa00164b4&0xfffffff0))logFile<<"psram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep;
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
		logFile<<"Psram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" "<<std::hex<<data<<" => ";
	#elif defined(NPC_MIN_TRACE)
		if((addr&0xfffffff0) == (0xa00164b4&0xfffffff0))logFile<<"Psram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" "<<std::hex<<data<<" => ";
	#endif
	psram[addrX+0]=(uint8_t)(data&0xff);
	#if defined(NPC_M_TRACE)
		logFile<<std::hex<<(uint32_t)psram[addrX+0]<<std::endl;
	#elif defined(NPC_MIN_TRACE)
		if((addr&0xfffffff0) == (0xa00164b4&0xfffffff0))logFile<<std::hex<<(uint32_t)psram[addrX+0]<<"\n";
	#endif
}
extern "C" int sdram_read(int32_t addr){
	uint32_t addrX=((uint32_t)addr);
	#if defined(NPC_M_TRACE)
		logFile<<"sdram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep;
	#elif defined(NPC_MIN_TRACE)
		if(runStep >= NpcMinTraceBegin)logFile<<std::hex<<getRegPc(0)<<"\n";
		if(addr&0xfffffffc == 0x800001f4)logFile<<"sdram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep;
	#endif
	if(addrX>=sdramSize)NpcReturn("sdram read error",addrX);
	uint32_t temp=
		((uint32_t)sdram[addrX+0]<< 0)|
		((uint32_t)sdram[addrX+1]<< 8)|
		((uint32_t)sdram[addrX+2]<<16)|
		((uint32_t)sdram[addrX+3]<<24);
	#ifdef NPC_M_TRACE
		logFile<<" => "<<std::hex<<temp<<std::endl;
	#endif
	return temp;
}
extern "C" void sdram_write(int addr,int data){
	uint32_t addrX=(uint32_t)addr;
	#if defined(NPC_M_TRACE)
		logFile<<"sdram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<getRegPc(0)<<" T="<<std::dec<<runStep<<" "<<std::hex<<data<<" => ";
		#endif
	sdram[addrX+0]=(uint8_t)(data&0xff);
	#if defined(NPC_M_TRACE)
		logFile<<std::hex<<(uint32_t)sdram[addrX+0]<<std::endl;
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
	#if defined(NPC_M_TRACE) || defined(NPC_MIN_TRACE)
		logFile.open("./log/ysyxSoCFull.log",std::ios::out);
		if(!logFile.is_open()) {
		printf("Failed to open log file!\n");
		exit(-1);
	}
	#endif
	#ifdef NPC_NVBroad
		nvboard_bind_pin(&top->externalPins_uart_rx  ,1,UART_RX);
		nvboard_bind_pin(&top->externalPins_uart_tx  ,1,UART_TX);
		nvboard_bind_pin(&top->externalPins_gpio_in  ,16,SW15,SW14,SW13,SW12,SW11,SW10,SW9,SW8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0);
		nvboard_bind_pin(&top->externalPins_gpio_out ,16,LD15,LD14,LD13,LD12,LD11,LD10,LD9,LD8,LD7,LD6,LD5,LD4,LD3,LD2,LD1,LD0);
		nvboard_bind_pin(&top->externalPins_gpio_seg_0,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_1,8,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F,SEG1G,DEC1P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_2,8,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G,DEC2P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_3,8,SEG3A,SEG3B,SEG3C,SEG3D,SEG3E,SEG3F,SEG3G,DEC3P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_4,8,SEG4A,SEG4B,SEG4C,SEG4D,SEG4E,SEG4F,SEG4G,DEC4P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_5,8,SEG5A,SEG5B,SEG5C,SEG5D,SEG5E,SEG5F,SEG5G,DEC5P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_6,8,SEG6A,SEG6B,SEG6C,SEG6D,SEG6E,SEG6F,SEG6G,DEC6P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_7,8,SEG7A,SEG7B,SEG7C,SEG7D,SEG7E,SEG7F,SEG7G,DEC7P);
		
		nvboard_init();
	#endif
}
void NpcInitMem(int argc, char** argv){
	FILE *file;
	if(argc>1&&argv[1]!=NULL){
		printf("!!bin:%s\n",argv[1]);
		file = fopen(argv[1],"rb");
	}else{
		printf("!!shuould input bin\n");
		exit(-1);
	}
	if(file==NULL){printf("can't open file\n");exit(-1);}

	fseek(file, 0, SEEK_END);
	long fileSize = ftell(file);
	fseek(file, 0, SEEK_SET);
	size_t wordsRead = fread(flash, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);
	// printf("fileSize=%lx\n",fileSize);
	// printf("has open.fileSize=%lx\n",fileSize);
	// for(int i=0;i<0x100;i+=4){//小段检查
	// 	printf("%02x%02x%02x%02x ",flash[i+3],flash[i+2],flash[i+1],flash[i]);
	// 	if(i%16==15)printf("\n");
	// }
	NpcDifftestInit8(flashSize,flash,flashAddr,"/home/biruide/ysyx-workbench/npc/test/cpp/lib/riscv32-nemu-interpreter-so-flash-sdram");
	// for(uint32_t i=0;i<0x100;i++){
	// 	flash[i]=i&0xff;
	// }
	// file =fopen("/home/biruide/ysyx-workbench/am-kernels/tests/my-tests/build/myTest_chat-riscv32i-ysyxsoc.bin","rb");
	// if(file==NULL){printf("can't open myTest_chat\n");exit(-1);}
	// fseek(file, 0, SEEK_END);
	// fileSize = ftell(file);
	// fseek(file, 0, SEEK_SET);
	// wordsRead = fread(flash, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	// if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	// fclose(file);
	// for(uint32_t i=0;i<0x100;i+=4){
	// 	uint32_t temp=
	// 	((uint32_t)flash[i+0]<< 0)|
	// 	((uint32_t)flash[i+1]<< 8)|
	// 	((uint32_t)flash[i+2]<<16)|
	// 	((uint32_t)flash[i+3]<<24);
	// 	logFile<<std::hex<<temp<<std::endl;
	// }
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
	#ifdef NPC_NVBroad
		nvboard_quit();
	#endif
	printf("%s runStep=%ld pc=0x %x\n",msg,runStep,getRegPc(0)-4);//实质上是已经是next pc了
	const char *regsName[] = {
	"pc", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
	"s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
	"a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
	"s8", "s9", "sA", "sB", "t3", "t4", "t5", "t6"
	};//A=10 B=11
	for(int i=0;i<32;i++){
		printf("[%2d %s]%8x ",i,regsName[i],getRegPc(i));
		if(i%8==7)printf("\n");
	}
	delete top;
	delete contextp;
	#if defined(NPC_M_TRACE) || defined(NPC_MIN_TRACE)
		logFile.close();
	#endif
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
	// for(int i=0;i<100000000L&(!contextp->gotFinish());i++){
		#ifdef NPC_NVBroad
			nvboard_update();
		#endif
		NpcWave();
		top->clock=1;top->eval();
		NpcWave();
		top->clock=0;top->eval();
		runStep++;
	}
	NpcReturn("ending",-1);
}