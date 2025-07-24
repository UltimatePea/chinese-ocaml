(** 骆言编译器基础字符串操作模块接口

    此模块提供基础字符串拼接和转换函数，是所有格式化模块的基础设施。

    设计原则:
    - 零Printf.sprintf依赖：不使用Printf.sprintf进行格式化
    - 高性能字符串操作：使用优化的字符串拼接算法
    - 类型安全：提供类型安全的数据转换接口
    - 通用性：适用于所有格式化场景的基础工具

    用途：为error_formatters、position_formatters等专门模块提供基础字符串操作 *)

(** 基础字符串操作工具模块 *)
module Base_string_ops : sig
  (** 基础字符串拼接函数 *)
  val concat_strings : string list -> string

  (** 带分隔符的字符串拼接 *)
  val join_with_separator : string -> string list -> string

  (** 基础类型转换函数 *)
  val int_to_string : int -> string
  val float_to_string : float -> string
  val bool_to_string : bool -> string
  val char_to_string : char -> string

  (** 高级模板替换函数（用于复杂场景） *)
  val template_replace : string -> (string * string) list -> string

  (** 列表格式化 - 方括号包围，分号分隔 *)
  val list_format : string list -> string
end

(** 导出的顶层函数 *)

(** 基础字符串拼接函数 *)
val concat_strings : string list -> string

(** 带分隔符的字符串拼接 *)
val join_with_separator : string -> string list -> string

(** 基础类型转换函数 *)
val int_to_string : int -> string
val float_to_string : float -> string
val bool_to_string : bool -> string
val char_to_string : char -> string

(** 高级模板替换函数（用于复杂场景） *)
val template_replace : string -> (string * string) list -> string

(** 列表格式化 - 方括号包围，分号分隔 *)
val list_format : string list -> string