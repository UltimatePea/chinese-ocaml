(** C代码生成格式化模块

    本模块专门处理C代码生成时的字符串格式化， 提供统一的C代码生成工具函数。

    @author 骆言技术债务清理团队
    @version 1.0
    @since 2025-07-20 Issue #708 重构 *)

(** 函数调用格式 *)
let function_call func_name args =
  let args_str = String.concat ", " args in
  Printf.sprintf "%s(%s)" func_name args_str

(** 双参数函数调用 *)
let binary_function_call func_name e1_code e2_code =
  Printf.sprintf "%s(%s, %s)" func_name e1_code e2_code

(** 字符串相等性检查 *)
let string_equality_check expr_var escaped_string =
  Printf.sprintf "luoyan_equals(%s, luoyan_string(\"%s\"))" expr_var escaped_string

(** 类型转换 *)
let type_conversion target_type expr = Printf.sprintf "(%s)%s" target_type expr

