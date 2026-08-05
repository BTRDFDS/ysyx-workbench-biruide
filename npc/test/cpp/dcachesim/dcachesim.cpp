#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>

// const uint32_t size	= 5;
// const uint32_t bit	= 1;
// const uint32_t num=1<<bit;//2^bit
uint32_t bolckTag[0x100]{};
uint32_t bolckValid[0x100]{};
std::fstream file;
int main() {
	// for(uint32_t size=2;size<=5;size++){
	// 	for(uint32_t bit=2;bit<=5;bit++){
	for(uint32_t total=6;total<=6;total++){
		for(uint32_t bit=0;bit<=total-2;bit++){//size至少为2
			uint32_t size=total-bit;
			file.open("./bin/microbench-train.bin", std::ios::in | std::ios::binary);
			if (!file.is_open()) {printf("Failed to open file\n");return -1;}
			uint32_t pc;
			uint64_t hit=0;
			for(uint64_t cnt=0;;cnt++){
				if(!file.read((char*)&pc, sizeof(pc))){
					const float PpM= 33.923908;
					printf("%2dB%2dW%4d:cnt= %ld hit= %ld Hp= %f\tWait= %f brust= %f\n",
						1<<bit,(1<<size)/4,(1<<bit)*(1<<size)/4,cnt,hit,(float)hit/cnt,
						(((1<<size)/4)*PpM*(cnt-hit)+cnt)/(float)cnt,
						(((1<<size)*3/16)*5+PpM*(cnt-hit)+cnt)/(float)cnt
					);
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
			file.close();
		}
	}
}