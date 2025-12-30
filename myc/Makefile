CFLAGS=-Wall -g -Isrc

SOURCES=$(wildcard src/ex*.c)
OBJECTS=$(patsubst src/%.c,bin/%.o,$(SOURCES))
BINS = $(patsubst src/%.c,bin/%,$(SOURCES))

all: $(BINS)
	git add -f *

bin/%.o: src/%.c
	gcc $(CFLAGS) -c $< -o $@

clean:
	rm -f $(BINS) $(OBJECTS)
test: bin/ex19
bin/ex19:bin/object.o bin/ex19.o
	gcc $(CFLAGS) bin/ex19.o bin/object.o -o $@
bin/ex19a: bin/object.o bin/ex19.o
	gcc $(CFLAGS) bin/ex19.o bin/object.o -o $@
bin/ex22: bin/ex22.o bin/exn22.o
	gcc $(CFLAGS) bin/ex22.o bin/exn22.o -o $@


log:
	git log --pretty=format:"%h | %ad | %s" --date=iso --abbrev-commit --no-merges --since="2025-01-01"
