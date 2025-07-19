(*
 * 内置函数公共工具模块接口
 * Phase 15.3: 内置函数重构的核心组件
 *)

open Value_operations

(** 字符串处理工具函数 *)

(** 字符串反转工具函数 *)
val reverse_string : string -> string

(** 参数验证助手函数 *)

(** 单参数验证助手 *)
val validate_single_param : (runtime_value -> string -> 'a) -> runtime_value list -> string -> 'a

(** 双参数验证助手 *)
val validate_double_params : (runtime_value -> string -> 'a) -> (runtime_value -> string -> 'b) -> runtime_value list -> string -> 'a * 'b

(** 通用长度计算函数 *)
val get_length_value : runtime_value -> runtime_value

(** 柯里化函数包装器 *)
val create_binary_function : (runtime_value -> string -> 'a) -> (runtime_value -> string -> 'b) -> ('a -> 'b -> runtime_value) -> string -> runtime_value list -> runtime_value

(** 集合操作模板 *)
type collection_type = [`String of string | `List of runtime_value list | `Array of runtime_value array]

val apply_to_collection : (collection_type -> 'a) -> runtime_value -> 'a

(** 数值聚合器模板 *)
val create_aggregator : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a