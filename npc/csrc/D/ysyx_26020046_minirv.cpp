#include "Vysyx_26020046_minirv.h"
#include "verilated.h"
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include "svdpi.h"
#include "Vysyx_26020046_minirv__Dpi.h"
#include <time.h>

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
extern "C" int pmem_read(int raddr) {
#ifdef DEBUG
	printf("pmem_read : ");
#endif
	uint32_t raddrX=(uint32_t)raddr;
	if(raddr==timeADDR){//返回毫秒数
		// printf("pmem_read time:0x");
		uint32_t time=0;
		timespec t;
		if(clock_gettime(CLOCK_MONOTONIC,&t)!=0){printf("time err\n");exit(-1);}
		time=(t.tv_sec*1000000+t.tv_nsec/1000)-(st.tv_sec*1000000+st.tv_nsec/1000);//微秒
		// printf("%x\n",time);
		return time;
	}
	if((raddrX>=(max+ADDR_RESET)|raddrX<=ADDR_RESET)&(raddrX!=0)){
		// printf("read x%x %d when x%x %d\n",raddrX,raddr,pc,runStep);
		// exit(-1);
		return 0;
}
	if(((raddrX-ADDR_RESET)>>2)>max){
#ifdef DEBUG
		printf("\033[1;31merror x%x => x%x => x%x > x%x\033[0m\n",raddr,(raddr-ADDR_RESET),((raddr-ADDR_RESET)>>2),max);
#endif
		// exit(-1);
		return 0;
	}
#ifdef DEBUG
	printf("0x%x(0x%x) >> 0x%x(0x%x):%x\n",raddr,raddr>>2,(raddr-ADDR_RESET),(raddr-ADDR_RESET)>>2,M[(raddr-ADDR_RESET)>>2]);
#endif
	return M[(raddr-ADDR_RESET) >> 2];
}

extern "C" void pmem_write(int waddr, int wdata, char wmask) {
#ifdef DEBUG
	printf("pmem_write ");
	printf("0x%x(0x%x) >> 0x%x(0x%x):%x<=%x with 0x%x ",waddr,waddr>>2,(waddr-ADDR_RESET),(waddr-ADDR_RESET)>>2,M[(waddr-ADDR_RESET)>>2],wdata,wmask);
#endif
	uint32_t waddrX=(uint32_t)waddr;
	if(waddrX==0x10000000){
		// putchar(wdata);
		printf("%c",wdata);
		return;
	}

	if((waddrX>=(max+ADDR_RESET)|waddrX<=ADDR_RESET)&(waddrX!=0)){printf("pmem_write %x %d\n",waddrX,waddr);}
	if((wmask&0b1111)==0b1111){
#ifdef DEBUG
	printf("all\n");
#endif
    M[(waddr-ADDR_RESET)>>2]=wdata;
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
	uint32_t temp=M[(waddr-ADDR_RESET)>>2];
	temp&=mask1;
	temp|=data;
	M[(waddr-ADDR_RESET)>>2]=temp;
  }
#ifdef DEBUG
	printf("become 0x%x(0x%x) >> 0x%x(0x%x):%x\n",waddr,waddr>>2,(waddr-ADDR_RESET),(waddr-ADDR_RESET)>>2,M[(waddr-ADDR_RESET)>>2]);
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

		file = fopen(argv[1],"rb");
	}else{

#ifdef DEBUG
		printf("\n!!bin:%s ",p);
#endif

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
	pc=top->pc;
	top->code=M[(pc-ADDR_RESET)>>2];
	top->eval();

#ifdef DEBUG
	printf("\n!! reset finish ");
	printf("pc=%d M[0]=0x%x]\n\n",(pc-ADDR_RESET)>>2,M[(pc-ADDR_RESET)>>2]);
#endif

  for(runStep=0;(runStep<=step)|unlim;runStep++){//30000
	top->clk=1;
	pc=top->pc;
	top->code=M[(pc-ADDR_RESET)>>2];
	top->eval();

#ifdef DEBUG
	printf("clk up finish\n");
#endif

	top->clk=0;
	pc=top->pc;
	top->code=M[(pc-ADDR_RESET)>>2];
	top->eval();

#ifdef DEBUG
	printf("clk down finish\n");
	printf("runStep=%d pc=%x(%x)\n\n",runStep,pc,(pc-ADDR_RESET)>>2);
#endif

	// if(runStep%1000000==0){
	// 	printf("step:%d\n",runStep);
	// }
  }
	delete top;
	delete contextp;
	return -1;
}