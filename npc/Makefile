BUILD_DIR = ./build

test:
	mill -i test

SRC_FILES = $(shell find $(NPC_HOME)/src -type f -name "*.scala")
verilog:$(SRC_FILES)
	$(call git_commit, "generate verilog")
	mkdir -p $(BUILD_DIR)
	mill -i runMain Builder --target-dir $(BUILD_DIR)

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
	-rm -rf $(BUILD_DIR)

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

srcVerilog = $(shell find $(NPC_HOME)/build -type f -name "*.sv" -not -name "ysyx_26020046_MemTop.sv")

srcCpp += $(NPC_HOME)/test/cpp/npcDifftest/npcDifftest.c

LDFLAGS += -lreadline
LDFLAGS += -L$(NPC_HOME)/test/cpp/lib
LDFLAGS += -lcapstone
LDFLAGS += -ldl

CXXFLAGS += -I/$(NEMU_HOME)/include
wave:
	mkdir -p wave

srcNpc =ysyx_26020046_MemTop
srcVerilogNpc = $(NPC_HOME)/build/$(srcNpc).sv
srcCppNpc = $(NPC_HOME)/test/cpp/$(srcNpc).cpp

# runNpc:verilog $(srcVerilog) $(srcCpp) $(srcCppNpc) wave
runNpc:$(srcVerilog) $(srcCpp) $(srcCppNpc) wave
	verilator $(VERILATOR_CFLAGS) $(srcVerilog) $(srcVerilogNpc) \
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

runYsyxSoc:verilog $(srcVerilog) $(srcCpp) $(srcCppNpc) wave
# runYsyxSoc:$(srcVerilog) $(srcCpp) $(srcCppNpc) wave
	verilator $(VERILATOR_CFLAGS) $(YsyxSoc_VLT) $(srcVerilog) $(srcVerilogYsyxSoc) \
	--exe $(srcCpp) $(srcCppYsyxSoc) --Mdir build/$(srcYsyxSoc) --build $(NVBOARD_ARCHIVE) \
	--top-module $(srcYsyxSoc) $(SOC_CFLAGS) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	./build/$(srcYsyxSoc)/V$(srcYsyxSoc) $(ARG)
	make sim	 
