#include "Vysyx_26020046_minirv.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include "svdpi.h"
#include "Vysyx_26020046_minirv__Dpi.h"

VerilatedContext* contextp;
Vysyx_26020046_minirv* top;

// uint32_t M[100000]={
//     0x01400513,
//     0x010000e7,
//     0x00c000e7,
//     // 0x00c00067,
//     0x00100073,
// 	0x00a50513,
// 	0x00008067,
// };

//0x80000000
#define ADDR_RESET 0x80000000
#define max 262144

uint32_t M[max];
uint32_t pc;

extern "C" int pmem_read(int raddr) {
	printf("pmem_read : ");
	if(((raddr-ADDR_RESET)>>2)>max){
		printf("\033[1;31merror x%x => x%x => x%x > x%x\033[0m\n",raddr,(raddr-ADDR_RESET),((raddr-ADDR_RESET)>>2),max);
		// exit(-1);
		return 0;
	}
	printf("0x%x(0x%x) >> 0x%x(0x%x):%x\n",raddr,raddr>>2,(raddr-ADDR_RESET),(raddr-ADDR_RESET)>>2,M[(raddr-ADDR_RESET)>>2]);
	return M[(raddr-ADDR_RESET) >> 2];
}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
	printf("pmem_write ");
	printf("0x%x(0x%x) >> 0x%x(0x%x):%x<=%x with 0x%x ",waddr,waddr>>2,(waddr-ADDR_RESET),(waddr-ADDR_RESET)>>2,M[(waddr-ADDR_RESET)>>2],wdata,wmask);
  if((wmask&0b1111)==0b1111){
	printf("all\n");
    M[(waddr-ADDR_RESET)>>2]=wdata;
  }else{
	printf("part\n");
	uint32_t mask1=0xffffffff;
	uint32_t data=wdata&0xff;
	switch(wmask&0x0f){
		case 0b0001:
			mask1=0xffffff00;
			data=data;
			break;
		case 0b0010:
			mask1=0xffff00ff;
			data=data<<8;
			break;
		case 0b0100:
			mask1=0xff00ffff;
			data=data<<16;
			break;
		case 0b1000:
			mask1=0x00ffffff;
			data=data<<24;
			break;
		default    :
			mask1=0xffffffff;
			data=0;
			break;
	}
	uint32_t temp=M[(waddr-ADDR_RESET)>>2];
	temp&=mask1;
	temp|=data;
	M[(waddr-ADDR_RESET)>>2]=temp;
  }
	printf("become 0x%x(0x%x) >> 0x%x(0x%x):%x\n",waddr,waddr>>2,(waddr-ADDR_RESET),(waddr-ADDR_RESET)>>2,M[(waddr-ADDR_RESET)>>2]);
}

extern "C" void ebreak(unsigned char eb){
	printf("ebreak:");
	delete top;
	delete contextp;
	if(eb){
		printf("\033[1;32mHIT GOOD TRAP\033[0m\n");
		exit(0);
	}else{
	    printf("\033[1;31mHIT BAD TRAP\033[0m\n");
		exit(-1);
	}
}

int main(int argc, char** argv) {
	const char *p={"hex/sum.bin"};
    FILE *file;
	if(argc>1&&argv[1]!=NULL){
		printf("\n!!bin:%s ",argv[1]);
		file = fopen(argv[1],"rb");
	}else{
		printf("\n!!bin:%s ",p);
		file = fopen(p,"rb");
	}
    // FILE *file = fopen("hex/mem.bin","rb");
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
			printf("ebreak at 0x%lx\n\n",strtoul(argv[2], NULL,0));
			M[strtoul(argv[2],NULL,0)]=0x00100073;
		}else{
			printf("\n\n");
		}
	}else{
		printf("ebreak at 0x%x\n\n",0x8A);
    	M[0x8A] = 0x00100073;//sum
	}
	// M[0x488]=0x00100073;//mem

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_26020046_minirv{contextp};
	top->pcReset=ADDR_RESET;

	top->clk=0;
	top->reset=1;
	top->eval();
	top->clk=1;
	top->reset=1;
	top->eval();
	top->clk=0;
	top->reset=0;
	top->eval();

	pc=top->pc;
	top->code=M[(pc-ADDR_RESET)>>2];
	printf("!! pc=%d M[0]=0x%x] reset finish\n\n\n",(pc-ADDR_RESET)>>2,M[(pc-ADDR_RESET)>>2]);
  for(uint32_t i=0;i<=60000;i++){//30000
	top->clk=1;
	pc=top->pc;
	top->code=M[(pc-ADDR_RESET)>>2];
	top->eval();
	printf("clk up finish\n");

	top->clk=0;
	pc=top->pc;
	top->code=M[(pc-ADDR_RESET)>>2];
	top->eval();
	printf("clk down finish\n");

	printf("i=%d pc=%x(%x)\n\n",i,pc,(pc-ADDR_RESET)>>2);
  }
	delete top;
	delete contextp;
	return -1;
}