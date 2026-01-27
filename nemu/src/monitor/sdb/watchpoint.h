#include "sdb.h"
#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>
typedef struct watchpoint {
  int NO;
  struct watchpoint *next;
  word_t line;//第几行代码
  bool use;//有没有被使用
  /* TODO: Add more members if necessary */

} WP;
#define NR_WP 32
static WP wp_pool[NR_WP] = {};