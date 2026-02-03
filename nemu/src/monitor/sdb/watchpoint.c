/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "sdb.h"
#include "watchpoint.h"
#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>


WP wp_pool[NR_WP] = {};
static WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */

WP* new_wp(){//其中new_wp()从free_链表中返回一个空闲的监视点结构
  assert(free_ != NULL);
  WP *wp = free_;
  free_ = free_->next;
  wp->use = true;
  if (wp == NULL) {
    printf("too many watchpoint\n");
    assert(0);
  }
  return wp;
}
void free_wp(WP *wp) {
  if(wp != NULL && wp->use == true){
    wp->use = false;
    wp->next = free_;
    free_ = wp;
  }else{
    printf("no watchpoint\n");
  }
}
int checkWp(){
  int i=0;
  bool success=false;
  word_t val;
  while(wp_pool[i].use == true&&i<NR_WP){//wp_pool[i].use == true&&
    // if(cpu.pc==wp_pool[i].line){
    //   Log("pin watchpoint %d : 0x%x",wp_pool[i].NO,wp_pool[i].line);
    //   return 0;
    // }
    val=expr(wp_pool[i].require,&success);
    if(success&&val!=wp_pool[i].value&&wp_pool[i].use==true){
      wp_pool[i].value=val;
      Log("watchpoint %d : %s,val form %u to %u",wp_pool[i].NO,wp_pool[i].require,wp_pool[i].value,val);
      wp_pool[i].value=val;
      return 0;
    }
    i++;
  }
  return -1;
}