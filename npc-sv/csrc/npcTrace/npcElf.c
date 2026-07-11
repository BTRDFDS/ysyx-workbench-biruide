#include <npcTrace.h>
#include <elf.h>
typedef struct {
    uint32_t start; // 函数起始地址
    uint32_t end;   // 函数结束地址 (start + size)
    char *name;     // 函数名指针 (直接指向 strtab 里的字符串)
}funcAddrName;
typedef struct {
    funcAddrName *func;
    uint32_t funcNumber;    // 函数数量
    bool has;
}funcTracer;

char *strtab=NULL;
funcTracer fTracer;

void errCtl(const char *errcode){
  fTracer.has=false;
  extern FILE *npctraceFtraceFp;
  fprintf(npctraceFtraceFp,"err %s .ftrace maybe been close or output ???\n",errcode);
}
void NpcTraceInitElf(char *img_file){

FILE *elf_fp=NULL;
Elf32_Ehdr ehdr;
Elf32_Shdr *shdrs=NULL;
Elf32_Shdr *shstrtab_shdr=NULL;
//指针地址不是值
Elf32_Shdr *symtab_sh=NULL; //函数查找表.symtab
Elf32_Shdr *strtab_sh=NULL; //名字本.strtab
int sym_count=0;
char *dot=NULL;
Elf32_Sym *symtab=NULL;
char *shstrtab=NULL;
char *elf_file=NULL;

  if(img_file==NULL){
    printf("No image is given.ftrace maybe been close or output ???\n");
    errCtl("img_file");
    return;
  }else{
    fTracer.has=true;
  }

  char *img_dir = (char*)malloc(strlen(img_file) + 3);
  // Assert(img_dir!=NULL,"err img_dir");
  if(img_dir==NULL){errCtl("img_dir");goto err;}

  strcpy(img_dir, img_file);
  dot = strrchr(img_dir, '.');
  if (dot!= NULL) {*dot= '\0';}

  elf_file= (char*)malloc(strlen(img_file)+strlen(".elf")+1);
  // Assert(elf_file!=NULL,"err elf_file");
  if(elf_file==NULL){errCtl("elf_file");goto err;}
  strcpy(elf_file, img_dir);
  strcat(elf_file, ".elf");
  elf_fp = fopen(elf_file, "rb");
  // Assert(elf_fp, "Can not open '%s'", elf_file);
  if(elf_fp==NULL){errCtl("open elf_fp");goto err;}

  // Assert(fread(&ehdr, sizeof(ehdr), 1, elf_fp) == 1, "err ehdr");
  if(fread(&ehdr,sizeof(ehdr),1,elf_fp)!=1){errCtl("fread ehdr");goto err;}

  shdrs = (Elf32_Shdr*)malloc(ehdr.e_shnum * sizeof(Elf32_Shdr));//节头，e_shnum条，每条是Elf32_Shdr的大小
  // Assert(shdrs!=NULL,"err shdrs");
  if(shdrs==NULL){errCtl("shdrs");goto err;}
  if(fseek(elf_fp,ehdr.e_shoff,SEEK_SET)!=0){errCtl("fseek shdrs");goto err;}
  if(fread(shdrs,sizeof(Elf32_Shdr),ehdr.e_shnum,elf_fp)!=ehdr.e_shnum){errCtl("fread shdrs");goto err;}

  shstrtab_shdr = &shdrs[ehdr.e_shstrndx];
  shstrtab = (char*)malloc(shstrtab_shdr->sh_size);//字符串表
  // Assert(shstrtab!=NULL,"err shstrtab");
  if(shstrtab==NULL){errCtl("shstrtab");goto err;}
  if(fseek(elf_fp,shstrtab_shdr->sh_offset,SEEK_SET)!=0){errCtl("fseek shstrtab");goto err;}
  if(fread(shstrtab,shstrtab_shdr->sh_size,1,elf_fp)!=1){errCtl("fread shstrtab");goto err;}


  for (int i = 0; i < ehdr.e_shnum; i++) {
    char *name = &shstrtab[shdrs[i].sh_name]; // 取出节的名字
    if(strcmp(name,".symtab")==0){symtab_sh=&shdrs[i];}
    if(strcmp(name,".strtab")==0){strtab_sh=&shdrs[i];}
  }
  if(symtab_sh==NULL){errCtl("symtab_sh");goto err;}
  if(strtab_sh==NULL){errCtl("strtab_sh");goto err;}

  symtab=(Elf32_Sym*)malloc(symtab_sh->sh_size);
  if(symtab==NULL){errCtl("symtab");goto err;}
  sym_count=symtab_sh->sh_size/sizeof(Elf32_Sym);
  if(fseek(elf_fp,symtab_sh->sh_offset,SEEK_SET)!=0){errCtl("fseek symtab");goto err;}
  if(fread(symtab,symtab_sh->sh_size,1,elf_fp)!=1){errCtl("fread symtab");goto err;}

  strtab=(char*)malloc(strtab_sh->sh_size);
  // Assert(strtab!=NULL,"err strtab");
  if(strtab==NULL){errCtl("strtab");goto err;}
  if(fseek(elf_fp,strtab_sh->sh_offset,SEEK_SET)!=0){errCtl("fseek strtab");goto err;}
  if(fread(strtab,strtab_sh->sh_size,1,elf_fp)!=1){errCtl("fread strtab");goto err;}

  fTracer.funcNumber = 0;
  fTracer.func = (funcAddrName*)malloc(sym_count * sizeof(funcAddrName));
  if(fTracer.func==NULL){errCtl("tracer.func");goto err;}

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
    funcAddrName *temp = (funcAddrName*)realloc(fTracer.func, fTracer.funcNumber * sizeof(funcAddrName));
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
char *getFuncName(uint32_t addr){
  if(fTracer.has==false){return errName;}
  for (int i = 0; i < fTracer.funcNumber; i++) {
    if (addr >= fTracer.func[i].start && addr < fTracer.func[i].end){
      return fTracer.func[i].name;
    }
  }
  return errName;
}