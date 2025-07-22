(** 骆言编译器底层格式化基础设施接口

    此模块提供不依赖Printf.sprintf的基础字符串格式化工具接口。 *)

(** 基础字符串格式化工具模块 *)
module Base_formatter : sig
  val concat_strings : string list -> string
  (** 基础字符串拼接函数 *)

  val join_with_separator : string -> string list -> string
  (** 带分隔符的字符串拼接 *)

  val int_to_string : int -> string
  (** 基础类型转换函数 *)

  val float_to_string : float -> string
  val bool_to_string : bool -> string
  val char_to_string : char -> string

  (** 常用格式化模式 *)

  val token_pattern : string -> string -> string
  (** Token模式: TokenType(value) *)

  val char_token_pattern : string -> char -> string
  (** Token模式: TokenType('char') *)

  val context_message_pattern : string -> string -> string
  (** 错误上下文模式: context: message *)

  val file_position_pattern : string -> int -> int -> string
  (** 位置信息模式: filename:line:column *)

  val line_col_message_pattern : int -> int -> string -> string
  (** 位置信息模式: (line:column): message *)

  val token_position_pattern : string -> int -> int -> string
  (** Token位置模式: token@line:column *)

  val param_count_pattern : int -> int -> string
  (** 参数计数模式: 期望X个参数，但获得Y个参数 *)

  val function_name_pattern : string -> string
  (** 函数名模式: 函数名函数 *)

  val function_param_error_pattern : string -> int -> int -> string
  (** 函数错误模式: 函数名函数期望X个参数，但获得Y个参数 *)

  val type_expectation_pattern : string -> string
  (** 类型期望模式: 期望X参数 *)

  val function_type_error_pattern : string -> string -> string
  (** 函数类型错误模式: 函数名函数期望X参数 *)

  val type_mismatch_pattern : string -> string -> string
  (** 类型不匹配模式: 期望 X，但得到 Y *)

  val index_out_of_bounds_pattern : int -> int -> string
  (** 索引超出范围模式: 索引 X 超出范围，数组长度为 Y *)

  val file_operation_error_pattern : string -> string -> string
  (** 文件操作错误模式: 无法X文件: Y *)

  val luoyan_function_pattern : string -> string -> string
  (** C代码生成模式: luoyan_function_name(args) *)

  val luoyan_env_bind_pattern : string -> string -> string
  (** C环境绑定模式: luoyan_env_bind(env, "var", expr); *)

  val c_code_structure_pattern : string -> string -> string -> string
  (** C代码结构模式: includes + functions + main *)

  val stat_report_pattern : string -> string -> int -> string
  (** 统计报告模式: icon category: count 个 *)

  val stat_report_line_pattern : string -> string -> int -> string
  (** 带换行的统计报告模式 *)

  val analysis_message_pattern : string -> string -> string
  (** 分析消息模式: icon message *)

  val analysis_message_line_pattern : string -> string -> string
  (** 带换行的分析消息模式 *)

  val performance_creation_pattern : int -> string -> string
  (** 性能分析消息模式: 创建了包含X个元素的大型Y *)

  val performance_field_pattern : int -> string -> string
  (** 性能字段分析模式: 创建了包含X个字段的大型Y *)

  val poetry_char_count_pattern : int -> int -> string
  (** 诗词字符数不匹配模式: 字符数不匹配：期望X字，实际Y字 *)

  val poetry_couplet_pattern : int -> int -> string
  (** 诗词对偶不匹配模式: 对偶字数不匹配：左联X字，右联Y字 *)

  val poetry_quatrain_pattern : int -> string
  (** 绝句格式模式: 绝句包含X句，通常为4句 *)

  val list_format : string list -> string
  (** 列表格式化 - 方括号包围，分号分隔 *)

  val function_call_format : string -> string list -> string
  (** 函数调用格式化: FunctionName(arg1, arg2, ...) *)

  val module_access_format : string -> string -> string
  (** 模块访问格式化: Module.member *)

  val template_replace : string -> (string * string) list -> string
  (** 高级模板替换函数（用于复杂场景） *)

  (** 错误消息格式化模式扩展 *)
  val file_not_found_pattern : string -> string
  val file_read_error_pattern : string -> string
  val file_write_error_pattern : string -> string
  val type_mismatch_error_pattern : string -> string
  val unknown_type_pattern : string -> string
  val invalid_type_operation_pattern : string -> string
  val parse_failure_pattern : string -> string -> string
  val json_parse_error_pattern : string -> string
  val test_case_parse_error_pattern : string -> string
  val config_parse_error_pattern : string -> string
  val config_list_parse_error_pattern : string -> string
  val comprehensive_test_parse_error_pattern : string -> string
  val summary_items_parse_error_pattern : string -> string
  val unknown_checker_type_pattern : string -> string
  val unexpected_exception_pattern : string -> string
  val generic_error_pattern : string -> string -> string
  val undefined_variable_pattern : string -> string
  val variable_already_defined_pattern : string -> string
  val function_not_found_pattern : string -> string
  val function_param_mismatch_pattern : string -> int -> int -> string
  val module_not_found_pattern : string -> string
  val member_not_found_pattern : string -> string -> string
  val invalid_operation_pattern : string -> string
  val pattern_match_failure_pattern : string -> string
  
  (** 位置格式化专用模式扩展 - 第三阶段Printf.sprintf统一化 *)
  val position_standard : string -> int -> int -> string
  (** 标准位置格式: filename:line:column *)
  
  val position_chinese_format : int -> int -> string
  (** 中文行列格式: 行:line 列:column *)
  
  val position_parentheses : int -> int -> string
  (** 括号位置格式: (行:line, 列:column) *)
  
  val position_range : int -> int -> int -> int -> string
  (** 位置范围格式: start_line:start_col-end_line:end_col *)
  
  val line_only_format : int -> string
  (** 简化行号格式: 行:line *)
  
  val line_with_colon_format : int -> string
  (** 行号带冒号格式: line: *)
  
  val position_with_offset_format : int -> int -> int -> string
  (** 带偏移的位置格式: 行:line 列:column 偏移:offset *)
  
  val relative_position_format : int -> int -> string
  (** 相对位置格式: 相对位置(+line_diff,+col_diff) *)
  
  val full_position_with_file_format : string -> int -> int -> string
  (** 完整文件位置格式: 文件:filename 行:line 列:column *)
  
  val same_line_range_format : int -> int -> int -> string
  (** 同行位置范围格式: 第line行 列start_col-end_col *)
  
  val multi_line_range_format : int -> int -> int -> int -> string
  (** 多行位置范围格式: 第start_line行第start_col列 至 第end_line行第end_col列 *)
  
  val error_position_marker_format : int -> int -> string
  (** 错误位置标记格式: >>> 错误位置: 行:line 列:column *)
  
  val debug_position_info_format : string -> int -> int -> string -> string
  (** 调试位置信息格式: [DEBUG] func_name@filename:line:column *)
  
  val error_type_with_position_format : string -> string -> string -> string
  (** 错误类型与位置结合格式: error_type pos_str: message *)
  
  val optional_position_wrapper_format : string -> string
  (** 可选位置包装格式: 如果有位置则返回 ( position )，否则返回空字符串 *)

  (** 第三阶段Phase 3.3扩展：报告格式化和C代码生成专用模式 *)
  val context_info_pattern : string -> string
  (** 上下文信息模式: 📍 上下文: context *)

  val suggestion_replacement_pattern : string -> string -> string
  (** 建议替换模式: 建议将「current」改为「suggestion」 *)

  val similarity_match_pattern : string -> float -> string
  (** 相似度匹配模式: 可能想使用：「match_name」(相似度: score%) *)

  val binary_function_pattern : string -> string -> string -> string
  (** 双参数函数模式: func_name(param1, param2) *)

  val luoyan_string_equality_pattern : string -> string -> string
  (** Luoyan字符串相等检查模式: luoyan_equals(expr, luoyan_string("str")) *)

  val c_type_cast_pattern : string -> string -> string
  (** C类型转换模式: (type)expr *)
end

include module type of Base_formatter
(** 导出常用函数到顶层 *)
