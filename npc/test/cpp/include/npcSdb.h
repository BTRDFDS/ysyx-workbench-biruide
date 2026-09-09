#ifndef _NPC_SDB_H_

#define _NPC_SDB_H_
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <regex.h>

#include <readline/readline.h>
#include <readline/history.h>

const char *npcsdbGprName[32] = {//注意：0号寄存器替代为pc
"pc", "ra",  "sp",  "gp", "tp", "t0", "t1", "t2",
"s0", "s1",  "a0",  "a1", "a2", "a3", "a4", "a5",
"a6", "a7",  "s2",  "s3", "s4", "s5", "s6", "s7",
"s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};
#include "npcConfig.h"
#include "npcCounter.h"
#include "npcMem.h"
#include "npcSdbExpr.h"
#include "npcSdbWp.h"

#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))
//提供
// extern void NpcSdbMainloop();
// extern void NpcSdbInit();
//需求
extern void NpcsdbRun(uint32_t times);

static int is_batch_mode = false;

void init_regex();
/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
	static char *line_read = NULL;

	if (line_read) {
		free(line_read);
		line_read = NULL;
	}

	line_read = readline("(\033[1;35m npcSdb) \033[0m");

	if (line_read && *line_read) {
		add_history(line_read);
	}

	return line_read;
}

static int cmd_c(char *args) {
	NpcsdbRun(0);
	return 0;
}


static int cmd_si(char *args) {
	int step=1;
	if(args != NULL) {step=atoi(args);}
	NpcsdbRun(step);
	return 0;
}

static int cmd_info(char *args) {
	if(args == NULL) {printf("r - print register\nw - print watchpoints\n");return 1;}
	switch (*args)
	{
	case 'r':
		for(int i=0;i<4;i++){
			for(int j=0;j<8;j++){
				printf("%2d:%3s=%8x ",i*8+j,npcsdbGprName[i*8+j],regs[i*8+j]);
			}
			printf("\n");
		}
		break;
	case 'w':{
			bool has=false;
			for(int i=0;wp_pool[i].use == true&&i<NR_WP;i++){
				if(wp_pool[i].use == true){
					has=true;
					printf("no %d : %s | now value=%u\n",i,wp_pool[i].require,wp_pool[i].value);
				}
			}
			if(has==false){printf("no watchpoints\n");}
		break;}
	default:
		printf("%c is unknow\nr - print register\nw - print watchpoints\n", *args);
		break;
	}
	return 0;
}


static int cmd_x(char *args) {
	if(args==NULL) {printf("x N EXPR,whitout N EXPR\n");return 0;}
	char *n=strtok(args, " ");
	if(n==NULL) {printf("x N EXPR,without N\n");return 0;}
	char *EXPR = strtok(NULL, " ");
	if(EXPR==NULL) {printf("x N EXPR,without EXPR\n");return 0;}
	// paddr_t addr = strtol(EXPR,NULL,0);
	// int len = strtol(n,NULL,0);
	extern uint32_t m[];
	bool success;
	uint32_t addr = expr(EXPR,&success);
	if(success!=true){printf("EXPR is error");return 0;}
	int len = expr(n,&success);
	if(success!=true){printf("N is error");return 0;}
	// printf("%x,%x\n",addr,len);
	// vaddr_read(addr,len);
	printf("pc = %x\n",regs[0]);
	for(int i=0;i<len;i++) {
		// printf("%x:%x",addr,pmem[addr]);
		// printf("%x:%8x\n",addr+i*4,vaddr_read(addr+i*4,4));
		printf("%x:%8x\n",addr+i*4,NpcsdbReadMem(addr+i*4));
	}
	return 0;
}


static int cmd_p(char *args) {
	bool success;
	uint32_t val=expr(args,&success);
	if(success==true) printf("%u or 0x%x\n",val,val);
	return 0;
}


static int cmd_w(char *args) {
	if(args==NULL) {printf("need somethinng\n");return 0;}
	uint32_t number =new_wp();
	bool success=false;
	strcpy(wp_pool[number].require,args);
	wp_pool[number].value = expr(wp_pool[number].require,&success);
	if(success!=true){printf("expr is wrong\n");free_wp();return 0;}
	printf("add watchpoints no.%d is %s\n",number,wp_pool[number].require);

	// wp->line=strtoul(args,NULL,0);
	// printf("add no %d in line 0x%x\n",wp->NO,wp->line);
	return 0;
}

static int cmd_d(char *args) {
	if(args==NULL) {printf("need no\n");return 0;}
	int no = strtoul(args,NULL,0);
	if(no<0||no>tailWp){printf("%d is err\n",no);return 0;}
	for(int i=0;wp_pool[i].use == true&&i<NR_WP;i++){
		if(i == no) {
			for(;wp_pool[i].use == true&&i<NR_WP-1;i++){
				if(wp_pool[i+1].use == true){
					wp_pool[i].value = wp_pool[i+1].value;
					strcpy(wp_pool[i].require,wp_pool[i+1].require);
				}
				else{break;}
			}
			free_wp();
			printf("delete no %d\n",no);
			return 0;
		}
	}
	printf("no %d is not exist\n",no);
	return 0;
}




static int cmd_q(char *args) {
	return -1;
}

static int cmd_help(char *args);
int cmd_t(char *args);
static struct {
	const char *name;
	const char *description;
	int (*handler) (char *);
} cmd_table [] = {
	{ "help", "Display information about all supported commands", cmd_help },
	{ "c", "Continue the execution of the program", cmd_c },
	{ "q", "Exit NEMU", cmd_q },
	{ "si", "Step into one instruction", cmd_si },
	{ "info", "Print someshing status", cmd_info },
	{ "x", "Print memory", cmd_x },
	{ "p", "Print value", cmd_p },
	{ "w", "Set watching point", cmd_w },
	{ "d", "Delete watching point", cmd_d },
	{ "t", "do somr test", cmd_t}
};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
	/* extract the first argument */
	char *arg = strtok(NULL, " ");
	int i;

	if (arg == NULL) {
		/* no argument given */
		for (i = 0; i < NR_CMD; i ++) {
			printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
		}
	}
	else {
		for (i = 0; i < NR_CMD; i ++) {
			if (strcmp(arg, cmd_table[i].name) == 0) {
				printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
				return 0;
			}
		}
		printf("Unknown command '%s'\n", arg);
	}
	return 0;
}
int cmd_t(char *args) {
	if(args == NULL) {
		printf("without order,then will show help\n");
		cmd_help(NULL);
	}else{
		switch (*args)
		{
			case 'p':
				gen_expr();
				break;
			case 'c':
				NpcsdbRun(0);
				return -1;
				break;
			default:
				printf("unknow order\n");
				break;
		}
	}
	return 0;
}

void sdb_set_batch_mode() {
	is_batch_mode = true;
}

void NpcSdbMainloop() {
	if (is_batch_mode) {
		cmd_c(NULL);
		return;
	}

	for (char *str; (str = rl_gets()) != NULL; ) {
		char *str_end = str + strlen(str);

		/* extract the first token as the command */
		char *cmd = strtok(str, " ");
		if (cmd == NULL) { continue; }

		/* treat the remaining string as the arguments,
		 * which may need further parsing
		 */
		char *args = cmd + strlen(cmd) + 1;
		if (args >= str_end) {
			args = NULL;
		}

		int i;
		for (i = 0; i < NR_CMD; i ++) {
			if (strcmp(cmd, cmd_table[i].name) == 0) {
				if (cmd_table[i].handler(args) < 0) { return; }
				break;
			}
		}

		if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
	}
}

void NpcSdbInit() {
#ifdef NPC_SDB
	init_regex();
	init_wp_pool();
	printf("\033[1;34m SDB\t\033[0m");
#endif
}
#endif //_NPC_SDB_H_