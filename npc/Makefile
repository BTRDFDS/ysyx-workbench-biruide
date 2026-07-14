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
VERILATOR_VLT = 

srcVerilogNpc = $(NPC_HOME)/src/ysyx_26020046_MemTop.scala
srcVerilog = $(shell find $(NPC_HOME)/build -type f -name "*.sv" -not -name "ysyx_26020046_MemTop.sv")

srcCppNpc += $(NPC_HOME)/test/cpp/ysyx_26020046_MemTop.cpp
srcCpp += $(NPC_HOME)/test/cpp/npcDifftest/npcDifftest.c

LDFLAGS += -lreadline
LDFLAGS += -L$(NPC_HOME)/test/cpp/lib
LDFLAGS += -lcapstone
LDFLAGS += -ldl

CXXFLAGS += -I/$(NEMU_HOME)/include
wave:
	mkdir -p wave

# runNpc:verilog $(srcVerilog) $(srcCpp) $(srcCppNpc) wave
runNpc:$(srcVerilog) $(srcCpp) $(srcCppNpc) wave
	verilator $(VERILATOR_CFLAGS) $(VERILATOR_VLT) $(srcVerilog) $(srcVerilogNpc) \
	 --exe $(srcCpp) $(srcCppNpc) --Mdir build/ysyx_26020046_MemTop --build $(NVBOARD_ARCHIVE) \
	--top-module ysyx_26020046_MemTop \
	$(SOC_CFLAGS) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	./build/ysyx_26020046_MemTop/Vysyx_26020046_MemTop $(ARG)
	make sim
	

