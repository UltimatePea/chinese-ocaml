(** 骆言编译器统一格式化工具 - Phase 15.4: 模式重复消除

    此模块提供统一的字符串格式化接口，消除项目中236次字符串格式化重复。

    设计目标:
    - 统一错误消息格式
    - 标准化调试信息输出
    - 简化C代码生成格式化
    - 提供一致的类型和参数错误报告 *)

(* 使用UnifiedLogger进行统一日志管理 *)

(** 错误消息统一格式化 *)
module ErrorMessages = struct
  (** 变量相关错误 *)
  let undefined_variable var_name = Unified_logger.Legacy.sprintf "未定义的变量: %s" var_name

  let variable_already_defined var_name = Unified_logger.Legacy.sprintf "变量已定义: %s" var_name

  let variable_suggestion var_name available_vars =
    let vars_str = String.concat "、" available_vars in
    Unified_logger.Legacy.sprintf "未定义的变量: %s（可用变量: %s）" var_name vars_str

  (** 函数相关错误 *)
  let function_not_found func_name = Unified_logger.Legacy.sprintf "函数未找到: %s" func_name

  let function_param_count_mismatch func_name expected actual =
    Unified_logger.Legacy.sprintf "函数「%s」参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" func_name expected actual

  let function_param_count_mismatch_simple expected actual =
    Unified_logger.Legacy.sprintf "函数参数数量不匹配: 期望 %d 个参数，但提供了 %d 个参数" expected actual

  let function_needs_params func_name expected actual =
    Unified_logger.Legacy.sprintf "函数「%s」需要 %d 个参数，但只提供了 %d 个" func_name expected actual

  let function_excess_params func_name expected actual =
    Unified_logger.Legacy.sprintf "函数「%s」只需要 %d 个参数，但提供了 %d 个" func_name expected actual

  (** 类型相关错误 *)
  let type_mismatch expected actual =
    Unified_logger.Legacy.sprintf "类型不匹配，期望 %s，得到 %s" expected actual

  let type_mismatch_detailed expected actual context =
    Unified_logger.Legacy.sprintf "类型不匹配: 期望 %s，但得到 %s（%s）" expected actual context

  let unknown_type type_name = Unified_logger.Legacy.sprintf "未知类型: %s" type_name

  let invalid_type_operation op_name = Unified_logger.Legacy.sprintf "无效的类型操作: %s" op_name

  let invalid_argument_type expected actual =
    Unified_logger.Legacy.sprintf "参数类型错误，期望 %s，得到 %s" expected actual

  (** Token和语法错误 *)
  let unexpected_token token = Unified_logger.Legacy.sprintf "意外的Token: %s" token

  let expected_token expected actual =
    Unified_logger.Legacy.sprintf "期望Token %s，得到 %s" expected actual

  let syntax_error message = Unified_logger.Legacy.sprintf "语法错误: %s" message

  (** 文件操作错误 *)
  let file_not_found filename = Unified_logger.Legacy.sprintf "文件未找到: %s" filename

  let file_read_error filename = Unified_logger.Legacy.sprintf "文件读取错误: %s" filename
  let file_write_error filename = Unified_logger.Legacy.sprintf "文件写入错误: %s" filename

  let file_operation_error operation filename =
    Unified_logger.Legacy.sprintf "无法%s文件: %s" operation filename

  (** 模块相关错误 *)
  let module_not_found mod_name = Unified_logger.Legacy.sprintf "未定义的模块: %s" mod_name

  let member_not_found mod_name member_name =
    Unified_logger.Legacy.sprintf "模块 %s 中未找到成员: %s" mod_name member_name

  (** 配置错误 *)
  let config_parse_error message = Unified_logger.Legacy.sprintf "配置解析错误: %s" message

  let invalid_config_value key value = Unified_logger.Legacy.sprintf "配置值无效: %s = %s" key value

  (** 操作错误 *)
  let invalid_operation operation = Unified_logger.Legacy.sprintf "无效操作: %s" operation

  let pattern_match_failure value_type =
    Unified_logger.Legacy.sprintf "模式匹配失败: 无法匹配类型为 %s 的值" value_type

  (** 通用错误 *)
  let generic_error context message = Unified_logger.Legacy.sprintf "%s: %s" context message
end

(** 编译器状态消息格式化 *)
module CompilerMessages = struct
  let compiling_file filename = Unified_logger.Legacy.sprintf "正在编译文件: %s" filename
  let compilation_complete filename = Unified_logger.Legacy.sprintf "编译完成: %s" filename

  let compilation_failed filename error =
    Unified_logger.Legacy.sprintf "编译失败: %s - %s" filename error

  (** 符号禁用消息 *)
  let unsupported_chinese_symbol char_bytes =
    Unified_logger.Legacy.sprintf "非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: %s" char_bytes
end

(** C代码生成格式化 *)
module CCodegen = struct
  (** 函数调用 *)
  let function_call func_name args =
    Unified_logger.Legacy.sprintf "%s(%s)" func_name (String.concat ", " args)

  let binary_function_call func_name left right =
    Unified_logger.Legacy.sprintf "%s(%s, %s)" func_name left right

  let unary_function_call func_name operand =
    Unified_logger.Legacy.sprintf "%s(%s)" func_name operand

  (** 骆言特定格式 *)
  let luoyan_call func_code arg_count args_code =
    Unified_logger.Legacy.sprintf "luoyan_call(%s, %d, %s)" func_code arg_count args_code

  let luoyan_bind_var var_name value =
    Unified_logger.Legacy.sprintf "luoyan_bind_var(\"%s\", %s)" var_name value

  let luoyan_string s = Unified_logger.Legacy.sprintf "luoyan_string(\"%s\")" (String.escaped s)
  let luoyan_int i = Unified_logger.Legacy.sprintf "luoyan_int(%d)" i
  let luoyan_float f = Unified_logger.Legacy.sprintf "luoyan_float(%g)" f

  let luoyan_bool b =
    Unified_logger.Legacy.sprintf "luoyan_bool(%s)" (if b then "true" else "false")

  let luoyan_unit () = "luoyan_unit()"

  let luoyan_equals expr_var value =
    Unified_logger.Legacy.sprintf "luoyan_equals(%s, %s)" expr_var value

  let luoyan_let var_name value_code body_code =
    Unified_logger.Legacy.sprintf "luoyan_let(\"%s\", %s, %s)" var_name value_code body_code

  let luoyan_function_create func_name first_param =
    Unified_logger.Legacy.sprintf "luoyan_function_create(%s_impl_%s, env, \"%s\")" func_name
      first_param func_name

  let luoyan_pattern_match expr_var =
    Unified_logger.Legacy.sprintf "luoyan_pattern_match(%s)" expr_var

  let luoyan_var_expr expr_var expr_code =
    Unified_logger.Legacy.sprintf "({ luoyan_value_t* %s = %s; luoyan_match(%s); })" expr_var
      expr_code expr_var

  (** 环境绑定格式化 *)
  let luoyan_env_bind var_name expr_code =
    Unified_logger.Legacy.sprintf "luoyan_env_bind(env, \"%s\", %s);" (String.escaped var_name) expr_code

  let luoyan_function_create_with_args func_code func_name =
    Unified_logger.Legacy.sprintf "luoyan_function_create(%s, env, \"%s\")" func_code (String.escaped func_name)

  (** 字符串相等性检查 *)
  let luoyan_string_equality_check expr_var escaped_string =
    Unified_logger.Legacy.sprintf "luoyan_equals(%s, luoyan_string(\"%s\"))" expr_var escaped_string

  (** 编译日志消息 *)
  let compilation_start_message output_file =
    Unified_logger.Legacy.sprintf "开始编译为C代码，输出文件：%s" output_file

  let compilation_status_message action details =
    Unified_logger.Legacy.sprintf "%s：%s" action details

  (** C模板格式化 *)
  let c_template_with_includes include_part main_part footer_part =
    Unified_logger.Legacy.sprintf "%s\n\n%s\n\n%s\n" include_part main_part footer_part
end

(** 调试和日志格式化 *)
module LogMessages = struct
  let debug module_name message = Unified_logger.Legacy.sprintf "[DEBUG] %s: %s" module_name message
  let info module_name message = Unified_logger.Legacy.sprintf "[INFO] %s: %s" module_name message

  let warning module_name message =
    Unified_logger.Legacy.sprintf "[WARNING] %s: %s" module_name message

  let error module_name message = Unified_logger.Legacy.sprintf "[ERROR] %s: %s" module_name message
  let trace func_name message = Unified_logger.Legacy.sprintf "[TRACE] %s: %s" func_name message
end

(** 位置信息格式化 *)
module Position = struct
  let format_position filename line column =
    Unified_logger.Legacy.sprintf "%s:%d:%d" filename line column

  let format_error_with_position position error_type message =
    Unified_logger.Legacy.sprintf "%s %s: %s" error_type position message

  let format_optional_position = function
    | Some (filename, line, column) ->
        Unified_logger.Legacy.sprintf " (%s)" (format_position filename line column)
    | None -> ""
end

(** 通用格式化工具 *)
module General = struct
  let format_identifier name = Unified_logger.Legacy.sprintf "「%s」" name

  let format_function_signature name params =
    Unified_logger.Legacy.sprintf "%s(%s)" name (String.concat ", " params)

  let format_type_signature name type_params =
    Unified_logger.Legacy.sprintf "%s<%s>" name (String.concat ", " type_params)

  let format_module_path path = String.concat "." path
  let format_list items separator = String.concat separator items
  let format_key_value key value = Unified_logger.Legacy.sprintf "%s: %s" key value

  (** 中文语法相关 *)
  let format_chinese_list items = String.concat "、" items

  let format_variable_definition var_name = Unified_logger.Legacy.sprintf "让 「%s」 = 值" var_name

  let format_context_info count item_type =
    Unified_logger.Legacy.sprintf "当前作用域中有 %d 个可用%s" count item_type
end

(** 索引和数组操作格式化 *)
module Collections = struct
  let index_out_of_bounds index length =
    Unified_logger.Legacy.sprintf "索引 %d 超出范围，数组长度为 %d" index length

  let array_access_error array_name index =
    Unified_logger.Legacy.sprintf "数组 %s 索引 %d 访问错误" array_name index

  let list_operation_error operation = Unified_logger.Legacy.sprintf "列表操作错误: %s" operation
end

(** 转换和类型转换格式化 *)
module Conversions = struct
  let type_conversion target_type expr = Unified_logger.Legacy.sprintf "(%s)%s" target_type expr

  let casting_error from_type to_type =
    Unified_logger.Legacy.sprintf "无法将 %s 转换为 %s" from_type to_type
end



(** 错误处理和安全操作格式化 *)
module ErrorHandling = struct
  let safe_operation_error func_name msg =
    Unified_logger.Legacy.sprintf "%s: %s" func_name msg

  let unexpected_error_format func_name error_string =
    Unified_logger.Legacy.sprintf "%s: 未预期错误 - %s" func_name error_string

  (** 词法错误格式化 *)
  let lexical_error detail = Unified_logger.Legacy.sprintf "词法错误：%s" detail
  let lexical_error_with_char char = Unified_logger.Legacy.sprintf "词法错误：无效字符 '%s'" char

  (** 解析错误格式化 *)
  let parse_error detail = Unified_logger.Legacy.sprintf "解析错误：%s" detail
  let parse_error_syntax syntax = Unified_logger.Legacy.sprintf "解析错误：语法错误 '%s'" syntax

  (** 运行时错误格式化 *)
  let runtime_error detail = Unified_logger.Legacy.sprintf "运行时错误：%s" detail
  let runtime_arithmetic_error detail = Unified_logger.Legacy.sprintf "运行时错误：算术错误 '%s'" detail

  (** 带位置的错误格式化 *)
  let error_with_position message filename line =
    Unified_logger.Legacy.sprintf "%s (%s:%d)" message filename line

  let lexical_error_with_position filename line message =
    Unified_logger.Legacy.sprintf "词法错误 (%s:%d): %s" filename line message

  (** 通用错误类别格式化 *)
  let error_with_detail error_type detail =
    Unified_logger.Legacy.sprintf "%s：'%s'" error_type detail

  let category_error category detail =
    Unified_logger.Legacy.sprintf "类别错误: %s - %s" category detail

  let simple_category_error category =
    Unified_logger.Legacy.sprintf "类别错误: %s" category
end

(** 报告和统计格式化 *)
module ReportFormatting = struct
  (* 该模块暂无使用中的函数，保留模块定义以维护接口兼容性 *)
end

