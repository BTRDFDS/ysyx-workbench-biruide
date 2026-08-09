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
		if (pht[idx] < 3) pht[idx]++;
	} else {
		if (pht[idx] > 0) pht[idx]--;
	}
	ghr = ((ghr << 1) | (result ? 1 : 0)) & GSHAmask;
	
    return res;
}

bool TPGL(bool actual,uint32_t pc) {//从deepseek搞来锦标赛体验一下，但是占用空间太大了我是不会用的
    // ========== 硬件参数 ==========
    static const uint32_t TPGLbits = 10;
    static const uint32_t TPGLsize = 1u << TPGLbits;
    static const uint32_t TPGLmask = TPGLsize - 1u;

    // ========== 存储单元（SRAM + 寄存器） ==========
    static uint8_t  TPGLglobal_pht[1024];    // 全局预测器 2-bit 表
    static uint16_t TPGLlocal_history[1024]; // 局部历史模式
    static uint8_t  TPGLlocal_pht[1024];     // 局部预测器 2-bit 表
    static uint8_t  TPGLchoice_pht[1024];    // 选择器 2-bit 表
    static uint32_t TPGLglobal_ghr = 0;      // 全局历史寄存器

    // ========== 上电初始化（仅执行一次） ==========
    static bool TPGLinit = true;
    if (TPGLinit) {
        for (uint32_t i = 0; i < TPGLsize; ++i) {
            TPGLglobal_pht[i] = 2;
            TPGLlocal_pht[i] = 2;
            TPGLchoice_pht[i] = 2;
            TPGLlocal_history[i] = 0;
        }
        TPGLglobal_ghr = 0;
        TPGLinit = false;
    }

    // ========== 索引生成 ==========
    uint32_t base_idx = ((uint32_t)(pc >> 2)) & TPGLmask;

    // ========== 1. 全局预测（Gshare风格） ==========
    uint32_t g_idx = (base_idx ^ TPGLglobal_ghr) & TPGLmask;
    bool g_pred = (TPGLglobal_pht[g_idx] >= 2);

    // ========== 2. 局部预测（两级表） ==========
    uint32_t l_hist = TPGLlocal_history[base_idx];
    uint32_t l_idx = l_hist & TPGLmask;
    bool l_pred = (TPGLlocal_pht[l_idx] >= 2);

    // ========== 3. 选择器裁决 ==========
    bool use_global = (TPGLchoice_pht[base_idx] >= 2);
    bool final_pred = use_global ? g_pred : l_pred;

    // ========== 4. 更新计数器 ==========
    // 更新全局 PHT
    if (actual) { if (TPGLglobal_pht[g_idx] < 3) TPGLglobal_pht[g_idx]++; }
    else        { if (TPGLglobal_pht[g_idx] > 0) TPGLglobal_pht[g_idx]--; }

    // 更新局部 PHT
    if (actual) { if (TPGLlocal_pht[l_idx] < 3) TPGLlocal_pht[l_idx]++; }
    else        { if (TPGLlocal_pht[l_idx] > 0) TPGLlocal_pht[l_idx]--; }

    // 更新局部历史（每 PC 独享）
    TPGLlocal_history[base_idx] = (uint16_t)(((TPGLlocal_history[base_idx] << 1) | (actual ? 1u : 0u)) & TPGLmask);

    // 更新全局历史
    TPGLglobal_ghr = ((TPGLglobal_ghr << 1) | (actual ? 1u : 0u)) & TPGLmask;

    // ========== 5. 更新选择器（核心逻辑） ==========
    if (g_pred != l_pred) {
        if (g_pred == actual) { // 全局对，局部错 -> 更信任全局
            if (TPGLchoice_pht[base_idx] < 3) TPGLchoice_pht[base_idx]++;
        } else {                // 局部对，全局错 -> 更信任局部
            if (TPGLchoice_pht[base_idx] > 0) TPGLchoice_pht[base_idx]--;
        }
    }

    return final_pred;
}
int main() {
	file.open("./bin/Bmicrobench-test.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/Bdiv.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t bij{},bnj{},btf{},btb{},hitBTFN{},hitBPB1{},hitBPB2{},hitGSHA{},hitTPGL{};
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
			printf("hitTPGL= %ld[%f]\n",hitTPGL,hitTPGL/(float)cnt);
			break;
		}
		file.read((char*)&state, sizeof(state));
		if((state&0x7f)==1){file.read((char*)&addr, sizeof(addr));bij++;
		}else if((state&0x7f)==0){bnj++;
		}else{printf("state= %d\n",state);break;}
		if(state>>7){btb++;
		}else{btf++;}
		if((state&0x7f)==BTFN(state>>7)){hitBTFN++;}
		if((state&0x7f)==BPB1(state&0x7f)){hitBPB1++;}
		if((state&0x7f)==BPB2(state&0x7f)){hitBPB2++;}
		if((state&0x7f)==GSHA(state&0x7f,pc)){hitGSHA++;}
		if((state&0x7f)==TPGL(state&0x7f,pc)){hitTPGL++;}
	}
	file.close();
}