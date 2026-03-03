/***************************************************************************************
* Copyright (c) 2014-2024 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include "local-include/reg.h"
#include <cpu/cpu.h>
#include <cpu/ifetch.h>
#include <cpu/decode.h>
#include <memory/paddr.h>

#define R(i) gpr(i)
#define Mr vaddr_read
#define Mw vaddr_write

enum {
  TYPE_I, TYPE_U, TYPE_S, TYPE_J, TYPE_R, TYPE_B,
  TYPE_N, // none
};

#define src1R() do { *src1 = R(rs1); } while (0)
#define src2R() do { *src2 = R(rs2); } while (0)
#define immI() do { *imm = SEXT(BITS(i, 31, 20), 12); } while(0)
#define immU() do { *imm = SEXT(BITS(i, 31, 12), 20) << 12; } while(0)
#define immS() do { *imm = (SEXT(BITS(i, 31, 25), 7) << 5) | BITS(i, 11, 7); } while(0)
#define immJ() do { *imm = (SEXT(BITS(i, 31, 31), 1) << 20) | (BITS(i, 19, 12) << 12) | (BITS(i, 20, 20) << 11) | (BITS(i, 30, 21) << 1);} while(0)
// #define immJ() do { *imm = SEXT((BITS(i, 31, 31) << 19) | (BITS(i, 19, 12) << 11) | (BITS(i, 20, 20) << 10) | BITS(i, 30, 21) , 20) << 1;} while(0)
#define immB() do { *imm = (SEXT(BITS(i, 31, 31), 1) << 12) | (BITS(i, 7, 7) << 11) | (BITS(i, 30, 25) << 5) | (BITS(i, 11, 8) << 1); } while(0)

int32_t riscv32mDiv(int32_t rs1,int32_t rs2){
  if(rs2==0){
    printf("div 0\n");
    // exit(-1);
    return -1;
  }
  else if(rs1==INT32_MIN&&rs2==-1){return INT32_MIN;}
  else return rs1/rs2;
}
uint32_t riscv32mDivU(uint32_t rs1,uint32_t rs2){
  if(rs2==0){
    printf("divU 0\n");
    // exit(-1);
    return -1;
  }
  else if(rs1==INT32_MIN&&rs2==-1){return 0;}
  else return rs1/rs2;
}
int32_t riscv32mRem(int32_t rs1,int32_t rs2){
  if(rs2==0){
    printf("rem 0\n");
    // exit(-1);
    return rs1;
  }
  else if(rs1==INT32_MIN&&rs2==-1){return 0;}
  else return rs1%rs2;
}
uint32_t riscv32mRemU(uint32_t rs1,uint32_t rs2){
  if(rs2==0){
    printf("remU 0\n");
    // exit(-1);
    return rs1;
  }
  else if(rs1==INT32_MIN&&rs2==-1){return INT32_MIN;}
  else return rs1%rs2;
}

#ifdef CONFIG_FTRACE
#include <common.h>

extern FILE *log_ftrace_fp;
static int ftraceCount = 0;
#endif

void riscv32FtraceJalr(Decode *s,int rd){
#ifdef CONFIG_FTRACE
  if(s->isa.inst==0x00008067){
    // printf("ret\n");
    fprintf(log_ftrace_fp,"0x%8x : ",s->pc);
    ftraceCount--;
    for(int i=0;i<ftraceCount;i++){
      fprintf(log_ftrace_fp,"\t");
    }
    fprintf(log_ftrace_fp,"ret [%s]\n",getFuncName(s->pc));
  }else if(rd==1){
    // printf("call\n");
    fprintf(log_ftrace_fp,"0x%8x : ",s->pc);
    for(int i=0;i<ftraceCount;i++){
      fprintf(log_ftrace_fp,"\t");
    }
    fprintf(log_ftrace_fp,"call[%s@0x%8x]\n",getFuncName(s->dnpc),s->dnpc);
    ftraceCount++;
  }
#endif
}
void riscv32FtraceJal(Decode *s,int rd){
#ifdef CONFIG_FTRACE
  if(rd==1){
    // printf("call\n");
    fprintf(log_ftrace_fp,"0x%8x : ",s->pc);
    for(int i=0;i<ftraceCount;i++){
      fprintf(log_ftrace_fp,"\t");
    }
    fprintf(log_ftrace_fp,"call[%s@0x%8x]\n",getFuncName(s->dnpc),s->dnpc);
    ftraceCount++;
  }
#endif
}

word_t mepc=0;
word_t mcause=0;
word_t mstatus=0x1800;
word_t mtvec=0;

word_t riscv32zCsrrw(word_t rs1,word_t addr){
  printf("csrrw addr=%x rs1=%x\n",addr,rs1);
  word_t old=0;
  switch(addr){
    case 0x300:old=mstatus;mstatus=rs1;break;
    case 0x305:old=mtvec;  mtvec=rs1;  break;
    case 0x341:old=mepc;   mepc=rs1;   break;
    case 0x342:old=mcause; mcause=rs1; break;
    default: panic("csrrw addr=%x",addr);
  }
  return old;
}
word_t riscv32zCsrrs(word_t rs1,word_t addr){
  printf("csrrs addr=%x rs1=%x\n",addr,rs1);
  word_t old=0;
  switch(addr){
    case 0x300:old=mstatus;mstatus|=rs1;break;
    case 0x305:old=mtvec;  mtvec  |=rs1;break;
    case 0x341:old=mepc;   mepc   |=rs1;break;
    case 0x342:old=mcause; mcause |=rs1;break;
    default: panic("csrrs addr=%x",addr);
  }
  return old;
}
word_t riscv32mret(){
  mstatus=0x1800;
  mcause=0;
  printf("mret to 0x%x\n",mepc);
  return mepc+4;
}
word_t riscv32ecall(word_t pc){
  mepc=pc;
  mcause=11;
  printf("ecall@0x%x to 0x%x\n",pc,mtvec);
  return mtvec;
}

static void decode_operand(Decode *s, int *rd, word_t *src1, word_t *src2, word_t *imm, int type) {
  uint32_t i = s->isa.inst;
  int rs1 = BITS(i, 19, 15);
  int rs2 = BITS(i, 24, 20);
  *rd     = BITS(i, 11, 7);
  switch (type) {
    case TYPE_R: src1R(); src2R();       ; break;
    case TYPE_I: src1R();          immI(); break;
    case TYPE_S: src1R(); src2R(); immS(); break;
    case TYPE_B: src1R(); src2R(); immB(); break;
    case TYPE_U:                   immU(); break;
    case TYPE_J:                   immJ(); break;
    case TYPE_N: break;
    default: panic("unsupported type = %d", type);
  }
}

static int decode_exec(Decode *s) {
  s->dnpc = s->snpc;

#define INSTPAT_INST(s) ((s)->isa.inst)
#define INSTPAT_MATCH(s, name, type, ... /* execute body */ ) { \
  int rd = 0; \
  word_t src1 = 0, src2 = 0, imm = 0; \
  decode_operand(s, &rd, &src1, &src2, &imm, concat(TYPE_, type)); \
  __VA_ARGS__ ; \
}

  INSTPAT_START();
  //RV32I
  INSTPAT("??????? ????? ????? ??? ????? 0110111", lui      , U, R(rd) = imm);
  INSTPAT("??????? ????? ????? ??? ????? 0010111", auipc    , U, R(rd) = s->pc + imm);
  INSTPAT("??????? ????? ????? ??? ????? 1101111", jal      , J, R(rd) = s->snpc , s->dnpc = imm+s->pc, riscv32FtraceJal(s,rd));
  INSTPAT("??????? ????? ????? 000 ????? 1100111", jalr     , I, R(rd) = s->snpc , s->dnpc = imm+src1 ,riscv32FtraceJalr(s,rd));
  INSTPAT("??????? ????? ????? 000 ????? 1100011", beq      , B, s->dnpc = ((uint32_t)src1 == (uint32_t)src2)?imm+s->pc:s->snpc);
  INSTPAT("??????? ????? ????? 001 ????? 1100011", bne      , B, s->dnpc = ((uint32_t)src1 != (uint32_t)src2)?imm+s->pc:s->snpc);
  INSTPAT("??????? ????? ????? 100 ????? 1100011", blt      , B, s->dnpc = (( int32_t)src1 <  ( int32_t)src2)?imm+s->pc:s->snpc);
  INSTPAT("??????? ????? ????? 101 ????? 1100011", bge      , B, s->dnpc = (( int32_t)src1 >= ( int32_t)src2)?imm+s->pc:s->snpc);
  INSTPAT("??????? ????? ????? 110 ????? 1100011", bltu     , B, s->dnpc = ((uint32_t)src1 <  (uint32_t)src2)?imm+s->pc:s->snpc);
  INSTPAT("??????? ????? ????? 111 ????? 1100011", bgeu     , B, s->dnpc = ((uint32_t)src1 >= (uint32_t)src2)?imm+s->pc:s->snpc);
  INSTPAT("??????? ????? ????? 000 ????? 0000011", lb       , I, R(rd) = SEXT(Mr((uint32_t)src1 + imm, 1),8));
  INSTPAT("??????? ????? ????? 001 ????? 0000011", lh       , I, R(rd) = SEXT(Mr((uint32_t)src1 + imm, 2),16));
  INSTPAT("??????? ????? ????? 010 ????? 0000011", lw       , I, R(rd) = Mr((uint32_t)src1 + imm, 4));
  INSTPAT("??????? ????? ????? 100 ????? 0000011", lbu      , I, R(rd) = Mr((uint32_t)src1 + imm, 1)&0x000000FF);
  INSTPAT("??????? ????? ????? 101 ????? 0000011", lhu      , I, R(rd) = Mr((uint32_t)src1 + imm, 2)&0x0000FFFF);
  INSTPAT("??????? ????? ????? 000 ????? 0100011", sb       , S, Mw((uint32_t)src1 + imm, 1, (uint32_t)src2&0x00FF));
  INSTPAT("??????? ????? ????? 001 ????? 0100011", sh       , S, Mw((uint32_t)src1 + imm, 2, (uint32_t)src2&0xFFFF));
  INSTPAT("??????? ????? ????? 010 ????? 0100011", sw       , S, Mw((uint32_t)src1 + imm, 4, (uint32_t)src2));
  INSTPAT("??????? ????? ????? 000 ????? 0010011", addi     , I, R(rd) = imm+(uint32_t)src1);
  INSTPAT("??????? ????? ????? 010 ????? 0010011", slti     , I, R(rd) = (( int32_t)src1 < ( int32_t)imm)?1:0);
  INSTPAT("??????? ????? ????? 011 ????? 0010011", sltiu    , I, R(rd) = ((uint32_t)src1 < (uint32_t)imm)?1:0);
  INSTPAT("??????? ????? ????? 100 ????? 0010011", xori     , I, R(rd) = (uint32_t)src1 ^ imm);
  INSTPAT("??????? ????? ????? 110 ????? 0010011", ori      , I, R(rd) = (uint32_t)src1 | imm);
  INSTPAT("??????? ????? ????? 111 ????? 0010011", andi     , I, R(rd) = (uint32_t)src1 & imm);
  INSTPAT("0000000 ????? ????? 001 ????? 0010011", slli     , I, R(rd) = (uint32_t)src1 << (imm&0b11111));
  INSTPAT("0000000 ????? ????? 101 ????? 0010011", srli     , I, R(rd) = (uint32_t)src1 >> (imm&0b11111));
  INSTPAT("0100000 ????? ????? 101 ????? 0010011", srai     , I, R(rd) = ( int32_t)src1 >> (imm&0b11111));
  INSTPAT("0000000 ????? ????? 000 ????? 0110011", add      , R, R(rd) = (uint32_t)src1+src2);
  INSTPAT("0100000 ????? ????? 000 ????? 0110011", sub      , R, R(rd) = (uint32_t)src1-src2);
  INSTPAT("0000000 ????? ????? 001 ????? 0110011", sll      , R, R(rd) = (uint32_t)src1 << (src2&0b11111));
  INSTPAT("0000000 ????? ????? 010 ????? 0110011", slt      , R, R(rd) = (( int32_t)src1 < ( int32_t)src2)?1:0);
  INSTPAT("0000000 ????? ????? 011 ????? 0110011", sltu     , R, R(rd) = ((uint32_t)src1 < (uint32_t)src2)?1:0);
  INSTPAT("0000000 ????? ????? 100 ????? 0110011", xor      , R, R(rd) = (uint32_t)src1 ^ (uint32_t)src2);
  INSTPAT("0000000 ????? ????? 101 ????? 0110011", srl      , R, R(rd) = (uint32_t)src1 >> ((uint32_t)src2&0b11111));
  INSTPAT("0100000 ????? ????? 101 ????? 0110011", sra      , R, R(rd) = ( int32_t)src1 >> ((uint32_t)src2&0b11111));
  INSTPAT("0000000 ????? ????? 110 ????? 0110011", or       , R, R(rd) = (uint32_t)src1 | (uint32_t)src2);
  INSTPAT("0000000 ????? ????? 111 ????? 0110011", and      , R, R(rd) = (uint32_t)src1 & (uint32_t)src2);
  // INSTPAT("??????? ????? ????? 000 ????? 0001111", fence    ,);
  // INSTPAT("1000001 10011 00000 000 00000 0001111", fence.tso,);
  // INSTPAT("0000000 10000 00000 000 00000 0001111", pause    ,);
  INSTPAT("0000000 00000 00000 000 00000 1110011", ecall    , N, s->dnpc=riscv32ecall(s->pc));
  INSTPAT("0000000 00001 00000 000 00000 1110011", ebreak   , N, NEMUTRAP(s->pc, R(10))); // R(10) is $a0
  //RV32M
  INSTPAT("0000001 ????? ????? 000 ????? 0110011", MUL      , R, R(rd) =  (uint32_t)src1 * (uint32_t)src2);
  INSTPAT("0000001 ????? ????? 001 ????? 0110011", MULH     , R, R(rd) = (( int64_t)SEXT(src1,32) * ( int64_t)SEXT(src2,32))>>32);
  INSTPAT("0000001 ????? ????? 010 ????? 0110011", MULHSU   , R, R(rd) = (( int64_t)SEXT(src1,32) * (uint64_t)src2)>>32);
  INSTPAT("0000001 ????? ????? 011 ????? 0110011", MULHU    , R, R(rd) = ((uint64_t)src1 * (uint64_t)src2)>>32);
  INSTPAT("0000001 ????? ????? 100 ????? 0110011", DIV      , R, R(rd) =  riscv32mDiv (( int32_t)src1, ( int32_t)src2));
  INSTPAT("0000001 ????? ????? 101 ????? 0110011", DIVU     , R, R(rd) =  riscv32mDivU((uint32_t)src1, (uint32_t)src2));
  INSTPAT("0000001 ????? ????? 110 ????? 0110011", REM      , R, R(rd) =  riscv32mRem (( int32_t)src1, ( int32_t)src2));
  INSTPAT("0000001 ????? ????? 111 ????? 0110011", REMU     , R, R(rd) =  riscv32mRemU((uint32_t)src1, (uint32_t)src2));
  //RV32Z
  INSTPAT("??????? ????? ????? 001 ????? 1110011", csrrw    , I, R(rd) = riscv32zCsrrw((uint32_t)src1, imm));
  INSTPAT("??????? ????? ????? 010 ????? 1110011", csrrs    , I, R(rd) = riscv32zCsrrs((uint32_t)src1, imm));
  INSTPAT("0011000 00010 00000 000 00000 1110011", mret     , N, s->dnpc=riscv32mret());
  //未能匹配
  INSTPAT("??????? ????? ????? ??? ????? ???????", inv      , N, INV(s->pc));
  INSTPAT_END();

  R(0) = 0; // reset $zero to 0

  return 0;
}

int isa_exec_once(Decode *s) {
  s->isa.inst = inst_fetch(&s->snpc, 4);
  return decode_exec(s);
}
