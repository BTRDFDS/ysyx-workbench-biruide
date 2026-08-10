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
bool TAGE(bool actual,uint32_t pc) {//也是从deepseek搞来的
    // ========== 1. 硬件参数（编译期固定） ==========
    static const uint32_t TAGEbanks = 4;          // 4 个标记表（不含基础表）
    static const uint32_t TAGEtable_size = 1024;  // 每个表 1024 项
    static const uint32_t TAGEmask = TAGEtable_size - 1u;
    
    // 各级历史长度（几何级数）：基础表(0)，表1(4)，表2(8)，表3(16)，表4(32)
    static const uint32_t TAGEhist_len[5] = {0, 4, 8, 16, 32};
    // 对应的掩码，用于截取 GHR 的低位（避免移位溢出）
    static const uint32_t TAGEhist_mask[5] = {0, 0xF, 0xFF, 0xFFFF, 0xFFFFFFFF};

    // ========== 2. 存储单元（SRAM 阵列） ==========
    // 计数器表（2-bit 饱和计数器）：[表编号][表项索引]
    static uint8_t TAGEpred[5][1024];
    // 标签表：用于验证当前 PC+历史 是否命中该项
    static uint32_t TAGEtag[5][1024];
    // 有用性计数器（2-bit）：记录该表项是否“经常被用到”，用于替换策略
    static uint8_t TAGEuseful[5][1024];

    // 全局历史寄存器（GHR）
    static uint32_t TAGEghr = 0;

    // ========== 3. 上电复位（仅执行一次） ==========
    static bool TAGEinit = true;
    if (TAGEinit) {
        for (uint32_t i = 0; i < 5; ++i) {
            for (uint32_t j = 0; j < TAGEtable_size; ++j) {
                TAGEpred[i][j] = 2;    // 初始化为“弱跳转”
                TAGEuseful[i][j] = 0;  // 初始为“无用”
                TAGEtag[i][j] = 0;
            }
        }
        TAGEghr = 0;
        TAGEinit = false;
    }

    // ========== 4. 基础索引（PC 右移 2 位去掉对齐低 2 位） ==========
    uint32_t base_pc = (uint32_t)(pc >> 2);

    // ========== 5. 查找：从最长历史（表4）到最短历史（表1） ==========
    int8_t TAGEchosen_bank = -1;      // -1 表示未命中任何标记表
    uint8_t TAGEchosen_pred = 2;      // 默认使用基础表预测

    for (uint32_t bank = TAGEbanks; bank >= 1; --bank) {
        // 截取 GHR 的低 N 位作为该级的历史
        uint32_t hist = TAGEghr & TAGEhist_mask[bank];
        // 生成索引：PC 与历史异或，再取低 10 位
        uint32_t idx = (base_pc ^ hist) & TAGEmask;
        // 生成标签：PC 与完整 GHR 异或（实际硬件常用更复杂哈希，此处简化）
        uint32_t tag = base_pc ^ TAGEghr;

        // 检查是否命中（标签匹配）
        if (TAGEtag[bank][idx] == tag) {
            TAGEchosen_bank = (int8_t)bank;
            TAGEchosen_pred = TAGEpred[bank][idx];
            break;  // 命中即停止，因为越长的历史优先级越高
        }
    }

    // ========== 6. 基础表预测（始终作为兜底） ==========
    uint32_t base_idx = base_pc & TAGEmask;
    uint8_t base_pred = TAGEpred[0][base_idx];

    // ========== 7. 最终预测结果 ==========
    bool final_pred = (TAGEchosen_bank == -1) ? (base_pred >= 2) : (TAGEchosen_pred >= 2);

    // ========== 8. 更新计数器 ==========
    // 8.1 更新基础表计数器（无论是否命中标记表，基础表始终更新）
    if (actual) { if (TAGEpred[0][base_idx] < 3) TAGEpred[0][base_idx]++; }
    else        { if (TAGEpred[0][base_idx] > 0) TAGEpred[0][base_idx]--; }

    // 8.2 如果命中了某个标记表，更新该表的计数器
    if (TAGEchosen_bank != -1) {
        uint32_t bank = (uint32_t)TAGEchosen_bank;
        if (actual) { if (TAGEpred[bank][(base_pc ^ (TAGEghr & TAGEhist_mask[bank])) & TAGEmask] < 3) 
                         TAGEpred[bank][(base_pc ^ (TAGEghr & TAGEhist_mask[bank])) & TAGEmask]++; }
        else        { if (TAGEpred[bank][(base_pc ^ (TAGEghr & TAGEhist_mask[bank])) & TAGEmask] > 0) 
                         TAGEpred[bank][(base_pc ^ (TAGEghr & TAGEhist_mask[bank])) & TAGEmask]--; }
    }

    // ========== 9. 错误预测时的分配策略（TAGE 的精髓） ==========
    // 只在最终预测错误时，才尝试在【比命中表更长历史】的表中分配新条目
    if (final_pred != actual) {
        uint32_t start_bank = (TAGEchosen_bank == -1) ? 1 : ((uint32_t)TAGEchosen_bank + 1);
        for (uint32_t bank = start_bank; bank <= TAGEbanks; ++bank) {
            uint32_t hist = TAGEghr & TAGEhist_mask[bank];
            uint32_t idx = (base_pc ^ hist) & TAGEmask;
            uint32_t tag = base_pc ^ TAGEghr;

            // 替换策略：如果该表项“无用”（useful == 0），直接覆盖
            if (TAGEuseful[bank][idx] == 0) {
                TAGEtag[bank][idx] = tag;
                TAGEpred[bank][idx] = 2;        // 新条目初始为弱跳转
                TAGEuseful[bank][idx] = 1;      // 标记为“刚分配，有用”
                break;  // 只分配一次
            } else {
                // 如果表项有用，降低其有用性计数（给未来替换机会）
                if (TAGEuseful[bank][idx] > 0) TAGEuseful[bank][idx]--;
            }
        }
    } else {
        // 如果预测正确，且命中了标记表，增加该表项的“有用性”
        if (TAGEchosen_bank != -1) {
            uint32_t bank = (uint32_t)TAGEchosen_bank;
            uint32_t idx = (base_pc ^ (TAGEghr & TAGEhist_mask[bank])) & TAGEmask;
            if (TAGEuseful[bank][idx] < 3) TAGEuseful[bank][idx]++;
        }
    }

    // ========== 10. 更新全局历史寄存器（左移，低位存本次结果） ==========
    TAGEghr = ((TAGEghr << 1) | (actual ? 1u : 0u)) & 0xFFFFFFFF;

    return final_pred;
}
uint32_t BTB(uint32_t pc,uint32_t addr){
	static const uint32_t BTBbits = 4;
	static const uint32_t BTBsize = 1<<BTBbits;
	static const uint32_t BTBmask = BTBsize-1;
	static uint32_t BTBtags[BTBsize]{};
	static uint32_t BTBaddr[BTBsize]{};
	static uint32_t cnt{};
	uint32_t BTBidx = (pc>>2)&BTBmask;
	uint32_t res{};
	// if(BTBtags[BTBidx]==(pc>>(BTBbits+2))){
	// 	res = BTBaddr[BTBidx];
	// }else 
	for(uint32_t i=0;i<BTBsize;i++){
		if(BTBtags[i]==(pc>>2)){
			res = BTBaddr[i];
			break;
		}
	}
	if(res==0 && addr!=0){
		// BTBtags[BTBidx] = (pc>>(BTBbits+2));
		// BTBaddr[BTBidx] = addr;
		BTBtags[cnt] = pc>>2;
		BTBaddr[cnt] = addr;
		cnt = (cnt+1)%BTBsize;
	}
	return res;
}
int main() {
	file.open("./bin/Bmicrobench-train.bin", std::ios::in | std::ios::binary);
	// file.open("./bin/Bdiv.bin", std::ios::in | std::ios::binary);
	if (!file.is_open()) {printf("Failed to open file\n");return -1;}
	uint64_t bij{},bnj{},btf{},btb{},hitBTFN{},hitBPB1{},hitBPB2{},hitGSHA{},hitTPGL{},hitTAGE{},hitBTB{},hitBTFN_BTB{},hitBPB2_BTB{};
	for(uint64_t cnt=0;;cnt++){
		uint32_t addr{},pc{};
		uint8_t state{};
		if(!file.read((char*)&pc, sizeof(pc))){
			printf("cnt= %ld bij= %ld[%f] bnj= %ld[%f] btf= %ld[%f] btb= %ld[%f]\n",
				cnt,
				bij,bij/(float)cnt,
				bnj,bnj/(float)cnt,
				btf,btf/(float)cnt,
				btb,btb/(float)cnt
			);
			printf("hitBTFN= %ld[%f]\n",hitBTFN,hitBTFN/(float)cnt);
			// printf("hitBPB1= %ld[%f]\n",hitBPB1,hitBPB1/(float)cnt);
			printf("hitBPB2= %ld[%f]\n",hitBPB2,hitBPB2/(float)cnt);
			// printf("hitGSHA= %ld[%f]\n",hitGSHA,hitGSHA/(float)cnt);
			// printf("hitTPGL= %ld[%f]\n",hitTPGL,hitTPGL/(float)cnt);
			// printf("hitTAGE= %ld[%f]\n",hitTAGE,hitTAGE/(float)cnt);
			printf("hitBTB= %ld[%f]\n",hitBTB,hitBTB/(float)cnt);
			printf("hitBTFN_BTB= %ld[%f]\n",hitBTFN_BTB,hitBTFN_BTB/(float)cnt);
			printf("hitBPB2_BTB= %ld[%f]\n",hitBPB2_BTB,hitBPB2_BTB/(float)cnt);
			break;
		}
		file.read((char*)&state, sizeof(state));
		bool State_btfn = false;
		bool State_btb = false;
		bool State_bpb2 = false;
		if((state&0x7f)==1){
			file.read((char*)&addr, sizeof(addr));
			bij++;
			if(addr==BTB(pc,addr)){
				hitBTB++;
				State_btb = true;
			}
		}else if((state&0x7f)==0){bnj++;
		}else{printf("state= %d\n",state);break;}
		if(state>>7){btb++;
		}else{btf++;}
		if((state&0x7f)==BTFN(state>>7)){hitBTFN++;State_btfn=true;}
		// if((state&0x7f)==BPB1(state&0x7f)){hitBPB1++;}
		if((state&0x7f)==BPB2(state&0x7f)){hitBPB2++;State_bpb2=true;}
		// if((state&0x7f)==GSHA(state&0x7f,pc)){hitGSHA++;}
		// if((state&0x7f)==TPGL(state&0x7f,pc)){hitTPGL++;}
		// if((state&0x7f)==TAGE(state&0x7f,pc)){hitTAGE++;}
		if(State_btfn&&State_btb)hitBTFN_BTB++;
		if(State_bpb2&&State_btb)hitBPB2_BTB++;
	}
	file.close();
}