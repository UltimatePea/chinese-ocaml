(** 骆言词法分析器核心模块 - 统一错误处理版本 *)

open Token_types
open Compiler_errors
open Lexer_error_adapter

(** 重新导出类型定义 *)
type lexer_state = Lexer_core.lexer_state

(** 统一错误处理的词法分析函数 *)

(** 创建词法分析器状态 *)
val create_lexer_state : string -> string -> lexer_state

(** 获取当前字符 *)
val current_char : lexer_state -> char option

(** 前进状态 *)
val advance : lexer_state -> lexer_state

(** 跳过空白字符和注释 - 使用统一错误处理 *)
val skip_whitespace_and_comments : lexer_state -> lexer_state lex_result

(** 读取字符串字面量 - 使用统一错误处理 *)
val read_string_literal : lexer_state -> (token * position * lexer_state) lex_result

(** 读取引用标识符 - 使用统一错误处理 *)
val read_quoted_identifier : lexer_state -> (token * position * lexer_state) lex_result

(** 包装原始词法分析函数以支持统一错误处理 *)
val safe_tokenize : string -> string -> (token * position) list lex_result

(** 兼容性函数：将统一错误处理结果转换为异常 *)
val tokenize_with_exceptions : string -> string -> (token * position) list

(** 错误恢复式词法分析 *)
val tokenize_with_recovery : string -> string -> (token * position) list * error_info option

(** 分析错误模式并提供建议 *)
val analyze_error_pattern : error_info -> error_info