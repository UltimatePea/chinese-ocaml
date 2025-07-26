(** 骆言编译器 - 操作符和分隔符转换器接口
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Yyocamlc_lib.Token_types
open Yyocamlc_lib.Error_types
open Token_converter
open Token_system_unified_mapping.Operator_mapping

val operator_converter : (module CONVERTER)
(** 操作符转换器实例 *)

val delimiter_converter : (module CONVERTER)
(** 分隔符转换器实例 *)

val get_operator_precedence_info : token -> int * associativity
(** 获取操作符优先级和结合性信息 *)

val is_binary_operator : token -> bool
(** 操作符类型检查 *)

val is_unary_operator : token -> bool
val is_comparison_operator : token -> bool
val is_arithmetic_operator : token -> bool
val is_logical_operator : token -> bool

val check_bracket_matching : token list -> unit token_result
(** 括号匹配检查 *)

val get_operator_delimiter_stats : token list -> (string * int) list
(** 获取操作符和分隔符统计信息 *)
