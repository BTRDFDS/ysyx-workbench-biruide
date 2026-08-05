#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>

const uint32_t bit	= 5;
const uint32_t num=1<<bit;
uint32_t bolckTag[num]{};
uint32_t bolckValid[num]{};
uint64_t hit=0;
uint32_t addr;
std::fstream file;
int main() {
	file.open("./bin/Dmicrobench-test.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	for(uint64_t cnt=0;;cnt++){
		if(!file.read((char*)&addr, sizeof(addr))){
			printf("cnt= %ld\thit= %ld\tHp= %f\n",cnt,hit,(float)cnt/(float)hit);
			break;
		}
		uint32_t index = addr&((1<<bit)-1);
		uint32_t tag = addr>>bit&((1<<(32-bit))-1);
		if(bolckValid[index] && bolckTag[index]==tag)hit++;
		else{
			bolckTag[index]=tag;
			bolckValid[index]=true;
		}
	}
	file.close();
}