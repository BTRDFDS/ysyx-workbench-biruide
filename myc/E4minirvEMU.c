#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#define NDEBUG
#include <dbg.h>
uint32_t PC = 0;
uint32_t R[32];
uint32_t M[262143];
#define opAdd 0x33
#define opAddi 0x13
#define opLui 0x37
#define opL 0x3
#define opS 0x23
#define opJalr 0x67
#define opW 0x2
int main(int argc, char *argv[]){
    //函数主循环开始
    while(1){
        uint32_t code,cRd,im,cR1,cR2,op7,op3,up7;

        //指令分解
        code = M[PC>>2];
        op7 = code&0b1111111;
        cRd = (code>>7)&0b11111;
        op3 = (code>>12)&0b111;
        cR1 = (code>>15)&0b11111;
        cR2 = (code>>20)&0b11111;
        up7 = (code>>25)&0b1111111;
        
        //执行
        switch(op7){
            case opAdd:
                R[cRd] = R[cR1] + R[cR2];
                break;
            case opAddi:
                im = (up7<<5)|(cR2);
                R[cRd] = R[cR1] + im;
                break;
            case opLui:
                R[cRd] = up7<<12;
                break;
            case opL:
                uint32_t temp1,temp2;
                im = (up7<<5)|(cR2);
                temp1 = (R[cR1]+im);
                R[cRd] = M[temp1>>2];
                if(op3 != opW){
                    temp2 = (temp1&0b11)*8;
                    R[cRd] = (R[cRd]>>temp2)&0xff;
                }
                break;
            case opS:
                uint32_t temp1,temp2,temp3;
                im = (up7<<5)|(cRd);
                temp1 =(R[cR1]+im);
                //temp2 = M[temp1>>2];
                if(op3 == opW){
                    M[temp1>>2] = R[cR2];
                }else{
                    temp2 = (temp1&0b11)*8;
                    temp3 = M[(temp1>>2)];
                    temp3 = temp3&(~(0xff<<temp2));
                    temp3 = temp3|((R[cR2]&0xff)<<temp2);
                    M[temp1>>2] = temp3;
                }
                break;
            case opJalr:
                R[cRd] = PC+4;
                im = (up7<<5)|(cR2);
                PC = R[cR1]+im;
                continue;
                break;
            default:
                break;
        }
        //PC自增
        PC += 4;
    }
    return 0;
}