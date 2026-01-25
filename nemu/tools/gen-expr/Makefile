#***************************************************************************************
# Copyright (c) 2014-2024 Zihao Yu, Nanjing University
#
# NEMU is licensed under Mulan PSL v2.
# You can use this software according to the terms and conditions of the Mulan PSL v2.
# You may obtain a copy of Mulan PSL v2 at:
#          http://license.coscl.org.cn/MulanPSL2
#
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
#
# See the Mulan PSL v2 for more details.
#**************************************************************************************/

NAME = gen-expr
SRCS = gen-expr.c
include $(NEMU_HOME)/scripts/build.mk
build/gen-expr:gen-expr.c
	gcc -g -o $@ $^ -O0
run:build/gen-expr
	./build/gen-expr 10000 > input
# 	./build/gen-expr 2000 > input
# 	./build/gen-expr 20 > input
# 	./build/gen-expr 1000 > input
gdb:build/gen-expr
	gdb -tui ./build/gen-expr
val:
	time valgrind --leak-check=full --show-reachable=yes ./build/gen-expr 100 > input

build/do:do.c
	gcc -g -o $@ $^
do:build/do
	./build/do