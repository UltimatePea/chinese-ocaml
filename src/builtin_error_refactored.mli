(** 骆言内置函数错误处理模块接口 - 重构版本示例

    演示如何使用新的通用工具模块消除代码重复

    重构前: 89行代码，大量重复的let绑定和错误处理模式 重构后: ~50行代码，使用统一的工具函数

    Phase 7 技术债务清理 - 代码重复消除示例

    @author Beta, 代码审查代理
    @version 2.0 - 重构版本
    @since 2025-07-27 - Fix #1429 *)

open Value_operations

val make_builtin_error_context : Utils.Error_handling_utils.error_context
(** 模块错误上下文创建器 *)

val runtime_error : string -> 'a
(** 错误处理辅助函数 *)

val safe_check_args_count : int -> int -> string -> unit
(** 安全的参数计数检查 *)

val safe_check_positive_number : 'a -> string -> 'a
(** 安全的正数检查 *)

val safe_numeric_divide : float -> float -> string -> float
(** 安全的数值除法 *)

val check_args_count : int -> int -> string -> unit
(** 参数计数检查 *)

val check_args_with_pattern : [< `None | `Single | `Double ] -> 'a list -> string -> unit
(** 参数模式检查 *)

val check_single_arg : 'a list -> string -> unit
(** 单参数检查 *)

val check_double_args : 'a list -> string -> unit
(** 双参数检查 *)

val check_no_args : 'a list -> string -> unit
(** 无参数检查 *)

val validate_type_with_context : ('a -> bool) -> string -> 'a -> 'a
(** 类型验证函数 *)

val expect_string : string -> Value_operations.value -> Value_operations.value
val expect_int : string -> Value_operations.value -> Value_operations.value
val expect_float : string -> Value_operations.value -> Value_operations.value
val expect_bool : string -> Value_operations.value -> Value_operations.value
val expect_list : string -> Value_operations.value -> Value_operations.value
val expect_array : string -> Value_operations.value -> Value_operations.value
val expect_builtin_function : string -> Value_operations.value -> Value_operations.value
val expect_number : string -> Value_operations.value -> Value_operations.value
val expect_string_or_list : string -> Value_operations.value -> Value_operations.value

val expect_nonempty_list : Value_operations.value -> string -> Value_operations.value
(** 非空列表验证 *)

val handle_file_error : string -> string -> (unit -> 'a) -> 'a
(** 文件错误处理 *)

val handle_higher_order_error :
  string -> (Value_operations.value -> 'a) -> Value_operations.value -> 'a
(** 高阶函数错误处理 *)

val check_array_bounds : int -> int -> string -> unit
(** 数组边界检查 *)

val expect_non_negative : Value_operations.value -> string -> Value_operations.value
(** 非负数检查 *)

val refactoring_stats : string * int * int
(** 重构统计信息 *)
