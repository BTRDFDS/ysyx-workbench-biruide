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

#include <common.h>
#include "monitor/sdb/sdb.h"

void init_monitor(int, char *[]);
void am_init_monitor();
void engine_start();
int is_exit_status_bad();

#define genExprMax 10000
void gen_expr(){
  FILE *fp = fopen("/tools/gen-expr/genExpr", "r");
  assert(fp!=NULL);
  char buf[65570];
  char *res;
  char *exp;
  bool success;
  for(int i=0;i<genExprMax;i++){
    if(fgets(buf, 65570, fp)!=NULL){
      res =strtok(buf, ",");
      if(res==NULL){continue;}
      exp=strtok(NULL, "\0");
      if(exp==NULL){continue;}
      word_t should=strtoul(res, NULL, 10);
      assert(should==expr(exp,&success));
      assert(success==1);
    }else{continue;}

  }
}
int main(int argc, char *argv[]) {

  gen_expr();

  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

  /* Start engine. */
  engine_start();

  return is_exit_status_bad();
}
