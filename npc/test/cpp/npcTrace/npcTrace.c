#include <npcTrace.h>


csh handle;

FILE *npctraceIringsFp=NULL;
FILE *npctraceFtraceFp=NULL;
FILE *npctraceEtraceFp=NULL;
FILE *npctraceDtraceFp=NULL;

const char *npctraceIringsFile={"log/irings.log"};
const char *npctraceFtraceFile={"log/ftrace.log"};
const char *npctraceEtraceFile={"log/etrace.log"};
const char *npctraceDtraceFile={"log/dtrace.log"};

void NpcTraceInitFile(){
#ifdef NPC_I_TRACE
	npctraceIringsFp = fopen(npctraceIringsFile, "w");
	if(npctraceIringsFp == NULL){printf("err:open %s",npctraceIringsFile);exit(-1);}
	printf("\033[1;34m ITRACE\t\033[0m");
#endif
#ifdef NPC_F_TRACE
	npctraceFtraceFp = fopen(npctraceFtraceFile, "w");
	if(npctraceFtraceFp == NULL){printf("err:open %s",npctraceFtraceFile);exit(-1);}
	printf("\033[1;34m FTRACE\t\033[0m");
#endif
#ifdef NPC_E_TRACE
	npctraceEtraceFp = fopen(npctraceEtraceFile, "w");
	if(npctraceEtraceFp == NULL){printf("err:open %s",npctraceEtraceFile);exit(-1);}
	printf("\033[1;34m ETRACE\t\033[0m");
#endif
#ifdef NPC_D_TRACE
	npctraceDtraceFp = fopen(npctraceDtraceFile, "w");
	if(npctraceDtraceFp == NULL){printf("err:open %s",npctraceDtraceFile);exit(-1);}
	printf("\033[1;34m DTRACE\t\033[0m");
#endif
}

void NpcTraceCloseFile(){
	if(npctraceIringsFp != NULL){
		printf("irings:%s\n",npctraceIringsFile);
		fclose(npctraceIringsFp);
	}
	if(npctraceFtraceFp != NULL){
		printf("ftrace:%s\n",npctraceFtraceFile);
		fclose(npctraceFtraceFp);
	}
	if(npctraceEtraceFp != NULL){
		printf("ftrace:%s\n",npctraceEtraceFile);
		fclose(npctraceEtraceFp);
	}
	if(npctraceDtraceFp != NULL){
		printf("ftrace:%s\n",npctraceDtraceFile);
		fclose(npctraceDtraceFp);
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
		sprintf(npctraceIrings[iringbufCount%npcTraceIringMax],"%8x:%s\t%s",pc,mnemonic,op);
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
void NpcTraceDtrace(const char *format, ...){
#ifdef NPC_D_TRACE
	if(npctraceDtraceFp!=NULL){
		va_list args;
		va_start(args, format);
		if(vfprintf(npctraceDtraceFp,format,args)<0){printf("dtrace write err\n");exit(-1);}
		else{fflush(npctraceDtraceFp);}
		va_end(args);
	}
#endif
}

void NpcTraceFtrace(uint32_t pc,uint32_t incode,uint32_t dnpc){
	#define FTRACE_COUNT_MAX 10
	#define FTRACE_COUNT_ULM true
	// printf("pc=%x incode=%x dnpc=%x incode&0x7FU=%x incode&0xF80U=%x ret=%x call1=%x call2=%x call=%x\n",pc,incode,dnpc,incode&0x7FU,incode&0xF80U,incode==0x00008067,((incode&0x7FU)==0x67U),((incode&0xF80U)==0x80U),((incode&0x7F)==0x67)&&((incode&0xF80)==0x80));
	static uint32_t ftraceCount=0;
	if(incode==0x00008067){
		// printf("ret");
		fprintf(npctraceFtraceFp,"0x%8x: ",pc);
		for(int i=1;(i<ftraceCount)&&(ftraceCount>=0)&&((i<FTRACE_COUNT_MAX)||FTRACE_COUNT_ULM);i++){
			fprintf(npctraceFtraceFp,"\t");
		}
		ftraceCount--;
		fprintf(npctraceFtraceFp,"ret [%s]\n",getFuncName(pc));
		fflush(npctraceFtraceFp);
		// printf(">\n");
	}else if((((incode&0x7F)==0x67)||((incode&0x7F)==0x6F))&&((incode&0xF80)==0x80)){
		// printf("call");
		fprintf(npctraceFtraceFp,"0x%8x: ",pc);
		for(int i=0;(i<ftraceCount)&&(ftraceCount>=0)&&((i<FTRACE_COUNT_MAX)||FTRACE_COUNT_ULM);i++){
			fprintf(npctraceFtraceFp,"\t");
		}
		ftraceCount++;
		fprintf(npctraceFtraceFp,"call[%s@0x%8x]\n",getFuncName(dnpc),dnpc);
		fflush(npctraceFtraceFp);
		// printf(">\n");
	}
}
void NpcTraceEtrace(uint32_t pc,uint32_t incode,uint32_t dnpc){
	#define ETRACE_COUNT_MAX 10
	#define ETRACE_COUNT_ULM true
	// printf("pc=%x incode=%x dnpc=%x incode&0x7FU=%x incode&0xF80U=%x ret=%x call1=%x call2=%x call=%x\n",pc,incode,dnpc,incode&0x7FU,incode&0xF80U,incode==0x00008067,((incode&0x7FU)==0x67U),((incode&0xF80U)==0x80U),((incode&0x7F)==0x67)&&((incode&0xF80)==0x80));
	static uint32_t EtraceCount=0;
	if(incode==0x30200073){
		// printf("ret");
		fprintf(npctraceEtraceFp,"0x%8x: ",pc);
		for(int i=1;(i<EtraceCount)&&(EtraceCount>=0)&&((i<ETRACE_COUNT_MAX)||ETRACE_COUNT_ULM);i++){
			fprintf(npctraceEtraceFp,"\t");
		}
		EtraceCount--;
		fprintf(npctraceEtraceFp,"mret [%sto%x]\n",getFuncName(dnpc),dnpc);
		fflush(npctraceEtraceFp);
		// printf(">\n");
	}else if(incode==0x00000073){
		// printf("call");
		fprintf(npctraceEtraceFp,"0x%8x: ",pc);
		for(int i=0;(i<EtraceCount)&&(EtraceCount>=0)&&((i<ETRACE_COUNT_MAX)||ETRACE_COUNT_ULM);i++){
			fprintf(npctraceEtraceFp,"\t");
		}
		EtraceCount++;
		fprintf(npctraceEtraceFp,"ecall[%s@0x%8x]\n",getFuncName(pc),dnpc);
		fflush(npctraceEtraceFp);
		// printf(">\n");
	}
}
void NpcTraceWrite(uint32_t pc,uint32_t incode,uint32_t dnpc){
#ifdef NPC_I_TRACE
	char mnemonic[32]={0};
	char op[160]={0};
	if(NpcTraceCapstone(incode,mnemonic,op)!=true){
			printf("err:capstone\n");
			exit(-1);
	}
	NpcTraceIrings(pc,incode,mnemonic,op);
#endif

#ifdef NPC_F_TRACE
	NpcTraceFtrace(pc,incode,dnpc);
#endif
#ifdef NPC_E_TRACE
	NpcTraceEtrace(pc,incode,dnpc);
#endif
}