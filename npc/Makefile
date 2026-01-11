FLAGS=  --debug --cc #--trace

vFile  = $(wildcard vsrc/*.v)
cFile  = $(patsubst vsrc/%.v,csrc/%.cpp,$(vFile))
BINS   = $(patsubst vsrc/%.v,bin/%,   $(vFile))
BUILDS = $(patsubst vsrc/%.v,build/%, $(vFile))

all: $(BINS)
bin/%: vsrc/%.v csrc/%.cpp | build/% bin
	verilator $(FLAGS) $< --exe csrc/$*.cpp --Mdir build/$* --build
	
# 	cd build/$* && make -f V$*.mk
	cp build/$*/V$* $@

bin:
	mkdir -p bin
build/%:
	mkdir -p $@

sim:
	$(call git_commit, "sim RTL") # DO NOT REMOVE THIS LINE!!!
	@echo "Write this Makefile by your self."

include ../Makefile
