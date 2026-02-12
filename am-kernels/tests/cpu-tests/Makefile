.PHONY: all run gdb clean latest $(ALL)

RESULT = .result
$(shell > $(RESULT))

COLOR_RED   = \033[1;31m
COLOR_GREEN = \033[1;32m
COLOR_NONE  = \033[0m

t ?= 0

ALL = $(basename $(notdir $(shell find tests/. -name "*.c")))
cleanNemu:
	make -C $(NEMU_HOME) clean
all: $(if $(filter 1,$(t)), cleanNemu) $(addprefix Makefile., $(ALL))
ifeq ($(t),1)
	make -C $(NEMU_HOME) clean
endif
	@echo "test list [$(words $(ALL)) item(s)]:" $(ALL)

$(ALL): %: Makefile.%

Makefile.%: tests/%.c latest
	@/bin/echo -e "NAME = $*\nSRCS = $<\ninclude $${AM_HOME}/Makefile" > $@
# 	@if make -s -f $@ ARCH=$(ARCH) $(MAKECMDGOALS) TEST_AM=$(t); then 
	@if make -f $@ ARCH=$(ARCH) $(MAKECMDGOALS) TEST_AM=$(t) XEB=$(XEB); then \
		printf "[%14s] $(COLOR_GREEN)PASS$(COLOR_NONE)\n" $* >> $(RESULT); \
	else \
		printf "[%14s] $(COLOR_RED)***FAIL***$(COLOR_NONE)\n" $* >> $(RESULT); \
	fi
	-@rm -f Makefile.$*

run: all
	@cat $(RESULT)
	@grep -q "FAIL" $(RESULT); FAIL=$$?; rm $(RESULT); test $$FAIL -ne 0

gdb: all


clean:
	rm -rf Makefile.* build/
help:
	@echo "make run ARCH=riscv32-nemu ALL=add t=1"
	@echo "make ARCH=minirv-npc ALL=dummy run"
latest:
