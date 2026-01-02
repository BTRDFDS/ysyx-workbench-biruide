clang c.c --analyze -Xanalyzer -analyzer-output=text
c.c:5:6: warning: Use of memory after it is freed [unix.Malloc]
  *p = 0;
  ~~ ^
c.c:3:12: note: Memory is allocated
  int *p = malloc(sizeof(*p) * 10);
           ^~~~~~~~~~~~~~~~~~~~~~~
c.c:4:3: note: Memory is released
  free(p);
  ^~~~~~~
c.c:5:6: note: Use of memory after it is freed
  *p = 0;
  ~~ ^
1 warning generated.