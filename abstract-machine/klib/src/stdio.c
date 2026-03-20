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
  bool getPrintfNumber=false;
  bool isLong=false;
  while(*fmt!='\0'){
    // *out=*fmt;
    if(*fmt=='%'||getPrintfNumber==true||isLong==true){
      fmt++;
      switch(*fmt){
        case 'l':
          isLong=true;
          // putch('*');
          break;
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
          #define MAXprintfD 22
          // int num=va_arg(argp, int);
          int num=0;
          long lnum=0;
          char number[MAXprintfD]={0};
          int point=MAXprintfD-1;
          bool minus=false;
          bool zero=false;
          if(isLong){
            // putch('*');
            lnum=va_arg(argp, long);
            isLong=false;
            if(lnum==0){
              zero=true;
              // putch('0');
              // count++;
            }
            else if(lnum<0L){
              minus=true;
              printfNumber--;
              while(lnum<0L&&point>= 0){
                number[point]=-(lnum % 10L)+'0';
                lnum/= 10L;
                point--;
              }
            }else{
              while(lnum>0L&&point>= 0){
                number[point]=(lnum % 10L)+'0';
                lnum/= 10L;
                point--;
              }
            }
            // for (int i = 0; i < MAXprintfD; i++){putch(number[i]);}halt(-1);
            
          }else{
            // putch('*');
            num=va_arg(argp, int);
            if(num==0){
              zero=true;
              // putch('0');
              // count++;
            }
            else if(num<0){
              minus=true;
              printfNumber--;
              // putch('-');
              // count++;
              while(num<0&&point>= 0){
                number[point]=-(num % 10)+'0';
                num/= 10;
                point--;
              }
            }else{
              while(num>0&&point>= 0){
                number[point]=(num % 10)+'0';
                num/= 10;
                point--;
              }
            }
          }
          int iNow=point+1;
          if(printfNumber>0&&printfNumber>MAXprintfD-point-1){
            for(int i=0;i<(printfNumber-(MAXprintfD-point-1));i++){
              putch(' ');
              count++;
            }
          }
          if(zero){putch('0');count++;}
          else{
            if(minus){putch('-');count++;}
            for(int i=iNow;i<MAXprintfD;i++){
                if(number[i]!='\0'){
                  putch(number[i]);
                  count++;
                }
            }
          }
          printfNumber=0;
          getPrintfNumber=false;
          break;
        case 'x':
        case 'X':
          bool isBig;
          if(*fmt=='x'){isBig=false;}else{isBig=true;}
          fmt++;
          #define MAXprintfX 12
          unsigned numX=va_arg(argp, int);
          char numberX[MAXprintfX]={0};
          int pointX=MAXprintfX-1;
          bool zeroX=false;
          if(numX==0){
            // putch('0');
            // count++;
            zeroX=true;
          }
          while(numX>0&&pointX>= 0){
              // number[point]=(num % 10)+'0';
              // num/= 10;
              switch(numX%16){
                case  0:numberX[pointX]='0';break;
                case  1:numberX[pointX]='1';break;
                case  2:numberX[pointX]='2';break;
                case  3:numberX[pointX]='3';break;
                case  4:numberX[pointX]='4';break;
                case  5:numberX[pointX]='5';break;
                case  6:numberX[pointX]='6';break;
                case  7:numberX[pointX]='7';break;
                case  8:numberX[pointX]='8';break;
                case  9:numberX[pointX]='9';break;
                case 10:numberX[pointX]=isBig?'A':'a';break;
                case 11:numberX[pointX]=isBig?'B':'b';break;
                case 12:numberX[pointX]=isBig?'C':'c';break;
                case 13:numberX[pointX]=isBig?'D':'d';break;
                case 14:numberX[pointX]=isBig?'E':'e';break;
                case 15:numberX[pointX]=isBig?'F':'f';break;
              }
              numX/= 16;
              pointX--;
          }
          int iNowX=pointX+1;
          if(printfNumber>0&&printfNumber>MAXprintfX-pointX-1){
            for(int i=0;i<(printfNumber-(MAXprintfX-pointX-1));i++){
              putch(' ');
              count++;
            }
          }
          if(zeroX){putch('0');count++;}
          else{
            for(int i=iNowX;i<MAXprintfX;i++){
                if(numberX[i]!='\0'){
                  putch(numberX[i]);
                  count++;
                }
            }
          }
          printfNumber=0;
          getPrintfNumber=false;
          break;
        case '0':printfNumber=printfNumber*10+0;getPrintfNumber=true;break;
        case '1':printfNumber=printfNumber*10+1;getPrintfNumber=true;break;
        case '2':printfNumber=printfNumber*10+2;getPrintfNumber=true;break;
        case '3':printfNumber=printfNumber*10+3;getPrintfNumber=true;break;
        case '4':printfNumber=printfNumber*10+4;getPrintfNumber=true;break;
        case '5':printfNumber=printfNumber*10+5;getPrintfNumber=true;break;
        case '6':printfNumber=printfNumber*10+6;getPrintfNumber=true;break;
        case '7':printfNumber=printfNumber*10+7;getPrintfNumber=true;break;
        case '8':printfNumber=printfNumber*10+8;getPrintfNumber=true;break;
        case '9':printfNumber=printfNumber*10+9;getPrintfNumber=true;break;
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

int sprintf(char *out, const char *fmt, ...){
  if(out==NULL){panic("out is NULL");}
  if(fmt==NULL){panic("fmt is NULL");}
  va_list argp;
  va_start(argp, fmt);
  char *start=out;
  int printfNumber=0;
  bool getPrintfNumber=0;
  while(*fmt!='\0'){
    if(*fmt=='%'||getPrintfNumber==true){
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
          #define MAXsprintfD 11
          int num=va_arg(argp, int);
          char number[MAXsprintfD]={0};
          int point=MAXsprintfD-1;
          bool minus=false;
          bool zero=false;
          // printf("num=%d point=%d\n",num,point);
          // if(num==0){*out='0';out++;break;}
          if(num==0){zero=true;}
          else if(num<0){
            // *out='-';out++;
            printfNumber--;
            minus=true;
            while(num<0&&point>= 0){
              number[point]=-(num % 10)+'0';
              num/= 10;
              point--;
            }
          }
          else{
            while(num>0&&point>= 0){
              number[point]=(num % 10)+'0';
              num/= 10;
              point--;
            }
          }
          // printf("num=%d point=%d\n",num,point);
          while(num>0&&point>= 0){
              number[point]=(num % 10)+'0';
              num/= 10;
              point--;
          }
          int iNow=point+1;
          if(printfNumber>0&&printfNumber>MAXsprintfD-point-1){
            for(int i=0;i<(printfNumber-(MAXsprintfD-point-1));i++){
              *out=' ';
              out++;
            }
          }
          if(zero){*out='0';out++;}
          else{
            if(minus==true){*out='-';out++;}
            for(int i=iNow;i<MAXsprintfD;i++){
                if(number[i]!='\0'){
                  *out=number[i];
                  out++;
                }
            }
          }
          printfNumber=0;
          getPrintfNumber=false;
          break;
        case 'x':
        case 'X':
          bool isBig;
          bool zeroX=false;
          if(*fmt=='x'){isBig=false;}else{isBig=true;}
          fmt++;
          #define MAXsprintfX 11
          unsigned numX=va_arg(argp, int);
          char numberX[MAXsprintfX]={0};
          int pointX=MAXsprintfX-1;
          // if(numX==0){*out='0';out++;break;}
          if(numX==0){zeroX=true;}
          while(numX>0&&pointX>= 0){
              // number[point]=(num % 10)+'0';
              // num/= 10;
              switch(numX%16){
                case  0:numberX[pointX]='0';break;
                case  1:numberX[pointX]='1';break;
                case  2:numberX[pointX]='2';break;
                case  3:numberX[pointX]='3';break;
                case  4:numberX[pointX]='4';break;
                case  5:numberX[pointX]='5';break;
                case  6:numberX[pointX]='6';break;
                case  7:numberX[pointX]='7';break;
                case  8:numberX[pointX]='8';break;
                case  9:numberX[pointX]='9';break;
                case 10:numberX[pointX]=isBig?'A':'a';break;
                case 11:numberX[pointX]=isBig?'B':'b';break;
                case 12:numberX[pointX]=isBig?'C':'c';break;
                case 13:numberX[pointX]=isBig?'D':'d';break;
                case 14:numberX[pointX]=isBig?'E':'e';break;
                case 15:numberX[pointX]=isBig?'F':'f';break;
              }
              numX/= 16;
              pointX--;
          }
          int iNowX=pointX+1;
          if(printfNumber>0&&printfNumber>MAXsprintfX-pointX-1){
            for(int i=0;i<(printfNumber-(MAXsprintfX-pointX-1));i++){
              *out='0';
              out++;
            }
          }
          if(zeroX){*out='0';out++;}
          else{
            for(int i=iNowX;i<MAXsprintfX;i++){
                if(numberX[i]!='\0'){
                  *out=numberX[i];
                  out++;
                }
            }
          }
          printfNumber=0;
          getPrintfNumber=false;
          break;
        case '0':printfNumber=printfNumber*10+0;getPrintfNumber=true;break;
        case '1':printfNumber=printfNumber*10+1;getPrintfNumber=true;break;
        case '2':printfNumber=printfNumber*10+2;getPrintfNumber=true;break;
        case '3':printfNumber=printfNumber*10+3;getPrintfNumber=true;break;
        case '4':printfNumber=printfNumber*10+4;getPrintfNumber=true;break;
        case '5':printfNumber=printfNumber*10+5;getPrintfNumber=true;break;
        case '6':printfNumber=printfNumber*10+6;getPrintfNumber=true;break;
        case '7':printfNumber=printfNumber*10+7;getPrintfNumber=true;break;
        case '8':printfNumber=printfNumber*10+8;getPrintfNumber=true;break;
        case '9':printfNumber=printfNumber*10+9;getPrintfNumber=true;break;
        case '%':
          *out='%';
          out++;
          fmt++;
          break;
        default :panic("printf error:%%");break;
      }
    }else if(*fmt=='\\'){
      fmt++;
      switch (*fmt)
      {
        case 'n':
          *out='\n';
          out++;
          fmt++;
          break;
        case '\\':
          *out='\\';
          out++;
          fmt++;
        default :panic("printf error:\\");break;
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
