(** 骆言字符串格式化工具模块 - String Formatting Utilities *)

(** C代码生成格式化工具 *)
module CCodegen = struct
  (** 格式化函数调用 *)
  let format_function_call func_name args =
    Printf.sprintf "%s(%s)" func_name (String.concat ", " args)

  (** 格式化二元运算 *)
  let format_binary_op op_name left right =
    Printf.sprintf "%s(%s, %s)" op_name left right

  (** 格式化一元运算 *)
  let format_unary_op op_name operand = Printf.sprintf "%s(%s)" op_name operand

  (** 格式化变量绑定 *)
  let format_var_binding var_name value =
    Printf.sprintf "luoyan_bind_var(\"%s\", %s)" var_name value

  (** 格式化字符串字面量 *)
  let format_string_literal s =
    Printf.sprintf "luoyan_string(\"%s\")" (String.escaped s)

  (** 格式化整数字面量 *)
  let format_int_literal i = Printf.sprintf "luoyan_int(%d)" i

  (** 格式化浮点数字面量 *)
  let format_float_literal f = Printf.sprintf "luoyan_float(%g)" f

  (** 格式化布尔字面量 *)
  let format_bool_literal b =
    Printf.sprintf "luoyan_bool(%s)" (if b then "true" else "false")

  (** 格式化单元字面量 *)
  let format_unit_literal () = "luoyan_unit()"

  (** 格式化等值比较 *)
  let format_equality_check expr_var value =
    Printf.sprintf "luoyan_equals(%s, %s)" expr_var value

  (** 格式化let表达式 *)
  let format_let_expr var_name value_code body_code =
    Printf.sprintf "luoyan_let(\"%s\", %s, %s)" var_name value_code body_code

  (** 格式化函数定义 *)
  let format_function_def func_name first_param =
    Printf.sprintf "luoyan_function_create(%s_impl_%s, env, \"%s\")" func_name
      first_param func_name

  (** 格式化模式匹配 *)
  let format_pattern_match expr_var =
    Printf.sprintf "luoyan_pattern_match(%s)" expr_var

  (** 格式化变量表达式 *)
  let format_var_expr expr_var expr_code =
    Printf.sprintf "({ luoyan_value_t* %s = %s; luoyan_match(%s); })" expr_var
      expr_code expr_var
end

(** 错误消息格式化工具 *)
module ErrorMessages = struct
  (** 格式化参数数量不匹配错误 *)
  let format_param_count_mismatch expected actual =
    Printf.sprintf "函数期望%d个参数，提供了%d个" expected actual

  (** 格式化参数缺失填充消息 *)
  let format_missing_params_filled expected actual missing =
    Printf.sprintf "函数期望%d个参数，提供了%d个，用默认值填充缺失的%d个参数" expected actual missing

  (** 格式化多余参数忽略消息 *)
  let format_extra_params_ignored expected actual extra =
    Printf.sprintf "函数期望%d个参数，提供了%d个，忽略多余的%d个参数" expected actual extra

  (** 格式化意外词元错误 *)
  let format_unexpected_token token = Printf.sprintf "意外的词元: %s" token

  (** 格式化语法错误 *)
  let format_syntax_error msg position =
    Printf.sprintf "语法错误: %s (位置: %s)" msg position

  (** 格式化类型错误 *)
  let format_type_error expected actual =
    Printf.sprintf "类型错误: 期望 %s，实际 %s" expected actual
end

(** 日志格式化工具 *)
module LogMessages = struct
  (** 格式化调试消息 *)
  let format_debug_message module_name message =
    Printf.sprintf "[DEBUG] %s: %s" module_name message

  (** 格式化信息消息 *)
  let format_info_message module_name message =
    Printf.sprintf "[INFO] %s: %s" module_name message

  (** 格式化警告消息 *)
  let format_warning_message module_name message =
    Printf.sprintf "[WARNING] %s: %s" module_name message

  (** 格式化错误消息 *)
  let format_error_message module_name message =
    Printf.sprintf "[ERROR] %s: %s" module_name message
end

(** 通用格式化工具 *)
module General = struct
  (** 格式化标识符 *)
  let format_identifier name = Printf.sprintf "「%s」" name

  (** 格式化函数签名 *)
  let format_function_signature name params =
    Printf.sprintf "%s(%s)" name (String.concat ", " params)

  (** 格式化类型签名 *)
  let format_type_signature name type_params =
    Printf.sprintf "%s<%s>" name (String.concat ", " type_params)

  (** 格式化模块路径 *)
  let format_module_path path = String.concat "." path

  (** 格式化列表 *)
  let format_list items separator = String.concat separator items

  (** 格式化键值对 *)
  let format_key_value key value = Printf.sprintf "%s: %s" key value
end
