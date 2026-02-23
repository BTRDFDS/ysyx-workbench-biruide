AM_SRCS := riscv/npc/start.S \
           riscv/npc/trm.c \
           riscv/npc/ioe.c \
           riscv/npc/timer.c \
           riscv/npc/input.c \
           riscv/npc/cte.c \
           riscv/npc/trap.S \
           platform/dummy/vme.c \
           platform/dummy/mpe.c

CFLAGS    += -fdata-sections -ffunction-sections
LDSCRIPTS += $(AM_HOME)/scripts/linker.ld
LDFLAGS   += --defsym=_pmem_start=0x80000000 --defsym=_entry_offset=0x0
LDFLAGS   += --gc-sections -e _start

MAINARGS_MAX_LEN = 64
MAINARGS_PLACEHOLDER = the_insert-arg_rule_in_Makefile_will_insert_mainargs_here
CFLAGS += -DMAINARGS_MAX_LEN=$(MAINARGS_MAX_LEN) -DMAINARGS_PLACEHOLDER=$(MAINARGS_PLACEHOLDER)

insert-arg: image
	@python $(AM_HOME)/tools/insert-arg.py $(IMAGE).bin $(MAINARGS_MAX_LEN) $(MAINARGS_PLACEHOLDER) "$(mainargs)"

image: image-dep
	@$(OBJDUMP) -d $(IMAGE).elf > $(IMAGE).txt
	@echo + OBJCOPY "->" $(IMAGE_REL).bin
	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary $(IMAGE).elf $(IMAGE).bin

run: insert-arg
	make -C $(NPC_HOME) run t=$(TARGET) ARG=$(IMAGE).bin xEb=$(XEB)
gdb: insert-arg
	make -C $(NPC_HOME) gdb t=$(TARGET) ARG=$(IMAGE).bin xEb=$(XEB)
val: insert-arg
	make -C $(NPC_HOME) val t=$(TARGET) ARG=$(IMAGE).bin xEb=$(XEB)

# ifeq ($(TEST_AM),1)
# 	make -C $(NPC_HOME) run t=ysyx_26020046_minirv ARG=$(IMAGE).bin xEb=$(XEB) 
# else
# 	make -C $(NPC_HOME) run t=ysyx_26020046_minirv ARG=$(IMAGE).bin xEb=$(XEB) ePrintf=-DDEBUG
# endif
.PHONY: insert-arg
