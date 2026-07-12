BUILD_DIR = ./build

test:
	mill -i test

verilog:
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
	@echo "Write this Makefile by yourself."
-include ../Makefile


include $(NVBOARD_HOME)/scripts/nvboard.mk
FLAGS=  --cc -MMD -O3 --x-assign fast --x-initial fast --noassert -Wpedantic -MMD
VERILATOR_CFLAGS += $(FLAGS)
VERILATOR_CFLAGS += --autoflush
VERILATOR_CFLAGS += --trace-fst --trace-structs --trace-params --no-trace-top
VERILATOR_VLT = 
srcVerilog = $(shell find $(NPC_HOME)/build -type f -name "*.sv")
srcCpp += $(NPC_HOME)/test/cpp/ysyx_26020046_MemTop.cpp
srcCpp += $(NPC_HOME)/test/cpp/npcDifftest/npcDifftest.c

LDFLAGS += -lreadline
LDFLAGS += -L$(NPC_HOME)/test/cpp/lib
LDFLAGS += -lcapstone
LDFLAGS += -ldl
wave:
	mkdir -p wave
run:verilog $(srcVerilog) $(srcCpp) wave
	verilator $(VERILATOR_CFLAGS) $(VERILATOR_VLT) $(sort $(srcVerilog)) --exe $(srcCpp) --Mdir build/ysyx_26020046_MemTop --build $(NVBOARD_ARCHIVE) \
	--top-module ysyx_26020046_MemTop \
	$(SOC_CFLAGS) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	./build/ysyx_26020046_MemTop/Vysyx_26020046_MemTop $(ARG)
	

