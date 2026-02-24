#include <npcTrace.h>


csh handle;

FILE *npctraceIringsFp=NULL;
FILE *npctraceMtraceFp=NULL;
FILE *npctraceFtraceFp=NULL;

const char *npctraceIringsFile={"log/irings.log"};
const char *npctraceMtraceFile={"log/mtrace.log"};
const char *npctraceFtraceFile={"log/ftrace.log"};

void NpcTraceInitFile(){

		const char *npc_home = getenv("NPC_HOME");
		if (npc_home == NULL) {
				printf("err NPC_HEME\n");
				return;
		}

	npctraceIringsFp = fopen(npctraceIringsFile, "w");
	if(npctraceIringsFp == NULL){printf("err:open %s",npctraceIringsFile);exit(-1);}

	npctraceMtraceFp = fopen(npctraceMtraceFile, "w");
	if(npctraceMtraceFp == NULL){printf("err:open %s",npctraceMtraceFile);exit(-1);}

	npctraceFtraceFp = fopen(npctraceFtraceFile, "w");
	if(npctraceFtraceFp == NULL){printf("err:open %s",npctraceFtraceFile);exit(-1);}
}

void NpcTraceCloseFile(){
	if(npctraceIringsFp != NULL){
		printf("irings:%s\n",npctraceIringsFile);
		fclose(npctraceIringsFp);
	}
	if(npctraceMtraceFp != NULL){
		printf("mtrace:%s\n",npctraceMtraceFile);
		fclose(npctraceMtraceFp);
	}
	if(npctraceFtraceFp != NULL){
		printf("ftrace:%s\n",npctraceFtraceFile);
		fclose(npctraceFtraceFp);
	}
}

void NpcTraceInitCapstone(){
	cs_err err = cs_open(CS_ARCH_RISCV, CS_MODE_RISCV32, &handle);
	if (err != CS_ERR_OK) {
		printf("ERROR Capstone:%s\n", cs_strerror(err));
		exit(-1);
	}
	cs_option(handle, CS_OPT_DETAIL, CS_OPT_OFF);
}

bool NpcTraceCapstone(uint32_t incode,char*mnemonic,char*op){
	if(mnemonic==NULL){printf("err:mnemonic");exit(-1);}
	if(op==NULL){printf("err:op");exit(-1);}
	cs_insn *insn;
		uint8_t *code_bytes = (uint8_t*)&incode;
	size_t count=cs_disasm(handle, code_bytes,4,0,0,&insn);
	if(count>0){
		strncpy(mnemonic,insn[0].mnemonic,32);
		strncpy(op,insn[0].op_str,160);
		cs_free(insn, count);
		return true;
	}else{
		if(count!=0){cs_free(insn, count);}
		return false;
	}
}

void NpcTraceCloseCapstone(){
	cs_close(&handle);
}

void NpcTraceInit(char *argv){
	NpcTraceInitFile();
	NpcTraceInitCapstone();
	NpcTraceInitElf(argv);
}

void NpcTraceClose(){
	NpcTraceCloseCapstone();
	NpcTraceCloseFile();
}

void NpcTraceIrings(uint32_t pc,uint32_t incode,char*mnemonic,char*op){
		
	static int iringbufCount=0;
	static char npctraceIrings[npcTraceIringMax][npcTraceIringSize]={0};
	if(npctraceIringsFp !=NULL){
		memset(npctraceIrings[iringbufCount%npcTraceIringMax],0,sizeof(npctraceIrings[iringbufCount%npcTraceIringMax]));
		// strncpy(npctraceIrings[iringbufCount%npcTraceIringMax],_this->logbuf,npcTraceIringSize);
		sprintf(npctraceIrings[iringbufCount%npcTraceIringMax],"%x:%s\t%s",pc,mnemonic,op);
		iringbufCount++;

		fseek(npctraceIringsFp,0,SEEK_SET);
		if(ftruncate(fileno(npctraceIringsFp), 0)!=0){printf("err ftruncate\n");exit(-1);}

		for(int i=0;i<(iringbufCount>=npcTraceIringMax?npcTraceIringMax:iringbufCount);i++){
			if(i==(iringbufCount%npcTraceIringMax)-1||(iringbufCount!=0&&i==npcTraceIringMax-1&&iringbufCount%npcTraceIringMax==0)){
				fprintf(npctraceIringsFp,"-->\t%s",npctraceIrings[i]);
			}
			else{fprintf(npctraceIringsFp,"\t%s",npctraceIrings[i]);}
			if(i<(iringbufCount>=npcTraceIringMax?npcTraceIringMax:iringbufCount)-1){fprintf(npctraceIringsFp,"\n");}
		}
		fflush(npctraceIringsFp);
	}
}
void NpcTraceMtraceWrite(uint32_t pc,uint32_t incode){
		
}
void NpcTraceMtraceRead(uint32_t pc,uint32_t incode){
    
}
void NpcTraceFtrace(uint32_t pc,uint32_t incode,char*mnemonic,uint32_t dnpc){
	static uint32_t ftraceCount=0;
  if(strcmp(mnemonic,"ret")==0){printf(">");
    // printf("ret\n");
    fprintf(npctraceFtraceFp,"0x%8x:",pc);
    ftraceCount--;
    for(int i=0;i<ftraceCount&&ftraceCount>=0&&i<10;i++){
      fprintf(npctraceFtraceFp,"\t");
    }
    fprintf(npctraceFtraceFp,"ret [%s]\n",getFuncName(pc));
  }else if(strcmp(mnemonic,"call")==0&&(incode&0xF80==0x80)){printf(">");
    // printf("call\n");
    fprintf(npctraceFtraceFp,"0x%8x:",pc);
    for(int i=0;i<ftraceCount&&ftraceCount>=0&&i<10;i++){
      fprintf(npctraceFtraceFp,"\t");
    }
    fprintf(npctraceFtraceFp,"call[%s@0x%8x]\n",getFuncName(dnpc),dnpc);
    ftraceCount++;
  }
}
void NpcTraceWrite(uint32_t pc,uint32_t incode,uint32_t dnpc){
	char mnemonic[32]={0};
	char op[160]={0};
	if(NpcTraceCapstone(incode,mnemonic,op)!=true){
			printf("err:capstone\n");
			exit(-1);
	}
	NpcTraceIrings(pc,incode,mnemonic,op);
	NpcTraceFtrace(pc,incode,mnemonic,dnpc);
}