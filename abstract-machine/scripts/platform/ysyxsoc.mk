AM_SRCS := riscv/npc/start.S \
           riscv/ysyxSoC/trm.c \
           riscv/ysyxSoC/ioe.c \
           riscv/npc/timer.c \
           riscv/ysyxSoC/uart.c \
           riscv/ysyxSoC/input.c

CFLAGS    += -fdata-sections -ffunction-sections
LDSCRIPTS += $(AM_HOME)/scripts/linkerYsyxSoC.ld
# LDFLAGS   += --defsym=_pmem_start=0x20000000 --defsym=_entry_offset=0x0
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
#.boot  .load  .data
# 	@$(OBJCOPY) -S --set-section-flags .bss=alloc,contents -O binary \
# 	--only-section=.boot \
# 	--only-section=.load \
# 	--only-section=.data \
# 	$(IMAGE).elf $(IMAGE).bin 

run: insert-arg
	make -C $(NPC_HOME) runYsyxSoc t=$(TARGET) ARG=$(IMAGE).bin

.PHONY: insert-arg
