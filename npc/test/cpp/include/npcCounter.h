#ifndef _NPC_COUNT_
#define _NPC_COUNT_
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include "npcDevice.h"

////////////////////////////////////////////////////////////////////////////////////////
inline uint64_t numCycle		=0;
inline uint64_t numInst			=0;
inline uint64_t numIchHit		=0;
inline uint64_t numIchMiss		=0;
inline uint64_t numIfuInst		=0;
inline uint64_t numIfuStall 	=0;
inline uint64_t numIfuJbHit		=0;
inline uint64_t numIfuJbMiss	=0;
inline uint64_t numIduCal		=0;
inline uint64_t numIduJump		=0;
inline uint64_t numIduImm		=0;
inline uint64_t numIduLs		=0;
inline uint64_t numIduCsr		=0;
inline uint64_t numIduBr		=0;
inline uint64_t numIduMiss		=0;
inline uint64_t numLsuLoad		=0;
inline uint64_t numLsuLoadWait	=0;
inline uint64_t numLsuStore		=0;
inline uint64_t numLsuStoreWait	=0;

extern "C" void ichHit()		{numIchHit++;		}
extern "C" void ichMiss()		{numIchMiss++;		}
extern "C" void ifuInst()		{numIfuInst++;		}
extern "C" void ifuStall()		{numIfuStall++;		}
extern "C" void ifuJbHit()		{numIfuJbHit++;		}
extern "C" void ifuJbMiss()		{numIfuJbMiss++;	}
extern "C" void iduCal()		{numIduCal++;		}
extern "C" void iduJump()		{numIduJump++;		}
extern "C" void iduImm()		{numIduImm++;		}
extern "C" void iduLs()			{numIduLs++;		}
extern "C" void iduCsr()		{numIduCsr++;		}
extern "C" void iduBr()			{numIduBr++;		}
extern "C" void iduMiss()		{numIduMiss++;		}
extern "C" void lsuLoad()		{numLsuLoad++;		}
extern "C" void lsuLoadWait()	{numLsuLoadWait++;	}
extern "C" void lsuStore()		{numLsuStore++;		}
extern "C" void lsuStoreWait()	{numLsuStoreWait++;	}

inline void printCounter(){
	printf("cycle= %ld inst= %ld IPC= %f CPI= %f\n",numCycle,numInst,((float)numInst)/((float)numCycle),((float)numCycle)/((float)numInst));//实质上是已经是next pc了
	numIchHit=numIfuInst-numIchMiss;
	printf("ich hit= %ld[%f] miss= %ld[%f] sum= %ld\n",
		numIchHit ,numIchHit /(float)numIfuInst,
		numIchMiss,numIchMiss/(float)numIfuInst,
		numIchHit+numIchMiss);
	printf("ifu inst = %ld[+ %ld %f] wait= %ld AMAT= %f\n",
		numIfuInst,numIfuInst-numInst,(numIfuInst-numInst)/(float)numInst,
		numIfuStall,(float)((float)numIfuStall)/((float)numIfuInst)
	);
	uint64_t  missHit = numIfuJbHit;
	numIfuJbHit=numIduJump+numIduBr-numIfuJbMiss;
	printf("ifu jbHit= %ld[%f] jbMiss= %ld[%f]{bpMiss= %ld[%f]} bpHit= %ld[%f]\n",
		numIfuJbHit ,numIfuJbHit /(float)(numIfuJbHit+numIfuJbMiss),
		numIfuJbMiss,numIfuJbMiss/(float)(numIfuJbHit+numIfuJbMiss),
		missHit,missHit/(float)numIfuJbMiss,
		numIfuJbMiss-missHit+numIfuJbHit,(numIfuJbMiss-missHit+numIfuJbHit)/(float)(numIduJump+numIduBr)
	);
	printf("idu cal= %ld jump= %ld imm= %ld ls= %ld csr= %ld br= %ld sum= %ld miss= %ld\n",
		numIduCal,numIduJump,numIduImm,numIduLs,numIduCsr,numIduBr,
		numIduCal+numIduJump+numIduImm+numIduLs+numIduCsr+numIduBr,
		numIduMiss
	);
	printf("lsu load= %ld loadWait= %ld WpL= %f\n",numLsuLoad,numLsuLoadWait,(float)((float)numLsuLoadWait)/((float)numLsuLoad));
	printf("lsu store= %ld storeWait= %ld WpS= %f\n",numLsuStore,numLsuStoreWait,(float)((float)numLsuStoreWait)/((float)numLsuStore));
	}
#endif