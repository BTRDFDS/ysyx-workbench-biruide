test:
	@mill -i test
verilog:verilogNpc verilogYsyxSoc verilogSta verilogStaPart
	$(call git_commit, "generate verilog")
# 	@mkdir -p ./build
# 	@mill -i runMain Builder
# verilogNpc:
# 	$(call git_commit, "generate verilog for Npc")
# 	@mkdir -p ./build
# 	@mkdir -p ./build/npc
# 	@mill -i runMain BuilderNpc
# verilogYsyxSoc:
# 	$(call git_commit, "generate verilog for YsyxSoc")
# 	@mkdir -p ./build
# 	@mkdir -p ./build/ysyxsoc
# 	@mill -i runMain BuilderYsyxSoc
# verilogSta:
# 	$(call git_commit, "generate verilog for sta")
# 	@mkdir -p ./build
# 	@mkdir -p ./build/sta
# 	@mill -i runMain BuilderSta
# verilogIcache:
# 	$(call git_commit, "generate verilog for icache")
# 	@mkdir -p ./build
# 	@mkdir -p ./build/icache
# 	@mill -i runMain BuilderIcache
# help:
# 	@mill -i runMain Builder --help

srcScala = $(shell find $(NPC_HOME)/src -type f -name "*.scala")
build/%.stamp:$(srcScala)
	@mill -i runMain $*
	$(call git_commit, "generate verilog for $*")
	touch $@
verilogNpc:build/BuilderNpc.stamp
verilogYsyxSoc:build/BuilderYsyxSoc.stamp
verilogSta:build/BuilderSta.stamp
verilogIcache:build/BuilderIcache.stamp




reformat:
	@mill -i __.reformat

checkformat:
	@mill -i __.checkFormat

bsp:
	@mill -i @mill.bsp.BSP/install

idea:
	@mill -i @mill.idea.GenIdea/idea

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
CXXFLAGS += -I/$(NVBOARD_HOME)/usr/include

wave:
	@mkdir -p wave

srcNpc =ysyx_26020046_Npc
srcVerilogNpc = $(shell find $(NPC_HOME)/build/npc -type f -name "*.sv")
srcCppNpc = $(NPC_HOME)/test/cpp/$(srcNpc).cpp

runNpc:verilogNpc $(srcCpp) $(srcCppNpc) wave
# runNpc:$(srcCpp) $(srcCppNpc) wave
	@verilator $(VERILATOR_CFLAGS) $(srcVerilogNpc) \
	 --exe $(srcCpp) $(srcCppNpc) --Mdir build/$(srcNpc) --build $(NVBOARD_ARCHIVE) \
	--top-module $(srcNpc) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	time ./build/$(srcNpc)/V$(srcNpc) $(ARG)
	make sim

srcYsyxSoc = ysyxSoCFull
srcVerilogYsyxSoc += $(shell find $(NPC_HOME)/build/ysyxsoc -type f -name "*.sv")
srcVerilogYsyxSoc += $(shell find $(YSYX_SOC_HOME)/perip -type f -name "*.v")
srcVerilogYsyxSoc += $(YSYX_SOC_HOME)/build/ysyxSoCFull.v
srcCppYsyxSoc = $(NPC_HOME)/test/cpp/ysyxSoCFull.cpp

YsyxSoc_VLT = $(NPC_HOME)/wave/ysyxsocTrace.vlt

SOC_CFLAGS += -I$(YSYX_SOC_HOME)/perip/uart16550/rtl
SOC_CFLAGS += -I$(YSYX_SOC_HOME)/perip/spi/rtl
SOC_CFLAGS += --timescale "1ns/1ns"
SOC_CFLAGS += --no-timing

runYsyxSoc:verilogYsyxSoc $(srcCpp) $(srcCppYsyxSoc) wave
# runYsyxSoc:$(srcCpp) $(srcCppYsyxSoc) wave
	@verilator $(VERILATOR_CFLAGS) $(YsyxSoc_VLT) $(srcVerilogYsyxSoc) \
	--exe $(srcCpp) $(srcCppYsyxSoc) --Mdir build/$(srcYsyxSoc) --build $(NVBOARD_ARCHIVE) \
	--top-module $(srcYsyxSoc) $(SOC_CFLAGS) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
# 	 -Wno-UNOPTFLAT
# 	./build/$(srcYsyxSoc)/V$(srcYsyxSoc) $(ARG)
	time ./build/$(srcYsyxSoc)/V$(srcYsyxSoc) $(ARG)
	make sim

YOSYS_CONFIG = CLK_PORT_NAME=clock CLK_FREQ_MHZ=500 PDK=nangate45

srcVerilogSta += $(shell find $(NPC_HOME)/build/sta -type f -name "*.sv")
sta:verilogSta $(srcVerilogSta)
# sta: $(srcVerilogSta)
	time make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046 RTL_FILES="$(srcVerilogSta)" $(YOSYS_CONFIG)
# 	cp -r $(YOSYS_STA_HOME)/result/ysyx_26020046-500MHz ./result

srcVerilogStaWbu += $(NPC_HOME)/build/sta/ysyx_26020046_Wbu.sv
srcVerilogStaIdu += $(NPC_HOME)/build/sta/ysyx_26020046_Idu.sv
srcVerilogStaExu += $(NPC_HOME)/build/sta/ysyx_26020046_Exu.sv
srcVerilogStaIdu += $(NPC_HOME)/test/sta/ysyx_26020046_StaIdu.sv
srcVerilogStaExu += $(NPC_HOME)/test/sta/ysyx_26020046_StaExu.sv
staExu: $(srcVerilogStaExu)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_StaExu RTL_FILES="$(srcVerilogStaExu)" $(YOSYS_CONFIG)
staIdu: $(srcVerilogStaIdu)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_StaIdu RTL_FILES="$(srcVerilogStaIdu)" $(YOSYS_CONFIG)
staWbu: $(srcVerilogStaWbu)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_Wbu RTL_FILES="$(srcVerilogStaWbu)" $(YOSYS_CONFIG)
# staPart: verilogSta staWbu staIdu staExu
staPart: staWbu staIdu staExu

srcIcache = ysyx_26020046_Ich
srcCppIcache += $(NPC_HOME)/test/cpp/ysyx_26020046_Ich.cpp
srcVerilogIcache += $(shell find $(NPC_HOME)/build/icache -type f -name "*.sv")
# BuilderIcache
runIcache:verilogIcache $(srcCppIcache)
# runIcache: $(srcCppIcache)
	@verilator $(VERILATOR_CFLAGS) $(srcVerilogIcache) \
	--exe $(srcCpp) $(srcCppIcache) --Mdir build/$(srcIcache) --build \
	--top-module $(srcIcache) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
# 	 -Wno-UNOPTFLAT
# 	./build/$(srcIcache)/V$(srcIcache) $(ARG)
	time ./build/$(srcIcache)/V$(srcIcache) $(ARG)
	make sim

buildIcachesim:./test/cpp/icachesim/icachesim.cpp
	clang++ ./test/cpp/icachesim/icachesim.cpp -o ./test/cpp/icachesim/icachesim

icachesim:./test/cpp/icachesim/icachesim
	time ./test/cpp/icachesim/icachesim