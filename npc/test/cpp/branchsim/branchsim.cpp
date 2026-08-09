#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>


std::fstream file;
int main() {
	file.open("./bin/Bdummy.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t bij{},bnj{};
	uint32_t addr,pc;
	uint8_t jump;
	for(uint64_t cnt=0;;cnt++){
		if(!file.read((char*)&pc, sizeof(pc))){
			printf("cnt= %ld bij= %ld bnj= %ld jump= %f\n",cnt,bij,bnj,bij/(float)cnt);
			break;
		}
		file.read((char*)&jump, sizeof(jump))
		if(jump==1){
			bij++;
		}else if(jump==0){
			bnj++;
		}else{
			printf("jump= %d\n");
			break;
		}
	}
	file.close();
}