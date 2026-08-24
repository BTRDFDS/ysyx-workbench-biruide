#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include <vector>
std::fstream file;
enum class Code{Idle,branch,Jal,jalr};
struct BpuRes{
	uint32_t addr,pc;
	bool hit,jump;
	Code code;
};
struct Bpu{
	uint8_t b2=2;
	uint8_t btbCnt=0;
	static const  uint32_t BtbBits = 2;
	static const  uint32_t BtbSize = 1<<BtbBits;
	static const  uint32_t BtbMask = BtbSize-1;
	uint32_t btbPc[BtbSize]{};
	uint32_t btbAddr[BtbSize]{};
	Code btbCode[BtbSize]{};
	Bpu(){
		for(int i=0;i<BtbSize;i++){
			btbPc[i] = 0;
			btbAddr[i] = 0;
			btbCode[i] = Code::Idle;
		}
	}
	BpuRes locate(uint32_t pc){
		BpuRes res;
		res.pc=pc;
		uint32_t i;
		for(i=0;i<BtbSize;i++){
			if(btbPc[i]==pc && btbCode[i]!=Code::Idle){
				res.hit = true;
				break;
			}
		}
		res.code = btbCode[i];
		switch(btbCode[i]){
			case Code::branch	:res.jump = b2 >=2;break;
			case Code::Jal		:res.jump = true;break;
			case Code::jalr		:res.jump = true;break;
			case Code::Idle		:res.jump = false;break;
		}
		if(res.hit && res.jump)res.addr = btbAddr[i];
		else res.addr = pc+4;
		return res;
	}
	void update(uint32_t pc,uint32_t addr,bool pred,bool btb,bool prTo,Code btTo){
		if(btb){
			bool hit = false;
			int i;
			for(i=0;i<BtbSize;i++){
				if(btbPc[i]==pc){
					hit = true;
					break;
				}
			}
			if(hit){
				btbAddr[i] = addr;
				btbCode[i] = btTo;
			}else{
				btbPc	[btbCnt] = pc;
				btbAddr	[btbCnt] = addr;
				btbCode	[btbCnt] = btTo;
				btbCnt = (btbCnt+1)%BtbSize;
			}
		}
		if(pred){
			if(prTo){if(b2<3){b2++;}}
			else 	{if(b2>0){b2--;}}
		}
	}
};
int main() {
	Bpu bpu;
	// file.open("./bin/BJRmicrobench-train.bin", std::ios::in | std::ios::binary);
	file.open("./bin/BJRadd.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/BJRdiv.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/BJRdummy.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t ju{},jr{},bi{},bn{},hit{},miss{},mhBP2{},missBP2{};
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
			if((cnt-hit)!=(mhBP2+missBP2))printf("miss error\n");
			printf("hit= %ld[%f]\n",hit,hit/(float)cnt);
			printf("miss= %ld[%f]\n",miss,miss/(float)cnt);
			printf("mhBP2= %ld[%f]\n",mhBP2,mhBP2/(float)miss);
			printf("missBP2= %ld[%f]\n",missBP2,missBP2/(float)miss);
			uint64_t hitBP2 = hit+mhBP2;
			printf("hitBP2= %ld[%f]\n",hitBP2,hitBP2/(float)cnt);
			break;
		}
        bool branch{},jump{},sext{},jal{},jalr{};
		file.read((char*)&state, sizeof(state));
        if(state&0b1)	branch = true;
		if((state>>1)&0b1)jump = true;
		if((state>>2)&0b1)sext = true;
		if(jump){file.read((char*)&addr, sizeof(addr));}
		else {addr = pc+4;}
		if(!branch){
			if(sext)jalr = true;
			else	jal	 = true;
		}
		if(branch){
			if(jump)	bi++;
			else		bn++;
		}
		if(jalr)jr++;
		if(jal )ju++;
		uint32_t rightPc = jump?addr:(pc+4);

		BpuRes res = bpu.locate(pc);
		uint32_t dnpc = res.addr;
		switch(res.code){
			case Code::branch:
				if(dnpc!=rightPc){
					dnpc=rightPc;
					bpu.update(pc,rightPc,true,true,jump,Code::branch);
				}else{
					bpu.update(pc,rightPc,true,false,jump,Code::branch);
				}
				break;
			case Code::Jal:
				if(dnpc!=rightPc){
					dnpc=rightPc;
					bpu.update(pc,rightPc,false,true,false,Code::Jal);
				}break;
			case Code::jalr:
				if(dnpc!=rightPc){
					dnpc=rightPc;
					bpu.update(pc,rightPc,false,true,false,Code::jalr);
				}break;
			case Code::Idle:break;
		}


		if(dnpc!=rightPc){printf("error\n");break;}
	}
	file.close();
}