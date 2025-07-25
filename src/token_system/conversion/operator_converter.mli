(** 骆言编译器 - 操作符和分隔符转换器接口
    
    @author Alpha, 技术债务清理专员
    @version 2.0
    @since 2025-07-25
    @issue #1353 *)

open Token_system_core.Token_types
open Token_system_core.Token_errors
open Token_converter

(** 操作符转换器实例 *)
val operator_converter : (module CONVERTER)

(** 分隔符转换器实例 *)
val delimiter_converter : (module CONVERTER)

(** 获取操作符优先级和结合性信息 *)
val get_operator_precedence_info : token -> precedence * associativity

(** 操作符类型检查 *)
val is_binary_operator : token -> bool
val is_unary_operator : token -> bool
val is_comparison_operator : token -> bool
val is_arithmetic_operator : token -> bool
val is_logical_operator : token -> bool

(** 括号匹配检查 *)
val check_bracket_matching : token list -> unit token_result

(** 获取操作符和分隔符统计信息 *)
val get_operator_delimiter_stats : token list -> (string * int) list