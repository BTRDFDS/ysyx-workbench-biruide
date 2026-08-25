#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include <vector>
std::fstream file;
enum class Code{Idle,Branch,Jal,Jalr};
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
		res.hit = false;
		for(i=0;i<BtbSize;i++){
			if(btbPc[i]==pc && btbCode[i]!=Code::Idle){
				res.hit = true;
				break;
			}
		}
		res.code = btbCode[i];
		switch(btbCode[i]){
			case Code::Branch	:res.jump = b2 >=2;break;
			case Code::Jal		:res.jump = true;break;
			case Code::Jalr		:res.jump = true;break;
			case Code::Idle		:res.jump = false;break;
		}
		if(res.hit && res.jump)res.addr = btbAddr[i];
		else res.addr = pc+4;
		return res;
	}
	void update(uint32_t pc,uint32_t addr,bool pred,bool btb,bool prTo,Code btTo){
		if(btb&&(btTo==Code::Branch || btTo==Code::Jal)){
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
	file.open("/home/biruide/ysyx-workbench/npc/bin/BJRmicrobench-train.bin", std::ios::in | std::ios::binary);
	// file.open("/home/biruide/ysyx-workbench/npc/bin/BJRadd.bin", std::ios::in | std::ios::binary);
	// file.open("/home/biruide/ysyx-workbench/npc/bin/BJRdiv.bin", std::ios::in | std::ios::binary);
	// file.open("/home/biruide/ysyx-workbench/npc/bin/BJRdummy.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t ju{},jr{},bi{},bn{},hit{},miss{},errJalAddr{},errJalrAddr{},errBrNotJump{},errBrJump{},errBrAddr{};
	for(uint64_t cnt=0;;cnt++){
		uint32_t addr{},pc{};
		uint8_t state{};
		if(!file.read((char*)&pc, sizeof(pc))){
			uint64_t br = bi+bn;
			miss = cnt-hit;
			printf("cnt= %ld ju= %ld[%f] jr= %ld[%f] bi= %ld[%f] bn= %ld[%f]\n",
				cnt,
				ju,ju/(float)cnt,
				jr,jr/(float)cnt,
				bi,bi/(float)br,
				bn,bn/(float)br
			);
			// if((cnt-hit)!=(mhBP2+missBP2))printf("miss error\n");
			printf("hit= %ld[%f]\n",hit,hit/(float)cnt);
			printf("miss= %ld[%f]\n",miss,miss/(float)cnt);
			printf("errJalAddr= %ld[%f](%f){%f}\n",	errJalAddr,	errJalAddr /(float)cnt,errJalAddr /(float)miss,errJalAddr /(float)ju);
			printf("errJalrAddr= %ld[%f](%f){%f}\n",errJalrAddr,errJalrAddr/(float)cnt,errJalrAddr/(float)miss,errJalrAddr/(float)jr);
			printf("errBrNotJump= %ld[%f](%f)\n",errBrNotJump,errBrNotJump/(float)cnt,errBrNotJump/(float)miss);
			printf("errBrJump= %ld[%f](%f)\n",errBrJump,errBrJump/(float)cnt,errBrJump/(float)miss);
			printf("errBrAddr= %ld[%f](%f)\n",errBrAddr,errBrAddr/(float)cnt,errBrAddr/(float)miss);
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
		if(( (branch?1:0)+(jal?1:0)+(jalr?1:0))!=1){
			printf("error %x b:%d j:%d r:%d\n",pc,branch,jal,jalr);
		}
		if(branch){
			if(jump)	bi++;
			else		bn++;
		}
		if(jalr)jr++;
		if(jal )ju++;
		uint32_t rightPc = jump?addr:(pc+4);
		Code rightCode = Code::Idle;
		if(branch)	rightCode = Code::Branch;
		if(jal)		rightCode = Code::Jal;
		if(jalr)	rightCode = Code::Jalr;

		BpuRes res = bpu.locate(pc);
		// if(rightCode==Code::Jal){
		// 	res.jump=true;
		// 	res.addr=addr;
		// 	res.hit=true;
		// 	res.code=Code::Jal;
		// }
		uint32_t dnpc = res.addr;
		switch(rightCode){
			case Code::Branch:
				if(dnpc!=rightPc){
					dnpc=rightPc;
					bpu.update(pc,rightPc,true,true,jump,rightCode);
					if(res.jump!=jump){
						if(jump)errBrNotJump++;
						else 	errBrJump++;
					}else		errBrAddr++;
				}else{
					hit++;
					bpu.update(pc,rightPc,true,false,jump,rightCode);
				}
				break;
			case Code::Jal:
				if(dnpc!=rightPc){
					errJalAddr++;
					dnpc=rightPc;
					bpu.update(pc,rightPc,false,true,jump,rightCode);
				}else{
					hit++;
					bpu.update(pc,rightPc,false,false,jump,rightCode);//TODO
				}
				break;
			case Code::Jalr:
				if(dnpc!=rightPc){
					errJalrAddr++;
					dnpc=rightPc;
					bpu.update(pc,rightPc,false,true,jump,rightCode);
				}else{
					hit++;
					bpu.update(pc,rightPc,false,false,jump,rightCode);//TODO
				}
				break;
			case Code::Idle:
				if(dnpc!=rightPc || rightCode!=res.code){
					dnpc=rightPc;
					bpu.update(pc,rightPc,true,true,jump,rightCode);
					// printf("error %8x %d!=%d\n",pc,res.code,rightCode);
				}else{
					hit++;
					bpu.update(pc,rightPc,false,false,jump,rightCode);//TODO
				}
				break;
		}

		if(dnpc!=rightPc){
			printf("error %lu %8x != %8x\n",cnt,dnpc,rightPc);break;
		}
	}
	file.close();
}