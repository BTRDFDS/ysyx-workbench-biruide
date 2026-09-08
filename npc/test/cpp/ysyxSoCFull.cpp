//flash
//ysyxSoCFull
#include "VysyxSoCFull.h"
#include "verilated.h"
#include "svdpi.h"
#include "VysyxSoCFull__Dpi.h"
#include <npcDevice.h>

#ifdef NPC_NVBroad
#include <nvboard.h>
#endif

VerilatedContext* contextp;//verilator上下文
VysyxSoCFull* top;//顶层模块
////////////////////////////////////////////////////////////////////////////////////////
void NpcInitDeviceMem(int argc, char** argv){
	contextp = new VerilatedContext;
	contextp->commandArgs(argc, argv);
	top = new VysyxSoCFull{contextp};
	#if defined(NPC_WAVE)
		Verilated::traceEverOn(true);
		tfp = new VerilatedFstC;
		top->trace(tfp, 99);
		tfp->open("./wave/ysyxSoCFull.fst");
	#endif
	logFileInit("./log/ysyxSoCFull.log");
	TraceInit();
	#ifdef NPC_NVBroad
		nvboard_bind_pin(&top->externalPins_uart_rx  ,1,UART_RX);
		nvboard_bind_pin(&top->externalPins_uart_tx  ,1,UART_TX);
		nvboard_bind_pin(&top->externalPins_ps2_clk	 ,1,PS2_CLK);
		nvboard_bind_pin(&top->externalPins_ps2_data ,1,PS2_DAT);
		nvboard_bind_pin(&top->externalPins_gpio_in  ,16,SW15,SW14,SW13,SW12,SW11,SW10,SW9,SW8,SW7,SW6,SW5,SW4,SW3,SW2,SW1,SW0);
		nvboard_bind_pin(&top->externalPins_gpio_out ,16,LD15,LD14,LD13,LD12,LD11,LD10,LD9,LD8,LD7,LD6,LD5,LD4,LD3,LD2,LD1,LD0);
		nvboard_bind_pin(&top->externalPins_gpio_seg_0,8,SEG0A,SEG0B,SEG0C,SEG0D,SEG0E,SEG0F,SEG0G,DEC0P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_1,8,SEG1A,SEG1B,SEG1C,SEG1D,SEG1E,SEG1F,SEG1G,DEC1P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_2,8,SEG2A,SEG2B,SEG2C,SEG2D,SEG2E,SEG2F,SEG2G,DEC2P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_3,8,SEG3A,SEG3B,SEG3C,SEG3D,SEG3E,SEG3F,SEG3G,DEC3P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_4,8,SEG4A,SEG4B,SEG4C,SEG4D,SEG4E,SEG4F,SEG4G,DEC4P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_5,8,SEG5A,SEG5B,SEG5C,SEG5D,SEG5E,SEG5F,SEG5G,DEC5P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_6,8,SEG6A,SEG6B,SEG6C,SEG6D,SEG6E,SEG6F,SEG6G,DEC6P);
		nvboard_bind_pin(&top->externalPins_gpio_seg_7,8,SEG7A,SEG7B,SEG7C,SEG7D,SEG7E,SEG7F,SEG7G,DEC7P);
		
		nvboard_bind_pin(&top->externalPins_vga_r,8,VGA_R7,VGA_R6,VGA_R5,VGA_R4,VGA_R3,VGA_R2,VGA_R1,VGA_R0);
		nvboard_bind_pin(&top->externalPins_vga_g,8,VGA_G7,VGA_G6,VGA_G5,VGA_G4,VGA_G3,VGA_G2,VGA_G1,VGA_G0);
		nvboard_bind_pin(&top->externalPins_vga_b,8,VGA_B7,VGA_B6,VGA_B5,VGA_B4,VGA_B3,VGA_B2,VGA_B1,VGA_B0);
		nvboard_bind_pin(&top->externalPins_vga_hsync,1,VGA_HSYNC);
		nvboard_bind_pin(&top->externalPins_vga_vsync,1,VGA_VSYNC);
		nvboard_bind_pin(&top->externalPins_vga_valid,1,VGA_BLANK_N);

		nvboard_init();
	#endif
	FILE *file;
	if(argc>1&&argv[1]!=NULL){
		printf("!!bin:%s\n",argv[1]);
		file = fopen(argv[1],"rb");
	}else{
		printf("!!shuould input bin\n");
		exit(-1);
	}
	if(file==NULL){printf("can't open file\n");exit(-1);}

	fseek(file, 0, SEEK_END);
	long fileSize = ftell(file);
	fseek(file, 0, SEEK_SET);
	size_t wordsRead = fread(flash, sizeof(uint8_t), fileSize/sizeof(uint8_t), file);
	if(wordsRead!=fileSize/sizeof(uint8_t)){printf("can't read file\n");}
	fclose(file);
	NpcDifftestInit8(flashSize,flash,flashAddr,"/home/biruide/ysyx-workbench/npc/test/cpp/lib/riscv32-nemu-interpreter-so-soc");
	}
void NpcWave(){
	#ifdef NPC_WAVE
		contextp->timeInc(1);
		tfp->dump(contextp->time());
	#endif
	}
////////////////////////////////////////////////////////////////////////////////////////
int main(int argc, char** argv) {
	NpcInitDeviceMem(argc, argv);
	{//初始化
		for(int i=0;i<12;i++){
			top->clock=0;top->reset=1;top->eval();
			top->clock=1;top->reset=1;top->eval();
		}
		top->clock=0;top->reset=0;top->eval();
		numCycle=0;
	}
	printf("\033[1;32m Welcome to ysyxSoCFull[\033[1;36m%s %s\033[1;32m] \033[0m\n",__DATE__,__TIME__);
	for(int i=0;(i<RunstopTime||RunstopTime==0)&&(!contextp->gotFinish()&(!stop));i++){
		#ifdef NPC_NVBroad
			nvboard_update();
		#endif
		NpcWave();
		top->clock=1;top->eval();
		NpcWave();
		top->clock=0;top->eval();
		numCycle++;
	}
	#ifdef NPC_NVBroad
		nvboard_quit();
	#endif
	// NpcWave();
	printOver();
	contextp->statsPrintSummary();
	delete top;
	delete contextp;
	return returnCode;
}