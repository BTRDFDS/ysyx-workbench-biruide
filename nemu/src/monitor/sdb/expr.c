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

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

enum {
  TK_NOTYPE = 256, TK_EQ,TK_NUM,

  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  {" +", TK_NOTYPE},    // spaces
  {"\\+", '+'},         // plus
  {"==", TK_EQ},        // equal
  {"\\-",'-'},
  {"\\*",'*'},
  {"\\/",'/'},
  {"\\(",'('},
  {"\\)",')'},
  {"[0-9]+",TK_NUM},
  {"0[xX][0-9a-fA-F]+",TK_NUM},//16进制0x

};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

// static Token tokens[32] __attribute__((used)) = {};
static Token tokens[65536] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while ((e[position] != '\0')&&(e[position]!='\n')) {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;



        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
        if(nr_token>=65536){printf("too many input\n");return 0;}
        switch (rules[i].token_type) {
          case(TK_NUM):
            if(substr_len>10){printf("%d:%.*s too long,should <=10(2147483647)\n",position,substr_len,substr_start);return 0;}
            tokens[nr_token].type=TK_NUM;
            strncpy(tokens[nr_token].str,substr_start,substr_len);
            tokens[nr_token].str[substr_len] = '\0';
            break;
          case(TK_NOTYPE):
            nr_token--;
            break;
          default: 
            tokens[nr_token].type=rules[i].token_type;
            break;
        }
        // printf("%d:%s(%s)\n",nr_token,tokens[nr_token].str,substr_start);
        Log("match rules[%d] = \"%s\" at %d with len %d: %.*s when %d:%s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start,nr_token,tokens[nr_token].str);
        position += substr_len;
        nr_token++;
        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}
bool check_parentheses(int p, int q) {
  if(tokens[p].type!='('||tokens[q].type!=')'){
    return false;
  }
  else{
    // int l=0;
    // int r=0;
    int c=0;
    for(int i=p;i<=q;i++){
      if(tokens[i].type=='(')c++;
      else if(tokens[i].type==')')c--;
      if(c<=0){
        if(i==q)return true;
        else return false;
      }
      // if(tokens[i].type=='(')l++;
      // if(tokens[i].type==')')r++;
    }
    // if(l==r)return true;
    // else return false;
  }
  return false;
}
uint32_t eval(int p, int q) {
  if (p > q) {
    printf("Bad expression\n");
    return 0;
    /* Bad expression */
  }
  else if (p == q) {
    if(tokens[p].type!=TK_NUM){
      printf("Bad expression\n");
      return 0;
    }
    return strtoul(tokens[p].str,NULL,0);
    
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
  }
  else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1);
  }
  else {
    int op=p;
    int c=0;//括号计数
    int np=0;//等级
    int j=0;//缓存等级
    for (int i = p; i <= q; i++) {
      if(tokens[i].type=='(')c++;
      else if(tokens[i].type==')')c--;
      else if(c==0&&tokens[i].type!=TK_NUM){
        switch (tokens[i].type)
        {
        case '+':
          j=2;
          break;
        case '-':
          if(i>p&&(tokens[i-1].type==TK_NUM||tokens[i-1].type==')')){
            j=2;
          }else{
            j=0;
          }
          break;
        case '*':
        case '/':
          j=1;
          break;
        default:
          j=0;
          break;
        }
        if(j>=np){
          op=i;
          np=j;
        }
        continue;
      }
    }
    uint32_t val1, val2,res;
    if((op==q)){
      printf("Bad expression\n");
      return 0;
    }else if(op==p){
      if(tokens[p].type=='-'){
        val1=0;
      }else{
      printf("Bad expression\n");
      return 0;
      }
    }else{
      val1 = eval(p, op - 1);
    }
    // op = the position of 主运算符 in the token expression;
    val2 = eval(op + 1, q);
    switch (tokens[op].type) {
      case '+':
        res=val1 + val2;
        break;
      case '-':
        res=val1 - val2;
        break;
      case '*':
        res=val1 * val2;
        break;
      case '/': 
        if(val2==0){printf("%d: ?/0 => error\n",op);return 0;}
        res=val1 / val2;
        break;
      default: assert(0);
    }
    Log("%u %c %u = %u", val1, tokens[op].type, val2,res);
    return res;
  }
}

word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }else{*success=true;}

  /* TODO: Insert codes to evaluate the expression. */
  // TODO();
  // for (int i = 0; i < nr_token; i++){printf("%d:type=%c str=%s\n",i,tokens[i].type,tokens[i].str);}
  
  // printf("%d\n",eval(0,nr_token-1));
  return eval(0,nr_token-1);
  // return 0;
}
