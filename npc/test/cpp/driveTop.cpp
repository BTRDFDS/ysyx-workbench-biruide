//psram
//driveTop
#include "VdriveTop.h"
#include "include/npcDrive.h"
#include "verilated.h"
#include "svdpi.h"
#include <string>
#include "VdriveTop__Dpi.h"
#include "npcDrive.h"
#include "verilated_fst_c.h"
VerilatedContext* contextp;//verilator上下文
VdriveTop* top;//顶层模块
VerilatedFstC* tfp=nullptr;//波形文件
void NpcRun(){
	#ifdef NPC_WAVE
		contextp->timeInc(1);
		tfp->dump(contextp->time());
	#endif
	top->clock=1;top->eval();
	#ifdef NPC_WAVE
		contextp->timeInc(1);
		tfp->dump(contextp->time());
	#endif
	top->clock=0;top->eval();
	if(contextp->gotFinish()){stop=true;}
}
int main(int argc, char** argv) {
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

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VdriveTop{contextp};
	#if defined(NPC_WAVE)
		Verilated::traceEverOn(true);
		tfp = new VerilatedFstC;
		top->trace(tfp, 99);
		tfp->open("./wave/driveTop.fst");
	#endif
	NpcDifftestInit8(psramSize,psram,psramAddr,"./test/cpp/lib/riscv32-nemu-interpreter-so-driveTop");
	//初始化
	for(int i=0;i<12;i++){
		top->clock=0;top->reset=1;top->eval();
		top->clock=1;top->reset=1;top->eval();
	}	top->clock=0;top->reset=0;top->eval();
	printf("\033[1;32m Welcome to driveTop[\033[1;36m%s %s\033[1;32m] \033[0m ",__DATE__,__TIME__);
	NpcToDrive("./log/driveTop.log",argv[1]);
	if(tfp!=nullptr){
		tfp->close();
		delete tfp;
	}
	contextp->statsPrintSummary();
	// contextp->coveragep()->write("./log/driveTop.dat");
	if(top!=nullptr){delete top;}
	if(contextp!=nullptr){delete contextp;}
	return returnCode;
}