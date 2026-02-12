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

#define max 262143
uint32_t M[max];

extern "C" int pmem_read(int raddr) {
	printf("pmem_read 0x%x(0x%x):%x\n",raddr,raddr>>2,M[raddr>>2]);
	return M[raddr >> 2];
  // 总是读取地址为`raddr & ~0x3u`的4字节返回
}
extern "C" void pmem_write(int waddr, int wdata, char wmask) {
  // 总是往地址为`waddr & ~0x3u`的4字节按写掩码`wmask`写入`wdata`,wdata默认从低位开始取值
  // `wmask`中每比特表示`wdata`中1个字节的掩码,
  // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
  //wmask目前是要么是全是1要么是独热码
	printf("pmem_write 0x%x(0x%x):%x<=%x with %x ",waddr,waddr>>2,M[waddr>>2],wdata,wmask);
  if(wmask&0b1111==0b1111){
	printf("all\n");
    M[waddr>>2]=wdata;
  }else{
	printf("part\n");
	uint32_t mask1=0xffffffff;
	uint32_t data=wdata&0xff;
	switch(wmask&0b1111){
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
	uint32_t temp=M[waddr>>2];
	temp&=mask1;
	temp|=data;
	M[waddr>>2]=temp;
  }
	printf("become 0x%x(0x%x):%x\n",waddr,waddr>>2,M[waddr>>2]);
}

extern "C" void ebreak(unsigned char eb){
	printf("ebreak:");
	delete top;
	delete contextp;
	if(eb){
		printf("HIT GOOD TRAP\n");
		exit(0);
	}else{
	    printf("HIT BAD TRAP\n");
		exit(1);
	}
}


int main(int argc, char** argv) {

    FILE *file = fopen("hex/sum.bin","rb");
	if(file==NULL){printf("can't open file\n");}
    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);
    size_t wordsRead = fread(M, sizeof(uint32_t), fileSize/sizeof(uint32_t), file);
	if(wordsRead!=fileSize/sizeof(uint32_t)){printf("can't read file\n");}
	fclose(file);

    M[0x8A] = 0x00100073;//sum

	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new Vysyx_26020046_minirv{contextp};
  
  uint32_t pc=0;
	pc=top->pc;
	top->code=M[pc>>2];
  for(uint32_t i=0;(i<30000);i++){
	top->clk=1;
	pc=top->pc;
	top->code=M[pc>>2];
	top->eval();

	top->clk=0;
	top->eval();

	printf("i=%d\n\n",i);
  }
	delete top;
	delete contextp;
	return 0;
}