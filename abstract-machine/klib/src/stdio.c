#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {//TODO
  // panic("Not implemented");
  if(fmt==NULL){panic("fmt is NULL");}
  va_list argp;
  va_start(argp, fmt);
  int count=0;
  int printfNumber=0;
  while(*fmt!='\0'){
    // *out=*fmt;
    if(*fmt=='%'||printfNumber>0){
      fmt++;
      switch(*fmt){
        case 'c':
          putch(va_arg(argp, int));
          count++;
          fmt++;
          break;
        case 's':
          char *str=va_arg(argp, char*);
          for(int i=0;str[i]!='\0'&&i<100;i++){
            putch(str[i]);
            count++;
          }
          fmt++;
          break;
        case 'd':
          fmt++;
          #define MAX 11
          int num=va_arg(argp, int);
          char number[MAX]={0};
          int point=MAX-1;
          if(num==0){
            putch('0');
            count++;
          }
          else if(num<0){
            putch('-');
            count++;
          }
          while(num>0&&point>= 0){
              number[point]=(num % 10)+'0';
              num/= 10;
              point--;
          }
          int iNow=point+1;
          if(printfNumber>0&&printfNumber<MAX-point-1){
            iNow=MAX-1-printfNumber;
          }else if(printfNumber>0&&printfNumber>MAX-point-1){
            for(int i=0;i<(printfNumber-(MAX-point-1));i++){
              putch('0');
              count++;
            }
          }
          for(int i=iNow;i<MAX;i++){
              if(number[i]!='\0'){
                putch(number[i]);
                count++;
              }
          }
          printfNumber=0;
          break;
          //数字位就先储存:接下来处理如%数字
        case '0':printfNumber=printfNumber*10+0;break;
        case '1':printfNumber=printfNumber*10+1;break;
        case '2':printfNumber=printfNumber*10+2;break;
        case '3':printfNumber=printfNumber*10+3;break;
        case '4':printfNumber=printfNumber*10+4;break;
        case '5':printfNumber=printfNumber*10+5;break;
        case '6':printfNumber=printfNumber*10+6;break;
        case '7':printfNumber=printfNumber*10+7;break;
        case '8':printfNumber=printfNumber*10+8;break;
        case '9':printfNumber=printfNumber*10+9;break;
        case '%':
          putch('%');
          count++;
          fmt++;
          break;
        default :panic("printf error:%%");break;
      }
    }else if(*fmt=='\\'){
      fmt++;
      switch (*fmt)
      {
        case 'n':
          putch('\n');
          count++;
          fmt++;
          break;
        case '\\':
          putch('\\');
          count++;
          fmt++;
        default :panic("printf error:\\");break;
      }
    }else{
      putch(*fmt);
      count++;
      fmt++;
    }
  }
  va_end(argp);
  return count;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {//DONE:hello-str
  // panic("Not implemented");
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
  va_end(argp);
  return out-start;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
