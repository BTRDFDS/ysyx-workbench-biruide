#include "trap.h"

int a[10] = {0,1,2,3,4,5,6,7,8,9};
int main() {
	for(int i = 0; i < 10; i ++) {
        *(volatile char *)(0x10000000L) = '0'+i;
		check(a[i]==i);
	}
	return 0;
}
