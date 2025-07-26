# 长函数重构分析报告
==================================================

## 统计摘要
- 总函数数量: 1327
- 长函数数量 (≥50行): 113
- 长函数比例: 8.5%
- 平均函数长度: 22.8 行
- 最长函数长度: 229 行

## 最长的20个函数
| 函数名 | 文件 | 代码行数 | 总行数 | 复杂度指标 |
|--------|------|----------|--------|------------|
| lexer_pos_to_compiler_pos | parser_natural_functions.ml | 229 | 258 | 178 |
| convert_ancient_keywords | token_conversion_keywords_refactored.ml | 168 | 186 | 169 |
| env | semantic_expressions.ml | 153 | 170 | 119 |
| default_threshold | benchmark_regression.ml | 139 | 167 | 47 |
| collect_raw_data | consolidated_rhyme_data.ml | 137 | 179 | 26 |
| is_literal_token | parser_expressions_literals.ml | 130 | 164 | 109 |
| basic_type_to_chinese | types_convert.ml | 125 | 141 | 67 |
| arr_list | value_operations_conversion.ml | 120 | 164 | 119 |
| state3 | parser_types.ml | 114 | 152 | 102 |
| show_special_tokens | unified_token_mapper.ml | 112 | 153 | 125 |
| show_special_tokens | unified_token_mapper.ml | 112 | 153 | 125 |
| get_primary_expr_parser | parser_expressions_consolidated.ml | 108 | 201 | 41 |
| state6_clean | parser_expressions_natural_language.ml | 108 | 130 | 85 |
| rhyme_cache | rhyme_detection.ml | 105 | 148 | 95 |
| naming_checks | refactoring_analyzer_naming.ml | 104 | 126 | 25 |
| string_of_basic_value | value_operations_basic.ml | 102 | 138 | 142 |
| rhyme_data_strings | poetry_rhyme_data.ml | 97 | 111 | 5 |
| log_debug | parser_poetry.ml | 94 | 145 | 67 |
| module_parse_multiplicative_expr | parser_expressions_operators_consolidated.ml | 94 | 131 | 59 |
| state5 | parser_statements.ml | 92 | 108 | 97 |

## 需要重构的长函数 (≥50行)

### lexer_pos_to_compiler_pos
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_natural_functions.ml
- **位置**: 第 12-269 行
- **代码行数**: 229
- **总行数**: 258
- **复杂度指标**:
  - match_statements: 12
  - if_statements: 2
  - nested_functions: 88
  - pattern_matches: 59
  - exception_handling: 17
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### convert_ancient_keywords
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_conversion_keywords_refactored.ml
- **位置**: 第 112-297 行
- **代码行数**: 168
- **总行数**: 186
- **复杂度指标**:
  - match_statements: 2
  - nested_functions: 4
  - pattern_matches: 145
  - exception_handling: 18
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### env
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/semantic_expressions.ml
- **位置**: 第 14-183 行
- **代码行数**: 153
- **总行数**: 170
- **复杂度指标**:
  - match_statements: 13
  - nested_functions: 33
  - pattern_matches: 54
  - exception_handling: 19
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### default_threshold
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/performance/benchmark_regression.ml
- **位置**: 第 17-183 行
- **代码行数**: 139
- **总行数**: 167
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 6
  - nested_functions: 21
  - pattern_matches: 8
  - exception_handling: 8
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### collect_raw_data
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/consolidated_rhyme_data.ml
- **位置**: 第 51-229 行
- **代码行数**: 137
- **总行数**: 179
- **复杂度指标**:
  - if_statements: 1
  - nested_functions: 21
  - exception_handling: 4
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### is_literal_token
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_literals.ml
- **位置**: 第 20-183 行
- **代码行数**: 130
- **总行数**: 164
- **复杂度指标**:
  - match_statements: 8
  - nested_functions: 35
  - pattern_matches: 50
  - exception_handling: 16
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### basic_type_to_chinese
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/types_convert.ml
- **位置**: 第 185-325 行
- **代码行数**: 125
- **总行数**: 141
- **复杂度指标**:
  - match_statements: 6
  - nested_functions: 17
  - pattern_matches: 38
  - exception_handling: 6
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### arr_list
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_operations_conversion.ml
- **位置**: 第 37-200 行
- **代码行数**: 120
- **总行数**: 164
- **复杂度指标**:
  - match_statements: 15
  - if_statements: 1
  - nested_functions: 30
  - pattern_matches: 52
  - exception_handling: 21
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### state3
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_types.ml
- **位置**: 第 19-170 行
- **代码行数**: 114
- **总行数**: 152
- **复杂度指标**:
  - match_statements: 8
  - if_statements: 5
  - nested_functions: 50
  - pattern_matches: 26
  - exception_handling: 13
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### show_special_tokens
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/token_mapping/unified_token_mapper.ml
- **位置**: 第 119-271 行
- **代码行数**: 112
- **总行数**: 153
- **复杂度指标**:
  - match_statements: 16
  - nested_functions: 20
  - pattern_matches: 71
  - exception_handling: 18
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### show_special_tokens
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/mapping/unified_token_mapper.ml
- **位置**: 第 119-271 行
- **代码行数**: 112
- **总行数**: 153
- **复杂度指标**:
  - match_statements: 16
  - nested_functions: 20
  - pattern_matches: 71
  - exception_handling: 18
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### get_primary_expr_parser
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_consolidated.ml
- **位置**: 第 81-281 行
- **代码行数**: 108
- **总行数**: 201
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 3
  - nested_functions: 22
  - pattern_matches: 14
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构

### state6_clean
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_natural_language.ml
- **位置**: 第 59-188 行
- **代码行数**: 108
- **总行数**: 130
- **复杂度指标**:
  - match_statements: 6
  - if_statements: 1
  - nested_functions: 48
  - pattern_matches: 23
  - exception_handling: 7
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### rhyme_cache
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_detection.ml
- **位置**: 第 16-163 行
- **代码行数**: 105
- **总行数**: 148
- **复杂度指标**:
  - match_statements: 16
  - if_statements: 3
  - nested_functions: 31
  - pattern_matches: 27
  - exception_handling: 18
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### naming_checks
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/refactoring_analyzer_naming.ml
- **位置**: 第 42-167 行
- **代码行数**: 104
- **总行数**: 126
- **复杂度指标**:
  - if_statements: 6
  - nested_functions: 14
  - pattern_matches: 5
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数

### string_of_basic_value
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_operations_basic.ml
- **位置**: 第 16-153 行
- **代码行数**: 102
- **总行数**: 138
- **复杂度指标**:
  - match_statements: 17
  - if_statements: 6
  - nested_functions: 19
  - pattern_matches: 65
  - exception_handling: 35
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 函数过长，建议拆分为多个职责单一的小函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### rhyme_data_strings
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_data.ml
- **位置**: 第 14-124 行
- **代码行数**: 97
- **总行数**: 111
- **复杂度指标**:
  - if_statements: 1
  - nested_functions: 3
  - pattern_matches: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### log_debug
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_poetry.ml
- **位置**: 第 10-154 行
- **代码行数**: 94
- **总行数**: 145
- **复杂度指标**:
  - match_statements: 3
  - if_statements: 5
  - nested_functions: 43
  - pattern_matches: 9
  - exception_handling: 7
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### module_parse_multiplicative_expr
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_operators_consolidated.ml
- **位置**: 第 118-248 行
- **代码行数**: 94
- **总行数**: 131
- **复杂度指标**:
  - match_statements: 3
  - if_statements: 3
  - nested_functions: 40
  - pattern_matches: 10
  - exception_handling: 3
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### state5
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_statements.ml
- **位置**: 第 93-200 行
- **代码行数**: 92
- **总行数**: 108
- **复杂度指标**:
  - match_statements: 8
  - if_statements: 2
  - nested_functions: 50
  - pattern_matches: 24
  - exception_handling: 13
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### c
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer_state.ml
- **位置**: 第 39-145 行
- **代码行数**: 91
- **总行数**: 107
- **复杂度指标**:
  - match_statements: 8
  - if_statements: 6
  - nested_functions: 15
  - pattern_matches: 22
  - exception_handling: 14
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### state_after_first_colon
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer_punctuation_recognition.ml
- **位置**: 第 23-135 行
- **代码行数**: 90
- **总行数**: 113
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 17
  - nested_functions: 9
  - pattern_matches: 8
  - exception_handling: 1
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### format_position
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/compiler_errors_formatter.ml
- **位置**: 第 8-104 行
- **代码行数**: 89
- **总行数**: 97
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 2
  - nested_functions: 17
  - pattern_matches: 17
  - exception_handling: 4
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### compare_rhyme_quality
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_analysis.ml
- **位置**: 第 91-219 行
- **代码行数**: 88
- **总行数**: 129
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 9
  - nested_functions: 27
  - pattern_matches: 1
  - exception_handling: 1
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### delimiter_mappings
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_string_converter.ml
- **位置**: 第 229-330 行
- **代码行数**: 87
- **总行数**: 102
- **复杂度指标**:
  - match_statements: 3
  - nested_functions: 7
  - pattern_matches: 38
  - exception_handling: 6
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### base_complexity
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/refactoring_analyzer_complexity.ml
- **位置**: 第 87-182 行
- **代码行数**: 87
- **总行数**: 96
- **复杂度指标**:
  - match_statements: 3
  - loop_statements: 1
  - nested_functions: 16
  - pattern_matches: 24
  - exception_handling: 3
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构

### delimiter_mappings
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/utils/token_string_converter.ml
- **位置**: 第 231-332 行
- **代码行数**: 87
- **总行数**: 102
- **复杂度指标**:
  - match_statements: 3
  - nested_functions: 7
  - pattern_matches: 38
  - exception_handling: 6
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### complexity_checks
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/refactoring_analyzer_complexity.ml
- **位置**: 第 182-281 行
- **代码行数**: 85
- **总行数**: 100
- **复杂度指标**:
  - match_statements: 2
  - if_statements: 1
  - nested_functions: 7
  - pattern_matches: 5
  - exception_handling: 2
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### token_to_string
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_unified.ml
- **位置**: 第 160-245 行
- **代码行数**: 84
- **总行数**: 86
- **复杂度指标**:
  - nested_functions: 2
  - pattern_matches: 82
- **重构建议**:
  - 模式匹配过多，考虑使用数据结构重构

### convert
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_compatibility_bridge.ml
- **位置**: 第 18-118 行
- **代码行数**: 84
- **总行数**: 101
- **复杂度指标**:
  - nested_functions: 1
  - pattern_matches: 81
- **重构建议**:
  - 模式匹配过多，考虑使用数据结构重构

### create_test_tokens
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_conversion_benchmark.ml
- **位置**: 第 14-123 行
- **代码行数**: 83
- **总行数**: 110
- **复杂度指标**:
  - loop_statements: 3
  - nested_functions: 23
  - exception_handling: 5
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### constructor_func
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_operations_advanced.ml
- **位置**: 第 25-151 行
- **代码行数**: 82
- **总行数**: 127
- **复杂度指标**:
  - match_statements: 16
  - if_statements: 1
  - nested_functions: 23
  - pattern_matches: 41
  - exception_handling: 22
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### next_pos
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_utils.ml
- **位置**: 第 31-151 行
- **代码行数**: 82
- **总行数**: 121
- **复杂度指标**:
  - match_statements: 6
  - if_statements: 8
  - nested_functions: 36
  - pattern_matches: 28
  - exception_handling: 13
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### get_rhyme_stats
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_advanced_analysis.ml
- **位置**: 第 43-157 行
- **代码行数**: 82
- **总行数**: 115
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 5
  - nested_functions: 28
  - pattern_matches: 2
  - exception_handling: 6
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### convert_classical_token
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/conversion_lexer.ml
- **位置**: 第 142-224 行
- **代码行数**: 79
- **总行数**: 83
- **复杂度指标**:
  - match_statements: 1
  - nested_functions: 2
  - pattern_matches: 67
  - exception_handling: 1
- **重构建议**:
  - 模式匹配过多，考虑使用数据结构重构

### create_state
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_json_unified.ml
- **位置**: 第 72-163 行
- **代码行数**: 78
- **总行数**: 92
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 11
  - nested_functions: 19
  - pattern_matches: 7
  - exception_handling: 5
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### convert
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_compatibility_bridge.ml
- **位置**: 第 122-216 行
- **代码行数**: 77
- **总行数**: 95
- **复杂度指标**:
  - nested_functions: 1
  - pattern_matches: 74
- **重构建议**:
  - 模式匹配过多，考虑使用数据结构重构

### wenyan_token_to_string
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/utils/wenyan_tokens.ml
- **位置**: 第 101-179 行
- **代码行数**: 77
- **总行数**: 79
- **复杂度指标**:
  - match_statements: 6
  - nested_functions: 2
  - pattern_matches: 69
  - exception_handling: 6
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### create_parse_state
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_json_core.ml
- **位置**: 第 147-248 行
- **代码行数**: 77
- **总行数**: 102
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 11
  - nested_functions: 20
  - pattern_matches: 7
  - exception_handling: 5
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### create_parse_state
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/rhyme_json_parser.ml
- **位置**: 第 40-143 行
- **代码行数**: 76
- **总行数**: 104
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 11
  - nested_functions: 19
  - pattern_matches: 7
  - exception_handling: 5
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### create_group_collections
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_token_reducer.ml
- **位置**: 第 212-294 行
- **代码行数**: 75
- **总行数**: 83
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 2
  - nested_functions: 15
  - pattern_matches: 8
  - exception_handling: 4
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### trimmed
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/data_loader_parser.ml
- **位置**: 第 21-110 行
- **代码行数**: 75
- **总行数**: 90
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 8
  - nested_functions: 20
  - pattern_matches: 16
  - exception_handling: 12
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### create_group_collections
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/utils/parser_expressions_token_reducer.ml
- **位置**: 第 212-294 行
- **代码行数**: 75
- **总行数**: 83
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 2
  - nested_functions: 15
  - pattern_matches: 8
  - exception_handling: 4
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### siyan_tone_patterns
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/tone_pattern.ml
- **位置**: 第 123-228 行
- **代码行数**: 75
- **总行数**: 106
- **复杂度指标**:
  - match_statements: 2
  - if_statements: 9
  - nested_functions: 25
  - pattern_matches: 4
  - exception_handling: 2
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### style_consistency_rules
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/chinese_best_practices/checkers/style_consistency_checker.ml
- **位置**: 第 11-98 行
- **代码行数**: 74
- **总行数**: 88
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 2
  - nested_functions: 12
  - pattern_matches: 6
  - exception_handling: 7
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### s
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/formatter_logging.ml
- **位置**: 第 102-198 行
- **代码行数**: 72
- **总行数**: 97
- **复杂度指标**:
  - if_statements: 1
  - nested_functions: 20
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### get_all_data
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/expanded_word_class_data.ml
- **位置**: 第 28-105 行
- **代码行数**: 72
- **总行数**: 78
- **复杂度指标**:
  - match_statements: 8
  - nested_functions: 11
  - pattern_matches: 47
  - exception_handling: 8
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### analyze_expr_recursively
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/performance_analyzer_base.ml
- **位置**: 第 13-92 行
- **代码行数**: 71
- **总行数**: 80
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 1
  - nested_functions: 12
  - pattern_matches: 6
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### map_misc_keywords
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_compatibility_unified.ml
- **位置**: 第 158-240 行
- **代码行数**: 71
- **总行数**: 83
- **复杂度指标**:
  - match_statements: 14
  - if_statements: 2
  - nested_functions: 14
  - pattern_matches: 35
  - exception_handling: 16
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### s_start
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/poetry_json_parser.ml
- **位置**: 第 18-100 行
- **代码行数**: 71
- **总行数**: 83
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 11
  - nested_functions: 20
  - pattern_matches: 11
  - exception_handling: 9
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### position
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/utils/token_utils_core.ml
- **位置**: 第 9-86 行
- **代码行数**: 70
- **总行数**: 78
- **复杂度指标**:
  - match_statements: 2
  - nested_functions: 4
  - pattern_matches: 63
  - exception_handling: 2
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构

### imagery_keywords
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_data_loader.ml
- **位置**: 第 107-181 行
- **代码行数**: 69
- **总行数**: 75
- **复杂度指标**:
  - if_statements: 1
  - nested_functions: 3
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### arr_list
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_advanced_ops.ml
- **位置**: 第 14-111 行
- **代码行数**: 67
- **总行数**: 98
- **复杂度指标**:
  - match_statements: 6
  - nested_functions: 16
  - pattern_matches: 25
  - exception_handling: 6
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### is_special_keyword_token
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_special.ml
- **位置**: 第 18-106 行
- **代码行数**: 67
- **总行数**: 89
- **复杂度指标**:
  - match_statements: 4
  - nested_functions: 13
  - pattern_matches: 18
  - exception_handling: 13
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### convert_ancient_record_tokens
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_conversion_classical.ml
- **位置**: 第 138-215 行
- **代码行数**: 67
- **总行数**: 78
- **复杂度指标**:
  - match_statements: 2
  - nested_functions: 12
  - pattern_matches: 19
  - exception_handling: 12
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### state1
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_operators.ml
- **位置**: 第 44-145 行
- **代码行数**: 66
- **总行数**: 102
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 1
  - nested_functions: 18
  - pattern_matches: 16
  - exception_handling: 10
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### default_processor
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_token_reducer.ml
- **位置**: 第 121-192 行
- **代码行数**: 66
- **总行数**: 72
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 1
  - nested_functions: 8
  - pattern_matches: 29
  - exception_handling: 4
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### get_error_config
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/compiler_errors.ml
- **位置**: 第 85-176 行
- **代码行数**: 66
- **总行数**: 92
- **复杂度指标**:
  - match_statements: 3
  - if_statements: 3
  - nested_functions: 20
  - pattern_matches: 14
  - exception_handling: 7
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### english_bool_table
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/mapping/literal_mapping.ml
- **位置**: 第 85-182 行
- **代码行数**: 66
- **总行数**: 98
- **复杂度指标**:
  - match_statements: 11
  - if_statements: 5
  - nested_functions: 18
  - pattern_matches: 24
  - exception_handling: 15
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### default_processor
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/utils/parser_expressions_token_reducer.ml
- **位置**: 第 121-192 行
- **代码行数**: 66
- **总行数**: 72
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 1
  - nested_functions: 8
  - pattern_matches: 29
  - exception_handling: 4
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### evaluators
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_evaluator_comprehensive.ml
- **位置**: 第 16-104 行
- **代码行数**: 66
- **总行数**: 89
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 1
  - nested_functions: 11
  - pattern_matches: 6
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### config_key_table
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/config/config_loader.ml
- **位置**: 第 49-138 行
- **代码行数**: 66
- **总行数**: 90
- **复杂度指标**:
  - match_statements: 3
  - if_statements: 5
  - nested_functions: 24
  - pattern_matches: 8
  - exception_handling: 11
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### string_ops
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/binary_operations.ml
- **位置**: 第 38-117 行
- **代码行数**: 65
- **总行数**: 80
- **复杂度指标**:
  - match_statements: 10
  - if_statements: 1
  - nested_functions: 9
  - pattern_matches: 30
  - exception_handling: 10
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### chars1
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/parallelism_analysis.ml
- **位置**: 第 82-156 行
- **代码行数**: 65
- **总行数**: 75
- **复杂度指标**:
  - if_statements: 5
  - nested_functions: 18
  - pattern_matches: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### form_to_string
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_types.ml
- **位置**: 第 102-178 行
- **代码行数**: 65
- **总行数**: 77
- **复杂度指标**:
  - if_statements: 3
  - nested_functions: 18
  - pattern_matches: 6
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### luoyan_unit
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/formatter_codegen.ml
- **位置**: 第 32-136 行
- **代码行数**: 64
- **总行数**: 105
- **复杂度指标**:
  - if_statements: 2
  - loop_statements: 2
  - nested_functions: 32
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### to_bool_value
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/value_operations_basic.ml
- **位置**: 第 182-258 行
- **代码行数**: 64
- **总行数**: 77
- **复杂度指标**:
  - match_statements: 8
  - nested_functions: 2
  - pattern_matches: 34
  - exception_handling: 9
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### ai_friendly_rules
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/chinese_best_practices/checkers/ai_friendly_checker.ml
- **位置**: 第 16-92 行
- **代码行数**: 64
- **总行数**: 77
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 2
  - nested_functions: 9
  - pattern_matches: 5
  - exception_handling: 5
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### default_imagery_keywords
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/artistic_data_loader.ml
- **位置**: 第 102-170 行
- **代码行数**: 64
- **总行数**: 69
- **复杂度指标**:
  - nested_functions: 2

### convert_module_type_to_typ
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/types_convert.ml
- **位置**: 第 113-185 行
- **代码行数**: 63
- **总行数**: 73
- **复杂度指标**:
  - match_statements: 4
  - nested_functions: 16
  - pattern_matches: 24
  - exception_handling: 4
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### execute_stmt
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/codegen.ml
- **位置**: 第 74-151 行
- **代码行数**: 63
- **总行数**: 78
- **复杂度指标**:
  - match_statements: 6
  - nested_functions: 7
  - pattern_matches: 32
  - exception_handling: 6
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### create
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/core/token_registry.ml
- **位置**: 第 15-111 行
- **代码行数**: 63
- **总行数**: 97
- **复杂度指标**:
  - match_statements: 5
  - nested_functions: 18
  - pattern_matches: 22
  - exception_handling: 5
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### char_escape_table
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/c_codegen_context.ml
- **位置**: 第 61-134 行
- **代码行数**: 62
- **总行数**: 74
- **复杂度指标**:
  - match_statements: 2
  - if_statements: 4
  - loop_statements: 2
  - nested_functions: 8
  - pattern_matches: 8
  - exception_handling: 4
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### classical_style_rules
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/chinese_best_practices/checkers/classical_style_checker.ml
- **位置**: 第 11-85 行
- **代码行数**: 62
- **总行数**: 75
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 2
  - nested_functions: 9
  - pattern_matches: 4
  - exception_handling: 5
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### convert_ancient_keywords
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer_token_conversion_basic_keywords.ml
- **位置**: 第 113-176 行
- **代码行数**: 61
- **总行数**: 64
- **复杂度指标**:
  - nested_functions: 2
  - pattern_matches: 41
  - exception_handling: 19
- **重构建议**:
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### generate_performance_report
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_conversion_benchmark.ml
- **位置**: 第 123-203 行
- **代码行数**: 61
- **总行数**: 81
- **复杂度指标**:
  - if_statements: 6
  - nested_functions: 11
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### count
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/refactoring_analyzer_duplication.ml
- **位置**: 第 17-85 行
- **代码行数**: 61
- **总行数**: 69
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 1
  - nested_functions: 15
  - pattern_matches: 13
  - exception_handling: 2
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构

### expect_token
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser.ml
- **位置**: 第 34-103 行
- **代码行数**: 60
- **总行数**: 70
- **复杂度指标**:
  - match_statements: 4
  - if_statements: 5
  - nested_functions: 26
  - pattern_matches: 12
  - exception_handling: 6
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### guard_result
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/pattern_matcher.ml
- **位置**: 第 57-129 行
- **代码行数**: 60
- **总行数**: 73
- **复杂度指标**:
  - match_statements: 11
  - if_statements: 2
  - nested_functions: 8
  - pattern_matches: 23
  - exception_handling: 14
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### convert_ancient_keywords
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/keyword_converter.ml
- **位置**: 第 134-198 行
- **代码行数**: 60
- **总行数**: 65
- **复杂度指标**:
  - nested_functions: 4
  - pattern_matches: 46
  - exception_handling: 7
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### c3
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/utf8_utils.ml
- **位置**: 第 43-136 行
- **代码行数**: 60
- **总行数**: 94
- **复杂度指标**:
  - match_statements: 2
  - if_statements: 9
  - nested_functions: 21
  - pattern_matches: 5
  - exception_handling: 4
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### hui_yun_traditional_series
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/data/rhyme_groups/ze_sheng/hui_rhyme_data.ml
- **位置**: 第 208-276 行
- **代码行数**: 60
- **总行数**: 69
- **复杂度指标**:
  - match_statements: 2
  - nested_functions: 16
  - pattern_matches: 15
  - exception_handling: 4
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### get_timestamp
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/logging/log_core.ml
- **位置**: 第 85-190 行
- **代码行数**: 60
- **总行数**: 106
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 10
  - loop_statements: 1
  - nested_functions: 34
  - pattern_matches: 3
  - exception_handling: 1
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### error_msg
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_identifiers.ml
- **位置**: 第 26-101 行
- **代码行数**: 59
- **总行数**: 76
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 2
  - nested_functions: 24
  - pattern_matches: 10
  - exception_handling: 3
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### convert_ancient_keywords
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_conversion_keywords.ml
- **位置**: 第 114-178 行
- **代码行数**: 58
- **总行数**: 65
- **复杂度指标**:
  - match_statements: 2
  - nested_functions: 6
  - pattern_matches: 36
  - exception_handling: 4
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### keyword_token_to_string
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/utils/keyword_tokens.ml
- **位置**: 第 92-151 行
- **代码行数**: 58
- **总行数**: 60
- **复杂度指标**:
  - match_statements: 7
  - nested_functions: 2
  - pattern_matches: 51
  - exception_handling: 7
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### sorted_distances
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/interpreter_utils.ml
- **位置**: 第 17-91 行
- **代码行数**: 57
- **总行数**: 75
- **复杂度指标**:
  - match_statements: 7
  - if_statements: 2
  - nested_functions: 11
  - pattern_matches: 21
  - exception_handling: 15
- **重构建议**:
  - 考虑将复杂的match表达式拆分为多个辅助函数
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### value
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/statement_executor.ml
- **位置**: 第 13-84 行
- **代码行数**: 57
- **总行数**: 72
- **复杂度指标**:
  - match_statements: 3
  - nested_functions: 12
  - pattern_matches: 21
  - exception_handling: 6
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### state1
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_identifiers.ml
- **位置**: 第 108-190 行
- **代码行数**: 57
- **总行数**: 83
- **复杂度指标**:
  - match_statements: 2
  - nested_functions: 24
  - pattern_matches: 13
  - exception_handling: 4
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### vars_str
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/formatter_errors.ml
- **位置**: 第 21-108 行
- **代码行数**: 55
- **总行数**: 88
- **复杂度指标**:
  - nested_functions: 28
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### create_state
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_data_unified.ml
- **位置**: 第 114-177 行
- **代码行数**: 55
- **总行数**: 64
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 8
  - nested_functions: 11
  - pattern_matches: 5
  - exception_handling: 3
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### to_string
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/tokens/wenyan_keywords.ml
- **位置**: 第 58-112 行
- **代码行数**: 54
- **总行数**: 55
- **复杂度指标**:
  - nested_functions: 2
  - pattern_matches: 52
- **重构建议**:
  - 模式匹配过多，考虑使用数据结构重构

### is_data_loaded
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_rhyme_data.ml
- **位置**: 第 225-287 行
- **代码行数**: 54
- **总行数**: 63
- **复杂度指标**:
  - if_statements: 1
  - nested_functions: 15
  - pattern_matches: 22
  - exception_handling: 2
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构

### show_help
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/main.ml
- **位置**: 第 44-105 行
- **代码行数**: 53
- **总行数**: 62
- **复杂度指标**:
  - match_statements: 2
  - if_statements: 3
  - nested_functions: 5
  - pattern_matches: 14
  - exception_handling: 11
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### convert_ancient_token
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer_token_conversion_classical.ml
- **位置**: 第 57-112 行
- **代码行数**: 53
- **总行数**: 56
- **复杂度指标**:
  - nested_functions: 4
  - pattern_matches: 41
  - exception_handling: 8
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### get_timestamp
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/logger.ml
- **位置**: 第 66-139 行
- **代码行数**: 53
- **总行数**: 74
- **复杂度指标**:
  - if_statements: 7
  - nested_functions: 36
  - exception_handling: 3
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### create_expression_processor
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_token_reducer.ml
- **位置**: 第 298-353 行
- **代码行数**: 53
- **总行数**: 56
- **复杂度指标**:
  - match_statements: 1
  - nested_functions: 8
  - pattern_matches: 4
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### from_string
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/tokens/wenyan_keywords.ml
- **位置**: 第 112-165 行
- **代码行数**: 53
- **总行数**: 54
- **复杂度指标**:
  - nested_functions: 2
  - pattern_matches: 51
- **重构建议**:
  - 模式匹配过多，考虑使用数据结构重构

### create_expression_processor
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/utils/parser_expressions_token_reducer.ml
- **位置**: 第 298-353 行
- **代码行数**: 53
- **总行数**: 56
- **复杂度指标**:
  - match_statements: 1
  - nested_functions: 8
  - pattern_matches: 4
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### line_diff
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/formatter_tokens.ml
- **位置**: 第 171-226 行
- **代码行数**: 52
- **总行数**: 56
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 4
  - nested_functions: 5
  - pattern_matches: 2
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### validate_mapping_result
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer/token_mapping/unified_token_mapper.ml
- **位置**: 第 271-332 行
- **代码行数**: 52
- **总行数**: 62
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 1
  - loop_statements: 1
  - nested_functions: 18
  - pattern_matches: 4
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### validate_mapping_result
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/token_system_unified/mapping/unified_token_mapper.ml
- **位置**: 第 271-332 行
- **代码行数**: 52
- **总行数**: 62
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 1
  - loop_statements: 1
  - nested_functions: 18
  - pattern_matches: 4
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### an_yun_ping_sheng_chars
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_data_original.ml
- **位置**: 第 30-82 行
- **代码行数**: 52
- **总行数**: 53
- **复杂度指标**:
  - nested_functions: 2

### tian_yun_ping_sheng_chars
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_data_original.ml
- **位置**: 第 218-270 行
- **代码行数**: 52
- **总行数**: 53
- **复杂度指标**:
  - nested_functions: 2

### type_keyword_mapping
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/parser_expressions_constructs.ml
- **位置**: 第 45-110 行
- **代码行数**: 51
- **总行数**: 66
- **复杂度指标**:
  - match_statements: 2
  - if_statements: 1
  - nested_functions: 18
  - pattern_matches: 6
  - exception_handling: 4
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### generate_builtin_bindings
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/c_codegen_statements.ml
- **位置**: 第 66-124 行
- **代码行数**: 51
- **总行数**: 59
- **复杂度指标**:
  - nested_functions: 16
  - pattern_matches: 3
  - exception_handling: 2
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### comprehensive_artistic_evaluation
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/poetry_artistic_engine.ml
- **位置**: 第 199-268 行
- **代码行数**: 51
- **总行数**: 70
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 5
  - nested_functions: 15
  - pattern_matches: 6
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数

### analyze_verse
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_api.ml
- **位置**: 第 113-178 行
- **代码行数**: 51
- **总行数**: 66
- **复杂度指标**:
  - match_statements: 2
  - if_statements: 2
  - nested_functions: 15
  - pattern_matches: 4
  - exception_handling: 4
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### analyze_poem
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/core/rhyme_core_api.ml
- **位置**: 第 178-243 行
- **代码行数**: 51
- **总行数**: 66
- **复杂度指标**:
  - if_statements: 6
  - nested_functions: 13
- **重构建议**:
  - 考虑使用模式匹配或策略模式减少if-else链
  - 考虑将嵌套函数提取为独立的顶级函数

### is_valid_identifier
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer_utils.ml
- **位置**: 第 16-82 行
- **代码行数**: 50
- **总行数**: 67
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 4
  - nested_functions: 14
  - pattern_matches: 7
  - exception_handling: 6
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### format_basic_type
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/core_types.ml
- **位置**: 第 76-137 行
- **代码行数**: 50
- **总行数**: 62
- **复杂度指标**:
  - match_statements: 2
  - nested_functions: 8
  - pattern_matches: 13
  - exception_handling: 3
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 模式匹配过多，考虑使用数据结构重构

### create_unsupported_char_error
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/lexer_utils_modular.ml
- **位置**: 第 18-84 行
- **代码行数**: 50
- **总行数**: 67
- **复杂度指标**:
  - match_statements: 1
  - if_statements: 4
  - nested_functions: 14
  - pattern_matches: 7
  - exception_handling: 6
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
  - 异常处理逻辑复杂，考虑使用Result类型或错误处理模块

### overall_score
- **文件**: /home/zc/chinese-ocaml-worktrees/chinese-ocaml/src/poetry/form_evaluators.ml
- **位置**: 第 135-194 行
- **代码行数**: 50
- **总行数**: 60
- **复杂度指标**:
  - if_statements: 4
  - nested_functions: 16
  - exception_handling: 1
- **重构建议**:
  - 考虑将嵌套函数提取为独立的顶级函数
