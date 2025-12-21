FLAGS=-Wall -g

SRCS = $(wildcard ex*.c)

# 2. 将所有 .c 后缀的源文件，转换为同名可执行文件（如 ex1.c → ex1）
BINS = $(SRCS:.c=)

# 3. 默认目标（执行 make 时，自动执行该目标）
all: $(BINS)
	git add -f *

# 4. 清理命令：删除所有生成的可执行文件（执行 make clean 触发）
clean:
	rm -f $(BINS)
