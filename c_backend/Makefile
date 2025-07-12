# 骆言编程语言C后端构建系统
# Luoyan Programming Language C Backend Build System

CC = clang
CFLAGS = -Wall -Wextra -std=c99 -I./runtime
LDFLAGS = 
RUNTIME_SRC = runtime/luoyan_runtime.c
RUNTIME_HDR = runtime/luoyan_runtime.h

.PHONY: all clean test

all: test_simple

# 编译运行时为静态库
runtime/luoyan_runtime.o: $(RUNTIME_SRC) $(RUNTIME_HDR)
	$(CC) $(CFLAGS) -c $(RUNTIME_SRC) -o $@

# 编译测试程序
test_simple: test_simple.c runtime/luoyan_runtime.o
	$(CC) $(CFLAGS) test_simple.c runtime/luoyan_runtime.o -o $@ $(LDFLAGS)

# 运行测试程序
test: test_simple
	./test_simple

# 清理构建文件
clean:
	rm -f test_simple runtime/*.o

# 编译任意C文件（通用规则）
%.out: %.c runtime/luoyan_runtime.o
	$(CC) $(CFLAGS) $< runtime/luoyan_runtime.o -o $@ $(LDFLAGS)

# 调试版本
debug: CFLAGS += -g -DLUOYAN_DEBUG
debug: all

# 优化版本
release: CFLAGS += -O2 -DNDEBUG
release: all