# Claude Code Settings

This file contains configuration for Claude Code permissions and settings for this project.

## Tool Permissions

### File Operations
- **Read**: Allow reading all files in the project directory and subdirectories
- **Write**: Allow creating, editing, and modifying files within the project directory
- **File Management**: Allow file creation, deletion, and organization

### Git Operations
- **Git Commands**: Allow all git operations including:
  - `git status`, `git diff`, `git log`
  - `git add`, `git commit`, `git push`, `git pull`
  - `git branch`, `git checkout`, `git merge`
  - `git reset`, `git revert`, `git stash`
  - Any other git commands for version control

### GitHub CLI (gh) Operations
- **GitHub Commands**: Allow all GitHub CLI operations including:
  - `gh pr create`, `gh pr list`, `gh pr view`
  - `gh issue create`, `gh issue list`, `gh issue view`
  - `gh repo clone`, `gh repo fork`, `gh repo view`
  - `gh auth login`, `gh auth status`
  - Any other gh commands for GitHub integration

### General Shell Commands
- **Development Tools**: Allow running development-related commands:
  - `dune build`, `dune runtest`, `dune exec`
  - `ocaml`, `opam`, package management commands
  - `make`, build tools
  - File system operations (`ls`, `find`, `grep`, etc.)

## Project Context

This is a Chinese programming language compiler called "骆言" (Luoyan), built in OCaml. The project includes:

- **Source Code**: Located in `src/` directory
- **Tests**: Located in `test/` directory  
- **Examples**: Located in `examples/` directory
- **Build System**: Uses Dune for compilation
- **Language**: OCaml with Chinese language features

## Working Directory Scope

All permissions are scoped to the current working directory: `/Users/zc/temp/chinese-ocaml`

No operations outside this directory tree should be performed without explicit user consent.

## Recent Improvements

✅ **All Tests Passing**: Fixed 4 failing tests including:
- Recursive function support with global function table
- List expression evaluation and pattern matching
- Complex recursive functions (Fibonacci)  
- Integration tests for factorial program

✅ **Code Quality**: 
- Fixed all compiler warnings in test files
- Added proper warning suppressions for unused code
- Improved error handling and runtime value types

✅ **Enhanced Features**:
- Added `ListValue` runtime type
- Implemented `ListExpr` evaluation
- Enhanced pattern matching for lists (`EmptyListPattern`, `ConsPattern`)
- Fixed recursive function self-reference using global state

The project is now in excellent working condition with comprehensive test coverage and clean code.