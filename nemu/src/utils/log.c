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
FILE *log_mtrace_fp = NULL;
FILE *log_dtrace_fp = NULL;

char *log_file_printf=NULL;
char *log_iringbuf_file=NULL;
char *log_mtrace_file=NULL;
char *log_dtrace_file=NULL;

void init_log(const char *log_file) {
  log_fp = stdout;
  log_iringbuf_fp=stdout;
  log_mtrace_fp=stdout;
  log_dtrace_fp=stdout;

  if (log_file != NULL) {

    log_file_printf=malloc(strlen(log_file)+strlen(".txt")+1);
    strcpy(log_file_printf,log_file);
    strcat(log_file_printf, ".txt");

    FILE *fp = fopen(log_file, "w");
    Assert(fp, "Can not open '%s'", log_file);
    log_fp = fp;

    log_iringbuf_file = malloc(strlen(log_file) + strlen("_iringbuf.txt") + 1);
    strcpy(log_iringbuf_file, log_file);
    strcat(log_iringbuf_file, "_iringbuf.txt");
    FILE *fp_iringbuf = fopen(log_iringbuf_file, "w");
    Assert(fp_iringbuf, "Can not open '%s'", log_iringbuf_file);
    log_iringbuf_fp = fp_iringbuf;

#ifdef CONFIG_MTRACE
    log_mtrace_file = malloc(strlen(log_file) + strlen("_mtrace.txt") + 1);
    strcpy(log_mtrace_file, log_file);
    strcat(log_mtrace_file, "_mtrace.txt");
    FILE *fp_mtrace = fopen(log_mtrace_file, "w");
    Assert(fp_mtrace, "Can not open '%s'", log_mtrace_file);
    log_mtrace_fp = fp_mtrace;
#endif

#ifdef CONFIG_DTRACE
    log_dtrace_file = malloc(strlen(log_file) + strlen("_dtrace.txt") + 1);
    strcpy(log_dtrace_file, log_file);
    strcat(log_dtrace_file, "_dtrace.txt");
    FILE *fp_dtrace = fopen(log_dtrace_file, "w");
    Assert(fp_dtrace, "Can not open '%s'", log_dtrace_file);
    log_dtrace_fp = fp_dtrace;
#endif
  }
  Log("Log is written to %s", log_file ? log_file : "stdout");
  Log("Log of iringbuf is written to %s", log_iringbuf_file ? log_iringbuf_file : "stdout");
  // if(log_iringbuf_file!=NULL)free(log_iringbuf_file);

#ifdef CONFIG_MTRACE
  Log("Log of mtrace is written to %s", log_mtrace_file ? log_mtrace_file : "stdout");
  // if(log_mtrace_file!=NULL)free(log_mtrace_file);
#endif

#ifdef CONFIG_DTRACE
  Log("Log of dtrace is written to %s", log_dtrace_file ? log_dtrace_file : "stdout");
#endif

}

bool log_enable() {
  return MUXDEF(CONFIG_TRACE, (g_nr_guest_inst >= CONFIG_TRACE_START) &&
         (g_nr_guest_inst <= CONFIG_TRACE_END), false);
}

void closeLog(){
  if(log_iringbuf_fp!=NULL&&log_iringbuf_fp!=stdout){
    // Log("Log of iringbuf is written to %s",log_iringbuf_file);
    if(log_iringbuf_file!=NULL){Log("Log of iringbuf is written to %s",log_iringbuf_file);}
    fclose(log_iringbuf_fp);
  }
  if(log_iringbuf_file!=NULL){free(log_iringbuf_file);}

#ifdef CONFIG_MTRACE
  if(log_mtrace_fp!=NULL&&log_mtrace_fp!=stdout){
    if(log_mtrace_file!=NULL){Log("Log of mtrace is written to %s",log_mtrace_file);}
    // Log("Log of mtrace is written to %s",log_mtrace_file);
    fclose(log_mtrace_fp);
  }
  if(log_mtrace_file!=NULL){free(log_mtrace_file);}
#endif
#ifdef CONFIG_DTRACE
  if(log_dtrace_fp!=NULL&&log_dtrace_fp!=stdout){
    if(log_dtrace_file!=NULL){Log("Log of dtrace is written to %s",log_dtrace_file);}
    fclose(log_dtrace_fp);
  }
  if(log_dtrace_file!=NULL){free(log_dtrace_file);}
#endif

  if(log_fp!=NULL&&log_fp!=stdout){
    if(log_file_printf!=NULL){Log("Log is written to %s",log_file_printf);}
    fclose(log_fp);
  }
  if(log_file_printf!=NULL){free(log_file_printf);}
}
#endif
