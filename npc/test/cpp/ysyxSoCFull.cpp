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
#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
	#include "verilated_fst_c.h"
	VerilatedFstC* tfp;//波形文件
#endif
////////////////////////////////////////////////////////////////////////////////////////
#if defined(NPC_M_TRACE) || defined(NPC_MIN_TRACE)
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

uint64_t numCycle		=0;
uint64_t numInst		=0;
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

void NpcEbreak(int returnCode);
void NpcRun(uint32_t times);
void NpcReturn(const char* msg,int returnCode);
void NpcWave();
////////////////////////////////////////////////////////////////////////////////////////
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

extern "C" int getRegPc(int addr);
extern "C" void ebreak(){	numInst++;numIduCsr++;NpcReturn("\nebreak",getRegPc(10)!=0);}
extern "C" void wbuCheck(){	numInst++;if(NpcDifftestCheck(getRegPc(0)))NpcReturn("difftest",-1);}
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
void NpcInitDevice(int argc, char** argv){
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VysyxSoCFull{contextp};
	scope=svGetScopeFromName("TOP.ysyxSoCFull.asic.cpu.cpu.wbu.wbuChk");
	svSetScope(scope);
	#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
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
		nvboard_bind_pin(&top->externalPins_ps2_clk	 ,1,PS2_CLK);
		nvboard_bind_pin(&top->externalPins_ps2_data ,1,PS2_DAT);
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
		
		nvboard_bind_pin(&top->externalPins_vga_r,8,VGA_R7,VGA_R6,VGA_R5,VGA_R4,VGA_R3,VGA_R2,VGA_R1,VGA_R0);
		nvboard_bind_pin(&top->externalPins_vga_g,8,VGA_G7,VGA_G6,VGA_G5,VGA_G4,VGA_G3,VGA_G2,VGA_G1,VGA_G0);
		nvboard_bind_pin(&top->externalPins_vga_b,8,VGA_B7,VGA_B6,VGA_B5,VGA_B4,VGA_B3,VGA_B2,VGA_B1,VGA_B0);
		nvboard_bind_pin(&top->externalPins_vga_hsync,1,VGA_HSYNC);
		nvboard_bind_pin(&top->externalPins_vga_vsync,1,VGA_VSYNC);
		nvboard_bind_pin(&top->externalPins_vga_valid,1,VGA_BLANK_N);

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
	#elif defined(NPC_MIN_TRACE)
	if(numCycle >= NpcMinTraceBegin){
		contextp->timeInc(1);
		tfp->dump(contextp->time());
	}
	#endif
}
void NpcReturn(const char* msg,int returnCode){
	NpcWave();
	#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
		tfp->close();
	#endif
	#ifdef NPC_NVBroad
		nvboard_quit();
	#endif
	printf("%s pc=0x %x cycle=%ld inst=%ld IPC=%f\n",msg,getRegPc(0)-4,numCycle,numInst,(float)(((float)numInst)/((float)numCycle)));//实质上是已经是next pc了
	printf("ifu inst = %ld wait= %ld WpI= %f jump= %ld for= %ld back= %ld fpj= %f bpj= %f\n",
		numIfuInst,numIfuStall,(float)((float)numIfuStall)/((float)numIfuInst),
		numIfuJump,numIfuForward,numIfuBackward,
		(float)((float)numIfuForward)/(float)(numIfuJump),
		(float)((float)numIfuBackward)/(float)(numIfuJump)
	);
	printf("idu cal= %ld jump= %ld imm= %ld ls= %ld csr= %ld br= %ld sum= %ld\n",
		numIduCal,numIduJump,numIduImm,numIduLs,numIduCsr,numIduBr,
		numIduCal+numIduJump+numIduImm+numIduLs+numIduCsr+numIduBr
	);
	printf("exu done= %ld\n",numExuDone);
	printf("lsu load= %ld loadWait= %ld WpL= %f\n",numLsuLoad,numLsuLoadWait,(float)((float)numLsuLoadWait)/((float)numLsuLoad));
	printf("lsu store= %ld storeWait= %ld WpS= %f\n",numLsuStore,numLsuStoreWait,(float)((float)numLsuStoreWait)/((float)numLsuStore));

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
	#if defined(NPC_M_TRACE)// || defined(NPC_MIN_TRACE)
		logFile.close();
	#endif
	exit(returnCode);
}
////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
	NpcInitDevice(argc, argv);
	NpcInitMem(argc, argv);
	{//初始化
		for(int i=0;i<12;i++){
			top->clock=0;top->reset=1;top->eval();
			top->clock=1;top->reset=1;top->eval();
		}
		top->clock=0;top->reset=0;top->eval();
		numCycle=0;
	}
	printf("\033[1;32m Welcome to YsyxSoc[\033[1;36m%s %s\033[1;32m] \033[0m\n",__DATE__,__TIME__);
	for(int i=0;(!contextp->gotFinish());i++){
	// for(int i=0;i<500000&(!contextp->gotFinish());i++){
		#ifdef NPC_NVBroad
			nvboard_update();
		#endif
		NpcWave();
		top->clock=1;top->eval();
		NpcWave();
		top->clock=0;top->eval();
		numCycle++;
	}
	NpcReturn("ending",-1);
}