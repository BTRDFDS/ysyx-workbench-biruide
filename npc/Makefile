# include $(NVBOARD_HOME)/scripts/nvboard.mk
include ../Makefile
ifeq ($(NVB),1)
include $(NVBOARD_HOME)/scripts/nvboard.mk
NVBOARD_FLAGS = $(NVBOARD_ARCHIVE)
else
NVBOARD_FLAGS =
endif

MAKEFLAGS += -k
# FLAGS=  --debug --cc --trace -MMD -O0
FLAGS=  --cc -MMD -O3 --x-assign fast --x-initial fast --noassert
VERILATOR_CFLAGS += $(FLAGS)

vFile = $(shell find vsrc -type f -name "*.v")
cFile = $(patsubst vsrc/%.v,csrc/%.cpp,$(vFile))
BINS  = $(patsubst vsrc/%.v,bin/%,$(vFile))
NAME  = $(basename $(vFile))
CXXFLAGS += -O3 -march=native -fomit-frame-pointer

INC_PATH ?=
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS)

LDFLAGS += -lreadline
LDFLAGS += -L$(NPC_HOME)/lib
LDFLAGS += -lcapstone
ifeq ($(MAKECMDGOALS),gdb)
VERILATOR_CFLAGS += -DDEBUG
CXXFLAGS += -DDEBUG
endif

ifeq ($(MAKECMDGOALS),sdb)
CXXFLAGS += -DDEBUG_SDB
endif

ifeq ($(MAKECMDGOALS),dft)
CXXFLAGS += -DDIFFTEST
LDFLAGS += -ldl
CXXFLAGS += -I/$(NEMU_HOME)/include
endif


t?=water#工程名称
tF?=$(t)#工程文件查找名
tV?=$(shell find vsrc -type f \( -name "$(tF).sv" -o -name "$(tF).v" \))#工程文件查找结果
tC?=$(shell find csrc -type f -name "$(tF).cpp")#驱动文件查找结果
# tU?=$(notdir $(basename $(tV)))#工程全程
tVd?=$(NPC_HOME)/$(tV)#工程文件绝对路径
tCd?=$(NPC_HOME)/$(tC)#驱动文件绝对路径
ifeq ($(t),minirvO)
	tF=ysyx_26020046_minirvO
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_Reg.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_ALU.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_IDC.v,$(tV))
	tVd+= $(NPC_HOME)/$(patsubst vsrc/%/$(tF).v,vsrc/%/ysyx_26020046_minirv_LSU.v,$(tV))
endif
ifeq ($(t),minirv_sta)
tF=ysyx_26020046_minirv_sta
endif
ifeq ($(t),minirvS)
	tF=ysyx_26020046_minirvS
endif
ifeq ($(t),minirvN)
	tF=ysyx_26020046_minirvN
endif
ifeq ($(t),minirv)
	tF=ysyx_26020046_minirv
	tCd += $(NPC_HOME)/csrc/npcSdb/*
	tCd += $(NPC_HOME)/csrc/npcTrace/*
	tCd += $(NPC_HOME)/csrc/npcDifftest/*
endif
ifeq ($(t),rv32i)
	tF=ysyx_26020046_rv32i
# 	tF=ysyx_26020046_rv32iOneHotN
	tCd += $(NPC_HOME)/csrc/npcSdb/*
	tCd += $(NPC_HOME)/csrc/npcTrace/*
	tCd += $(NPC_HOME)/csrc/npcDifftest/*
endif

bin/%: $(tVd) $(tCd) | build/$(tF) bin

	@echo "t=$(t)"
	@echo "tF=$(tF)"
	@echo "tV=$(tV)"
	@echo "tC=$(tC)"
	@echo "tVd=$(tVd)"
	@echo "tCd=$(tCd)"

	mkdir -p build/$(tF)
	verilator --lint-only -Wall $(tVd) --top-module $(tF) -Wno-DECLFILENAME
	verilator $(VERILATOR_CFLAGS) $(ePrintf) $(tVd) --exe $(tCd) --Mdir build/$(tF) --build $(NVBOARD_ARCHIVE) \
	--top-module $(tF) \
	-CFLAGS -I$(NPC_HOME)/include \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	cp build/$(tF)/V$(tF) bin/$(tF)
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

sim:bin/$(tF) wave
	./bin/$(t)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	gtkwave wave/$(t).vcd
clean:
	rm -rf bin/* build/*

run:bin/$(tF)
	./bin/$(tF) $(ARG) $(xEb)
# 	perf record -g ./bin/$(tF) $(ARG) $(xEb)
# 	perf stat ./bin/$(tF) $(ARG) $(xEb)
# 	./bin/$(tF) $(ARG) $(xEb) > log/$(tF).log
sdb:bin/$(tF)
	./bin/$(tF) $(ARG) $(xEb)
dft:bin/$(tF)
	./bin/$(tF) $(ARG) $(xEb)
	./bin/$(tF) $(ARG) $(xEb) > log/$(tF)_dft.log
gdb:bin/$(tF) log/$(dir $(tF))
	./bin/$(tF) $(ARG) $(xEb) > log/$(tF)_gdb.log
# 	./bin/$(tF) $(ARG) $(xEb)
val:bin/$(tF)
	valgrind --leak-check=full --show-leak-kinds=all ./bin/$(tF) $(ARG) $(xEb) > log/$(tF)_val.log

do:bin/$(tF)
gtk:
	gtkwave wave/$(tF).vcd
# log:
# 	git log --pretty=format:"%h | %ad | %s" --date=iso --abbrev-commit --no-merges --since="2026-01-01"
tree:
	exa --grid --color=always --sort=name *

chk:
# 	@echo "t=$(t)"
# 	@echo "tV=$(tV)"
# 	@echo "tCd=$(tCd)"
# 	@echo "tF=$(tF)"
# 	@echo "tVd=$(tVd)"
	verilator --lint-only -Wall $(tVd) -top-module $(tF)
syn:$(tV)
	make -C $(YOSYS_STA_HOME) syn DESIGN=$(tF) RTL_FILES="$(tVd)"
	cp -r $(YOSYS_STA_HOME)/result/$(tF)*-500MHz ./result
# 	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
sta:$(tV)
	make -C $(YOSYS_STA_HOME) sta DESIGN=$(tF) RTL_FILES="$(tVd)"
	cp -r $(YOSYS_STA_HOME)/result/$(tF)*-500MHz ./result
# 	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
symy:
	yosys yosys.tcl
try:
	cp -r $(YOSYS_STA_HOME)/result/$(tF)* ./result
git:
	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*