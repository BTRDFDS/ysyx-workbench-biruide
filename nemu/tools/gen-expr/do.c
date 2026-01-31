#include <stdio.h>
#include <stdint.h>
int main() {
uint32_t result = (1==0)||(1==1);
printf("%u\n", result);
return 0;
}