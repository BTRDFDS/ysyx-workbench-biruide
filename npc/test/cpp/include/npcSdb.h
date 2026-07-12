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

#include <npcConfig.h>

extern const char *npcsdbRegs[32];
extern uint32_t npcsdbGpr[32];//注意：0号寄存器替代为pc
extern uint32_t tailWp;

#define ARRLEN(arr) (int)(sizeof(arr) / sizeof(arr[0]))

#define NR_WP 32
#define wpRequireLen 256
typedef struct watchpoint {
  char require[wpRequireLen];
  bool use;//有没有被使用
  uint32_t value;//当前值
} WP;
extern WP wp_pool[NR_WP];
extern void init_wp_pool();
extern uint32_t new_wp();
extern void free_wp();


extern uint32_t expr(char *e, bool *success);
extern int cmd_t(char *args);
extern void gen_expr();
extern int checkWp();

extern void NpcSdbMainloop();
extern void NpcSdbInit();
extern int NpcsdbCheck();
extern void NpcsdbGetGpr();
extern uint32_t NpcsdbGetReg(uint32_t addr);
extern uint32_t NpcsdbReadMem(uint32_t addr);
extern uint32_t NpcsdbRegTranslate(const char *s, bool *success);

extern void NpcsdbRun(uint32_t times);
#endif //_NPC_SDB_H_