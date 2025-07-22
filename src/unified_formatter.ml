(** 骆言编译器统一格式化工具 - Fix #853: Printf.sprintf模式统一优化

    此模块提供统一的字符串格式化接口，消除项目中Printf.sprintf重复使用。
    现已使用基础格式化器实现，零Printf.sprintf依赖。

    设计目标:
    - 统一错误消息格式（使用Base_formatter）
    - 标准化调试信息输出（零sprintf依赖）
    - 简化C代码生成格式化（高性能字符串拼接）
    - 提供一致的类型和参数错误报告（类型安全） *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** 错误消息统一格式化 *)
module ErrorMessages = struct
  (** 变量相关错误 *)
  let undefined_variable var_name = context_message_pattern "未定义的变量" var_name

  let variable_already_defined var_name = context_message_pattern "变量已定义" var_name

  let variable_suggestion var_name available_vars =
    let vars_str = join_with_separator "、" available_vars in
    concat_strings ["未定义的变量: "; var_name; "（可用变量: "; vars_str; "）"]

  (** 函数相关错误 *)
  let function_not_found func_name = context_message_pattern "函数未找到" func_name

  let function_param_count_mismatch func_name expected actual =
    concat_strings [
      "函数「"; func_name; "」参数数量不匹配: 期望 "; int_to_string expected; 
      " 个参数，但提供了 "; int_to_string actual; " 个参数"
    ]

  let function_param_count_mismatch_simple expected actual =
    concat_strings [
      "函数参数数量不匹配: 期望 "; int_to_string expected; 
      " 个参数，但提供了 "; int_to_string actual; " 个参数"
    ]

  let function_needs_params func_name expected actual =
    concat_strings [
      "函数「"; func_name; "」需要 "; int_to_string expected; 
      " 个参数，但只提供了 "; int_to_string actual; " 个"
    ]

  let function_excess_params func_name expected actual =
    concat_strings [
      "函数「"; func_name; "」只需要 "; int_to_string expected; 
      " 个参数，但提供了 "; int_to_string actual; " 个"
    ]

  (** 类型相关错误 *)
  let type_mismatch expected actual = type_mismatch_pattern expected actual

  let type_mismatch_detailed expected actual context =
    concat_strings ["类型不匹配: 期望 "; expected; "，但得到 "; actual; "（"; context; "）"]

  let unknown_type type_name = context_message_pattern "未知类型" type_name

  let invalid_type_operation op_name = context_message_pattern "无效的类型操作" op_name

  let invalid_argument_type expected actual =
    concat_strings ["参数类型错误，期望 "; expected; "，得到 "; actual]

  (** Token和语法错误 *)
  let unexpected_token token = context_message_pattern "意外的Token" token

  let expected_token expected actual =
    concat_strings ["期望Token "; expected; "，得到 "; actual]

  let syntax_error message = context_message_pattern "语法错误" message

  (** 文件操作错误 *)
  let file_not_found filename = context_message_pattern "文件未找到" filename

  let file_read_error filename = context_message_pattern "文件读取错误" filename
  let file_write_error filename = context_message_pattern "文件写入错误" filename

  let file_operation_error operation filename = file_operation_error_pattern operation filename

  (** 模块相关错误 *)
  let module_not_found mod_name = context_message_pattern "未定义的模块" mod_name

  let member_not_found mod_name member_name =
    concat_strings ["模块 "; mod_name; " 中未找到成员: "; member_name]

  (** 配置错误 *)
  let config_parse_error message = context_message_pattern "配置解析错误" message

  let invalid_config_value key value = 
    concat_strings ["配置值无效: "; key; " = "; value]

  (** 操作错误 *)
  let invalid_operation operation = context_message_pattern "无效操作" operation

  let pattern_match_failure value_type =
    concat_strings ["模式匹配失败: 无法匹配类型为 "; value_type; " 的值"]

  (** 通用错误 *)
  let generic_error context message = context_message_pattern context message
end

(** 编译器状态消息格式化 *)
module CompilerMessages = struct
  let compiling_file filename = context_message_pattern "正在编译文件" filename
  let compilation_complete filename = context_message_pattern "编译完成" filename

  let compilation_failed filename error =
    concat_strings ["编译失败: "; filename; " - "; error]

  (** 符号禁用消息 *)
  let unsupported_chinese_symbol char_bytes =
    concat_strings ["非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: "; char_bytes]
end

(** C代码生成格式化 *)
module CCodegen = struct
  (** 函数调用 *)
  let function_call func_name args = function_call_format func_name args

  let binary_function_call func_name left right =
    function_call_format func_name [left; right]

  let unary_function_call func_name operand =
    function_call_format func_name [operand]

  (** 骆言特定格式 *)
  let luoyan_call func_code arg_count args_code =
    function_call_format "luoyan_call" [func_code; int_to_string arg_count; args_code]

  let luoyan_bind_var var_name value =
    concat_strings ["luoyan_bind_var(\""; var_name; "\", "; value; ")"]

  let luoyan_string s = 
    concat_strings ["luoyan_string(\""; String.escaped s; "\")"]
    
  let luoyan_int i = function_call_format "luoyan_int" [int_to_string i]
  
  let luoyan_float f = function_call_format "luoyan_float" [float_to_string f]

  let luoyan_bool b =
    function_call_format "luoyan_bool" [if b then "true" else "false"]

  let luoyan_unit () = "luoyan_unit()"

  let luoyan_equals expr_var value =
    function_call_format "luoyan_equals" [expr_var; value]

  let luoyan_let var_name value_code body_code =
    function_call_format "luoyan_let" ["\"" ^ var_name ^ "\""; value_code; body_code]

  let luoyan_function_create func_name first_param =
    concat_strings [
      "luoyan_function_create("; func_name; "_impl_"; first_param; 
      ", env, \""; func_name; "\")"
    ]

  let luoyan_pattern_match expr_var =
    function_call_format "luoyan_pattern_match" [expr_var]

  let luoyan_var_expr expr_var expr_code =
    concat_strings [
      "({ luoyan_value_t* "; expr_var; " = "; expr_code; 
      "; luoyan_match("; expr_var; "); })"
    ]

  (** 环境绑定格式化 *)
  let luoyan_env_bind var_name expr_code = luoyan_env_bind_pattern var_name expr_code

  let luoyan_function_create_with_args func_code func_name =
    concat_strings [
      "luoyan_function_create("; func_code; ", env, \""; String.escaped func_name; "\")"
    ]

  (** 字符串相等性检查 *)
  let luoyan_string_equality_check expr_var escaped_string =
    concat_strings [
      "luoyan_equals("; expr_var; ", luoyan_string(\""; escaped_string; "\"))"
    ]

  (** 编译日志消息 *)
  let compilation_start_message output_file =
    concat_strings ["开始编译为C代码，输出文件："; output_file]

  let compilation_status_message action details =
    context_message_pattern action details

  (** C模板格式化 *)
  let c_template_with_includes include_part main_part footer_part =
    c_code_structure_pattern include_part main_part footer_part
end

(** 调试和日志格式化 *)
module LogMessages = struct
  let debug module_name message = context_message_pattern "[DEBUG]" (context_message_pattern module_name message)
  let info module_name message = context_message_pattern "[INFO]" (context_message_pattern module_name message)

  let warning module_name message =
    context_message_pattern "[WARNING]" (context_message_pattern module_name message)

  let error module_name message = context_message_pattern "[ERROR]" (context_message_pattern module_name message)
  let trace func_name message = context_message_pattern "[TRACE]" (context_message_pattern func_name message)
end

(** 位置信息格式化 *)
module Position = struct
  let format_position filename line column = file_position_pattern filename line column

  let format_error_with_position position error_type message =
    concat_strings [error_type; " "; position; ": "; message]

  let format_optional_position = function
    | Some (filename, line, column) ->
        concat_strings [" ("; format_position filename line column; ")"]
    | None -> ""
end

(** 通用格式化工具 *)
module General = struct
  let format_identifier name = concat_strings ["「"; name; "」"]

  let format_function_signature name params = function_call_format name params

  let format_type_signature name type_params =
    concat_strings [name; "<"; join_with_separator ", " type_params; ">"]

  let format_module_path path = join_with_separator "." path
  let format_list items separator = join_with_separator separator items
  let format_key_value key value = context_message_pattern key value

  (** 中文语法相关 *)
  let format_chinese_list items = join_with_separator "、" items

  let format_variable_definition var_name = 
    concat_strings ["让 「"; var_name; "」 = 值"]

  let format_context_info count item_type =
    concat_strings [
      "当前作用域中有 "; int_to_string count; " 个可用"; item_type
    ]
end

(** 索引和数组操作格式化 *)
module Collections = struct
  let index_out_of_bounds index length = index_out_of_bounds_pattern index length

  let array_access_error array_name index =
    concat_strings ["数组 "; array_name; " 索引 "; int_to_string index; " 访问错误"]

  let list_operation_error operation = context_message_pattern "列表操作错误" operation
end

(** 转换和类型转换格式化 *)
module Conversions = struct
  let type_conversion target_type expr = concat_strings ["("; target_type; ")"; expr]

  let casting_error from_type to_type =
    concat_strings ["无法将 "; from_type; " 转换为 "; to_type]
end



(** 错误处理和安全操作格式化 *)
module ErrorHandling = struct
  let safe_operation_error func_name msg = context_message_pattern func_name msg

  let unexpected_error_format func_name error_string =
    concat_strings [func_name; ": 未预期错误 - "; error_string]

  (** 词法错误格式化 *)
  let lexical_error detail = context_message_pattern "词法错误" detail
  let lexical_error_with_char char = 
    concat_strings ["词法错误：无效字符 '"; char; "'"]

  (** 解析错误格式化 *)
  let parse_error detail = context_message_pattern "解析错误" detail
  let parse_error_syntax syntax = 
    concat_strings ["解析错误：语法错误 '"; syntax; "'"]

  (** 运行时错误格式化 *)
  let runtime_error detail = context_message_pattern "运行时错误" detail
  let runtime_arithmetic_error detail = 
    concat_strings ["运行时错误：算术错误 '"; detail; "'"]

  (** 带位置的错误格式化 *)
  let error_with_position message filename line =
    concat_strings [message; " ("; filename; ":"; int_to_string line; ")"]

  let lexical_error_with_position filename line message =
    concat_strings [
      "词法错误 ("; filename; ":"; int_to_string line; "): "; message
    ]

  (** 通用错误类别格式化 *)
  let error_with_detail error_type detail =
    concat_strings [error_type; "：'"; detail; "'"]

  let category_error category detail =
    concat_strings ["类别错误: "; category; " - "; detail]

  let simple_category_error category =
    context_message_pattern "类别错误" category
end

(** 报告和统计格式化 *)
module ReportFormatting = struct
  (* 该模块暂无使用中的函数，保留模块定义以维护接口兼容性 *)
end

