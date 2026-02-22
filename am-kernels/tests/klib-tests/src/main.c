#include <trap.h>

#define N 64
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
	printf("\033[1;32m ALL klib-tests PASS \033[0m\n");
	return 0;
}