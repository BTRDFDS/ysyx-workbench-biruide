include $(NVBOARD_HOME)/scripts/nvboard.mk

MAKEFLAGS += -k
FLAGS=  --debug --cc --trace -MMD -O0
VERILATOR_CFLAGS += $(FLAGS)

vFile = $(shell find vsrc -type f -name "*.v")
cFile = $(patsubst vsrc/%.v,csrc/%.cpp,$(vFile))
BINS  = $(patsubst vsrc/%.v,bin/%,$(vFile))
NAME  = $(basename $(vFile))

INC_PATH ?=
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS)

ifeq ($(MAKECMDGOALS),gdb)
	ePrintf = -DDEBUG
endif



t?=water
tF?=t
tV?=$(shell find vsrc -type f \( -name "$(tF).sv" -o -name "$(tF).v" \))
# tC ?=$(patsubst vsrc/%.v,csrc/%.cpp,$(tV))
tU=$(notdir $(basename $(tV)))
# tC=$(patsubst vsrc/%,csrc/%.cpp,$(basename $(tV)))
tC?=$(shell find csrc -type f -name "$(tU).cpp")
tVd?=$(NPC_HOME)/$(tV)
ifeq ($(t),minirvO)
	tF=ysyx_26020046_minirvO
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_Reg.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_ALU.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_IDC.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_LSU.v,$(tV))
endif
ifeq ($(t),minirv_sta)
tF=ysyx_26020046_minirv_sta
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_Reg.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_ALU.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_IDC.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_LSU.v,$(tV))
endif
ifeq ($(t),minirvS)
	tF=ysyx_26020046_minirvS
endif
ifeq ($(t),minirvN)
	tF=ysyx_26020046_minirvN
endif
ifeq ($(t),minirv)
	tF=ysyx_26020046_minirv
endif
# all: $(BINS)
# bin/%: vsrc/%.v csrc/%.cpp | build/% bin
# 	mkdir -p $(dir $@)
# 	verilator --lint-only -Wall $< --top-module $(notdir $*) -Wno-DECLFILENAME
# 	verilator $(VERILATOR_CFLAGS) $< --exe csrc/$*.cpp --Mdir build/$* --build $(NVBOARD_ARCHIVE) \
# 	--top-module $(notdir $*) \
# 	$(addprefix -CFLAGS , $(CXXFLAGS)) \
# 	$(addprefix -LDFLAGS , $(LDFLAGS))
# 	cp build/$*/V$(notdir $*) $@
# 	git add .
# all: $(BINS)
# bin/%: vsrc/%.v csrc/%.cpp | build/% bin
bin/%: $(tVd) $(tC) | build/% bin

# 	@echo "t=$(t)"
# 	@echo "tV=$(tV)"
# 	@echo "tC=$(tC)"
# 	@echo "tU=$(tU)"
# 	@echo "tVd=$(tVd)"

	mkdir -p $(dir $@)
	verilator --lint-only -Wall $(tVd) --top-module $(tF) -Wno-DECLFILENAME
	verilator $(VERILATOR_CFLAGS) $(ePrintf) $(tVd) --exe $(tC) --Mdir build/$* --build $(NVBOARD_ARCHIVE) \
	--top-module $(tF) \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	cp build/$*/V$(notdir $*) $@
	git add .

bin:
	mkdir -p bin
log:
	mkdir -p log
log/%:
	mkdir -p $@
build/%:
	mkdir -p $@
wave:
	mkdir -p wave

sim:bin/$(tU) wave
	./bin/$(t)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	gtkwave wave/$(t).vcd
clean:
	rm -rf bin/* build/*

run:bin/$(tU)
	./bin/$(tU) $(ARG) $(xEb)
gdb:bin/$(tU) log/$(dir $(tU))
	./bin/$(tU) $(ARG) $(xEb) > log/$(tU)_gdb.log
# 	./bin/$(tU) $(ARG) $(xEb)
val:bin/$(tU)
	valgrind --leak-check=full --show-leak-kinds=all ./bin/$(tU) $(ARG) $(xEb) > log/$(tU)_val.log

do:bin/$(tU)
gtk:
	gtkwave wave/$(tU).vcd
# log:
# 	git log --pretty=format:"%h | %ad | %s" --date=iso --abbrev-commit --no-merges --since="2026-01-01"
tree:
	exa --grid --color=always --sort=name *

chk:
# 	@echo "t=$(t)"
# 	@echo "tV=$(tV)"
# 	@echo "tC=$(tC)"
# 	@echo "tU=$(tU)"
# 	@echo "tVd=$(tVd)"
	verilator --lint-only -Wall $(tVd) -top-module $(tU)
syn:$(tV) chk
	make -C $(YOSYS_STA_HOME) syn DESIGN=$(tU) RTL_FILES="$(tVd)
	cp -r $(YOSYS_STA_HOME)/result/$(tU)*-500MHz ./result
	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
sta:$(tV)
	make -C $(YOSYS_STA_HOME) sta DESIGN=$(tU) RTL_FILES="$(tVd)"
	cp -r $(YOSYS_STA_HOME)/result/$(tU)*-500MHz ./result
	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
symy:
	yosys yosys.tcl
try:
	cp -r $(YOSYS_STA_HOME)/result/$(tU)* ./result
git:
	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
include ../Makefile