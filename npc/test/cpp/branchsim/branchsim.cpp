#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>


std::fstream file;
int main() {
	file.open("./bin/Bdiv.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t bij{},bnj{},btf{},btb{};
	uint32_t addr,pc;
	uint8_t state;
	for(uint64_t cnt=0;;cnt++){
		if(!file.read((char*)&pc, sizeof(pc))){
			printf("cnt= %ld bij= %ld[%f] bnj= %ld[%f] btf= %ld[%f] btb= %ld[%f] \n",cnt,bij,bij/(float)cnt,bnj,bnj/(float)cnt,btf,btf/(float)cnt,btb,btb/(float)cnt);
			break;
		}
		file.read((char*)&state, sizeof(state));
		if((state&0x7f)==1){
			file.read((char*)&addr, sizeof(addr));
			bij++;
		}else if((state&0x7f)==0){
			bnj++;
		}else{
			printf("state= %d\n",state);
			break;
		}
		if(state>>7){
			btf++;
		}else{
			btb++;
		}
	}
	file.close();
}