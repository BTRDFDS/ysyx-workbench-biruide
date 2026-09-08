//psram
//driveTop
#include "VdriveTop.h"
#include "verilated.h"
#include "svdpi.h"
#include "VdriveTop__Dpi.h"
#include "npcDevice.h"

VerilatedContext* contextp;//verilator上下文
VdriveTop* top;//顶层模块
////////////////////////////////////////////////////////////////////////////////////////
void NpcInitDeviceMem(int argc, char** argv){
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VdriveTop{contextp};
	#if defined(NPC_WAVE)  || defined(NPC_MIN_TRACE)
		Verilated::traceEverOn(true);
		tfp = new VerilatedFstC;
		top->trace(tfp, 99);
		tfp->open("./wave/driveTop.fst");
	#endif
	logFileInit("./log/driveTop.log");
	TraceInit();
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
	size_t wordsRead = fread(psram, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);
	NpcDifftestInit8(psramSize,psram,psramAddr,"/home/biruide/ysyx-workbench/npc/test/cpp/lib/riscv32-nemu-interpreter-so-npc");
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
////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
	NpcInitDeviceMem(argc, argv);
	{//初始化
		for(int i=0;i<12;i++){
			top->clock=0;top->reset=1;top->eval();
			top->clock=1;top->reset=1;top->eval();
		}
		top->clock=0;top->reset=0;top->eval();
		numCycle=0;
	}
	printf("\033[1;32m Welcome to driveTop[\033[1;36m%s %s\033[1;32m] \033[0m\n",__DATE__,__TIME__);
	for(uint64_t i=0;(i<runstopTime||runstopTime==0)&&(!contextp->gotFinish()&(!stop));i++){
		NpcWave();
		top->clock=1;top->eval();
		NpcWave();
		top->clock=0;top->eval();
		numCycle++;
		// if(numIfuInst < numInst+numIduMiss)break;
	}
	// NpcWave();
	printOver();
	contextp->statsPrintSummary();
	contextp->coveragep()->write("./log/driveTop.dat");
	delete top;
	delete contextp;
	return returnCode;
}