test:
	@mill -i test
verilog:verilogSta
	cat $(shell find $(NPC_HOME)/build/sta -type f -name "*.sv") > $(NPC_HOME)/build/ysyx_26020046.sv
	$(call git_commit, "generate verilog")

srcScala = $(shell find $(NPC_HOME)/src -type f -name "*.scala")
build/%:$(srcScala)
	@mkdir -p wave
	@mkdir -p build
	./mill --version
	@mill -i runMain $(notdir $*)
	@touch $@
verilogNpc:build/npc/BuilderNpc
verilogYsyxSoc:build/ysyxsoc/BuilderYsyxSoc
verilogSta:build/sta/BuilderSta
verilogIcache:build/icache/BuilderIcache
verilogIverilog:build/iverilog/BuilderIverilog
verilogNetlist:build/netlist/BuilderNetlist


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
# VERILATOR_CFLAGS += --threads 2

# srcCpp += $(NPC_HOME)/test/cpp/npcDifftest/npcDifftest.c

LDFLAGS += -lreadline
LDFLAGS += -L$(NPC_HOME)/test/cpp/lib
LDFLAGS += -lcapstone
LDFLAGS += -ldl

CXXFLAGS += -I/$(NEMU_HOME)/include
CXXFLAGS += -I/$(NVBOARD_HOME)/usr/include

srcNpc =driveTop
srcVerilogNpc = $(shell find $(NPC_HOME)/build/npc -type f -name "*.sv")
srcCppNpc = $(NPC_HOME)/test/cpp/$(srcNpc).cpp

runNpc:verilogNpc $(srcCpp) $(srcCppNpc)
	@verilator --coverage $(VERILATOR_CFLAGS) $(srcVerilogNpc) \
	 --exe $(srcCpp) $(srcCppNpc) --Mdir build/$(srcNpc) --build $(NVBOARD_ARCHIVE) \
	--top-module $(srcNpc) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	./build/$(srcNpc)/V$(srcNpc) $(ARG)

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

runYsyxSoc:verilogYsyxSoc $(srcCpp) $(srcCppYsyxSoc)
	@verilator $(VERILATOR_CFLAGS) $(YsyxSoc_VLT) $(srcVerilogYsyxSoc) \
	--exe $(srcCpp) $(srcCppYsyxSoc) --Mdir build/$(srcYsyxSoc) --build $(NVBOARD_ARCHIVE) \
	--top-module $(srcYsyxSoc) $(SOC_CFLAGS) \
	-CFLAGS -I$(NPC_HOME)/test/cpp/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	./build/$(srcYsyxSoc)/V$(srcYsyxSoc) $(ARG)


srcVerilogIverilog += $(shell find $(NPC_HOME)/build/iverilog -type f -name "*.sv")
srcVerilogIverilog += $(NPC_HOME)/test/iverilog/iverliog.v
iverilog:verilogIverilog
	riscv64-linux-gnu-objcopy -I binary -O verilog $(ARG) $(NPC_HOME)/test/iverilog/iverilog.hex
	iverilog -g2012 -o build/iverilogCpu $(srcVerilogIverilog)
	vvp build/iverilogCpu -fst
sim-iverilog:verilogIverilog
	riscv64-linux-gnu-objcopy -I binary -O verilog $(IMG) $(NPC_HOME)/test/iverilog/iverilog.hex
	iverilog -g2012 -o build/iverilogCpu $(srcVerilogIverilog)
	vvp build/iverilogCpu -fst

srcVerilogNetlist += $(NPC_HOME)/test/iverilog/iverliog.v
srcVerilogNetlist += $(shell find $(NPC_HOME)/build/netlist -type f -name "*.sv")
NETLIST ?= $(YOSYS_STA_HOME)/result/ysyx_26020046-500MHz/ysyx_26020046.netlist.v.sim
CELLS	?= $(YOSYS_STA_HOME)/pdk/nangate45/sim/cells.v
netlist:verilogNetlist sta
	riscv64-linux-gnu-objcopy -I binary -O verilog $(ARG) $(NPC_HOME)/test/iverilog/iverilog.hex
	iverilog -g2012 -o build/netlistCpu $(srcVerilogNetlist) $(NETLIST) $(CELLS)
	vvp build/netlistCpu -fst
sim-iverilog-netlist:verilogNetlist
	riscv64-linux-gnu-objcopy -I binary -O verilog $(IMG) $(NPC_HOME)/test/iverilog/iverilog.hex
	iverilog -g2012 -o build/netlistCpu $(srcVerilogNetlist) $(NETLIST) $(CELLS)
	vvp build/netlistCpu -fst

YOSYS_CONFIG = CLK_PORT_NAME=clock CLK_FREQ_MHZ=500 PDK=nangate45
# nangate45 icsprout55

srcVerilogSta += $(shell find $(NPC_HOME)/build/sta -type f -name "*.sv")
sta:verilogSta $(srcVerilogSta)
	time make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046 RTL_FILES="$(srcVerilogSta)" $(YOSYS_CONFIG)
# 	cp -r $(YOSYS_STA_HOME)/result/ysyx_26020046-500MHz ./result

chk:verilogSta $(srcVerilogSta)
	verilator --lint-only -Wall $(srcVerilogSta) --top-module ysyx_26020046

srcVerilogStaWbu += $(NPC_HOME)/build/sta/ysyx_26020046_Wbu.sv
srcVerilogStaIdu += $(NPC_HOME)/build/sta/ysyx_26020046_Idu.sv
srcVerilogStaIdu += $(NPC_HOME)/test/sta/ysyx_26020046_StaIdu.sv
srcVerilogStaExu += $(NPC_HOME)/build/sta/ysyx_26020046_Exu.sv
srcVerilogStaExu += $(NPC_HOME)/test/sta/ysyx_26020046_StaExu.sv
srcVerilogStaIch += $(NPC_HOME)/build/sta/ysyx_26020046_Ich.sv
srcVerilogStaIfu += $(NPC_HOME)/build/sta/ysyx_26020046_Ifu.sv
srcVerilogStaLsu += $(NPC_HOME)/build/sta/ysyx_26020046_Lsu.sv
staExu:verilogSta $(srcVerilogStaExu)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_StaExu RTL_FILES="$(srcVerilogStaExu)" $(YOSYS_CONFIG)
staIdu:verilogSta $(srcVerilogStaIdu)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_StaIdu RTL_FILES="$(srcVerilogStaIdu)" $(YOSYS_CONFIG)
staWbu:verilogSta $(srcVerilogStaWbu)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_Wbu RTL_FILES="$(srcVerilogStaWbu)" $(YOSYS_CONFIG)
staIch:verilogSta $(srcVerilogStaIch)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_Ich RTL_FILES="$(srcVerilogStaIch)" $(YOSYS_CONFIG)
staIfu:verilogSta $(srcVerilogStaIfu)
	make -C $(YOSYS_STA_HOME) sta DESIGN=ysyx_26020046_Ifu RTL_FILES="$(srcVerilogStaIfu)" $(YOSYS_CONFIG)
staPart:verilogSta staWbu staIdu staExu staIch staIfu

icachesim:./test/cpp/icachesim/icachesim.cpp
	clang++ ./test/cpp/icachesim/icachesim.cpp -o ./test/cpp/icachesim/icachesim
	time ./test/cpp/icachesim/icachesim

dcachesim:./test/cpp/dcachesim/dcachesim.cpp
	clang++ ./test/cpp/dcachesim/dcachesim.cpp -o ./test/cpp/dcachesim/dcachesim
	time ./test/cpp/dcachesim/dcachesim
branchsim:./test/cpp/branchsim/branchsim.cpp
	clang++ ./test/cpp/branchsim/branchsim.cpp -o ./test/cpp/branchsim/branchsim
	time ./test/cpp/branchsim/branchsim
bjsim:./test/cpp/bjsim/bjsim.cpp
	clang++ ./test/cpp/bjsim/bjsim.cpp -o ./test/cpp/bjsim/bjsim
	time ./test/cpp/bjsim/bjsim

coverager:
	lcov --list --rc branch_coverage=1 --rc function_coverage=0 $(NPC_HOME)/log/merged.info