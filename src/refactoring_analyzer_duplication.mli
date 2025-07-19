(** 重复代码检测分析器模块接口 *)

open Ast
open Refactoring_analyzer_types

type expression_pattern = {
  pattern_name : string;
  pattern_signature : string;
  complexity_weight : int;
}
(** 表达式模式类型 *)

val extract_expression_pattern : expr -> expression_pattern
(** 提取表达式的结构模式 *)

val detect_simple_duplication : expr list -> refactoring_suggestion list
(** 检测简单的重复代码模式 *)

val detect_structural_duplication : expr list -> refactoring_suggestion list
(** 检测结构相似的重复代码 *)

val detect_function_duplication : (string * expr) list -> refactoring_suggestion list
(** 检测函数级别的重复 *)

val detect_code_clones : expr list -> refactoring_suggestion list
(** 检测克隆代码 *)

val detect_code_duplication : expr list -> refactoring_suggestion list
(** 综合重复代码检测 *)

val analyze_duplication_impact : refactoring_suggestion list -> int * int * int
(** 分析重复代码的影响 *)

val generate_duplication_report : refactoring_suggestion list -> string
(** 生成重复代码分析报告 *)
