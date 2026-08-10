#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
std::fstream file;

bool BTFN(bool forward){return forward;}
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
const uint32_t BTBbits = 4;
const uint32_t BTBsize = 1<<BTBbits;
const uint32_t BTBmask = BTBsize-1;
uint32_t BTBtags[BTBsize]{};
uint32_t BTBaddr[BTBsize]{};
uint32_t BTBr(uint32_t pc){
	uint32_t BTBidx = (pc>>2)&BTBmask;
	uint32_t res{};
	if(BTBtags[BTBidx]==(pc>>(BTBbits+2))){
		res = BTBaddr[BTBidx];
	}
	// for(uint32_t i=0;i<BTBsize;i++){
	// 	if(BTBtags[i]==(pc>>2)){
	// 		res = BTBaddr[i];
	// 		break;
	// 	}
	// }
	return res;
}
void BTBw(uint32_t pc,uint32_t addr){
	uint32_t BTBidx = (pc>>2)&BTBmask;
	BTBtags[BTBidx] = (pc>>(BTBbits+2));
	BTBaddr[BTBidx] = addr;
	static uint32_t cnt{};
	// BTBtags[cnt] = pc>>2;
	// BTBaddr[cnt] = addr;
	// cnt = (cnt+1)%BTBsize;
}
int main() {
	file.open("./bin/BJdiv.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t ju{},bi{},bn{},btf{},btb{},hitBTFN{},hitBPB2{},hitBTFN_BTB{},hitBPB2_BTB{};
	for(uint64_t cnt=0;;cnt++){
		uint32_t addr{},pc{};
		uint8_t state{};
		if(!file.read((char*)&pc, sizeof(pc))){
			uint64_t br = bi+bn;
			printf("cnt= %ld ju= %ld[%f] bi= %ld[%f] bn= %ld[%f] btf= %ld[%f] btb= %ld[%f]\n",
				cnt,
				ju,ju/float(cnt),
				bi,bi/(float)br,
				bn,bn/(float)br,
				btf,btf/(float)br,
				btb,btb/(float)br
			);
			printf("hitBTFN= %ld[%f]\n",hitBTFN,hitBTFN/(float)br);
			printf("hitBPB2= %ld[%f]\n",hitBPB2,hitBPB2/(float)br);
			printf("hitBTFN_BTB= %ld[%f]\n",hitBTFN_BTB,hitBTFN_BTB/(float)cnt);
			printf("hitBPB2_BTB= %ld[%f]\n",hitBPB2_BTB,hitBPB2_BTB/(float)cnt);
			break;
		}
        bool branch{},jump{},sext{};
		file.read((char*)&state, sizeof(state));
        if(state&0b1){
			if((state>>1)&0b1)jump = true;
			if((state>>2)&0b1)sext = true;
			branch = true;
		}else jump = true;
		if(jump){file.read((char*)&addr, sizeof(addr));}
		if(branch){
			if(jump)	bi++;
			else		bn++;
			if(sext)	btb++;
			else		btf++;
		}else			ju++;

		bool btfn	= false;
		bool btb	= false;
		bool bpb2	= false;
		if(branch){
			btfn = BTFN(sext);
			bpb2 = BPB2(jump);
		}
		if(!branch || btfn || bpb2){
			btb = BTBr(pc)==addr && addr!=0;
		}
		if(branch){
			if(jump == btfn)hitBTFN++;
			if(jump == bpb2)hitBPB2++;
			if(jump == btfn && (jump?btb:1))hitBTFN_BTB++;
			if(jump == bpb2 && (jump?btb:1))hitBPB2_BTB++;
		}
		if(!branch && btb){
			hitBTFN++;
			hitBPB2++;
			hitBTFN_BTB++;
			hitBPB2_BTB++;
		}
		if(jump && !btb)BTBw(pc,addr);
	}
	file.close();
}