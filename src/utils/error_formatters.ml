(** 骆言编译器错误消息格式化模块

    此模块专门负责各类错误消息的标准化格式化，提供统一的错误信息显示模式。

    设计原则:
    - 一致性：所有错误消息遵循统一的格式模式
    - 可读性：错误信息清晰易懂，便于调试和修复
    - 中文本地化：所有错误消息使用简体中文
    - 上下文感知：提供丰富的错误上下文信息

    用途：为整个编译器提供标准化的错误消息格式化服务 *)

open Base_string_ops

(** 错误消息格式化工具模块 *)
module Error_formatters = struct
  (** 错误上下文模式: context: message *)
  let context_message_pattern context message = concat_strings [ context; ": "; message ]

  (** 参数计数模式: 期望X个参数，但获得Y个参数 *)
  let param_count_pattern expected actual =
    concat_strings [ "期望"; int_to_string expected; "个参数，但获得"; int_to_string actual; "个参数" ]

  (** 函数名模式: 函数名函数 *)
  let function_name_pattern func_name = concat_strings [ func_name; "函数" ]

  (** 函数错误模式: 函数名函数期望X个参数，但获得Y个参数 *)
  let function_param_error_pattern func_name expected actual =
    concat_strings [ func_name; "函数"; param_count_pattern expected actual ]

  (** 类型期望模式: 期望X参数 *)
  let type_expectation_pattern expected_type = concat_strings [ "期望"; expected_type; "参数" ]

  (** 函数类型错误模式: 函数名函数期望X参数 *)
  let function_type_error_pattern func_name expected_type =
    concat_strings [ func_name; "函数"; type_expectation_pattern expected_type ]

  (** 类型不匹配模式: 期望 X，但得到 Y *)
  let type_mismatch_pattern expected actual = concat_strings [ "期望 "; expected; "，但得到 "; actual ]

  (** 索引超出范围模式: 索引 X 超出范围，数组长度为 Y *)
  let index_out_of_bounds_pattern index length =
    concat_strings [ "索引 "; int_to_string index; " 超出范围，数组长度为 "; int_to_string length ]

  (** 文件操作错误模式: 无法X文件: Y *)
  let file_operation_error_pattern operation filename =
    concat_strings [ "无法"; operation; "文件: "; filename ]

  (** 文件操作错误模式: 文件未找到: filename *)
  let file_not_found_pattern filename = concat_strings [ "文件未找到: "; filename ]

  (** 文件读取错误模式: 无法读取测试配置文件: filename *)
  let file_read_error_pattern filename = concat_strings [ "无法读取测试配置文件: "; filename ]

  (** 文件写入错误模式: 文件写入错误: filename *)
  let file_write_error_pattern filename = concat_strings [ "文件写入错误: "; filename ]

  (** 类型不匹配错误模式: 类型不匹配: type_info *)
  let type_mismatch_error_pattern type_info = concat_strings [ "类型不匹配: "; type_info ]

  (** 未知类型错误模式: 未知类型: type_name *)
  let unknown_type_pattern type_name = concat_strings [ "未知类型: "; type_name ]

  (** 无效类型操作模式: 无效的类型操作: op_name *)
  let invalid_type_operation_pattern op_name = concat_strings [ "无效的类型操作: "; op_name ]

  (** 解析失败模式: format解析失败: message *)
  let parse_failure_pattern format msg = concat_strings [ format; "解析失败: "; msg ]

  (** JSON解析错误模式: 测试配置JSON格式错误: message *)
  let json_parse_error_pattern msg = concat_strings [ "测试配置JSON格式错误: "; msg ]

  (** 测试用例解析错误模式: 解析测试用例失败: message *)
  let test_case_parse_error_pattern msg = concat_strings [ "解析测试用例失败: "; msg ]

  (** 配置解析错误模式: 解析测试配置失败: message *)
  let config_parse_error_pattern msg = concat_strings [ "解析测试配置失败: "; msg ]

  (** 配置列表解析错误模式: 解析测试配置列表失败: message *)
  let config_list_parse_error_pattern msg = concat_strings [ "解析测试配置列表失败: "; msg ]

  (** 综合测试解析错误模式: 解析综合测试用例失败: message *)
  let comprehensive_test_parse_error_pattern msg = concat_strings [ "解析综合测试用例失败: "; msg ]

  (** 摘要项目解析错误模式: 解析测试摘要项目失败: message *)
  let summary_items_parse_error_pattern msg = concat_strings [ "解析测试摘要项目失败: "; msg ]

  (** 未知检查器类型模式: 未知的检查器类型: checker_type *)
  let unknown_checker_type_pattern checker_type = concat_strings [ "未知的检查器类型: "; checker_type ]

  (** 意外异常模式: 意外异常: exception_string *)
  let unexpected_exception_pattern exn_str = concat_strings [ "意外异常: "; exn_str ]

  (** 通用错误模式: context: message *)
  let generic_error_pattern context message = concat_strings [ context; ": "; message ]

  (** 未定义变量模式: 未定义的变量: var_name *)
  let undefined_variable_pattern var_name = concat_strings [ "未定义的变量: "; var_name ]

  (** 变量已定义模式: 变量已定义: var_name *)
  let variable_already_defined_pattern var_name = concat_strings [ "变量已定义: "; var_name ]

  (** 函数未找到模式: 函数未找到: func_name *)
  let function_not_found_pattern func_name = concat_strings [ "函数未找到: "; func_name ]

  (** 函数参数不匹配模式: 函数「func_name」参数数量不匹配: 期望 expected 个参数，但提供了 actual 个参数 *)
  let function_param_mismatch_pattern func_name expected actual =
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

  (** 未定义模块模式: 未定义的模块: mod_name *)
  let module_not_found_pattern mod_name = concat_strings [ "未定义的模块: "; mod_name ]

  (** 成员未找到模式: 模块 mod_name 中未找到成员: member_name *)
  let member_not_found_pattern mod_name member_name =
    concat_strings [ "模块 "; mod_name; " 中未找到成员: "; member_name ]

  (** 无效操作模式: 无效操作: operation *)
  let invalid_operation_pattern operation = concat_strings [ "无效操作: "; operation ]

  (** 模式匹配失败模式: 模式匹配失败: 无法匹配类型为 value_type 的值 *)
  let pattern_match_failure_pattern value_type =
    concat_strings [ "模式匹配失败: 无法匹配类型为 "; value_type; " 的值" ]

  (** 错误统计模式: 🚨 错误: X 个 *)
  let error_count_pattern count = concat_strings [ "   🚨 错误: "; int_to_string count; " 个" ]

  (** 警告统计模式: ⚠️ 警告: X 个 *)
  let warning_count_pattern count = concat_strings [ "   ⚠️ 警告: "; int_to_string count; " 个" ]

  (** 风格统计模式: 🎨 风格: X 个 *)
  let style_count_pattern count = concat_strings [ "   🎨 风格: "; int_to_string count; " 个" ]

  (** 提示统计模式: 💡 提示: X 个 *)
  let info_count_pattern count = concat_strings [ "   💡 提示: "; int_to_string count; " 个" ]

  (** 建议替换模式: 建议将「current」改为「suggestion」 *)
  let suggestion_replacement_pattern current suggestion =
    concat_strings [ "建议将「"; current; "」改为「"; suggestion; "」" ]

  (** 相似度匹配模式: 可能想使用：「match_name」(相似度: score%) *)
  let similarity_match_pattern match_name score =
    concat_strings [ "可能想使用：「"; match_name; "」(相似度: "; float_to_string (score *. 100.0); "%%)" ]

  (** 违规报告编号模式: N. icon severity message *)
  let violation_numbered_pattern num icon severity message =
    concat_strings [ int_to_string (num + 1); ". "; icon; " "; severity; " "; message ]

  (** 违规建议模式: 💡 建议: X *)
  let violation_suggestion_pattern suggestion = concat_strings [ "   💡 建议: "; suggestion ]

  (** 违规置信度模式: 🎯 置信度: X% *)
  let violation_confidence_pattern confidence =
    concat_strings [ "   🎯 置信度: "; float_to_string (confidence *. 100.0); "%%" ]

  (** 变量纠正模式: 将变量名"X"纠正为"Y" *)
  let variable_correction_pattern original corrected =
    concat_strings [ "将变量名\""; original; "\"纠正为\""; corrected; "\"" ]
end

include Error_formatters
(** 导出错误格式化函数到顶层，便于使用 *)