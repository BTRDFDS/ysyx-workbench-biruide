#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {//TODO
  // panic("Not implemented");
  //只能用str系列的函数，不能用其他的所有
  if(out==NULL){panic("out is NULL");}
  if(fmt==NULL){panic("fmt is NULL");}
  va_list argp;
  va_start(argp, fmt);
  char *start = out;
  while(*fmt!='\0'){
    // *out=*fmt;
    if(*fmt=='%'){
      fmt++;
      switch(*fmt){
        case 'c':
          *out=va_arg(argp, int);
          out++;
          fmt++;
          break;
        case 's':
          char *str=va_arg(argp, char*);
          for(int i=0;str[i]!='\0'&&i<100;i++){
            *out=str[i];
            out++;
          }
          fmt++;
          break;
        case 'd':
          fmt++;
          #define MAX 11
          int num=va_arg(argp, int);
          char number[MAX]={0};
          int point=MAX-1;
          if(num==0){*out='0';out++;break;}
          else if(num<0){*out='-';out++;num=-num;}
          while(num>0&&point>= 0){
              number[point]=(num % 10)+'0';
              num/= 10;
              point--;
          }
          for(int i=point+1;i<MAX;i++){
              if(number[i]!='\0'){
                *out=number[i];
                out++;
              }
          }
          break;
        default :panic("sprintf error");break;
      }
    }else{
      *out=*fmt;
      out++;
      fmt++;
    }
  }
  *out='\0';
  return out-start;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
