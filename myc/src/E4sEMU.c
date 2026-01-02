#include <stdint.h>
#include <stdio.h>
#define NDEBUG 0
#include <dbg.h>
uint8_t PC = 0;
uint8_t R[4];
uint8_t M[16] = {
    0x8a,0xb1,0x17,0x29,0xc9,0x42,0xdb,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};
int inst_cycle(){
    uint8_t code = M[PC];
    uint8_t op = code>>6;
    uint8_t rd = (code>>4)&0b11;
    uint8_t r1 = (code>>2)&0b11;
    uint8_t r2 = code&0b11;
    uint8_t imm= code&0b1111;
    uint8_t addr=(code>>2)&0b1111;

    // printf("PC:%d\tcode:%x\n",PC,code);
    // printf("\tR[0]:%d\tR[1]:%d\tR[2]:%d\tR[3]:%d\n",R[0],R[1],R[2],R[3]);
    debug("PC:%d\tcode:%x",PC,code);
    debug("\tR[0]:%d\tR[1]:%d\tR[2]:%d\tR[3]:%d",R[0],R[1],R[2],R[3]);

    switch(op){
        case 0b00:
            R[rd] = R[r1] + R[r2];
            PC++;
            // printf("\tadd R[%d] = R[%d] + R[%d]\n",rd,r1,r2);
            // printf("\tR[0]:%d\tR[1]:%d\tR[2]:%d\tR[3]:%d\n",R[0],R[1],R[2],R[3]);
            debug("\tadd R[%d] = R[%d] + R[%d]",rd,r1,r2);
            debug("\tR[0]:%d\tR[1]:%d\tR[2]:%d\tR[3]:%d",R[0],R[1],R[2],R[3]);
            break;
        case 0b10:
            R[rd] = imm;
            PC++;
            // printf("\timm R[%d] = %d\n",rd,imm);
            // printf("\tR[0]:%d\tR[1]:%d\tR[2]:%d\tR[3]:%d\n",R[0],R[1],R[2],R[3]);
            debug("\timm R[%d] = %d",rd,imm);
            debug("\tR[0]:%d\tR[1]:%d\tR[2]:%d\tR[3]:%d",R[0],R[1],R[2],R[3]);
            break;
        case 0b11:
            if(R[0]!=R[r2]){
                // printf("\tbner0 R[0](%d) != R[%d](%d)\n",R[0],r2,R[r2]);
                debug("\tbner0 R[0](%d) != R[%d](%d)",R[0],r2,R[r2]);
                if(PC==addr){
                    // printf("Running Out\n");
                    debug("Running Out");
                    return 1;
                }
                // printf("\tGoto %d\n",addr);
                debug("\tGoto %d",addr);
                PC = addr;
                PC = addr;
            }else{
                // printf("\tbner0 R[0] == R[%d]\n",r2);
                debug("\tbner0 R[0] == R[%d]",r2);
                if(PC==15){return 1;}
                PC++;
            }
            break;
        case 0b01:
            debug("\tbner0 R[0](%d) != R[%d](%d)",R[0],r2,R[r2]);
            printf("\tout R[%d] = %d\n",r2,R[r2]);
            debug("\tR[%d] = %d",r2,R[r2]);
            PC++;
            break;
        default:
            PC++;
            break;
    }
    return 0;
}
int main(){
    while (1){if(inst_cycle()==1){break;}}
    return 0;
}