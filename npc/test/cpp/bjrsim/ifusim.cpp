#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include <vector>
std::fstream file;
	static uint8_t b2{2};
bool BPB2(bool result=false,bool write=false){
	bool res = b2>=2;
	if(write){
		if(result)	{if(b2<3){b2++;}}
		else 		{if(b2>0){b2--;}}
	}
	return res;
}

uint32_t BTB(uint32_t pc,bool &suce,uint32_t addr=0,bool write=false){
	const  uint32_t BTBbits = 3;
	const  uint32_t BTBsize = 1<<BTBbits;
	const  uint32_t BTBmask = BTBsize-1;
	static uint32_t BTBtags[BTBsize]{};
	static uint32_t BTBaddr[BTBsize]{};
	static uint32_t BTBcnt{};

	uint32_t res{};
	uint32_t BTBidx = (pc>>2)&BTBmask;
	suce = false;
	if(write){
		BTBtags[BTBcnt]	= pc>>2;
		BTBaddr[BTBcnt]	= addr;
		BTBcnt = (BTBcnt+1)%BTBsize;
	}else{
		for(uint32_t i=0;i<BTBsize;i++){
			if(BTBtags[i]==(pc>>2)){
				res = BTBaddr[i];
				suce = true;
				break;
			}
		}
	}
	return res;
}
int main() {
	// file.open("./bin/BJRmicrobench-train.bin", std::ios::in | std::ios::binary);
	file.open("./bin/BJRdiv.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/BJRdummy.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t ju{},jr{},bi{},bn{},hit{},miss{},mhBPB2{},missBPB2{};
	for(uint64_t cnt=0;;cnt++){
		uint32_t addr{},pc{};
		uint8_t state{};
		if(!file.read((char*)&pc, sizeof(pc))){
			uint64_t br = bi+bn;
			miss = cnt-hit;
			printf("cnt= %ld ju= %ld[%f] jr= %ld[%f] bi= %ld[%f] bn= %ld[%f]\n",
				cnt,
				ju,ju/float(cnt),
				jr,jr/(float)br,
				bi,bi/(float)br,
				bn,bn/(float)br
			);
			if((cnt-hit)!=(mhBPB2+missBPB2))printf("miss error\n");
			printf("hit= %ld[%f]\n",hit,hit/(float)cnt);
			printf("miss= %ld[%f]\n",miss,miss/(float)cnt);
			printf("mhBPB2= %ld[%f]\n",mhBPB2,mhBPB2/(float)miss);
			printf("missBPB2= %ld[%f]\n",missBPB2,missBPB2/(float)miss);
			uint64_t hitBPB2 = hit+mhBPB2;
			printf("hitBPB2= %ld[%f]\n",hitBPB2,hitBPB2/(float)cnt);
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
		bool isJump{},isGet{true};
		uint32_t getAddr{};
		if(branch)	{isJump = BPB2();}
		else		{isJump = true;}
		if(isJump&&(branch || (~branch && ~sext))){getAddr = BTB(pc,isGet);}
		// printf("pc= %8x br= %d jump= %d sext= %d addr= %8x isJump= %d isGet= %d getAddr= %8x b2= %2d\n",pc,branch,jump,sext,addr,isJump,isGet,getAddr,b2);
		if(jump){
			if(isJump){
				if(isGet&&getAddr==addr)hit++;
				else {
					mhBPB2++;
					if(branch)BPB2(true,true);
					if(branch || (!sext))BTB(pc,isGet,addr,true);
				}
			}else {
				missBPB2++;
				if(branch)BPB2(true,true);
				if(branch || (!sext))BTB(pc,isGet,addr,true);
			}
		}else{
			if(isJump&&(isGet)){
				missBPB2++;
				if(branch)BPB2(false,true);
			}else{
				hit++;
			}
		}
	}
	file.close();
}