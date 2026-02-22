#include <trap.h>

#define N 64
#define word uint8_t

#define VAL 0
#define BEGIN 1

word data1[N];
word data2[N];

void reset(word*data) {
	for (uint32_t i = 0; i < N; i ++) {
		data[i] = i + 1;
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
			check_seq(data1,0,l,1);
			// printf("1");
			check_eq (data1,l,r,val);
			// printf("2");
			check_seq(data1,r,N,r+1);
			// printf("3");
		}
	}
	printf(" memset test \033[1;32mPASS\033[0m\n");
}

void test_strcpy(){
	for(uint32_t l = 0; l < N; l ++) {
		for (uint32_t r = l + 1; r <= N; r ++) {
			reset(data1);
			memset(data2, 0, N);
			data1[r-1]='\0';
			strcpy((char*)data2,(char*)data1 + l);
			// printf("0");
			check_seq(data2, 0, r - l-1, data1[l]);
			// printf("1");
			check_eq(data2, r - l, N, 0);
			// printf("2");
			check_seq(data1, 0,r-1, 1);
			// printf("3");
			check_seq(data1,r,N,r+1);
			// printf("4");
		}
	}
	printf(" strcpy test \033[1;32mPASS\033[0m\n");
}



void test_memcpy(){
    for (uint32_t l = 0; l < N; l ++) {
        for (uint32_t r = l + 1; r <= N; r ++) {
            reset(data1);
            memset(data2, 0, N);
			// printf("0");
            memcpy(data2, data1 + l, r - l);
			// printf("1");
            check_seq(data2, 0, r - l, data1[l]);
			// printf("2");
            check_eq(data2, r - l, N, 0);
			// printf("3");
            check_seq(data1, 0, N, 1);
			// printf("4");
        }
    }
    printf(" memcpy test \033[1;32mPASS\033[0m\n");
}

int main() {
	test_memset();
	test_strcpy();
	test_memcpy();
	printf("\033[1;32m ALL klib-tests PASS \033[0m\n");
	return 0;
}