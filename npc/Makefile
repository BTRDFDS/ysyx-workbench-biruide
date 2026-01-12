include $(NVBOARD_HOME)/scripts/nvboard.mk

FLAGS=  --debug --cc --trace -MMD
VERILATOR_CFLAGS += $(FLAGS)

vFile  = $(wildcard vsrc/*.v)
cFile  = $(patsubst vsrc/%.v,csrc/%.cpp,$(vFile))
BINS   = $(patsubst vsrc/%.v,bin/%,   $(vFile))
BUILDS = $(patsubst vsrc/%.v,build/%, $(vFile))
TOPNAME= $(patsubst vsrc/%.v,%,$(vFile))

INC_PATH ?=
INCFLAGS = $(addprefix -I, $(INC_PATH))
CXXFLAGS += $(INCFLAGS)

all: $(BINS) $(NVBOARD_ARCHIVE)
bin/%: vsrc/%.v csrc/%.cpp | build/% bin
	verilator $(VERILATOR_CFLAGS) $< --exe csrc/$*.cpp --Mdir build/$* --build \
	$(addprefix -CFLAGS , $(CXXFLAGS)) \
	$(addprefix -LDFLAGS , $(LDFLAGS))
	
# 	cd build/$* && make -f V$*.mk
	cp build/$*/V$* $@
	git add -f Makefile vsrc/* csrc/* bin/*

bin:
	mkdir -p bin
build/%:
	mkdir -p $@

sim:all
	./bin/$(t)
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	gtkwave wave/$(t).vcd
# 	@echo "Write this Makefile by your self."

clean:
	rm bin/* build/* -rf
run:
	./bin/$(t)
log:
	git log --pretty=format:"%h | %ad | %s" --date=iso --abbrev-commit --no-merges --since="2026-01-01"
tree:
	exa --grid --color=always --sort=name *

include ../Makefile