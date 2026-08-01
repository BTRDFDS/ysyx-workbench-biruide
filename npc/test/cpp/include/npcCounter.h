#ifndef _NPC_COUNTER_
#define _NPC_COUNTER_

uint64_t numCycle		=0;
uint64_t numInst		=0;
uint64_t numIfuInst		=0;
uint64_t numIfuStall 	=0;
uint64_t numIfuForward	=0;
uint64_t numIfuBackward	=0;
uint64_t numIfuJump		=0;
uint64_t numIduCal		=0;
uint64_t numIduJump		=0;
uint64_t numIduImm		=0;
uint64_t numIduLs		=0;
uint64_t numIduCsr		=0;
uint64_t numIduBr		=0;
uint64_t numExuDone		=0;
uint64_t numLsuLoad		=0;
uint64_t numLsuLoadWait	=0;
uint64_t numLsuStore	=0;
uint64_t numLsuStoreWait=0;

extern "C" void ifuInst()		{numIfuInst++;		}
extern "C" void ifuStall()		{numIfuStall++;		}
extern "C" void ifuForward()	{numIfuForward++;	}
extern "C" void ifuBackward()	{numIfuBackward++;	}
extern "C" void ifuJump()		{numIfuJump++;		}
extern "C" void iduCal()		{numIduCal++;		}
extern "C" void iduJump()		{numIduJump++;		}
extern "C" void iduImm()		{numIduImm++;		}
extern "C" void iduLs()			{numIduLs++;		}
extern "C" void iduCsr()		{numIduCsr++;		}
extern "C" void iduBr()			{numIduBr++;		}
extern "C" void exuDone()		{numExuDone++;		}
extern "C" void lsuLoad()		{numLsuLoad++;		}
extern "C" void lsuLoadWait()	{numLsuLoadWait++;	}
extern "C" void lsuStore()		{numLsuStore++;		}
extern "C" void lsuStoreWait()	{numLsuStoreWait++;	}

void printCounter(){
	printf("cycle=%ld inst=%ld IPC=%f\n",numCycle,numInst,(float)(((float)numInst)/((float)numCycle)));//实质上是已经是next pc了
	printf("ifu inst = %ld wait= %ld WpI= %f jump= %ld for= %ld back= %ld fpj= %f bpj= %f\n",
		numIfuInst,numIfuStall,(float)((float)numIfuStall)/((float)numIfuInst),
		numIfuJump,numIfuForward,numIfuBackward,
		(float)((float)numIfuForward)/(float)(numIfuJump),
		(float)((float)numIfuBackward)/(float)(numIfuJump)
	);
	printf("idu cal= %ld jump= %ld imm= %ld ls= %ld csr= %ld br= %ld sum= %ld\n",
		numIduCal,numIduJump,numIduImm,numIduLs,numIduCsr,numIduBr,
		numIduCal+numIduJump+numIduImm+numIduLs+numIduCsr+numIduBr
	);
	printf("exu done= %ld\n",numExuDone);
	printf("lsu load= %ld loadWait= %ld WpL= %f\n",numLsuLoad,numLsuLoadWait,(float)((float)numLsuLoadWait)/((float)numLsuLoad));
	printf("lsu store= %ld storeWait= %ld WpS= %f\n",numLsuStore,numLsuStoreWait,(float)((float)numLsuStoreWait)/((float)numLsuStore));
}
#endif