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

#include <cpu/cpu.h>
#include <../../monitor/sdb/sdb.h>

void sdb_mainloop();

void engine_start() {
  // printf("engine start\n");
// #ifdef TEST_AM
//   printf("TEST_AM\n");
//   cmd_t("c");
// #endif
#ifdef CONFIG_TARGET_AM
  cpu_exec(-1);
#elif AUTO_RUN|CONFIG_AUTO_RUN
  printf("AUTO_RUN\n");
  cmd_t("c");
#else
  /* Receive commands from user. */
  // cmd_t("c");
  sdb_mainloop();
#endif
}
