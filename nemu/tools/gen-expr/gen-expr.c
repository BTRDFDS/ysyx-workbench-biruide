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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";
int len = 65535;
int iTemp,j;
// char *cTemp = NULL;
uint32_t choose(uint32_t n){
  return rand()%n;
}
void gen(char c) {
  sprintf(buf + strlen(buf), "%c", c);
}
void gen_num() {
  if(len>10){
    iTemp=rand()%10;
  }else if(len>1){
    iTemp=rand()%len-1;
  }else{iTemp=0;}
  if(iTemp!=0){
    len-=iTemp;//插入空格
    j = rand()%iTemp;//后面是j个，前面是iTemp-j个
    for(int i=0;i<iTemp-j;i++){gen(' ');}
  }else{j=0;}



  if(len>31){
    iTemp=2^31;
  }else{
    iTemp=2^len;
  }
  if(iTemp==0){iTemp=1;}
  // sprintf(cTemp,"%u",iTemp);
  // if(len-strlen(cTemp)>0)
  sprintf(buf+ strlen(buf), "%u",abs(rand()%iTemp));
  len=65536-strlen(buf);
  if(j>0){
    for(int i=0;i<j;i++){gen(' ');}
  }
}
void gen_rand_op(){
  switch(choose(4)){
    case 0: gen('+'); break;
    case 1: gen('-'); break;
    case 2: gen('*'); break;
    case 3: gen('/'); break;
    default: gen('+'); break;
  }
}
static void gen_rand_expr() {
  iTemp = choose(3);
  if(len<=2){iTemp=0;}
  // else if(len<=2){iTemp=0;}
  switch (iTemp) {
    case 0:
      gen_num();
      break;
    case 1:
      len-=2;
      gen('(');
      gen_rand_expr();
      gen(')');
      break;
    case 2:
      len-=2;
      gen_rand_expr();
      gen_rand_op();
      len++;
      gen_rand_expr();
      break;
    default:
      len-=2;
      gen_rand_expr();
      gen_rand_op();
      len++;
      gen_rand_expr();
      break;
  }
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  // srand(seed);
  // srand(1769172359);//修复清零的种子
  // srand(1769173342);//修复除以零的种子
  // printf("seed = %d\n", seed);
  // int loop = 2000;
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
    // if(1%1000==0){printf("new is %d",i);}
    len = 65535;
    buf[0] = '\0';
    gen_rand_expr();

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr 2>/dev/null");
    // int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    // printf("%d\n",ret);
    if (ret != 0){i--;continue;}

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result,res;
    ret = fscanf(fp, "%d", &result);
    res=pclose(fp);
    if(ret != 1){i--;continue;}
    if(res != 0){i--;continue;}
    printf("%u,%s\n", result, buf);
  }
  return 0;
}
