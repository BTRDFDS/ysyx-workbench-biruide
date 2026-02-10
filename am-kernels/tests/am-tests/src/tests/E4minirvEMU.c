#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <am.h>
#include <klib-macros.h>

#define NDEBUG
#include <dbg.h>

#define max 262143
uint32_t PC = 0;
uint32_t R[32];
uint32_t M[max];
#define opAdd    0b0110011
#define opAddi   0b0010011
#define opLui    0b0110111
#define opL      0b0000011
#define opS      0b0100011
#define opJalr   0b1100111
#define opEbreak 0b1110011
#define opW 0b010

int w = 256, h = 256;
#define ramLimD 0x20000000
#define ramLimU 0x20040000

int riscvEMU(int argc, char *argv[]){

//加载指令
    FILE *file = fopen("/home/biruide/ysyx-workbench/am-kernels/tests/am-tests/build/native/src/tests/vga.bin","rb");
    check(file != NULL,"can't open file");
    fseek(file, 0, SEEK_END);
    long fileSize = ftell(file);
    fseek(file, 0, SEEK_SET);
    //size_t words_read = fread(M, sizeof(uint32_t), fileSize/sizeof(uint32_t), file);
    //printf("%ld %ld\n",fileSize,words_read);
    check(fread(M, sizeof(uint32_t), fileSize/sizeof(uint32_t), file) == fileSize/sizeof(uint32_t),"can't read file");
    fclose(file);
    debug(for (int i = 0; i < 16; i++){printf("%8x\n",M[i]);});

    
//初始化特殊值
    R[0]= 0;//初始化R0=1
    //M[0x00000db0>>2] = 0b1110011;//改成ebreak
    //函数主循环开始
    while(1){
        int32_t code,cRd,im,cR1,cR2,op7,op3,up7,addr,move,temp;

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
                if(up7 & 0b1000000){
                    im = (int32_t)((im << 20) >> 20);
                }
                R[cRd] = R[cR1] + im;
                break;
            case opLui:
                //R[cRd] = code&0b11111111111111111111000000000000;
                R[cRd] = (code>>12)<<12;
                //R[cRd] = code & 0xFFFFF000;
                break;
            case opL:
                im = (up7<<5)|(cR2);
                if(up7 & 0b1000000){
                    im = (int32_t)((im << 20) >> 20);
                }
                addr = (R[cR1]+im);
                R[cRd] = M[addr>>2];
                if(op3 != opW){
                    move = (addr&0b11)*8;
                    R[cRd] = (R[cRd]>>move)&0xff;
                }
                break;
            case opS:
                im = (up7<<5)|(cRd);
                if(up7 & 0b1000000){
                    im = (int32_t)((im << 20) >> 20);
                }
                addr =(R[cR1]+im);
                if(addr >= ramLimD && addr < ramLimU){
                    io_write(AM_GPU_FBDRAW, (addr>>2)&0xff, (addr>>10)&0xff, &R[cR2], 1, 1, true);
                }else if(addr < max*4){
                    if(op3 == opW){
                        M[addr>>2] = R[cR2];
                    }else{
                        move = (addr&0b11)*8;
                        temp = M[(addr>>2)];
                        temp = temp&(~(0xff<<move));
                        temp = temp|((R[cR2]&0xff)<<move);
                        M[addr>>2] = temp;
                    }
                }
                break;
            case opJalr:
                temp = PC+4;
                im = (up7<<5)|(cR2);
                if(up7 & 0b1000000){
                    im = (int32_t)((im << 20) >> 20);
                }
                move = R[cR1]+im;
                addr = move&0b11111111111111111111111111111100;
                debug("PC:%x Jalr to %x",PC,addr);
                PC = addr;
                R[cRd] = temp;
                R[0] = 0;
                continue;
            case opEbreak:
                if(R[10] == 0){
                    printf("HIT GOOD TRAP\n");
                }else{
                    printf("HIT BAD TRAP\n");
                }
                printf("PC:%x\n",PC);
                for(int i = 0; i < 4; i++){
                    for (int j = 0; j < 8; j++){
                        printf("%2d:%8x ",i*8+j,R[i*8+j]);
                    }
                    printf("\n");
                }
                return 0;
            default:
                break;
        }
        //PC自增
        PC += 4;
        R[0] = 0;
        check(PC <= max*4,"PC overflow");
    }
error:
    return 0;
}