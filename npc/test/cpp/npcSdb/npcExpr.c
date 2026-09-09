#include <npcSdb.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
uint32_t NpcsdbRegTranslate(const char *s, bool *success){
	if(s[0] != '$') {
		*success = false;
		return 0;
	}
	const char *name = s + 1;
	for(int i = 0; i < 32; i++) {
		if(strcmp(name, npcsdbRegs[i]) == 0) {
			*success = true;
			return NpcsdbGetReg(i);
		}
	}
	// if(strcmp(name, "pc") == 0) {
	// 	*success = true;
	// 	return cpu.pc;
	// }
	// *success = false;
	return 0;
}







enum {
	TK_NOTYPE = 256, TK_EQ,TK_NUM,TK_REG,TK_NEQ,TK_AND,TK_POINT,TK_HEX,TK_OR
};

static struct rule {
	const char *regex;
	int token_type;
} rules[] = {
	{" +", TK_NOTYPE},// spaces
	{"\\+", '+'},// plus
	{"==", TK_EQ},// equal
	{"!=", TK_NEQ},
	{"&&", TK_AND},
	{"\\-",'-'},
	{"\\*",'*'},
	{"\\/",'/'},
	{"\\(",'('},
	{"\\)",')'},
	{"0[xX][0-9a-fA-F]+",TK_HEX},//16进制0x
	{"\\$[a-zA-Z0-9]+",TK_REG},//寄存器以$开头
	{"[0-9]+",TK_NUM},
	{"\\|\\|", TK_OR},
};

#define NR_REGEX ARRLEN(rules)
static regex_t re[NR_REGEX] = {};
void init_regex() {
	int i;
	char error_msg[128];
	int ret;

	for (i = 0; i < NR_REGEX; i ++) {
		ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
		if (ret != 0) {
			regerror(ret, &re[i], error_msg, 128);
			// panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
			printf("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
			exit(1);
		}
	}
}

typedef struct token {
	int type;
	char str[32];
} Token;

// static Token tokens[32] __attribute__((used)) = {};
static Token tokens[65536] __attribute__((used)) = {};
static int nr_token __attribute__((used))	= 0;

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
					case(TK_REG):
						tokens[nr_token].type=TK_REG;
						strncpy(tokens[nr_token].str,substr_start,substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						break;
					case(TK_HEX):
						if(substr_len>10){printf("%d:%.*s too long,should <=10(0xFFFFFFFF)\n",position,substr_len,substr_start);return 0;}
						tokens[nr_token].type=TK_HEX;
						strncpy(tokens[nr_token].str,substr_start,substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						break;
					default:
						tokens[nr_token].type=rules[i].token_type;
						break;
				}
				// printf("%d:%s(%s)\n",nr_token,tokens[nr_token].str,substr_start);
				// Log("match rules[%d] = \"%s\" at %d with len %d: %.*s",i, rules[i].regex, position, substr_len, substr_len, substr_start);
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
uint32_t eval(int p, int q, bool *success) {
	if(*success==false){return 0;}
	if (p > q) {
		printf("Bad expression:p>q|it shouldn't happen\n");
		*success=false;
		return 0;
		/* Bad expression */
	}
	else if (p == q) {
		if(tokens[p].type==TK_NUM){
		return (uint32_t)strtoul(tokens[p].str,NULL,0);
		}else if(tokens[p].type==TK_REG){

			bool iSuccess = false;
			uint32_t res=NpcsdbRegTranslate(tokens[p].str,&iSuccess);
			if(iSuccess==true){
				*success=true;
				return res;
			}
			printf("%d: %s => error\n",p,tokens[p].str);
			*success=false;
			return 0;
		}else if(tokens[p].type==TK_HEX){
			uint32_t res = strtoul(tokens[p].str,NULL,16);
			*success=true;
			return res;
		}
			printf("Bad expression:val isn't number\n");
			*success=false;
			return 0;

		/* Single token.
		 * For now this token should be a number.
		 * Return the value of the number.
		 */
	}
	else if (check_parentheses(p, q) == true) {
		/* The expression is surrounded by a matched pair of parentheses.
		 * If that is the case, just throw away the parentheses.
		 */
		return eval(p + 1, q - 1,success);
	}else if(p+1==q&&tokens[p].type==TK_POINT){
		if(tokens[q].type==TK_NUM||tokens[q].type==TK_HEX)
		// return vaddr_read(eval(q,q,success),4);
		return NpcsdbReadMem(eval(q,q,success));
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
				case TK_EQ:
				case TK_NEQ:
				case TK_AND:
				case TK_OR:
					j=3;
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
			printf("Bad expression:without val2\n");
			*success=false;
			return 0;
		}else if(op==p){
			if(tokens[p].type=='-'){
				val1=0;
			}else{
			printf("Bad expression:without val1\n");
			*success=false;
			return 0;
			}
		}else{
			val1 = eval(p, op - 1,success);
			if(*success==false){return 0;}
		}
		// op = the position of 主运算符 in the token expression;
		val2 = eval(op + 1, q,success);
		if(*success==false){return 0;}
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
			case TK_EQ:
				if(val1==val2) res=1;
				else res=0;
				break;
			case TK_NEQ:
				if(val1!=val2) res=1;
				else res=0;
				break;
			case TK_AND:
				if(val1&&val2) res=1;
				else res=0;
				break;
			case TK_OR:
				if(val1||val2) res=1;
				else res=0;
				break;
			default:exit(-1);
		}
		// Log("%u %c %u = %u", val1, tokens[op].type, val2,res);

		*success=true;
		return res;
	}
	return 0;
}

uint32_t expr(char *e, bool *success) {
	if (!make_token(e)) {
		*success = false;
		return 0;
	}else{*success=true;}

	/* TODO: Insert codes to evaluate the expression. */
	// TODO();
	// for (int i = 0; i < nr_token; i++){printf("%d:type=%c str=%s\n",i,tokens[i].type,tokens[i].str);}
	for (int i=0;i<nr_token;i++) {
	if (tokens[i].type == '*' && (i==0||(tokens[i-1].type!=')'&&tokens[i-1].type!=TK_NUM))) {
		tokens[i].type = TK_POINT;
	}
	}
	// printf("%d\n",eval(0,nr_token-1));
	return eval(0,nr_token-1,success);
	// return 0;
}

#define genExprMax 10000
void gen_expr(){
	// init_regex();
	// FILE *fp = fopen("/home/biruide/ysyx-workbench/nemu/tools/gen-expr/input", "r");
	// FILE *fp = fopen("$NEMU_HOME/tools/gen-expr/genExpr", "r");
	// FILE *fp = fopen("/home/biruide/ysyx-workbench/nemu/tools/gen-expr/use", "r");
	FILE *fp = fopen("/home/biruide/ysyx-workbench/nemu/tools/gen-expr/genExpr", "r");
	// assert(fp!=NULL);
	if(fp==NULL){printf("error:can't open file\n");exit(-1);}
	char buf[65570];
	char *res;
	char *exp;
	bool success;
	uint32_t should,is;
	// #define errbuf 10
	// int errId[errbuf]={0};
	// uint32_t errShould[errbuf]={0};
	// uint32_t errIs[errbuf]={0};
	// int err=0;
	for(int i=0;i<genExprMax;i++){
		if(fgets(buf, 65570, fp)!=NULL){
			res =strtok(buf, ",");
			if(res==NULL){continue;}
			exp=strtok(NULL, "\0");
			if(exp==NULL){continue;}
			should=strtoul(res, NULL, 10);
			is=expr(exp,&success);
			// if(is!=should||success!=1){
			//	 err++;
			//	 errId[err]=i;
			//	 errShould[err]=should;
			//	 errIs[err]=is;
			// }
			if(is!=should){
				printf("error:should=%u, is=%u\n",should, is);
				printf("exp=%s\n",exp);
				exit(-1);
			}
			// assert(should==);
			// assert(success==1);
			if(success!=true){printf("no success\n");exit(-1);}
		}else{continue;}

	}
	printf("success!No error in %d\n",genExprMax);

	// printf("errors:%d in %d\n",err,genExprMax);
	// for(int i=0;i<err;i++){
	//	 printf("%d,%u,%u\n",errId[i],errShould[i],errIs[i]);
	// }
	// assert(0);
}