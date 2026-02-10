include $(NVBOARD_HOME)/scripts/nvboard.mk

MAKEFLAGS += -k
FLAGS=  --debug --cc --trace -MMD -O0
VERILATOR_CFLAGS += $(FLAGS)

# vFile  = $(wildcard vsrc/*.v)
# cFile  = $(patsubst vsrc/%.v,csrc/%.cpp,$(vFile))
# BINS   = $(patsubst vsrc/%.v,bin/%,   $(vFile))
# BUILDS = $(patsubst vsrc/%.v,build/%, $(vFile))
# TOPNAME= $(patsubst vsrc/%.v,%,$(vFile))
vFile = $(shell find vsrc -type f -name "*.v")
cFile = $(patsubst vsrc/%.v,csrc/%.cpp,$(vFile))
BINS  = $(patsubst vsrc/%.v,bin/%,$(vFile))
NAME  = $(basename $(vFile))
# BUILDS = $(patsubst %,build/%,$(basename $(notdir $(vFile))))
# TOPNAME= $(basename $(notdir $(vFile)))


INC_PATH ?=
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS)
t?=water
# tV=$(wildcard vsrc/$(t).v) $(wildcard vsrc/*/$(t).v)
tV=$(shell find vsrc -type f -name "$(t).v")
tC=$(patsubst vsrc/%.v,csrc/%.cpp,$(tV))
tU=$(patsubst vsrc/%.v,%,$(tV))
# tC=$(wildcard csrc/$(t).v) $(wildcard csrc/*/$(t).v)
# tC=$(shell find csrc -type f -name "$(t).cpp")
all: $(BINS)
# all: $(vFile) $(cFile)
# # 	@for file in $(vFile); do \
# 		bin_name=bin/$$(basename $$file .v); \
# 		make $$bin_name; \
# 	done
# 	@for file in $(NAME); do \
# 		make bin/$(file); \
# 	done

bin/%: vsrc/%.v csrc/%.cpp | build/% bin
	mkdir -p $(dir $@)
	verilator --lint-only -Wall $< --top-module $(notdir $*) -Wno-DECLFILENAME
	verilator $(VERILATOR_CFLAGS) $< --exe csrc/$*.cpp --Mdir build/$* --build $(NVBOARD_ARCHIVE) \
	--top-module $(notdir $*) \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	
# 	cd build/$* && make -f V$*.mk
	cp build/$*/V$(notdir $*) $@
	git add .

bin:
	mkdir -p bin
build/%:
	mkdir -p $@
wave:
	mkdir -p wave

sim:bin/$(t) wave
	./bin/$(t)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	gtkwave wave/$(t).vcd
# 	@echo "Write this Makefile by your self."

clean:
	rm bin/* build/* -rf
run:bin/$(tU)
	./bin/$(tU)
gtk:
	gtkwave wave/$(tU).vcd
log:
	git log --pretty=format:"%h | %ad | %s" --date=iso --abbrev-commit --no-merges --since="2026-01-01"
tree:
	exa --grid --color=always --sort=name *

chk:
	verilator --lint-only -Wall $(tV)
# 	verilator --lint-only -Wall vsrc/$(t).v

# include $(YOSYS_STA_HOME)/Makefile
syn:chk
	make -C $(YOSYS_STA_HOME) syn DESIGN=$(t) RTL_FILES=$(NPC_HOME)/$(tV)
# 	make -C $(YOSYS_STA_HOME) syn DESIGN=$(t) RTL_FILES=$(NPC_HOME)/vsrc/$(t).v
	cp -r $(YOSYS_STA_HOME)/result/$(t)*-500MHz ./result
	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
sta:
	make -C $(YOSYS_STA_HOME) sta DESIGN=$(t) RTL_FILES=$(NPC_HOME)/$(tV)
# 	make -C $(YOSYS_STA_HOME) sta DESIGN=$(t) RTL_FILES=$(NPC_HOME)/vsrc/$(t).v
	cp -r $(YOSYS_STA_HOME)/result/$(t)*-500MHz ./result
	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
# 	rm -rf $(YOSYS_STA_HOME)/result/$(t)*
symy:
	yosys yosys.tcl
try:
	cp -r $(YOSYS_STA_HOME)/result/$(t)* ./result
git:
	git add -f Makefile vsrc/* csrc/* bin/* syn/* result/*
include ../Makefile