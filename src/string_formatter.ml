(** 骆言字符串格式化工具模块 - String Formatting Utilities 

    重构说明：Printf.sprintf统一化Phase 3.2 - 完全消除Printf.sprintf依赖
    使用Base_formatter底层基础设施，实现零Printf.sprintf依赖的字符串格式化。
    
    @version 3.2 - Printf.sprintf统一化第三阶段
    @since 2025-07-24 Issue #1040 Printf.sprintf统一化 *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** C代码生成格式化工具 *)
module CCodegen = struct
  (** 格式化函数调用 - 使用Base_formatter消除Printf.sprintf *)
  let format_function_call func_name args =
    Base_formatter.function_call_format func_name args

  (** 格式化二元运算 - 使用Base_formatter消除Printf.sprintf *)
  let format_binary_op op_name left right =
    Base_formatter.function_call_format op_name [left; right]

  (** 格式化一元运算 - 使用Base_formatter消除Printf.sprintf *)
  let format_unary_op op_name operand = 
    Base_formatter.function_call_format op_name [operand]

  (** 格式化变量绑定 - 使用Base_formatter消除Printf.sprintf *)
  let format_var_binding var_name value =
    Base_formatter.luoyan_env_bind_pattern var_name value

  (** 格式化字符串字面量 - 使用Base_formatter消除Printf.sprintf *)
  let format_string_literal s =
    Base_formatter.luoyan_function_pattern "string" (Base_formatter.concat_strings ["\""; String.escaped s; "\""])

  (** 格式化整数字面量 - 使用Base_formatter消除Printf.sprintf *)
  let format_int_literal i = 
    Base_formatter.luoyan_function_pattern "int" (Base_formatter.int_to_string i)

  (** 格式化浮点数字面量 - 使用Base_formatter消除Printf.sprintf *)
  let format_float_literal f = 
    Base_formatter.luoyan_function_pattern "float" (Base_formatter.float_to_string f)

  (** 格式化布尔字面量 - 使用Base_formatter消除Printf.sprintf *)
  let format_bool_literal b =
    let bool_str = if b then "true" else "false" in
    Base_formatter.luoyan_function_pattern "bool" bool_str

  (** 格式化单元字面量 - 使用Base_formatter消除Printf.sprintf *)
  let format_unit_literal () = 
    Base_formatter.luoyan_function_pattern "unit" ""

  (** 格式化等值比较 - 使用Base_formatter消除Printf.sprintf *)
  let format_equality_check expr_var value =
    Base_formatter.function_call_format "luoyan_equals" [expr_var; value]

  (** 格式化let表达式 - 使用Base_formatter消除Printf.sprintf *)
  let format_let_expr var_name value_code body_code =
    let quoted_var = Base_formatter.concat_strings ["\""; var_name; "\""] in
    Base_formatter.function_call_format "luoyan_let" [quoted_var; value_code; body_code]

  (** 格式化函数定义 - 使用Base_formatter消除Printf.sprintf *)
  let format_function_def func_name first_param =
    let impl_name = Base_formatter.concat_strings [func_name; "_impl_"; first_param] in
    let func_str = Base_formatter.concat_strings ["\""; func_name; "\""] in
    Base_formatter.function_call_format "luoyan_function_create" [impl_name; "env"; func_str]

  (** 格式化模式匹配 - 使用Base_formatter消除Printf.sprintf *)
  let format_pattern_match expr_var =
    Base_formatter.function_call_format "luoyan_pattern_match" [expr_var]

  (** 格式化变量表达式 - 使用Base_formatter消除Printf.sprintf *)
  let format_var_expr expr_var expr_code =
    Base_formatter.concat_strings [
      "({ luoyan_value_t* "; expr_var; " = "; expr_code; "; luoyan_match("; expr_var; "); })"]
end

(** 错误消息格式化工具 - 使用Base_formatter消除Printf.sprintf *)
module ErrorMessages = struct
  (** 格式化参数数量不匹配错误 - 使用Base_formatter消除Printf.sprintf *)
  let format_param_count_mismatch expected actual =
    Base_formatter.concat_strings [
      "函数期望"; Base_formatter.int_to_string expected; "个参数，提供了"; 
      Base_formatter.int_to_string actual; "个"]

  (** 格式化参数缺失填充消息 - 使用Base_formatter消除Printf.sprintf *)
  let format_missing_params_filled expected actual missing =
    Base_formatter.concat_strings [
      "函数期望"; Base_formatter.int_to_string expected; "个参数，提供了";
      Base_formatter.int_to_string actual; "个，用默认值填充缺失的";
      Base_formatter.int_to_string missing; "个参数"]

  (** 格式化多余参数忽略消息 - 使用Base_formatter消除Printf.sprintf *)
  let format_extra_params_ignored expected actual extra =
    Base_formatter.concat_strings [
      "函数期望"; Base_formatter.int_to_string expected; "个参数，提供了";
      Base_formatter.int_to_string actual; "个，忽略多余的";
      Base_formatter.int_to_string extra; "个参数"]

  (** 格式化意外词元错误 - 使用Base_formatter消除Printf.sprintf *)
  let format_unexpected_token token = 
    Base_formatter.concat_strings ["意外的词元: "; token]

  (** 格式化语法错误 - 使用Base_formatter消除Printf.sprintf *)
  let format_syntax_error msg position =
    Base_formatter.concat_strings ["语法错误: "; msg; " (位置: "; position; ")"]

  (** 格式化类型错误 - 使用Base_formatter消除Printf.sprintf *)
  let format_type_error expected actual =
    Base_formatter.concat_strings ["类型错误: 期望 "; expected; "，实际 "; actual]
end

(** 日志格式化工具 - 使用Base_formatter消除Printf.sprintf *)
module LogMessages = struct
  (** 格式化调试消息 - 使用Base_formatter消除Printf.sprintf *)
  let format_debug_message module_name message =
    Base_formatter.concat_strings ["[DEBUG] "; module_name; ": "; message]

  (** 格式化信息消息 - 使用Base_formatter消除Printf.sprintf *)
  let format_info_message module_name message =
    Base_formatter.concat_strings ["[INFO] "; module_name; ": "; message]

  (** 格式化警告消息 - 使用Base_formatter消除Printf.sprintf *)
  let format_warning_message module_name message =
    Base_formatter.concat_strings ["[WARNING] "; module_name; ": "; message]

  (** 格式化错误消息 - 使用Base_formatter消除Printf.sprintf *)
  let format_error_message module_name message =
    Base_formatter.concat_strings ["[ERROR] "; module_name; ": "; message]
end

(** 通用格式化工具 - 使用Base_formatter消除Printf.sprintf *)
module General = struct
  (** 格式化标识符 - 使用Base_formatter消除Printf.sprintf *)
  let format_identifier name = 
    Base_formatter.concat_strings ["「"; name; "」"]

  (** 格式化函数签名 - 使用Base_formatter消除Printf.sprintf *)
  let format_function_signature name params =
    Base_formatter.function_call_format name params

  (** 格式化类型签名 - 使用Base_formatter消除Printf.sprintf *)
  let format_type_signature name type_params =
    let params_str = Base_formatter.join_with_separator ", " type_params in
    Base_formatter.concat_strings [name; "<"; params_str; ">"]

  (** 格式化模块路径 - 使用Base_formatter消除Printf.sprintf *)
  let format_module_path path = 
    Base_formatter.join_with_separator "." path

  (** 格式化列表 - 使用Base_formatter消除Printf.sprintf *)
  let format_list items separator = 
    Base_formatter.join_with_separator separator items

  (** 格式化键值对 - 使用Base_formatter消除Printf.sprintf *)
  let format_key_value key value = 
    Base_formatter.concat_strings [key; ": "; value]
end
