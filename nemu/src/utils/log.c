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

#include <common.h>

extern uint64_t g_nr_guest_inst;

#ifndef CONFIG_TARGET_AM
FILE *log_fp = NULL;
FILE *log_iringbuf_fp = NULL;
FILE *log_mtraece_fp = NULL;

void init_log(const char *log_file) {
  log_fp = stdout;
  log_iringbuf_fp=stdout;
  log_mtraece_fp=stdout;

  char *log_iringbuf_file=NULL;
  char *log_mtrace_file=NULL;

  if (log_file != NULL) {
    FILE *fp = fopen(log_file, "w");
    Assert(fp, "Can not open '%s'", log_file);
    log_fp = fp;

    log_iringbuf_file = malloc(strlen(log_file) + strlen("_iringbuf") + 1);
    strcpy(log_iringbuf_file, log_file);
    strcat(log_iringbuf_file, "_iringbuf");
    FILE *fp_iringbuf = fopen(log_iringbuf_file, "w");
    Assert(fp_iringbuf, "Can not open '%s'", log_iringbuf_file);
    log_iringbuf_fp = fp_iringbuf;

#ifdef CONFIG_MTRACE
    log_mtrace_file = malloc(strlen(log_file) + strlen("_mtrace") + 1);
    strcpy(log_mtrace_file, log_file);
    strcat(log_mtrace_file, "_mtrace");
    FILE *fp_mtrace = fopen(log_mtrace_file, "w");
    Assert(fp_mtrace, "Can not open '%s'", log_mtrace_file);
    log_mtraece_fp = fp_mtrace;
#endif
  }
  Log("Log is written to %s", log_file ? log_file : "stdout");
  Log("Log of iringbuf is written to %s", log_iringbuf_file ? log_iringbuf_file : "stdout");
  if(log_iringbuf_file!=NULL)free(log_iringbuf_file);

#ifdef CONFIG_MTRACE
  Log("Log of mtrace is written to %s", log_mtrace_file ? log_mtrace_file : "stdout");
  if(log_mtrace_file!=NULL)free(log_mtrace_file);
#endif
}

bool log_enable() {
  return MUXDEF(CONFIG_TRACE, (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END), false);
}

void closeLog(){
  if(log_fp!=NULL&&log_fp!=stdout){fclose(log_fp);}
  if(log_iringbuf_fp!=NULL&&log_iringbuf_fp!=stdout){fclose(log_iringbuf_fp);}

#ifdef CONFIG_MTRACE
  if(log_mtraece_fp!=NULL&&log_mtraece_fp!=stdout){fclose(log_mtraece_fp);}
#endif
}
#endif
