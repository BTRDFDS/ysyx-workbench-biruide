#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include <vector>
std::fstream file;
bool BPB2(bool result){
	static uint8_t b2{2};
	bool res = b2>=2;
	if(result)	{if(b2<3){b2++;}}
	else 		{if(b2>0){b2--;}}
	return res;
}
int main() {
	file.open("./bin/BJRmicrobench-test.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/BJdiv.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/BJRdummy.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t ju{},jr{},bi{},bn{},hitBTFN{},hitBPB2{};
	for(uint64_t cnt=0;;cnt++){
		uint32_t addr{},pc{};
		uint8_t state{};
		if(!file.read((char*)&pc, sizeof(pc))){
			uint64_t br = bi+bn;
			printf("cnt= %ld ju= %ld[%f] jr= %ld[%f] bi= %ld[%f] bn= %ld[%f]\n",
				cnt,
				ju,ju/float(cnt),
				jr,jr/(float)br,
				bi,bi/(float)br,
				bn,bn/(float)br
			);
			printf("bpb2= %ld[%f]\n",hitBPB2,hitBPB2/(float)cnt);
			break;
		}
        bool branch{},jump{},sext{};
		file.read((char*)&state, sizeof(state));
        if(state&0b1)	branch = true;
		if((state>>1)&0b1)jump = true;
		if((state>>2)&0b1)sext = true;
		if(jump){file.read((char*)&addr, sizeof(addr));}
		if(branch){
			if(jump)	bi++;
			else		bn++;
		}else{
			if(sext)	jr++;
			else		ju++;
		}
		if(branch){
			bool res = BPB2(jump);
			// printf("res=%d pc=%8x jump=%d addr=%8x\n",res,pc,jump,addr);
			if(res==jump){
				hitBPB2++;
			}else{
			}
		}
		else{
			hitBPB2++;
		}
	}
	file.close();
}