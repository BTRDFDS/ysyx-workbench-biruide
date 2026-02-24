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

void NpcTraceInit(){
	NpcTraceInitFile();
	NpcTraceInitCapstone();
}

void NpcTraceClose(){
	NpcTraceCloseCapstone();
	NpcTraceCloseFile();
}