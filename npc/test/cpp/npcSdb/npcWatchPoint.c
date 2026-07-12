#include <npcSdb.h>
WP wp_pool[NR_WP] = {};
uint32_t tailWp=0;
void init_wp_pool() {
	for (uint32_t i=0;i<NR_WP;i++){
		wp_pool[i].value=0;
		wp_pool[i].use=false;
		//清空wp_pool[i].require
		memset(wp_pool[i].require,0,sizeof(char)*wpRequireLen);
	}
	tailWp=0;
}

/* TODO: Implement the functionality of watchpoint */

uint32_t new_wp(){//其中new_wp()从free_链表中返回一个空闲的监视点结构
	if(tailWp==NR_WP){
		printf("no free watchpoint\n");
		return tailWp;
	}
	wp_pool[tailWp].use=true;
	tailWp++;
	return tailWp-1;
}
void free_wp(){
	if(tailWp==0){
			printf("no watchpoint\n");
	}else{
		wp_pool[tailWp-1].use=false;
		tailWp--;
	}
}
int checkWp(){
	bool success=false;
	uint32_t val;
	for(uint32_t i=0;i<tailWp&&wp_pool[i].use==true;i++){
		val=expr(wp_pool[i].require,&success);
		if(success&&val!=wp_pool[i].value&&wp_pool[i].use==true){
			printf("pc = %x watchpoint %d : %s form 0x%x to 0x%x | %u to %u | %d to |%d\n",npcsdbGpr[0],i,wp_pool[i].require,wp_pool[i].value,val,wp_pool[i].value,val,wp_pool[i].value,val);
			wp_pool[i].value=val;
			return 0;
		}
	}
	return -1;
}