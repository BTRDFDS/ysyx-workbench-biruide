#ifndef _NPC_MEM_
#define _NPC_MEM_
#include <cstdint>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fstream>
#include <stdint.h>
#include "npcDrive.h"
#include "npcTrace.h"
////////////////////////////////////////////////////////////////////////////////////////
const uint32_t psramAddr	=0x80000000;
// const uint32_t psramSize	=0x00ffffff;//psram极限地址是bfff_ffff
const uint32_t psramSize	=0x07ffffff;//为了NPC开大一点
inline uint8_t psram[psramSize];

const uint32_t sdramAddr	=0xa0000000;
const uint32_t sdramSize	=0x07ffffff;//2+12+10+2
inline uint8_t sdram[sdramSize];

const uint32_t mromAddr		=0x20000000;//mrom起始地址
const uint32_t mromSize		=0xfff;
inline uint8_t mrom[mromSize];


const uint32_t flashAddr	=0x30000000;
const uint32_t flashSize	=0x00ffffff;//flash极限地址是bfff_ffff
inline uint8_t flash[flashSize];
////////////////////////////////////////////////////////////////////////////////////////
extern void NpcFinish(const char* msg,int code);
extern "C" void flash_read(int32_t addr, int32_t *data) {
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	#ifdef NPC_M_TRACE
	logFile<<"flash	R "<<std::hex<<addr<<" at 0x "<<std::hex<<regs[0]<<" T="<<std::dec<<numCycle;
	#endif
	// if(addrX-flashAddr>=flashSize|addrX<flashAddr){return NpcFinish("flash read error",addrX);}
	if(addrX>=flashSize)return NpcFinish("flash read error",addrX);
	uint32_t temp=
		((uint32_t)flash[addrX+0]<< 0)|
		((uint32_t)flash[addrX+1]<< 8)|
		((uint32_t)flash[addrX+2]<<16)|
		((uint32_t)flash[addrX+3]<<24);
	*data=temp;
	#ifdef NPC_M_TRACE
		logFile<<" => "<<std::hex<<temp<<std::endl;
	#endif
	}
extern "C" void mrom_read(int32_t addr, int32_t *data) {
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	if(addrX-mromAddr>=mromSize|addrX<mromAddr){return NpcFinish("mrom read",-2);}
	uint32_t temp=
		((uint32_t)mrom[addrX-mromAddr+0]<< 0)|
		((uint32_t)mrom[addrX-mromAddr+1]<< 8)|
		((uint32_t)mrom[addrX-mromAddr+2]<<16)|
		((uint32_t)mrom[addrX-mromAddr+3]<<24);
	*data=temp;
	#ifdef NPC_M_TRACE
	logFile<<"mrom	R "<<std::hex<<addrX<<" at 0x "<<std::hex<<regs[0]<<" T="<<std::dec<<numCycle<<" => "<<std::hex<<temp<<std::endl;
	#endif
	}
extern "C" int psram_read(int32_t addr){
	uint32_t addrX=((uint32_t)addr)&0xfffffffc;
	#if defined(NPC_M_TRACE)
		logFile<<"psram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<regs[0]<<" T="<<std::dec<<numCycle;
	#endif
	if(addrX>=psramSize){NpcFinish("psram read error",addrX);return 0;}
	uint32_t temp=
		((uint32_t)psram[addrX+0]<< 0)|
		((uint32_t)psram[addrX+1]<< 8)|
		((uint32_t)psram[addrX+2]<<16)|
		((uint32_t)psram[addrX+3]<<24);
	#ifdef NPC_M_TRACE
		logFile<<" => "<<std::hex<<temp<<std::endl;
	#endif
	return temp;
	}
extern "C" void psram_write(int addr,int data){
	uint32_t addrX=(uint32_t)addr;
	#if defined(NPC_M_TRACE)
		logFile<<"Psram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<regs[0]<<" T="<<std::dec<<numCycle<<" "<<std::hex<<data<<" => ";
	#elif defined(NPC_MIN_TRACE)
		// if((addr&0x00fffff0) == (0xa00164b4&0x00fffff0))logFile<<"Psram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<regs[0]<<" T="<<std::dec<<numCycle<<" "<<std::hex<<data<<" => ";
	#endif
	psram[addrX+0]=(uint8_t)(data&0xff);
	#if defined(NPC_M_TRACE)
		logFile<<std::hex<<(uint32_t)psram[addrX+0]<<std::endl;
	#endif
	}
extern "C" int sdram_read(int32_t addr){
	uint32_t addrX=((uint32_t)addr);
	#if defined(NPC_M_TRACE)
		logFile<<"sdram	R "<<std::hex<<addr<<" at 0x "<<std::hex<<regs[0]<<" T="<<std::dec<<numCycle;
	#endif
	if(addrX>=sdramSize){NpcFinish("sdram read error",addrX);return 0;}
	uint32_t temp=
		((uint32_t)sdram[addrX+0]<< 0)|
		((uint32_t)sdram[addrX+1]<< 8)|
		((uint32_t)sdram[addrX+2]<<16)|
		((uint32_t)sdram[addrX+3]<<24);
	#ifdef NPC_M_TRACE
		logFile<<" => "<<std::hex<<temp<<std::endl;
	#endif
	return temp;
	}
extern "C" void sdram_write(int addr,int data){
	uint32_t addrX=(uint32_t)addr;
	#if defined(NPC_M_TRACE)
		logFile<<"sdram	W "<<std::hex<<addrX<<" at 0x "<<std::hex<<regs[0]<<" T="<<std::dec<<numCycle<<" "<<std::hex<<data<<" => ";
	#endif
	sdram[addrX+0]=(uint8_t)(data&0xff);
	#if defined(NPC_M_TRACE)
		logFile<<std::hex<<(uint32_t)sdram[addrX+0]<<std::endl;
	#endif
	}
uint32_t NpcLw(uint8_t* mem,uint32_t addr){
	return (
		(uint32_t)mem[addr+0]<< 0|
		(uint32_t)mem[addr+1]<< 8|
		(uint32_t)mem[addr+2]<<16|
		(uint32_t)mem[addr+3]<<24
	);
}
uint32_t NpcsdbReadMem(uint32_t addr){
	if(addr>=flashAddr	&addr<flashAddr+flashSize)	return NpcLw(flash	,addr-flashAddr	);
	if(addr>=mromAddr	&addr<mromAddr+mromSize)	return NpcLw(mrom	,addr-mromAddr	);
	if(addr>=psramAddr	&addr<psramAddr+psramSize)	return NpcLw(psram	,addr-psramAddr	);
	if(addr>=sdramAddr	&addr<sdramAddr+sdramSize)	return NpcLw(sdram	,addr-sdramAddr	);
	printf("error:sdb read %08x\n",addr);return 0;
}
#endif