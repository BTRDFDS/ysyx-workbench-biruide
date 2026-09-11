//flash
//ysyxSoCFull
#include "VysyxSoCFull.h"
#include "include/npcDrive.h"
#include "verilated.h"
#include "svdpi.h"
#include <string>
#include "VysyxSoCFull__Dpi.h"
#include "npcDrive.h"
#include "verilated_fst_c.h"
VerilatedContext* contextp;//verilator上下文
VysyxSoCFull* top;//顶层模块
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
	size_t wordsRead = fread(flash, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VysyxSoCFull{contextp};
	#if defined(NPC_WAVE)
		Verilated::traceEverOn(true);
		tfp = new VerilatedFstC;
		top->trace(tfp, 99);
		tfp->open("./wave/ysyxSoCFull.fst");
	#endif
	NpcDifftestInit8(flashSize,flash,flashAddr,"./test/cpp/lib/riscv32-nemu-interpreter-so-ysyxSoCFull");
	//初始化
	for(int i=0;i<12;i++){
		top->clock=0;top->reset=1;top->eval();
		top->clock=1;top->reset=1;top->eval();
	}	top->clock=0;top->reset=0;top->eval();
	printf("\033[1;32m Welcome to ysyxSoCFull[\033[1;36m%s %s\033[1;32m] \033[0m ",__DATE__,__TIME__);
	NpcToDrive("./log/ysyxSoCFull.log",argv[1]);
	if(tfp!=nullptr){
		tfp->close();
		delete tfp;
	}
	contextp->statsPrintSummary();
	// contextp->coveragep()->write("./log/ysyxSoCFull.dat");
	if(top!=nullptr){delete top;}
	if(contextp!=nullptr){delete contextp;}
	return returnCode;
}