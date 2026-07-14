#include <trap.h>
#include <klib.h>

#include <limits.h>

#define N 16
#define word uint8_t//按照字节操作，别动

#define VAL 5
#define BEGIN 3	//必须>0，不然可能会误读到'\0'

word data1[N];
word data2[N];

void reset(word*data) {
	for (uint32_t i = 0; i < N; i ++) {
		data[i] = i + BEGIN;
	}
}

// 检查[l,r)区间中的值是否依次为val, val + 1, val + 2...
void check_seq(word*data,uint32_t l, uint32_t r, uint32_t val) {
	for (uint32_t i = l; i < r; i ++) {
		// assert(data[i] == val + i - l);
		if(data[i] != val + i - l) {
			printf("sqErr [%d,%d) data[%d]=%d !=%d\n",l,r,i,data[i],val + i - l);
			assert(0);
		}
	}
}

// 检查[l,r)区间中的值是否均为val
void check_eq(word*data,uint32_t l, uint32_t r, uint32_t val) {
	for (uint32_t i = l; i < r; i ++) {
		// assert(data[i] == val);
		if(data[i] != val) {
			printf("eqErr [%d,%d) data[%d]=%d !=%d\n",l,r,i,data[i],val);
			assert(0);
		}
	}
}
//第一类
void test_memset() {
	for (uint32_t l = 0; l < N; l ++) {
		for (uint32_t r = l + 1; r <= N; r ++) {
			reset(data1);
			word val=(l+r)/2;
			memset(data1+l,val,r-l);
			// printf("0");
			check_seq(data1,0,l,BEGIN);
			// printf("1");
			check_eq (data1,l,r,val);
			// printf("2");
			check_seq(data1,r,N,r+BEGIN);
			// printf("3");
		}
	}
	printf(" memset test \033[1;32mPASS\033[0m\n");
}

void test_strcpy(){
	for(uint32_t l = 0; l < N; l ++) {
		for (uint32_t r = l + 1; r <= N; r ++) {
			reset(data1);
			memset(data2, VAL, N);
			data1[r-1]='\0';
			strcpy((char*)data2,(char*)data1 + l);
			// printf("0");
			check_seq(data2, 0, r - l-1, data1[l]);
			// printf("1");
			check_eq(data2, r - l, N, VAL);
			// printf("2");
			check_seq(data1, 0,r-1, BEGIN);
			// printf("3");
			check_seq(data1,r,N,r+BEGIN);
			// printf("4");
		}
	}
	printf(" strcpy test \033[1;32mPASS\033[0m\n");
}

void test_memcpy(){
    for (uint32_t l = 0; l < N; l ++) {
        for (uint32_t r = l + 1; r <= N; r ++) {
            reset(data1);
            memset(data2, VAL, N);
			// printf("0");
            memcpy(data2, data1 + l, r - l);
			// printf("1");
            check_seq(data2, 0, r - l, data1[l]);
			// printf("2");
            check_eq(data2, r - l, N, VAL);
			// printf("3");
            check_seq(data1, 0, N, BEGIN);
			// printf("4");
        }
    }
    printf(" memcpy test \033[1;32mPASS\033[0m\n");
}
//第二类
void test_memcmp(){
	if(BEGIN+N>UINT8_MAX){
		printf("BEGIN+N>MAX\n");
		assert(0);
	}
	for (uint32_t l=0;l<N;l++) {
		for (uint32_t r=0;r<N;r++) {
			reset(data1);
			reset(data2);
			data1[l]=BEGIN+N;
			data2[r]=BEGIN+N;
			for(uint32_t i=0;i<=N;i++){
				int res=memcmp(data1,data2,i);
				bool eq   =(res==0)&&(l==r||(i<=l&&i<=r));
				bool big  =(res> 0)&&(l< r||(i >l&&i <r));
				bool small=(res< 0)&&(l> r||(i <l&&i >r));
				if(!(eq||big||small)){
					printf("memcmp err l=%d r=%d i=%d res=%d eq=%d big=%d small=%d\n",l,r,i,res,eq,big,small);
					assert(0);
				}
			}
		}
	}
	printf(" memcmp test \033[1;32mPASS\033[0m\n");
}

void test_strlen(){
	for(uint32_t l=0;l<N;l++){
		for(uint32_t r=l+1;r<=N;r++){
			reset(data1);
			data1[r-1]='\0';
			uint32_t len=strlen((char*)data1+l);
			if(len!=r-l-1){
				printf("strlen err l=%d r=%d len=%d\n",l,r,len);
				assert(0);
			}
		}
	}
	printf(" strlen test \033[1;32mPASS\033[0m\n");
}
//第三类
void test_sprintf(){
	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"abcd123");
	if(strcmp((char*)data1,"abcd123")!=0){
		printf("sprintf err %s != abcd123\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"abcd%0d",123);
	if(strcmp((char*)data2,"abcd123")!=0){
		printf("sprintf err %s != abcd23\n",data2);
		assert(0);
	}
	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"abcd%000001d",123);
	if(strcmp((char*)data1,"abcd123")!=0){
		printf("sprintf err %s != abcd123\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"abcd%02d",123);
	if(strcmp((char*)data2,"abcd123")!=0){
		printf("sprintf err %s != abcd123\n",data2);
		assert(0);
	}
	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"abcd%4d",123);
	if(strcmp((char*)data1,"abcd 123")!=0){
		printf("sprintf err %s != abcd 123\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"abcd%0x",123);
	if(strcmp((char*)data2,"abcd7b")!=0){
	    printf("sprintf err %s != abcd7b\n",data2);
		assert(0);
	}

	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"abcd%01x",123);
	if(strcmp((char*)data1,"abcd7b")!=0){
		printf("sprintf err %s != abcd7b\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"abcd%08X",123);
	if(strcmp((char*)data2,"abcd0000007B")!=0){
		printf("sprintf err %s != abcd0000007B\n",data2);
		assert(0);
	}

	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"666%c",'P');
	if(strcmp((char*)data1,"666P")!=0){
		printf("sprintf err %s != 666P\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"666%s","well down");
	if(strcmp((char*)data2,"666well down")!=0){
		printf("sprintf err %s != 666well down\n",data2);
		assert(0);
	}

	//{0, INT_MAX / 17, INT_MAX, INT_MIN, INT_MIN + 1,UINT_MAX / 17, INT_MAX / 17, UINT_MAX};
	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"%d",0);
	if(strcmp((char*)data1,"0")!=0){
		printf("sprintf err %s != 0\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"%d",INT_MAX/17);
	if(strcmp((char*)data2,"126322567")!=0){
		printf("sprintf err %s != 126322567\n",data2);
		assert(0);
	}
	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"%d",INT_MAX);
	if(strcmp((char*)data1,"2147483647")!=0){
		printf("sprintf err %s != 2147483647\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"%17d",INT_MIN);
	if(strcmp((char*)data2,"      -2147483648")!=0){
		printf("sprintf err>%s!=      -2147483648\n",data2);
		assert(0);
	}
	memset(data1,VAL,N);
	memset(data2,VAL,N);
	sprintf((char*)data1,"%d",INT_MIN+1);
	if(strcmp((char*)data1,"-2147483647")!=0){
		printf("sprintf err %s != -2147483647\n",data1);
		assert(0);
	}
	sprintf((char*)data2,"%d",UINT_MAX/17);
	if(strcmp((char*)data2,"252645135")!=0){
		printf("sprintf err %s != 252645135\n",data2);
		assert(0);
	}
	memset(data1,VAL,N);
	if(sprintf((char*)data1,"%d",INT_MAX/17)==-1){
		printf("sprintf err %s != 6291456\n",data1);
		assert(0);
	}


	printf(" sprint test \033[1;32mPASS\033[0m\n");
}

void test_printf(){
	//{0, INT_MAX / 17, INT_MAX, INT_MIN, INT_MIN + 1,UINT_MAX / 17, INT_MAX / 17, UINT_MAX};
	printf("%4d==   0\n",0);
	printf("%1d==126322567\n",INT_MAX/17);
	printf("%d==2147483647\n",INT_MAX);
	printf("%17d==      -2147483648\n",INT_MIN);
	printf("%d==-2147483647\n",INT_MIN+1);
	printf("%d==252645135\n",UINT_MAX/17);
	printf("%d==126322567\n",INT_MAX/17);
	printf("%17d==               -1\n",UINT_MAX);
	printf("%4x==   0\n",0);
	printf("%1x==7878787\n",INT_MAX/17);
	printf("%x==7fffffff\n",INT_MAX);
	printf("%17x==         80000000\n",INT_MIN);
	printf("%x==80000001\n",INT_MIN+1);
	printf("%x==f0f0f0f\n",UINT_MAX/17);
	printf("%X==7878787\n",INT_MAX/17);
	printf("%17X==         FFFFFFFF\n",UINT_MAX);
	printf("%c==P\n",'P');
	printf("%s==well down\n","well down");

    printf(" printf test maybe \033[1;32mPASS\033[0m,please check output\n");
}

void test_csrr(){
	#define CSR
#ifdef CSR
	uint32_t temp;
	asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
	asm volatile("csrr %0, mcycleh"   : "=r"(temp));printf("mcycleh:  %x\n", temp);
	asm volatile("csrr %0, mvendorid" : "=r"(temp));printf("mvendorid:%x\n", temp);
	asm volatile("csrr %0, marchid"   : "=r"(temp));printf("marchid:  %d\n", temp);
	asm volatile("csrr %0, mcycle"    : "=r"(temp));printf("mcycle:   %x\n", temp);
	asm volatile("csrr %0, mcycleh"   : "=r"(temp));printf("mcycleh:  %x\n", temp);
	uint32_t time[10];
	asm volatile("csrr %0, mcycle"  : "=r"(time[0]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[1]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[2]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[3]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[4]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[5]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[6]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[7]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[8]));
	asm volatile("csrr %0, mcycle"  : "=r"(time[9]));
	printf("time: %x %x %x %x %x %x %x %x %x %x\n", time[0], time[1], time[2], time[3], time[4], time[5], time[6], time[7], time[8], time[9]);
	for(int i=0;i<10-2;i++){
		if(time[i+1]-time[i]!=time[i+2]-time[i+1]){//不再设为固定值而是一个等差数列就是ok的了，当然未来可能还需要再改
			printf("csrr test maybe \033[1;31mFAIL\033[0m\n");
			assert(0);
		}
	}
	printf(" csrr test maybe \033[1;32mPASS\033[0m,please check output\n");
#endif
}
int main() {
	if(BEGIN<=0){
		printf("BEGIN<=0\n");
		assert(0);
	}
	//第一类
	test_memset();
	test_strcpy();
	test_memcpy();
	//第二类
	test_memcmp();
	test_strlen();
	//第三类
	test_sprintf();
	test_printf();

	test_csrr();
	printf("\033[1;32m ALL klib-tests PASS \033[0m\n");
	return 0;
}