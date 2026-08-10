#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include <vector>
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
bool TPF2(bool forward,bool result){
	static uint8_t tp{2};
	bool res= (tp==2)?forward:tp>2;
	if(result)	if(tp<3)tp++;
	else		if(tp>0)tp--;
	return res;
}
// uint32_t BTBbits = 4;
// uint32_t BTBsize = 1<<BTBbits;
// uint32_t BTBmask = BTBsize-1;
// uint32_t BTBtags[BTBsize]{};
// uint32_t BTBaddr[BTBsize]{};
// uint32_t use[BTBsize]{};
// uint32_t BTB(uint32_t pc,uint32_t addr=0,bool write=false){
// 	uint32_t res{};
// 	uint32_t BTBidx = (pc>>2)&BTBmask;
// 	// if(write){
// 	// 	BTBtags[BTBidx] = (pc>>(BTBbits+2));
// 	// 	BTBaddr[BTBidx] = addr;
// 	// }else{
// 	// 	if(BTBtags[BTBidx]==(pc>>(BTBbits+2))){
// 	// 		res = BTBaddr[BTBidx];
// 	// 	}
// 	// }
// 	if(write){
// 		// uint32_t min{};
// 		// for(int i=0;i<BTBsize;i++)if(use[min]>use[i])min = i;
// 		// // printf("%d : %d\n",min,use[min]);
// 		// BTBtags[min] = pc>>2;
// 		// BTBaddr[min] = addr;
// 		// use[min] = 0;
// 		// for(int i=0;i<BTBsize;i++)use[i] /= 2;
// 		static uint32_t cnt{};
// 		BTBtags[cnt] = pc>>2;
// 		BTBaddr[cnt] = addr;
// 		cnt = (cnt+1)%BTBsize;
// 	}else{
// 		for(uint32_t i=0;i<BTBsize;i++){
// 			if(BTBtags[i]==(pc>>2)){
// 				res = BTBaddr[i];
// 				use[i]++;
// 				break;
// 			}
// 		}
// 	}
// 	return res;
// }
class BTB{
	uint32_t bits,size,mask,cnt;
	std::vector<uint32_t> tags,addr,uses;
	public:
		BTB(uint32_t bit= 4){
			bits = bit;
			size = 1<<bits;
			mask = size-1;
			cnt = 0;
			tags.resize(size);
			addr.resize(size);
			uses.resize(size);
		}
		uint32_t pcl(uint32_t pc,uint32_t tobe=0,bool write=false){
			uint32_t res{};
			uint32_t idx = (pc>>2)&mask;
			if(write){
				tags[idx] = (pc>>(bits+2));
				addr[idx] = tobe;
			}else{
				if(tags[idx]==(pc>>(bits+2))){
					res =addr[idx];
				}
			}
			return res;
		}
		uint32_t all(uint32_t pc,uint32_t tobe=0,bool write=false){
			uint32_t res{};
			if(write){
				tags[cnt] = pc>>2;
				addr[cnt] = tobe;
				cnt = (cnt+1)%size;
			}else{
				for(uint32_t i=0;i<size;i++){
					if(tags[i]==(pc>>2)){
						res = addr[i];
						uses[i]++;
						break;
					}
				}
			}
			return res;
		}
	};
int main() {
	BTB btb0(3);
	BTB btb1(1);
	file.open("./bin/BJRmicrobench-train.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/BJdiv.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/BJdummy.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t ju{},jr{},bi{},bn{},btf{},btb{},hitBTFN{},hitBPB2{},hitTPF2{},hitBTFN_BTB{},hitBPB2_BTB{},hitTPF2_BTB{};
	for(uint64_t cnt=0;;cnt++){
		uint32_t addr{},pc{};
		uint8_t state{};
		if(!file.read((char*)&pc, sizeof(pc))){
			uint64_t br = bi+bn;
			printf("cnt= %ld ju= %ld[%f] jr= %ld[%f] bi= %ld[%f] bn= %ld[%f] btf= %ld[%f] btb= %ld[%f]\n",
				cnt,
				ju,ju/float(cnt),
				jr,jr/(float)br,
				bi,bi/(float)br,
				bn,bn/(float)br,
				btf,btf/(float)br,
				btb,btb/(float)br
			);
			printf("hitBTFN= %ld[%f]\n",hitBTFN,hitBTFN/(float)br);
			printf("hitBPB2= %ld[%f]\n",hitBPB2,hitBPB2/(float)br);
			// printf("hitTPF2= %ld[%f]\n",hitTPF2,hitTPF2/(float)br);
			printf("hitBTFN_BTB= %ld[%f]\n",hitBTFN_BTB,hitBTFN_BTB/(float)cnt);
			printf("hitBPB2_BTB= %ld[%f]\n",hitBPB2_BTB,hitBPB2_BTB/(float)cnt);
			// printf("hitTPF2_BTB= %ld[%f]\n",hitTPF2_BTB,hitTPF2_BTB/(float)cnt);
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
			if(sext)	btb++;
			else		btf++;
		}else{
			if(sext)	jr++;
			else		ju++;
		}

		bool btfn	= false;
		bool bpb2	= false;
		bool tpf2	= false;
		bool btb	= false;
		if(branch){
			btfn = BTFN(sext);
			bpb2 = BPB2(jump);
			tpf2 = TPF2(sext,jump);
		}
		if(!branch || btfn || bpb2 || tpf2){
			if(!branch && sext)	btb = btb1.all(pc)==addr && addr!=0;
			else				btb = btb0.all(pc)==addr && addr!=0;
		}
		if(branch){
			if(jump == btfn)hitBTFN++;
			if(jump == bpb2)hitBPB2++;
			if(jump == tpf2)hitTPF2++;
			if(jump == btfn && (jump?btb:1))hitBTFN_BTB++;
			if(jump == bpb2 && (jump?btb:1))hitBPB2_BTB++;
			if(jump == tpf2 && (jump?btb:1))hitTPF2_BTB++;
		}
		if(!branch){
			hitBTFN++;
			hitBPB2++;
			hitTPF2++;
		}
		if(!branch && btb){
			hitBTFN_BTB++;
			hitBPB2_BTB++;
			hitTPF2_BTB++;
		}
		if(jump && !btb){
			if(!branch && sext)	btb1.all(pc,addr,true);
			else				btb0.all(pc,addr,true);
		}
	}
	file.close();
}