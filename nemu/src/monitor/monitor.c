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
#include <memory/paddr.h>
#include <libgen.h>

#include <common.h>
#include <elf.h>

void init_rand();
void init_log(const char *log_file);
void init_mem();
void init_difftest(char *ref_so_file, long img_size, int port);
void init_device();
void init_sdb();
void init_disasm();

static void welcome() {
  Log("Trace: %s", MUXDEF(CONFIG_TRACE, ANSI_FMT("ON", ANSI_FG_GREEN), ANSI_FMT("OFF", ANSI_FG_RED)));
  IFDEF(CONFIG_TRACE, Log("If trace is enabled, a log file will be generated "
        "to record the trace. This may lead to a large log file. "
        "If it is not necessary, you can disable it in menuconfig"));
  Log("Build time: %s, %s", __TIME__, __DATE__);
  printf("Welcome to %s-NEMU!\n", ANSI_FMT(str(__GUEST_ISA__), ANSI_FG_YELLOW ANSI_BG_RED));
  printf("For help, type \"help\"\n");
  // Log("Exercise: Please remove me in the source code and compile NEMU again.");
  // assert(0);
}

#ifndef CONFIG_TARGET_AM
#include <getopt.h>

void sdb_set_batch_mode();

static char *log_file = NULL;
static char *diff_so_file = NULL;
static char *img_file = NULL;
static int difftest_port = 1234;

static long load_img() {
  if (img_file == NULL) {
    Log("No image is given. Use the default build-in image.");
    return 4096; // built-in image size
  }

  FILE *fp = fopen(img_file, "rb");
  Assert(fp, "Can not open '%s'", img_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  Log("The image is %s, size = %ld", img_file, size);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
  assert(ret == 1);

  fclose(fp);
  return size;
}

#ifdef CONFIG_FTRACE
typedef struct {
    word_t start; // 函数起始地址
    word_t end;   // 函数结束地址 (start + size)
    char *name;     // 函数名指针 (直接指向 strtab 里的字符串)
}funcAddrName;
typedef struct {
    funcAddrName *func;
    uint32_t funcNumber;    // 函数数量
    bool has;
}funcTracer;

char *strtab=NULL;
funcTracer fTracer;

void errCtl(char *errcode){
  fTracer.has=false;
  extern FILE *log_ftrace_fp;
  fprintf(log_ftrace_fp,"err %s .ftrace maybe been close or output ???\n",errcode);
}


void init_ftrace(){
  if(img_file==NULL){
    fTracer.has=false;
    Log("No image is given.ftrace maybe been close or output ???");
    return;
  }else{
    fTracer.has=true;
  }

FILE *elf_fp=NULL;
Elf32_Ehdr ehdr;
Elf32_Shdr *shdrs=NULL;
Elf32_Shdr *shstrtab_shdr=NULL;
//指针地址不是值
Elf32_Shdr *symtab_sh=NULL; //函数查找表.symtab
Elf32_Shdr *strtab_sh=NULL; //名字本.strtab

Elf32_Sym *symtab=NULL;
char *shstrtab=NULL;
char *elf_file=NULL;


  
  char *img_dir = malloc(strlen(img_file) + 1);
  // Assert(img_dir!=NULL,"err img_dir");
  if(img_dir==NULL){errCtl("img_dir");goto err;}

  strcpy(img_dir, img_file);
  char *dot = strrchr(img_dir, '.');
  if (dot!= NULL) {*dot= '\0';}

  elf_file= malloc(strlen(img_file)+strlen(".elf")+1);
  // Assert(elf_file!=NULL,"err elf_file");
  if(elf_file==NULL){errCtl("elf_file");goto err;}
  strcpy(elf_file, img_dir);
  strcat(elf_file, ".elf");
  elf_fp = fopen(elf_file, "rb");
  // Assert(elf_fp, "Can not open '%s'", elf_file);
  if(elf_fp==NULL){errCtl("open elf_fp");goto err;}

  // Assert(fread(&ehdr, sizeof(ehdr), 1, elf_fp) == 1, "err ehdr");
  if(fread(&ehdr,sizeof(ehdr),1,elf_fp)!=1){errCtl("fread ehdr");goto err;}

  shdrs = malloc(ehdr.e_shnum * sizeof(Elf32_Shdr));//节头，e_shnum条，每条是Elf32_Shdr的大小
  Assert(shdrs!=NULL,"err shdrs");
  // fseek(elf_fp, ehdr.e_shoff, SEEK_SET);//从e_shoff开始
  // fread(shdrs, sizeof(Elf32_Shdr), ehdr.e_shnum, elf_fp);
  Assert(fseek(elf_fp,ehdr.e_shoff, SEEK_SET)==0,"err fseek shdrs");
  Assert(fread(shdrs,sizeof(Elf32_Shdr),ehdr.e_shnum,elf_fp)==ehdr.e_shnum,"err fread shdrs");

  shstrtab_shdr = &shdrs[ehdr.e_shstrndx];
  shstrtab = malloc(shstrtab_shdr->sh_size);//字符串表
  Assert(shstrtab!=NULL,"err shstrtab");
  // fseek(elf_fp, shstrtab_shdr->sh_offset, SEEK_SET);
  // fread(shstrtab, shstrtab_shdr->sh_size, 1, elf_fp);
  Assert(fseek(elf_fp,shstrtab_shdr->sh_offset, SEEK_SET)==0,"err fseek shstrtab");
  Assert(fread(shstrtab,shstrtab_shdr->sh_size,1,elf_fp)==1,"err fread shstrtab");


  for (int i = 0; i < ehdr.e_shnum; i++) {
    char *name = &shstrtab[shdrs[i].sh_name]; // 取出节的名字
    if(strcmp(name,".symtab")==0){symtab_sh=&shdrs[i];}
    if(strcmp(name,".strtab")==0){strtab_sh=&shdrs[i];}
  }
  Assert(symtab_sh!=NULL,"err symtab_sh");
  Assert(strtab_sh!=NULL,"err strtab_sh");

  symtab=malloc(symtab_sh->sh_size);
  Assert(symtab!=NULL, "err symtab");
  int sym_count=symtab_sh->sh_size/sizeof(Elf32_Sym);
  // fseek(elf_fp, symtab_sh->sh_offset, SEEK_SET);
  // fread(symtab, symtab_sh->sh_size,1,elf_fp);
  Assert(fseek(elf_fp,symtab_sh->sh_offset,SEEK_SET)==0,"err fseek symtab");
  Assert(fread(symtab,symtab_sh->sh_size,1,elf_fp)==1,"err fread symtab");

  strtab=malloc(strtab_sh->sh_size);
  Assert(strtab!=NULL,"err strtab");
  // fseek(elf_fp,strtab_sh->sh_offset,SEEK_SET);
  // fread(strtab,strtab_sh->sh_size,1,elf_fp);
  Assert(fseek(elf_fp,strtab_sh->sh_offset,SEEK_SET)==0,"err fseek strtab");
  Assert(fread(strtab,strtab_sh->sh_size,1,elf_fp)==1,"err fread strtab");

  fTracer.funcNumber = 0;
  fTracer.func = malloc(sym_count * sizeof(funcAddrName));
  Assert(fTracer.func!=NULL,"err tracer.func");

  for (int i = 0; i < sym_count; i++) {
    Elf32_Sym *sym = &symtab[i];
    if (ELF32_ST_TYPE(sym->st_info) != STT_FUNC){continue;}
    char *name = &strtab[sym->st_name];
    if (name[0] == '\0'){continue;}
    fTracer.func[fTracer.funcNumber].start = sym->st_value;
    fTracer.func[fTracer.funcNumber].end = sym->st_value + sym->st_size;
    fTracer.func[fTracer.funcNumber].name = name;
    fTracer.funcNumber++;
  }
  if (fTracer.funcNumber<sym_count) {
    funcAddrName *temp = realloc(fTracer.func, fTracer.funcNumber * sizeof(funcAddrName));
    if (temp != NULL) {fTracer.func = temp;}
  }

err:
  if(img_dir!=NULL){free(img_dir);}
  if(elf_file!=NULL){free(elf_file);}
  if(shdrs!=NULL){free(shdrs);}
  if(shstrtab!=NULL){free(shstrtab);}
  if(symtab!=NULL){free(symtab);}
  fclose(elf_fp);
}

char errName[]="???";
char *getFuncName(word_t addr){
  if(fTracer.has==false){return errName;}
  for (int i = 0; i < fTracer.funcNumber; i++) {
    if (addr >= fTracer.func[i].start && addr < fTracer.func[i].end){
      return fTracer.func[i].name;
    }
  }
  return errName;
}

void closeFtrace(){
  if(fTracer.has==false){return;}
  if(strtab!=NULL){free(strtab);}
  if(fTracer.func!=NULL){
    free(fTracer.func);
    fTracer.func=NULL;
    fTracer.funcNumber=0;
  }
}
#endif


static int parse_args(int argc, char *argv[]) {
  const struct option table[] = {
    {"batch"    , no_argument      , NULL, 'b'},
    {"log"      , required_argument, NULL, 'l'},
    {"diff"     , required_argument, NULL, 'd'},
    {"port"     , required_argument, NULL, 'p'},
    {"help"     , no_argument      , NULL, 'h'},
    {0          , 0                , NULL,  0 },
  };
  int o;
  while ( (o = getopt_long(argc, argv, "-bhl:d:p:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'p': sscanf(optarg, "%d", &difftest_port); break;
      case 'l': log_file = optarg; break;
      case 'd': diff_so_file = optarg; break;
      case 1: img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-l,--log=FILE           output log to FILE\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}

void init_monitor(int argc, char *argv[]) {
  /* Perform some global initialization. */

  /* Parse arguments. */
  parse_args(argc, argv);

  /* Set random seed. */
  init_rand();

  /* Open the log file. */
  init_log(log_file);

  /* Initialize memory. */
  init_mem();

  /* Initialize devices. */
  IFDEF(CONFIG_DEVICE, init_device());

  /* Perform ISA dependent initialization. */
  init_isa();

  /* Load the image to memory. This will overwrite the built-in image. */
  long img_size = load_img();

  IFDEF(CONFIG_FTRACE,init_ftrace());

  /* Initialize differential testing. */
  init_difftest(diff_so_file, img_size, difftest_port);

  /* Initialize the simple debugger. */
  init_sdb();

  IFDEF(CONFIG_ITRACE, init_disasm());

  /* Display welcome message. */
  welcome();
}
#else // CONFIG_TARGET_AM
static long load_img() {
  extern char bin_start, bin_end;
  size_t size = &bin_end - &bin_start;
  Log("img size = %ld", size);
  memcpy(guest_to_host(RESET_VECTOR), &bin_start, size);
  return size;
}

void am_init_monitor() {
  init_rand();
  init_mem();
  init_isa();
  load_img();
  IFDEF(CONFIG_DEVICE, init_device());
  welcome();
}
#endif
