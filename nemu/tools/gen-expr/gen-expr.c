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
static char code_buf[65536 + 70] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main(){unsigned r=%s;printf(\"%%u\",r);}";
char *useBuf;
int len = 65530;
int iTemp,j,k;
// char *cTemp = NULL;
uint32_t choose(uint32_t n){
  return rand()%n;
}
int max[10]={1,9,99,999,9999,99999,999999,9999999,99999999,999999999};
void gen(char c) {
  // sprintf(useBuf, "%c", c);
  *useBuf=c;
  useBuf++;
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



  if(len>=10){
    iTemp=INT32_MAX;
  }else{
    // iTemp=max[len];
    // iTemp=2^len;
    iTemp=1U<<len;
  }
  if(iTemp==0){iTemp=1;}
  // sprintf(cTemp,"%u",iTemp);
  // if(len-strlen(cTemp)>0)
  k=sprintf(useBuf, "%u",abs(rand()%iTemp));
  useBuf+=k;
  // len=65536-strlen(buf);
  len-=k;
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
  srand(1769173342);//修复除以零的种子
  // printf("seed = %d\n", seed);
  // int loop = 2000;
  int loop = 10;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop;) {
    // if(1%1000==0){printf("new is %d",i);}
    useBuf=buf;
    len = 65535;
    // buf[0] = '\0';
    // code_buf[0] = '\0';

    memset(buf, 0, sizeof(buf));
    memset(code_buf, 0, sizeof(code_buf));

    gen_rand_expr();

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);
    if(system("sed 's/\\<[0-9]\\+\\>/&U/g' /tmp/.code.c > /tmp/.code2.c")!=0){continue;}
    // system("sed 's/\\*/\\*(uint32_t)/g' /tmp/.code.c > /tmp/.code2.c");
    // system("sed 's/\\+/\\+(uint32_t)/g' /tmp/.code.c > /tmp/.code2.c");
    // system("sed 's/\\-/\\-(uint32_t)/g' /tmp/.code.c > /tmp/.code2.c");
    // int ret = system("gcc /tmp/.code2.c -Werror -o /tmp/.expr 2>/dev/null");
    if(system("gcc /tmp/.code2.c -Werror -o /tmp/.expr 2>/dev/null")!=0){continue;}
    // int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    // printf("%d\n",ret);
    // if (ret != 0){i--;continue;}

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result,res;
    // ret = fscanf(fp, "%d", &result);
    // res=pclose(fp);
    if(fscanf(fp, "%d", &result)!=1){continue;}
    if(pclose(fp)!=0){continue;}
    // if(ret != 1){i--;continue;}
    // if(res != 0){i--;continue;}
    printf("%u,%s\n", result, buf);
    i++;
  }
  return 0;
}
