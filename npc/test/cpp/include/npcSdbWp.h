#ifndef _NPC_SDB_WP_
#define _NPC_SDB_WP_
#include "npcSdb.h"
#include "npcDrive.h"
#include "npcSdbExpr.h"
#define NR_WP 32
#define wpRequireLen 256
typedef struct watchpoint {
  char require[wpRequireLen];
  bool use;//有没有被使用
  uint32_t value;//当前值
} WP;
inline WP wp_pool[NR_WP] = {};
inline uint32_t tailWp=0;
inline void init_wp_pool() {
	for (uint32_t i=0;i<NR_WP;i++){
		wp_pool[i].value=0;
		wp_pool[i].use=false;
		//清空wp_pool[i].require
		memset(wp_pool[i].require,0,sizeof(char)*wpRequireLen);
	}
	tailWp=0;
}
inline uint32_t new_wp(){//其中new_wp()从free_链表中返回一个空闲的监视点结构
	if(tailWp==NR_WP){
		printf("no free watchpoint\n");
		return tailWp;
	}
	wp_pool[tailWp].use=true;
	tailWp++;
	return tailWp-1;
}
inline void free_wp(){
	if(tailWp==0){
			printf("no watchpoint\n");
	}else{
		wp_pool[tailWp-1].use=false;
		tailWp--;
	}
}
inline bool NpcsdbCheck(){
	bool success=false;
	uint32_t val;
	for(uint32_t i=0;i<tailWp&&wp_pool[i].use==true;i++){
		val=expr(wp_pool[i].require,&success);
		if(success&&val!=wp_pool[i].value&&wp_pool[i].use==true){
			printf("pc = %x watchpoint %d : %s form 0x%x to 0x%x | %u to %u | %d to |%d\n",regs[0],i,wp_pool[i].require,wp_pool[i].value,val,wp_pool[i].value,val,wp_pool[i].value,val);
			wp_pool[i].value=val;
			return false;
		}
	}
	return true;
}
#endif