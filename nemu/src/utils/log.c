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

void init_log(const char *log_file) {
  log_fp = stdout;
  log_iringbuf_fp=stdout;
  char *log_iringbuf_file=NULL;
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
  }
  Log("Log is written to %s", log_file ? log_file : "stdout");
  Log("Log of iringbuf is written to %s", log_iringbuf_file ? log_iringbuf_file : "stdout");
  if(log_iringbuf_file!=NULL)
    free(log_iringbuf_file);
}

bool log_enable() {
  return MUXDEF(CONFIG_TRACE, (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END), false);
}

void closeLog(){
  if(log_fp!=NULL&&log_fp!=stdout){fclose(log_fp);}
  if(log_iringbuf_fp!=NULL&&log_iringbuf_fp!=stdout){fclose(log_iringbuf_fp);}
}

void writeIringbufLog(const char *format, ...) {
  
}

#endif
