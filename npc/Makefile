test:
	mill -i test

verilog:verilogNpc verilogYsyxSoc
	$(call git_commit, "generate verilog")
# 	mkdir -p ./build
# 	mill -i runMain Builder
verilogNpc:
	$(call git_commit, "generate verilog for Npc")
	mkdir -p ./build
	mkdir -p ./build/npc
	mill -i runMain BuilderNpc
verilogYsyxSoc:
	$(call git_commit, "generate verilog for YsyxSoc")
	mkdir -p ./build
	mkdir -p ./build/ysyxsoc
	mill -i runMain BuilderYsyxSoc

help:
	mill -i runMain Builder --help

reformat:
	mill -i __.reformat

checkformat:
	mill -i __.checkFormat

bsp:
	mill -i mill.bsp.BSP/install

idea:
	mill -i mill.idea.GenIdea/idea

clean:
	-rm -rf ./build

.PHONY: test verilog help reformat checkformat clean run

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
# 	@echo "Write this Makefile by yourself."
-include ../Makefile


include $(NVBOARD_HOME)/scripts/nvboard.mk
FLAGS=  --cc -MMD -O3 --x-assign fast --x-initial fast --noassert -Wpedantic -MMD
VERILATOR_CFLAGS += $(FLAGS)
VERILATOR_CFLAGS += --autoflush
VERILATOR_CFLAGS += --trace-fst --trace-structs --trace-params --no-trace-top

srcCpp += $(NPC_HOME)/test/cpp/npcDifftest/npcDifftest.c

LDFLAGS += -lreadline
LDFLAGS += -L$(NPC_HOME)/test/cpp/lib
LDFLAGS += -lcapstone
LDFLAGS += -ldl

CXXFLAGS += -I/$(NEMU_HOME)/include
wave:
	mkdir -p wave

srcNpc =ysyx_26020046_MemTop
srcVerilogNpc = $(shell find $(NPC_HOME)/build/npc -type f -name "*.sv")
srcCppNpc = $(NPC_HOME)/test/cpp/$(srcNpc).cpp

# runNpc:verilogNpc $(srcCpp) $(srcCppNpc) wave
runNpc:$(srcCpp) $(srcCppNpc) wave
	verilator $(VERILATOR_CFLAGS) $(srcVerilogNpc) \
	 --exe $(srcCpp) $(srcCppNpc) --Mdir build/$(srcNpc) --build $(NVBOARD_ARCHIVE) \
	--top-module $(srcNpc) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	./build/$(srcNpc)/V$(srcNpc) $(ARG)
	make sim

srcYsyxSoc = ysyxSoCFull
srcVerilogYsyxSoc += $(shell find $(YSYX_SOC_HOME)/perip -type f -name "*.v")
srcVerilogYsyxSoc += $(YSYX_SOC_HOME)/build/ysyxSoCFull.v
srcCppYsyxSoc = $(NPC_HOME)/test/cpp/ysyxSoCFull.cpp

YsyxSoc_VLT = $(NPC_HOME)/wave/ysyxsocTrace.vlt

SOC_CFLAGS += -I$(YSYX_SOC_HOME)/perip/uart16550/rtl
SOC_CFLAGS += -I$(YSYX_SOC_HOME)/perip/spi/rtl
SOC_CFLAGS += --timescale "1ns/1ns"
SOC_CFLAGS += --no-timing

runYsyxSoc:verilog $(srcCpp) $(srcCppNpc) wave
# runYsyxSoc:$(srcCpp) $(srcCppNpc) wave
	verilator $(VERILATOR_CFLAGS) $(YsyxSoc_VLT) $(srcVerilogYsyxSoc) \
	--exe $(srcCpp) $(srcCppYsyxSoc) --Mdir build/$(srcYsyxSoc) --build $(NVBOARD_ARCHIVE) \
	--top-module $(srcYsyxSoc) $(SOC_CFLAGS) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	./build/$(srcYsyxSoc)/V$(srcYsyxSoc) $(ARG)
	make sim	 
