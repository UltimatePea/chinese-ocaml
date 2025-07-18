(** 编译阶段处理模块接口 - Phase 8.3 技术债务清理 *)

open Types
open Lexer_tokens
open Compiler_config
open Ast

(** 词法分析阶段 *)
val perform_lexical_analysis : compile_options -> string -> (token * position) list

(** 语法分析阶段 *)
val perform_syntax_analysis : compile_options -> (token * position) list -> program

(** 语义分析阶段 *)
val perform_semantic_analysis : compile_options -> program -> bool

(** C代码生成阶段 *)
val perform_c_code_generation : compile_options -> program -> bool

(** 解释执行阶段 *)
val perform_interpretation : compile_options -> program -> bool

(** 恢复模式下的解释执行 *)
val perform_recovery_interpretation : compile_options -> program -> bool

(** 决定编译执行模式 *)
val determine_execution_mode : compile_options -> bool -> program -> bool