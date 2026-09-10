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

#include <memory/host.h>
#include <memory/paddr.h>
#include <device/mmio.h>
#include <isa.h>
#include <common.h>

#if   defined(CONFIG_PMEM_MALLOC)
static uint8_t *pmem_0 = NULL;
static uint8_t *pmem_1 = NULL;
static uint8_t *pmem_2 = NULL;
#else // CONFIG_PMEM_GARRAY
static uint8_t pmem_0[CONFIG_MSIZE] PG_ALIGN = {};
static uint8_t pmem_1[CONFIG_MEM_1_END-CONFIG_MEM_1_START] PG_ALIGN = {};
static uint8_t pmem_2[CONFIG_MEM_2_END-CONFIG_MEM_2_START] PG_ALIGN = {};
#endif
void free_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  if(pmem_0)free(pmem_0);
  if(pmem_1)free(pmem_1);
  if(pmem_2)free(pmem_2);
#endif
}

uint8_t* guest_to_host(paddr_t paddr) { return pmem_0 + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem_0 + CONFIG_MBASE; }

static word_t pmem_read(paddr_t addr, int len) {
  // word_t ret = host_read(guest_to_host(addr), len);
  if(addr - CONFIG_MBASE < CONFIG_MSIZE)return host_read(guest_to_host(addr), len);
  if(CONFIG_MEM_1_START<=addr&&addr<=CONFIG_MEM_1_END)return host_read(pmem_1 + addr - CONFIG_MEM_1_START, len);
  if(CONFIG_MEM_2_START<=addr&&addr<=CONFIG_MEM_2_END)return host_read(pmem_2 + addr - CONFIG_MEM_2_START, len);
  // return ret;
  return 0;
}

static void pmem_write(paddr_t addr, int len, word_t data) {
  // host_write(guest_to_host(addr), len, data); 
  if(addr - CONFIG_MBASE < CONFIG_MSIZE)host_write(guest_to_host(addr), len, data);
  else if(CONFIG_MEM_1_START<=addr&&addr<=CONFIG_MEM_1_END)host_write(pmem_1 + addr - CONFIG_MEM_1_START, len, data);
  else if(CONFIG_MEM_2_START<=addr&&addr<=CONFIG_MEM_2_END)host_write(pmem_2 + addr - CONFIG_MEM_2_START, len, data);
}

static void out_of_bound(paddr_t addr) {
  panic("address = " FMT_PADDR " is out of bound of pmem_0 [" FMT_PADDR ", " FMT_PADDR "] at pc = " FMT_WORD,
      addr, PMEM_LEFT, PMEM_RIGHT, cpu.pc);
}

void init_mem() {
#if   defined(CONFIG_PMEM_MALLOC)
  pmem_0 = malloc(CONFIG_MSIZE);
  assert(pmem_0);
  pmem_1 = malloc(CONFIG_MEM_1_END-CONFIG_MEM_1_START);
  assert(pmem_1);
  pmem_2 = malloc(CONFIG_MEM_2_END-CONFIG_MEM_2_START);
  assert(pmem_2);
#endif
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem_0, rand(), CONFIG_MSIZE));
  Log("physical memory area 0 [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem_1, rand(), CONFIG_MEM_1_END-CONFIG_MEM_1_START));
  Log("physical memory area 1 [" FMT_PADDR ", " FMT_PADDR "]", CONFIG_MEM_1_START, CONFIG_MEM_1_END);
  IFDEF(CONFIG_MEM_RANDOM, memset(pmem_2, rand(), CONFIG_MEM_2_END-CONFIG_MEM_2_START));
  Log("physical memory area 2 [" FMT_PADDR ", " FMT_PADDR "]", CONFIG_MEM_2_START, CONFIG_MEM_2_END);
}

word_t paddr_read(paddr_t addr, int len) {

#ifdef CONFIG_MTRACE
  extern FILE *log_mtrace_fp;
  fprintf(log_mtrace_fp, "x%08x x%x ", addr,len);
  if (likely(in_pmem(addr))) fprintf(log_mtrace_fp,"==%x",pmem_read(addr, len));
  fprintf(log_mtrace_fp,"\n");
  fflush(log_mtrace_fp);
#endif

  if (likely(in_pmem(addr))) return pmem_read(addr, len);
  IFDEF(CONFIG_DEVICE, return mmio_read(addr, len));
  out_of_bound(addr);
  return 0;
}

void paddr_write(paddr_t addr, int len, word_t data) {

#ifdef CONFIG_MTRACE
  extern FILE *log_mtrace_fp;
  fprintf(log_mtrace_fp, "x%08x %x=%08x\n", addr,len,data);
  fflush(log_mtrace_fp);
#endif

  if (likely(in_pmem(addr))) { pmem_write(addr, len, data); return; }
  IFDEF(CONFIG_DEVICE, mmio_write(addr, len, data); return);
  out_of_bound(addr);
}
