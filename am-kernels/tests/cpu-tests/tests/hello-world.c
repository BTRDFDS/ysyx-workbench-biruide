#include "trap.h"
int main() {
    char buf[128];
	sprintf(buf, "%s", "Hello world!\n");
	check(strcmp(buf, "Hello world!\n") == 0);
	return 0;
}
