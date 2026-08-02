#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>

uint32_t bit= 4;
uint32_t num=1<<bit;//2^bit
uint32_t bolckTag[num]{};
uint32_t bolckValid[num]{};

////////////////////////////////////////////////////////////////////////////////////////
int main() {
	std::fstream file("./bin/microbench-train.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint32_t pc;
	uint64_t hit=0;
	for(uint64_t cnt=0;(!contextp->gotFinish());cnt++){
		if(!file.read((char*)&pc, sizeof(pc))){
			printf("cnt= %ld hit= %ld Hp= %f\n",cnt,hit,(float)hit/cnt);
			break;
		}
        uint32_t index = pc>>(2);
        uint32_t tag = pc>>(2+bit);
        if(bolckValid[index] && bolckTag[index]==tag)hit++;
        else{
            bolckTag[index]=tag;
            bolckValid[index]=true;
        }
	}
}