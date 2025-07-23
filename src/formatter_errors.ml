(** 骆言编译器错误消息格式化模块

    本模块专注于错误消息的统一格式化，从unified_formatter.ml中拆分出来。 提供类型安全的错误消息格式化接口，消除Printf.sprintf依赖。

    重构目的：大型模块细化 - Fix #893
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-22 *)

(* 引入基础格式化器，实现零Printf.sprintf依赖 *)
open Utils.Base_formatter

(** 错误消息统一格式化 *)
module ErrorMessages = struct
  (** 变量相关错误 *)
  let undefined_variable var_name = context_message_pattern "未定义的变量" var_name

  let variable_already_defined var_name = context_message_pattern "变量已定义" var_name

  let variable_suggestion var_name available_vars =
    let vars_str = join_with_separator "、" available_vars in
    concat_strings [ "未定义的变量: "; var_name; "（可用变量: "; vars_str; "）" ]

  (** 函数相关错误 *)
  let function_not_found func_name = context_message_pattern "函数未找到" func_name

  let function_param_count_mismatch func_name expected actual =
    concat_strings
      [
        "函数「";
        func_name;
        "」参数数量不匹配: 期望 ";
        int_to_string expected;
        " 个参数，但提供了 ";
        int_to_string actual;
        " 个参数";
      ]

  let function_param_count_mismatch_simple expected actual =
    concat_strings
      [ "函数参数数量不匹配: 期望 "; int_to_string expected; " 个参数，但提供了 "; int_to_string actual; " 个参数" ]

  let function_needs_params func_name expected actual =
    concat_strings
      [
        "函数「"; func_name; "」需要 "; int_to_string expected; " 个参数，但只提供了 "; int_to_string actual; " 个";
      ]

  let function_excess_params func_name expected actual =
    concat_strings
      [
        "函数「"; func_name; "」只需要 "; int_to_string expected; " 个参数，但提供了 "; int_to_string actual; " 个";
      ]

  (** 类型相关错误 *)
  let type_mismatch expected actual = type_mismatch_pattern expected actual

  let type_mismatch_detailed expected actual context =
    concat_strings [ "类型不匹配: 期望 "; expected; "，但得到 "; actual; "（"; context; "）" ]

  let unknown_type type_name = context_message_pattern "未知类型" type_name
  let invalid_type_operation op_name = context_message_pattern "无效的类型操作" op_name

  let invalid_argument_type expected actual =
    concat_strings [ "参数类型错误，期望 "; expected; "，得到 "; actual ]

  (** Token和语法错误 *)
  let unexpected_token token = context_message_pattern "意外的Token" token

  let expected_token expected actual = concat_strings [ "期望Token "; expected; "，得到 "; actual ]

  let syntax_error message = context_message_pattern "语法错误" message

  (** 文件操作错误 *)
  let file_not_found filename = context_message_pattern "文件未找到" filename

  let file_read_error filename = context_message_pattern "文件读取错误" filename
  let file_write_error filename = context_message_pattern "文件写入错误" filename
  let file_operation_error operation filename = file_operation_error_pattern operation filename

  (** 模块相关错误 *)
  let module_not_found mod_name = context_message_pattern "未定义的模块" mod_name

  let member_not_found mod_name member_name =
    concat_strings [ "模块 "; mod_name; " 中未找到成员: "; member_name ]

  (** 配置错误 *)
  let config_parse_error message = context_message_pattern "配置解析错误" message

  let invalid_config_value key value = concat_strings [ "配置值无效: "; key; " = "; value ]

  (** 操作错误 *)
  let invalid_operation operation = context_message_pattern "无效操作" operation

  let pattern_match_failure value_type = concat_strings [ "模式匹配失败: 无法匹配类型为 "; value_type; " 的值" ]

  (** 通用错误 *)
  let generic_error context message = context_message_pattern context message

  let compilation_error phase message = concat_strings [ "编译错误（"; phase; "）: "; message ]

  let runtime_error operation message = concat_strings [ "运行时错误（"; operation; "）: "; message ]

  (** 变量拼写纠正消息 *)
  let variable_spell_correction original corrected =
    concat_strings [ "变量名'"; original; "'未找到，使用最接近的'"; corrected; "'" ]
end

(** 错误处理模块 *)
module ErrorHandling = struct
  let safe_operation_error func_name msg = context_message_pattern func_name msg

  let unexpected_error_format func_name error_string =
    concat_strings [ func_name; ": 未预期错误 - "; error_string ]

  (** 词法错误格式化 *)
  let lexical_error detail = context_message_pattern "词法错误" detail

  let lexical_error_with_char char = concat_strings [ "词法错误：无效字符 '"; char; "'" ]

  (** 解析错误格式化 *)
  let parse_error detail = context_message_pattern "解析错误" detail

  let parse_error_syntax syntax = concat_strings [ "解析错误：语法错误 '"; syntax; "'" ]

  (** 解析失败错误格式化 - Phase 2专用模式 *)
  let parse_failure_with_token expr_type token error_msg =
    concat_strings [ "解析"; expr_type; "时失败，token: "; token; "，错误: "; error_msg ]

  (** 运行时错误格式化 *)
  let runtime_error detail = context_message_pattern "运行时错误" detail

  let runtime_arithmetic_error detail = concat_strings [ "运行时错误：算术错误 '"; detail; "'" ]

  (** 带位置的错误格式化 *)
  let error_with_position message filename line =
    concat_strings [ message; " ("; filename; ":"; int_to_string line; ")" ]

  let lexical_error_with_position filename line message =
    concat_strings [ "词法错误 ("; filename; ":"; int_to_string line; "): "; message ]

  (** 通用错误类别格式化 *)
  let error_with_detail error_type detail = concat_strings [ error_type; "：'"; detail; "'" ]

  let category_error category detail = concat_strings [ "类别错误: "; category; " - "; detail ]
  let simple_category_error category = context_message_pattern "类别错误" category

  (** 参数验证 *)
  let invalid_argument param expected actual =
    concat_strings [ "参数 '"; param; "' 期望 "; expected; "，得到 "; actual ]

  let null_argument_error param = context_message_pattern "参数不能为空" param

  (** 边界检查 *)
  let index_out_of_bounds index length =
    concat_strings [ "索引越界: "; int_to_string index; "，容器长度: "; int_to_string length ]

  let array_bounds_error index size =
    concat_strings [ "数组索引 "; int_to_string index; " 超出界限（大小: "; int_to_string size; "）" ]

  (** 状态错误 *)
  let invalid_state expected actual = concat_strings [ "状态错误，期望 "; expected; "，当前 "; actual ]

  let operation_not_supported operation = context_message_pattern "操作不支持" operation

  (** 资源错误 *)
  let resource_exhausted resource = context_message_pattern "资源耗尽" resource

  let resource_not_available resource = context_message_pattern "资源不可用" resource
end

(** 增强错误消息模块 *)
module EnhancedErrorMessages = struct
  (** 变量相关增强错误 *)
  let undefined_variable_enhanced var_name = concat_strings [ "未定义的变量: "; var_name ]

  let variable_already_defined_enhanced var_name = concat_strings [ "变量已定义: "; var_name ]

  (** 模块相关增强错误 *)
  let module_member_not_found mod_name member_name =
    concat_strings [ "模块 "; mod_name; " 中未找到成员: "; member_name ]

  (** 文件相关增强错误 *)
  let file_not_found_enhanced filename = concat_strings [ "文件未找到: "; filename ]

  (** Token相关增强错误 - 需要定义这些函数 *)
  let token_expectation_error expected actual =
    concat_strings [ "期望token "; expected; "，实际 "; actual ]

  let unexpected_token_error token = concat_strings [ "意外的token: "; token ]

  (** 代码生成错误 *)
  let codegen_error phase expression_type detail =
    concat_strings [ "代码生成错误（"; phase; "）- "; expression_type; ": "; detail ]

  let unsupported_feature feature context =
    concat_strings [ "不支持的特性 '"; feature; "' 在 "; context; " 中" ]

  (** 数据结构错误 *)
  let empty_collection operation = concat_strings [ "空集合错误: 无法对空集合执行 "; operation ]

  let duplicate_key key = context_message_pattern "重复的键" key

  (** 解析错误 *)
  let parser_state_error expected_state current_state =
    concat_strings [ "解析器状态错误: 期望 "; expected_state; "，当前 "; current_state ]

  let lexer_error position character =
    concat_strings [ "词法分析错误，位置 "; position; ": 无效字符 '"; character; "'" ]

  (** 类型系统错误 *)
  let type_inference_failure expression = concat_strings [ "类型推断失败: 无法推断表达式 "; expression; " 的类型" ]

  let circular_type_dependency type_name = concat_strings [ "循环类型依赖: "; type_name ]

  (** 执行错误 *)
  let execution_timeout operation = concat_strings [ "执行超时: "; operation ]

  let memory_limit_exceeded operation = concat_strings [ "内存限制超出: "; operation ]
end

(** 错误处理格式化器 *)
module ErrorHandlingFormatter = struct
  (** 错误统计格式化 *)
  let format_error_statistics error_type count =
    concat_strings [ error_type; "错误统计: "; int_to_string count; " 个" ]

  (** 错误消息和上下文组合格式化 *)
  let format_error_message error_type detail = concat_strings [ error_type; ": "; detail ]

  (** 错误恢复信息格式化 *)
  let format_recovery_info recovery_action = concat_strings [ "恢复操作: "; recovery_action ]

  (** 错误上下文格式化 *)
  let format_error_context source_info line_number =
    concat_strings [ "错误位置: "; source_info; " 第"; int_to_string line_number; "行" ]

  (** 统一错误格式化 *)
  let format_unified_error error_category specific_message =
    concat_strings [ error_category; " - "; specific_message ]

  (** 错误建议格式化 *)
  let format_error_suggestion suggestion_number suggestion_text =
    concat_strings [ "   "; int_to_string suggestion_number; ". "; suggestion_text ]

  (** 错误提示格式化 *)
  let format_error_hint hint_number hint_text =
    concat_strings [ "   "; int_to_string hint_number; ". "; hint_text ]

  (** AI置信度格式化 *)
  let format_confidence_score confidence_percent =
    concat_strings [ "\n🎯 AI置信度: "; int_to_string confidence_percent; "%" ]

  (** 异常信息格式化 *)
  let format_exception exc_type message = concat_strings [ exc_type; ": "; message ]

  let format_stack_trace frames =
    let formatted_frames = List.map (fun frame -> concat_strings [ "  at "; frame ]) frames in
    join_with_separator "\n" formatted_frames

  (** 警告消息 *)
  let warning_message category message = concat_strings [ "警告（"; category; "）: "; message ]

  let deprecation_warning feature replacement =
    concat_strings [ "弃用警告: '"; feature; "' 已弃用，请使用 '"; replacement; "'" ]

  (** 调试信息 *)
  let debug_trace operation details = concat_strings [ "调试追踪 ["; operation; "]: "; details ]

  let performance_warning operation threshold actual =
    concat_strings
      [
        "性能警告 [";
        operation;
        "]: 执行时间 ";
        int_to_string actual;
        "ms 超过阈值 ";
        int_to_string threshold;
        "ms";
      ]
end
