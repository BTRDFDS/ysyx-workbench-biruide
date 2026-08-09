#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
std::fstream file;

bool BTFN(bool forward){
	if(forward){
		return true;
	}else{
		return false;
	}
}
bool BPB1(bool result){
	static bool b1{1};
	bool res = b1;
	b1 = result;
	return res;
}
bool BPB2(bool result){
	static uint8_t b2{2};
	bool res = b2>=2;
	if(result){
		if(b2<3){b2++;}
	}else{
		if(b2>0){b2--;}
	}
	return res;
}
bool GSHA(bool result,uint32_t pc){//全局历史预测器
	const uint32_t GSHAbits = 10;
	const uint32_t GSHAsize = 1 << GSHAbits;
	const uint32_t GSHAmask = GSHAsize - 1;
	static uint8_t pht[GSHAsize];
	static uint32_t ghr = 0;
	static bool init = true;
	if(init){
		for(uint32_t i=0;i<GSHAsize;i++){
			pht[i] = 2;
		}
		ghr = 0;
		init = false;
	}
	uint32_t idx = ((pc >> 2) ^ ghr) & GSHAmask;
	bool res = (pht[idx] >= 2);
	if (result) {
		if (pht[idx] < 3) ++pht[idx];
	} else {
		if (pht[idx] > 0) --pht[idx];
	}
	ghr = ((ghr << 1) | (result ? 1u : 0u)) & GSHAmask;
	
    return res;
}

int main() {
	file.open("./bin/Bmicrobench-test.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t bij{},bnj{},btf{},btb{},hitBTFN{},hitBPB1{},hitBPB2{},hitGSHA{};
	uint32_t addr,pc;
	uint8_t state;
	for(uint64_t cnt=0;;cnt++){
		if(!file.read((char*)&pc, sizeof(pc))){
			printf("cnt= %ld bij= %ld[%f] bnj= %ld[%f] btf= %ld[%f] btb= %ld[%f]\n",
				cnt,
				bij,bij/(float)cnt,
				bnj,bnj/(float)cnt,
				btf,btf/(float)cnt,
				btb,btb/(float)cnt
			);
			printf("hitBTFN= %ld[%f]\n",hitBTFN,hitBTFN/(float)cnt);
			printf("hitBPB1= %ld[%f]\n",hitBPB1,hitBPB1/(float)cnt);
			printf("hitBPB2= %ld[%f]\n",hitBPB2,hitBPB2/(float)cnt);
			printf("hitGSHA= %ld[%f]\n",hitGSHA,hitGSHA/(float)cnt);
			break;
		}
		file.read((char*)&state, sizeof(state));
		if((state&0x7f)==1){file.read((char*)&addr, sizeof(addr));bij++;
		}else if((state&0x7f)==0){bnj++;
		}else{printf("state= %d\n",state);break;}
		if(state>>7){btb++;
		}else{btf++;}
		if((state&0x7f)==BTFN(state>>7)){hitBTFN++;}
		if((state&0x7f)==BPB1(state>>7)){hitBPB1++;}
		if((state&0x7f)==BPB2(state>>7)){hitBPB2++;}
		if((state&0x7f)==GSHA(state>>7,pc)){hitGSHA++;}
	}
	file.close();
}