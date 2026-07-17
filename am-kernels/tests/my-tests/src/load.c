#include "trap.h"

// uint32_t a[10] = {0,1,2,3,4,5,6,7,8,9};
uint32_t a[2] = {0,1};
int main() {
	// return a[3];
	for(uint32_t i = 0; i < 2; i ++) {
		// check(a[i]==i);
		uint32_t p=a[i];
		if(p!=i)return p;
	}
	return 0;
}
