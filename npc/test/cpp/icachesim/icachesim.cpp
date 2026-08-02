#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>

// const uint32_t size	= 5;
// const uint32_t bit	= 1;
const uint32_t num=1<<bit;//2^bit
uint32_t bolckTag[0x100]{};
uint32_t bolckValid[0x100]{};
int main() {
	std::fstream file("./bin/microbench-train.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	for(uint32_t size=2;size<4;size++){
		for(uint32_t bit=0;bit<4;bit++){
			uint32_t pc;
			uint64_t hit=0;
			for(uint64_t cnt=0;;cnt++){
				if(!file.read((char*)&pc, sizeof(pc))){
					printf("%dBlock%d :cnt= %ld hit= %ld Hp= %f\n",1<<bit,1<<size,cnt,hit,(float)hit/cnt);
					break;
				}
				uint32_t index = (pc>>(size))&((1<<bit)-1);
				uint32_t tag = pc>>(size+bit)&((1<<(32-bit-size))-1);
				if(bolckValid[index] && bolckTag[index]==tag)hit++;
				else{
					bolckTag[index]=tag;
					bolckValid[index]=true;
				}
			}
		}
	}
}