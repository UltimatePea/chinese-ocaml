(** 骆言编译器错误消息格式化模块接口

    此模块专门负责各类错误消息的标准化格式化，提供统一的错误信息显示模式。

    设计原则:
    - 一致性：所有错误消息遵循统一的格式模式
    - 可读性：错误信息清晰易懂，便于调试和修复
    - 中文本地化：所有错误消息使用简体中文
    - 上下文感知：提供丰富的错误上下文信息

    用途：为整个编译器提供标准化的错误消息格式化服务 *)

(** 错误消息格式化工具模块 *)
module Error_formatters : sig
  (** 错误上下文模式: context: message *)
  val context_message_pattern : string -> string -> string

  (** 参数计数模式: 期望X个参数，但获得Y个参数 *)
  val param_count_pattern : int -> int -> string

  (** 函数名模式: 函数名函数 *)
  val function_name_pattern : string -> string

  (** 函数错误模式: 函数名函数期望X个参数，但获得Y个参数 *)
  val function_param_error_pattern : string -> int -> int -> string

  (** 类型期望模式: 期望X参数 *)
  val type_expectation_pattern : string -> string

  (** 函数类型错误模式: 函数名函数期望X参数 *)
  val function_type_error_pattern : string -> string -> string

  (** 类型不匹配模式: 期望 X，但得到 Y *)
  val type_mismatch_pattern : string -> string -> string

  (** 索引超出范围模式: 索引 X 超出范围，数组长度为 Y *)
  val index_out_of_bounds_pattern : int -> int -> string

  (** 文件操作错误模式: 无法X文件: Y *)
  val file_operation_error_pattern : string -> string -> string

  (** 文件操作错误模式: 文件未找到: filename *)
  val file_not_found_pattern : string -> string

  (** 文件读取错误模式: 无法读取测试配置文件: filename *)
  val file_read_error_pattern : string -> string

  (** 文件写入错误模式: 文件写入错误: filename *)
  val file_write_error_pattern : string -> string

  (** 类型不匹配错误模式: 类型不匹配: type_info *)
  val type_mismatch_error_pattern : string -> string

  (** 未知类型错误模式: 未知类型: type_name *)
  val unknown_type_pattern : string -> string

  (** 无效类型操作模式: 无效的类型操作: op_name *)
  val invalid_type_operation_pattern : string -> string

  (** 解析失败模式: format解析失败: message *)
  val parse_failure_pattern : string -> string -> string

  (** JSON解析错误模式: 测试配置JSON格式错误: message *)
  val json_parse_error_pattern : string -> string

  (** 测试用例解析错误模式: 解析测试用例失败: message *)
  val test_case_parse_error_pattern : string -> string

  (** 配置解析错误模式: 解析测试配置失败: message *)
  val config_parse_error_pattern : string -> string

  (** 配置列表解析错误模式: 解析测试配置列表失败: message *)
  val config_list_parse_error_pattern : string -> string

  (** 综合测试解析错误模式: 解析综合测试用例失败: message *)
  val comprehensive_test_parse_error_pattern : string -> string

  (** 摘要项目解析错误模式: 解析测试摘要项目失败: message *)
  val summary_items_parse_error_pattern : string -> string

  (** 未知检查器类型模式: 未知的检查器类型: checker_type *)
  val unknown_checker_type_pattern : string -> string

  (** 意外异常模式: 意外异常: exception_string *)
  val unexpected_exception_pattern : string -> string

  (** 通用错误模式: context: message *)
  val generic_error_pattern : string -> string -> string

  (** 未定义变量模式: 未定义的变量: var_name *)
  val undefined_variable_pattern : string -> string

  (** 变量已定义模式: 变量已定义: var_name *)
  val variable_already_defined_pattern : string -> string

  (** 函数未找到模式: 函数未找到: func_name *)
  val function_not_found_pattern : string -> string

  (** 函数参数不匹配模式: 函数「func_name」参数数量不匹配: 期望 expected 个参数，但提供了 actual 个参数 *)
  val function_param_mismatch_pattern : string -> int -> int -> string

  (** 未定义模块模式: 未定义的模块: mod_name *)
  val module_not_found_pattern : string -> string

  (** 成员未找到模式: 模块 mod_name 中未找到成员: member_name *)
  val member_not_found_pattern : string -> string -> string

  (** 无效操作模式: 无效操作: operation *)
  val invalid_operation_pattern : string -> string

  (** 模式匹配失败模式: 模式匹配失败: 无法匹配类型为 value_type 的值 *)
  val pattern_match_failure_pattern : string -> string

  (** 错误统计模式: 🚨 错误: X 个 *)
  val error_count_pattern : int -> string

  (** 警告统计模式: ⚠️ 警告: X 个 *)
  val warning_count_pattern : int -> string

  (** 风格统计模式: 🎨 风格: X 个 *)
  val style_count_pattern : int -> string

  (** 提示统计模式: 💡 提示: X 个 *)
  val info_count_pattern : int -> string

  (** 建议替换模式: 建议将「current」改为「suggestion」 *)
  val suggestion_replacement_pattern : string -> string -> string

  (** 相似度匹配模式: 可能想使用：「match_name」(相似度: score%) *)
  val similarity_match_pattern : string -> float -> string

  (** 违规报告编号模式: N. icon severity message *)
  val violation_numbered_pattern : int -> string -> string -> string -> string

  (** 违规建议模式: 💡 建议: X *)
  val violation_suggestion_pattern : string -> string

  (** 违规置信度模式: 🎯 置信度: X% *)
  val violation_confidence_pattern : float -> string

  (** 变量纠正模式: 将变量名"X"纠正为"Y" *)
  val variable_correction_pattern : string -> string -> string
end

(** 导出的顶层函数 *)

(** 错误上下文模式: context: message *)
val context_message_pattern : string -> string -> string

(** 参数计数模式: 期望X个参数，但获得Y个参数 *)
val param_count_pattern : int -> int -> string

(** 函数名模式: 函数名函数 *)
val function_name_pattern : string -> string

(** 函数错误模式: 函数名函数期望X个参数，但获得Y个参数 *)
val function_param_error_pattern : string -> int -> int -> string

(** 类型期望模式: 期望X参数 *)
val type_expectation_pattern : string -> string

(** 函数类型错误模式: 函数名函数期望X参数 *)
val function_type_error_pattern : string -> string -> string

(** 类型不匹配模式: 期望 X，但得到 Y *)
val type_mismatch_pattern : string -> string -> string

(** 索引超出范围模式: 索引 X 超出范围，数组长度为 Y *)
val index_out_of_bounds_pattern : int -> int -> string

(** 文件操作错误模式: 无法X文件: Y *)
val file_operation_error_pattern : string -> string -> string

(** 文件操作错误模式: 文件未找到: filename *)
val file_not_found_pattern : string -> string

(** 文件读取错误模式: 无法读取测试配置文件: filename *)
val file_read_error_pattern : string -> string

(** 文件写入错误模式: 文件写入错误: filename *)
val file_write_error_pattern : string -> string

(** 类型不匹配错误模式: 类型不匹配: type_info *)
val type_mismatch_error_pattern : string -> string

(** 未知类型错误模式: 未知类型: type_name *)
val unknown_type_pattern : string -> string

(** 无效类型操作模式: 无效的类型操作: op_name *)
val invalid_type_operation_pattern : string -> string

(** 解析失败模式: format解析失败: message *)
val parse_failure_pattern : string -> string -> string

(** JSON解析错误模式: 测试配置JSON格式错误: message *)
val json_parse_error_pattern : string -> string

(** 测试用例解析错误模式: 解析测试用例失败: message *)
val test_case_parse_error_pattern : string -> string

(** 配置解析错误模式: 解析测试配置失败: message *)
val config_parse_error_pattern : string -> string

(** 配置列表解析错误模式: 解析测试配置列表失败: message *)
val config_list_parse_error_pattern : string -> string

(** 综合测试解析错误模式: 解析综合测试用例失败: message *)
val comprehensive_test_parse_error_pattern : string -> string

(** 摘要项目解析错误模式: 解析测试摘要项目失败: message *)
val summary_items_parse_error_pattern : string -> string

(** 未知检查器类型模式: 未知的检查器类型: checker_type *)
val unknown_checker_type_pattern : string -> string

(** 意外异常模式: 意外异常: exception_string *)
val unexpected_exception_pattern : string -> string

(** 通用错误模式: context: message *)
val generic_error_pattern : string -> string -> string

(** 未定义变量模式: 未定义的变量: var_name *)
val undefined_variable_pattern : string -> string

(** 变量已定义模式: 变量已定义: var_name *)
val variable_already_defined_pattern : string -> string

(** 函数未找到模式: 函数未找到: func_name *)
val function_not_found_pattern : string -> string

(** 函数参数不匹配模式: 函数「func_name」参数数量不匹配: 期望 expected 个参数，但提供了 actual 个参数 *)
val function_param_mismatch_pattern : string -> int -> int -> string

(** 未定义模块模式: 未定义的模块: mod_name *)
val module_not_found_pattern : string -> string

(** 成员未找到模式: 模块 mod_name 中未找到成员: member_name *)
val member_not_found_pattern : string -> string -> string

(** 无效操作模式: 无效操作: operation *)
val invalid_operation_pattern : string -> string

(** 模式匹配失败模式: 模式匹配失败: 无法匹配类型为 value_type 的值 *)
val pattern_match_failure_pattern : string -> string

(** 错误统计模式: 🚨 错误: X 个 *)
val error_count_pattern : int -> string

(** 警告统计模式: ⚠️ 警告: X 个 *)
val warning_count_pattern : int -> string

(** 风格统计模式: 🎨 风格: X 个 *)
val style_count_pattern : int -> string

(** 提示统计模式: 💡 提示: X 个 *)
val info_count_pattern : int -> string

(** 建议替换模式: 建议将「current」改为「suggestion」 *)
val suggestion_replacement_pattern : string -> string -> string

(** 相似度匹配模式: 可能想使用：「match_name」(相似度: score%) *)
val similarity_match_pattern : string -> float -> string

(** 违规报告编号模式: N. icon severity message *)
val violation_numbered_pattern : int -> string -> string -> string -> string

(** 违规建议模式: 💡 建议: X *)
val violation_suggestion_pattern : string -> string

(** 违规置信度模式: 🎯 置信度: X% *)
val violation_confidence_pattern : float -> string

(** 变量纠正模式: 将变量名"X"纠正为"Y" *)
val variable_correction_pattern : string -> string -> string