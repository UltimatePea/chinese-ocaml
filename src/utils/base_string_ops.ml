(** 骆言编译器基础字符串操作模块

    此模块提供基础字符串拼接和转换函数，是所有格式化模块的基础设施。

    设计原则:
    - 零Printf.sprintf依赖：不使用Printf.sprintf进行格式化
    - 高性能字符串操作：使用优化的字符串拼接算法
    - 类型安全：提供类型安全的数据转换接口
    - 通用性：适用于所有格式化场景的基础工具

    用途：为error_formatters、position_formatters等专门模块提供基础字符串操作 *)

(** 基础字符串操作工具模块 *)
module Base_string_ops = struct
  (** 基础字符串拼接函数 *)
  let concat_strings parts = String.concat "" parts

  (** 带分隔符的字符串拼接 *)
  let join_with_separator sep parts = String.concat sep parts

  (** 基础类型转换函数 *)
  let int_to_string = string_of_int

  let float_to_string = string_of_float
  let bool_to_string = string_of_bool
  let char_to_string c = String.make 1 c

  (** 高级模板替换函数（用于复杂场景） *)
  let template_replace template replacements =
    List.fold_left
      (fun acc (placeholder, value) -> Str.global_replace (Str.regexp_string placeholder) value acc)
      template replacements

  (** 列表格式化 - 方括号包围，分号分隔 *)
  let list_format items = concat_strings [ "["; join_with_separator "; " items; "]" ]
end

include Base_string_ops
(** 导出常用函数到顶层，便于使用 *)