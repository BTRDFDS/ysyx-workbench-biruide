CFLAGS=-Wall -g -Isrc

SOURCES=$(wildcard src/ex*.c)
TEST_SOURCES=$(wildcard tests/ex*Test.c)
OBJECTS=$(patsubst src/%.c,build/%.o,$(SOURCES))
TEST_OBJECTS=$(patsubst tests/%.c,build/%.o,$(TEST_SOURCES))
BINS = $(patsubst src/%.c,bin/%,$(SOURCES))
TEST_BINS = $(patsubst tests/%.c,bin/%,$(TEST_SOURCES))

all: $(BINS) $(TEST_BINS)
	git add -f *

build/%.o: src/%.c
	gcc $(CFLAGS) -c $< -o $@

build/%.o: tests/%.c
	gcc $(CFLAGS) -c $< -o $@

bin/%Test: build/%Test.o
	gcc $(CFLAGS) $< -o $@


clean:
	rm -f $(BINS) $(OBJECTS)

bin/ex19:build/object.o build/ex19.o
	gcc $(CFLAGS) build/ex19.o build/object.o -o $@
bin/ex19a: build/object.o build/ex19.o
	gcc $(CFLAGS) build/ex19.o build/object.o -o $@

bin/ex22: build/ex22.o build/exn22.o
	gcc $(CFLAGS) build/ex22.o build/exn22.o -o $@

build/ex29lib.so: build/ex29lib.o
	cc -shared -o $@ $<
bin/ex29: bin/ex29.o build/ex29lib.so
	gcc $(CFLAGS) $< -ldl -o $@


log:
	git log --pretty=format:"%h | %ad | %s" --date=iso --abbrev-commit --no-merges --since="2025-01-01"

test:
	@if [ -f "bin/$(filter-out $@,$(MAKECMDGOALS))Test" ]; then \
		cd bin && \
		./$(filter-out $@,$(MAKECMDGOALS))Test 2>&1 | tee ../tests/tests.log; \
	elif [ -f "tests/$(filter-out $@,$(MAKECMDGOALS))" ]; then \
		cd bin && \
		> ../tests/tests.log && \
		(echo; cat ../tests/$(filter-out $@,$(MAKECMDGOALS))) | while IFS= read -r line; do \
			[ -z "$$line" ] && continue; \
			echo "$$ $$line" | tee -a ../tests/tests.log; \
			eval "$$line" 2>&1 | tee -a ../tests/tests.log; \
		done; \
	else \
		echo "No test found for $(filter-out $@,$(MAKECMDGOALS))"; \
	fi

%:
	@:




