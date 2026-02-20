#include <amtest.h>

void hello() {
  printf("hello world");
  for (int i = 0; i < 10; i ++) {
    putstr("Hello, AM World @ " __ISA__ "\n");
  }
}
