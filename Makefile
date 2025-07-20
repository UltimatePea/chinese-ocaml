# 骆言编程语言项目构建管理
# Makefile for the 骆言 (Luoyan) programming language project

.PHONY: help build clean test install dev-setup docker-build format lint docs coverage

# 默认目标：显示帮助信息
help:
	@echo "🎋 骆言编程语言项目构建管理"
	@echo ""
	@echo "📋 可用命令:"
	@echo "  help       - 显示此帮助信息"
	@echo "  build      - 构建项目"
	@echo "  clean      - 清理构建产物和临时文件"
	@echo "  test       - 运行测试套件"
	@echo "  install    - 安装编译器到系统"
	@echo "  dev-setup  - 设置开发环境"
	@echo "  format     - 格式化代码"
	@echo "  lint       - 代码质量检查"
	@echo "  docs       - 生成文档"
	@echo "  coverage   - 生成测试覆盖率报告"
	@echo "  docker     - 构建Docker镜像"
	@echo ""
	@echo "📊 项目状态:"
	@du -sh . | cut -f1 | xargs echo "  项目总大小:"
	@if [ -d "_build" ]; then du -sh _build | cut -f1 | xargs echo "  构建产物:"; else echo "  构建产物: 无"; fi

# 构建项目
build:
	@echo "🔧 构建骆言编译器..."
	dune build
	@echo "✅ 构建完成"

# 清理构建产物
clean:
	@echo "🧹 清理构建产物..."
	@./scripts/clean_build.sh

# 快速清理（仅清理构建产物）
clean-build:
	@echo "🧹 快速清理构建产物..."
	dune clean
	@echo "✅ 构建产物清理完成"

# 运行测试
test:
	@echo "🧪 运行测试套件..."
	dune runtest
	@echo "✅ 测试完成"

# 安装编译器
install:
	@echo "📦 安装骆言编译器..."
	dune install
	@echo "✅ 安装完成"

# 开发环境设置
dev-setup:
	@echo "⚙️ 设置开发环境..."
	@if ! command -v dune >/dev/null 2>&1; then \
		echo "❌ 错误: dune 未安装，请先安装 OCaml 和 dune"; \
		exit 1; \
	fi
	@if [ ! -f "github_auth.py" ]; then \
		echo "❌ 错误: github_auth.py 不存在"; \
		exit 1; \
	fi
	@echo "✅ 开发环境检查通过"

# 格式化代码
format:
	@echo "🎨 格式化代码..."
	dune build @fmt --auto-promote
	@echo "✅ 代码格式化完成"

# 代码质量检查
lint:
	@echo "🔍 代码质量检查..."
	@if command -v ocamlformat >/dev/null 2>&1; then \
		find src test -name "*.ml" -o -name "*.mli" | xargs ocamlformat --check; \
	else \
		echo "⚠️  ocamlformat 未安装，跳过格式检查"; \
	fi
	@echo "✅ 代码检查完成"

# 生成文档
docs:
	@echo "📚 生成文档..."
	dune build @doc
	@echo "✅ 文档生成完成"
	@echo "📁 文档位置: _build/default/_doc/_html/index.html"

# 测试覆盖率
coverage:
	@echo "📊 生成测试覆盖率报告..."
	@if command -v bisect-ppx >/dev/null 2>&1; then \
		dune build --instrument-with bisect_ppx; \
		dune runtest; \
		bisect-ppx-report html; \
		echo "📁 覆盖率报告: _coverage/index.html"; \
	else \
		echo "⚠️  bisect-ppx 未安装，无法生成覆盖率报告"; \
	fi

# Docker 构建
docker:
	@echo "🐳 构建 Docker 镜像..."
	@if [ -f "Dockerfile" ]; then \
		docker build -t luoyan-compiler .; \
		echo "✅ Docker 镜像构建完成: luoyan-compiler"; \
	else \
		echo "❌ 错误: Dockerfile 不存在"; \
		exit 1; \
	fi

# 性能测试
benchmark:
	@echo "⚡ 运行性能测试..."
	@if [ -d "性能测试" ]; then \
		cd 性能测试 && ./scripts/run_benchmark.sh; \
	else \
		echo "❌ 错误: 性能测试目录不存在"; \
	fi

# 项目状态检查
status:
	@echo "📊 项目状态检查"
	@echo "============================"
	@echo "📁 项目结构:"
	@echo "  源文件: $(shell find src -name "*.ml" | wc -l) .ml 文件"
	@echo "  接口文件: $(shell find src -name "*.mli" | wc -l) .mli 文件"
	@echo "  测试文件: $(shell find test -name "*.ml" | wc -l) 测试文件"
	@echo ""
	@echo "💾 磁盘使用:"
	@du -sh . | head -1
	@if [ -d "_build" ]; then du -sh _build; fi
	@echo ""
	@echo "🔧 构建状态:"
	@if dune build 2>/dev/null; then echo "  ✅ 构建成功"; else echo "  ❌ 构建失败"; fi

# 完整的开发流程
dev: clean build test
	@echo "🎉 开发流程完成：清理 → 构建 → 测试"

# 发布准备
release-prep: clean build test docs
	@echo "🚀 发布准备完成：清理 → 构建 → 测试 → 文档"