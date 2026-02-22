#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  // panic("Not implemented");
  if(s==NULL){panic("error:s is NULL");}
  size_t i=0;
  for(;*s!='\0';s++,i++);
  return i;
}

char *strcpy(char *dst, const char *src) {//DONE:string
  // panic("Not implemented");
  char *out;
  if(dst==NULL){panic("error:dst is NULL");}
  if(src==NULL){panic("error:src is NULL");}
  for(out=dst;*src!='\0';src++){
    *dst=*src;
    dst++;
  }
  *dst='\0';
  return out;
}

char *strncpy(char *dst, const char *src, size_t n) {
  panic("Not implemented");
}

char *strcat(char *dst, const char *src) {//DONE:string
  // panic("Not implemented");
  if(dst==NULL){panic("error:dst is NULL");}
  if(src==NULL){panic("error:src is NULL");}
  char *out;
  for(out=dst;*dst!='\0';dst++);
  for(;*src!='\0';src++){
    *dst=*src;
    dst++;
  }
  *dst='\0';
  return out;
}

int strcmp(const char *s1, const char *s2) {//DONE:string
  // panic("Not implemented");
  if(s1==NULL){panic("error:s1 is NULL");}
  if(s2==NULL){panic("error:s2 is NULL");}
  // while(*s1!='\0'||*s2!='\0'){
  //   if(*s1=='\0'&&*s2!='\0'){return -1;}
  //   else if(*s1!='\0'&&*s2=='\0'){return 1;}
  //   else if(*s1<*s2){return -1;}
  //   else if(*s1>*s2){return 1;}
  //   s1++;
  //   s2++;
  // }
  // return 0;
  for(;*s1!='\0'&&*s2!='\0'&&*s1==*s2;s1++,s2++);
  return *s1-*s2;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  panic("Not implemented");
}

void *memset(void *s, int c, size_t n) {//DONE:string
  // panic("Not implemented");
  if(s==NULL){panic("error:s is NULL");}
  for(size_t i=0;i<n;i++){
    ((char*)s)[i]=(char)c;
  }
  return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  // panic("Not implemented");
  if(n==0){return dst;}
  if(dst==NULL){panic("error:dst is NULL");}
  if(src==NULL){panic("error:src is NULL");}
    char *d = dst;
    const char *s = src;
    if (d < s) {
        for (size_t i = 0; i < n; i++) {
            d[i] = s[i];
        }
    } else if (d > s) {
        for (size_t i = n; i > 0; i--) {
            d[i-1] = s[i-1];
        }
    }
    return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
  // panic("Not implemented");
  if(n==0){return out;}
  if(out==NULL){panic("error:out is NULL");}
  if(in ==NULL){panic("error: in is NULL");}
  char *d = out;
  const char *s = in;
  for (size_t i = 0; i < n; i++) {
      d[i] = s[i];
  }
  return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {//DONE:string
  // panic("Not implemented");
  if(s1==NULL){panic("error:s1 is NULL");}
  if(s2==NULL){panic("error:s2 is NULL");}
  for (size_t i = 0; i < n; i++) {
    if (((unsigned char *)s1)[i] != ((unsigned char *)s2)[i]) {
      return ((unsigned char *)s1)[i] - ((unsigned char *)s2)[i];
    }
  }
  return 0;
}

#endif
