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

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"
#include "watchpoint.h"
#include <memory/paddr.h>
#include <memory/vaddr.h>

static int is_batch_mode = false;

void init_regex();
/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}


static int cmd_si(char *args) {
  int step=1;
  if(args != NULL) {step=atoi(args);}
  cpu_exec(step);
  return 0;
}

static int cmd_info(char *args) {
  if(args == NULL) {printf("r - print register\nw - print watchpoints\n");return 1;}
  switch (*args)
  {
  case 'r':
    printf("print register when pc = %x\n", cpu.pc);
    isa_reg_display();
    break;
  case 'w':
      // printf("print watchpoints\n");
      bool has=false;
      for(int i=0;wp_pool[i].use == true&&i<NR_WP;i++){
        if(wp_pool[i].use == true){
          has=true;
          printf("no %d :%s new value=%u\n",wp_pool[i].NO,wp_pool[i].require,wp_pool[i].value);
        }
      }
      if(has==false){printf("no watchpoints\n");}
    break;
  default:
    printf("%c is unknow\nr - print register\nw - print watchpoints\n", *args);
    break;
  }
  return 0;
}


static int cmd_x(char *args) {
  if(args==NULL) {printf("x N EXPR\n");return 0;}
  char *n=strtok(args, " ");
  if(n==NULL) {printf("x N EXPR\n");return 0;}
  char *EXPR = strtok(NULL, " ");
  if(EXPR==NULL) {printf("x N EXPR\n");return 0;}
  paddr_t addr = strtol(EXPR,NULL,0);
  int len = strtol(n,NULL,0);
  // printf("%x,%x\n",addr,len);
  // vaddr_read(addr,len);
  printf("pc = %x\n",cpu.pc);
  for(int i=0;i<len;i++) {
    // printf("%x:%x",addr,pmem[addr]);
    printf("%x:%8x\n",addr+i*4,vaddr_read(addr+i*4,4));
  }
  return 0;
}


static int cmd_p(char *args) {
  bool success;
  printf("%u\n",expr(args,&success));
  return 0;
}


static int cmd_w(char *args) {
  WP *wp =new_wp();
  bool success;
  assert(wp!=0);
  strcpy(wp->require,args);
  wp->value = expr(wp->require,&success);
  if(success == false) {printf("expr is wrong\n");free_wp(wp);return 0;}
  printf("add watchpoints no.%d is %s\n",wp->NO,wp->require);

  // wp->line=strtoul(args,NULL,0);
  // printf("add no %d in line 0x%x\n",wp->NO,wp->line);
  return 0;
}

static int cmd_d(char *args) {
  int no = strtoul(args,NULL,0);
  for(int i=0;wp_pool[i].use == true&&i<NR_WP;i++){
    if(wp_pool[i].NO == no) {
      for(;wp_pool[i].use == true&&i<NR_WP-1;i++){
        if(wp_pool[i+1].use == true){
          wp_pool[i].value = wp_pool[i+1].value;
          strcpy(wp_pool[i].require,wp_pool[i+1].require);
        }
        else{break;}
      }
      free_wp(&wp_pool[i]);
      printf("delete no %d\n",no);
      return 0;
    }
  }
  printf("no %d is not exist\n",no);
  return -1;
}




static int cmd_q(char *args) {
  nemu_state.state = NEMU_QUIT;
  return -1;
}

static int cmd_help(char *args);
static int cmd_test(char *args);
static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "Step into one instruction", cmd_si },
  { "info", "Print someshing status", cmd_info },
  { "x", "Print memory", cmd_x },
  { "p", "Print value", cmd_p },
  { "w", "Set watching point", cmd_w },
  { "d", "Delete watching point", cmd_d },
  { "test", "do somr test", cmd_test}

  /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}
static int cmd_test(char *args) {
  if(args == NULL) {
    printf("without order,then will show help\n");
    cmd_help(NULL);
  }else{
    switch (*args)
    {
      case 'p':
        gen_expr();
        break;
      default:
        printf("unknow order\n");
        break;
    }
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
