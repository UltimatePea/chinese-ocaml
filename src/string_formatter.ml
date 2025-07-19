(** 骆言字符串格式化工具模块 - String Formatting Utilities *)

(** C代码生成格式化工具 *)
module CCodegen = struct
  (** 格式化函数调用 *)
  let format_function_call func_name args =
    Unified_logger.Legacy.sprintf "%s(%s)" func_name (String.concat ", " args)

  (** 格式化二元运算 *)
  let format_binary_op op_name left right =
    Unified_logger.Legacy.sprintf "%s(%s, %s)" op_name left right

  (** 格式化一元运算 *)
  let format_unary_op op_name operand =
    Unified_logger.Legacy.sprintf "%s(%s)" op_name operand

  (** 格式化变量绑定 *)
  let format_var_binding var_name value =
    Unified_logger.Legacy.sprintf "luoyan_bind_var(\"%s\", %s)" var_name value

  (** 格式化字符串字面量 *)
  let format_string_literal s =
    Unified_logger.Legacy.sprintf "luoyan_string(\"%s\")" (String.escaped s)

  (** 格式化整数字面量 *)
  let format_int_literal i =
    Unified_logger.Legacy.sprintf "luoyan_int(%d)" i

  (** 格式化浮点数字面量 *)
  let format_float_literal f =
    Unified_logger.Legacy.sprintf "luoyan_float(%g)" f

  (** 格式化布尔字面量 *)
  let format_bool_literal b =
    Unified_logger.Legacy.sprintf "luoyan_bool(%s)" (if b then "true" else "false")

  (** 格式化单元字面量 *)
  let format_unit_literal () =
    "luoyan_unit()"

  (** 格式化等值比较 *)
  let format_equality_check expr_var value =
    Unified_logger.Legacy.sprintf "luoyan_equals(%s, %s)" expr_var value

  (** 格式化let表达式 *)
  let format_let_expr var_name value_code body_code =
    Unified_logger.Legacy.sprintf "luoyan_let(\"%s\", %s, %s)" var_name value_code body_code

  (** 格式化函数定义 *)
  let format_function_def func_name first_param =
    Unified_logger.Legacy.sprintf "luoyan_function_create(%s_impl_%s, env, \"%s\")" func_name first_param func_name

  (** 格式化模式匹配 *)
  let format_pattern_match expr_var =
    Unified_logger.Legacy.sprintf "luoyan_pattern_match(%s)" expr_var

  (** 格式化变量表达式 *)
  let format_var_expr expr_var expr_code =
    Unified_logger.Legacy.sprintf "({ luoyan_value_t* %s = %s; luoyan_match(%s); })" expr_var expr_code expr_var
end

(** 错误消息格式化工具 *)
module ErrorMessages = struct
  (** 格式化参数数量不匹配错误 *)
  let format_param_count_mismatch expected actual =
    Unified_logger.Legacy.sprintf "函数期望%d个参数，提供了%d个" expected actual

  (** 格式化参数缺失填充消息 *)
  let format_missing_params_filled expected actual missing =
    Unified_logger.Legacy.sprintf "函数期望%d个参数，提供了%d个，用默认值填充缺失的%d个参数" expected actual missing

  (** 格式化多余参数忽略消息 *)
  let format_extra_params_ignored expected actual extra =
    Unified_logger.Legacy.sprintf "函数期望%d个参数，提供了%d个，忽略多余的%d个参数" expected actual extra

  (** 格式化意外词元错误 *)
  let format_unexpected_token token =
    Unified_logger.Legacy.sprintf "意外的词元: %s" token

  (** 格式化语法错误 *)
  let format_syntax_error msg position =
    Unified_logger.Legacy.sprintf "语法错误: %s (位置: %s)" msg position

  (** 格式化类型错误 *)
  let format_type_error expected actual =
    Unified_logger.Legacy.sprintf "类型错误: 期望 %s，实际 %s" expected actual
end

(** 日志格式化工具 *)
module LogMessages = struct
  (** 格式化调试消息 *)
  let format_debug_message module_name message =
    Unified_logger.Legacy.sprintf "[DEBUG] %s: %s" module_name message

  (** 格式化信息消息 *)
  let format_info_message module_name message =
    Unified_logger.Legacy.sprintf "[INFO] %s: %s" module_name message

  (** 格式化警告消息 *)
  let format_warning_message module_name message =
    Unified_logger.Legacy.sprintf "[WARNING] %s: %s" module_name message

  (** 格式化错误消息 *)
  let format_error_message module_name message =
    Unified_logger.Legacy.sprintf "[ERROR] %s: %s" module_name message
end

(** 通用格式化工具 *)
module General = struct
  (** 格式化标识符 *)
  let format_identifier name =
    Unified_logger.Legacy.sprintf "「%s」" name

  (** 格式化函数签名 *)
  let format_function_signature name params =
    Unified_logger.Legacy.sprintf "%s(%s)" name (String.concat ", " params)

  (** 格式化类型签名 *)
  let format_type_signature name type_params =
    Unified_logger.Legacy.sprintf "%s<%s>" name (String.concat ", " type_params)

  (** 格式化模块路径 *)
  let format_module_path path =
    String.concat "." path

  (** 格式化列表 *)
  let format_list items separator =
    String.concat separator items

  (** 格式化键值对 *)
  let format_key_value key value =
    Unified_logger.Legacy.sprintf "%s: %s" key value
end