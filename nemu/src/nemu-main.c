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

/*
#include "monitor/sdb/sdb.h"
#define genExprMax 10000
void gen_expr(){
  // init_regex();
  // FILE *fp = fopen("/home/biruide/ysyx-workbench/nemu/tools/gen-expr/input", "r");
  FILE *fp = fopen("/home/biruide/ysyx-workbench/nemu/tools/gen-expr/genExpr", "r");
  // FILE *fp = fopen("/home/biruide/ysyx-workbench/nemu/tools/gen-expr/use", "r");
  assert(fp!=NULL);
  char buf[65570];
  char *res;
  char *exp;
  bool success;
  word_t should,is;
  #define errbuf 10
  int errId[errbuf]={0};
  word_t errShould[errbuf]={0};
  word_t errIs[errbuf]={0};
  int err=0;
  for(int i=0;i<genExprMax;i++){
    if(fgets(buf, 65570, fp)!=NULL){
      res =strtok(buf, ",");
      if(res==NULL){continue;}
      exp=strtok(NULL, "\0");
      if(exp==NULL){continue;}
      should=strtoul(res, NULL, 10);
      is=expr(exp,&success);
      if(is!=should||success!=1){
        err++;
        errId[err]=i;
        errShould[err]=should;
        errIs[err]=is;
      }
      if(is!=should){
        printf("error:should=%u, is=%u\n",should, is);
        printf("exp=%s\n",exp);
        assert(0);
      }
      // assert(should==);
      assert(success==1);
    }else{continue;}

  }
  printf("errors:%d in %d\n",err,genExprMax);
  for(int i=0;i<err;i++){
    printf("%d,%u,%u\n",errId[i],errShould[i],errIs[i]);
  }
  assert(0);
}
*/



int main(int argc, char *argv[]) {

  /* Initialize the monitor. */
#ifdef CONFIG_TARGET_AM
  am_init_monitor();
#else
  init_monitor(argc, argv);
#endif

  /* Start engine. */

  // gen_expr();
  
  engine_start();

  //结束前的最终清理
  closeLog();
  IFDEF(CONFIG_FTRACE, closeFtrace());

  return is_exit_status_bad();
}
