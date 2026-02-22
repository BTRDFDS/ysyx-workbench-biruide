#include "Vysyx_26020046_minirvN.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include "svdpi.h"
#include "Vysyx_26020046_minirvN__Dpi.h"
#include <time.h>

VerilatedContext* contextp;
Vysyx_26020046_minirvN* top;

// uint32_t M[100000]={
//     0x01400513,
//     0x010000e7,
//     0x00c000e7,
//     // 0x00c00067,
//     0x00100073,
// 	0x00a50513,
// 	0x00008067,
// };

#define max 2048000

//0x80000000
#define ADDR_RESET 0x80000000
#define timeADDR   0x0200BFF8
#define serialADDR 0x10000000

#define unlim 1
#define step 6000
// #define DEBUG

uint32_t M[max];
uint32_t runStep,pc;
timespec st;

uint32_t addrReset;

extern "C" int pmem_read(int raddr) {
#ifdef DEBUG
	printf("pmem_read : ");
#endif
	uint32_t raddrX=(uint32_t)raddr;
	if(raddr==timeADDR){//返回毫秒数
		//printf("pmem_read time:0x");
		uint32_t time=0;
		timespec t;
		if(clock_gettime(CLOCK_MONOTONIC,&t)!=0){printf("time err\n");exit(-1);}
		time=(t.tv_sec*1000000+t.tv_nsec/1000)-(st.tv_sec*1000000+st.tv_nsec/1000);//微秒
		//printf("%x\n",time);
		return time;
	}
	if(((((raddrX-addrReset)>>2)>max)|raddrX<=addrReset)&(raddrX!=0)){

#ifdef DEBUG
		printf("err x%x %d when x%x %d\n",raddrX,raddr,pc,runStep);
#endif

		// exit(-1);
		return 0;
}
	if(((raddrX-addrReset)>>2)>max){
#ifdef DEBUG
		printf("\033[1;31merror x%x => x%x => x%x > x%x\033[0m\n",raddr,(raddr-addrReset),((raddr-addrReset)>>2),max);
#endif
		// exit(-1);
		return 0;
	}
#ifdef DEBUG
	printf("0x%x(0x%x) >> 0x%x(0x%x):%x\n",raddr,raddr>>2,(raddr-addrReset),(raddr-addrReset)>>2,M[(raddr-addrReset)>>2]);
#endif
	return M[(raddr-addrReset) >> 2];
}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
#ifdef DEBUG
	printf("pmem_write ");
#endif
	uint32_t waddrX=(uint32_t)waddr;
	if(waddrX==0x10000000){
		// putchar(wdata);
		printf("%c",wdata);
		return;
	}

	if((((waddrX-addrReset)>>2)>max|waddrX<=addrReset)&(waddrX!=0)){

#ifdef DEBUG
		printf("err x%x %d when x%x %d (x%x,x%x)\n",waddrX,waddr,pc,runStep,addrReset,max+addrReset);
#endif

		return;
	}
#ifdef DEBUG
	printf("0x%x(0x%x) >> 0x%x(0x%x):%x<=%x with 0x%x ",waddr,waddr>>2,(waddr-addrReset),(waddr-addrReset)>>2,M[(waddr-addrReset)>>2],wdata,wmask);
#endif

	if((wmask&0b1111)==0b1111){

#ifdef DEBUG
	printf("all\n");
#endif
    M[(waddr-addrReset)>>2]=wdata;
  }else{
#ifdef DEBUG
	printf("part\n");
#endif
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
	uint32_t temp=M[(waddr-addrReset)>>2];
	temp&=mask1;
	temp|=data;
	M[(waddr-addrReset)>>2]=temp;
  }
#ifdef DEBUG
	printf("become 0x%x(0x%x) >> 0x%x(0x%x):%x\n",waddr,waddr>>2,(waddr-addrReset),(waddr-addrReset)>>2,M[(waddr-addrReset)>>2]);
#endif
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
	// const char *p={"hex/sum.bin"};
	const char *p={"hex/mem.bin"};
    FILE *file;
	if(argc>1&&argv[1]!=NULL){

#ifdef DEBUG
		printf("\n!!bin:%s ",argv[1]);
#endif

		addrReset=ADDR_RESET;
		file = fopen(argv[1],"rb");
	}else{

#ifdef DEBUG
		printf("\n!!bin:%s ",p);
#endif
		addrReset=0;
		file = fopen(p,"rb");
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
		printf("has open file %s\n",argv[1]);
	}else{
		printf("ebreak at 0x%x\n\n",0x8A);
    	// M[0x8A] = 0x00100073;//sum
		M[0x488]=0x00100073;//mem
	}

	if(clock_gettime(CLOCK_MONOTONIC,&st)!=0){printf("time err\n");exit(-1);}

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_26020046_minirvN{contextp};
	top->pcReset=addrReset;

	top->clk=0;
	top->reset=1;
	top->eval();
	top->clk=1;
	top->reset=1;
	top->eval();
	top->clk=0;
	top->reset=0;
	pc=top->pc;
	top->code=M[(pc-addrReset)>>2];
	top->eval();

#ifdef DEBUG
	printf("\n!! reset finish ");
	printf("pc=%d M[0]=0x%x]\n\n",(pc-addrReset)>>2,M[(pc-addrReset)>>2]);
#endif

  for(runStep=0;(runStep<=step)|unlim;runStep++){//30000
	top->clk=1;
	pc=top->pc;
	top->code=M[(pc-addrReset)>>2];
	top->eval();

#ifdef DEBUG
	printf("clk up finish,npc=0x%x\n",(top->pc-addrReset)>>2);
#endif

	top->clk=0;
	pc=top->pc;
	top->code=M[(pc-addrReset)>>2];
	top->eval();

#ifdef DEBUG
	printf("clk down finish\n");
	printf("runStep=%d pc=%x(%x)\n\n",runStep,pc,(pc-addrReset)>>2);
#endif

	// if(runStep%1000000==0){
	// 	printf("step:%d\n",runStep);
	// }
  }
	delete top;
	delete contextp;
	return -1;
}