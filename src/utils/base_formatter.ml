(** 骆言编译器底层格式化基础设施

    此模块提供不依赖Printf.sprintf的基础字符串格式化工具， 解决项目中Printf.sprintf重复使用导致的架构设计矛盾问题。

    设计原则:
    - 零Printf.sprintf依赖：底层模块不使用Printf.sprintf
    - 高性能字符串操作：使用最优化的字符串拼接
    - 模式化设计：提供常用格式化模式的专用函数
    - 类型安全：提供类型安全的格式化接口

    用途：作为所有上层格式化模块的基础设施 *)

(** 基础字符串格式化工具模块 *)
module Base_formatter = struct
  (** 基础字符串拼接函数 *)
  let concat_strings parts = String.concat "" parts

  (** 带分隔符的字符串拼接 *)
  let join_with_separator sep parts = String.concat sep parts

  (** 基础类型转换函数 *)
  let int_to_string = string_of_int

  let float_to_string = string_of_float
  let bool_to_string = string_of_bool
  let char_to_string c = String.make 1 c

  (** 常用格式化模式 *)

  (** Token模式: TokenType(value) *)
  let token_pattern token_type value = concat_strings [ token_type; "("; value; ")" ]

  (** Token模式: TokenType('char') *)
  let char_token_pattern token_type char =
    concat_strings [ token_type; "('"; char_to_string char; "')" ]

  (** 错误上下文模式: context: message *)
  let context_message_pattern context message = concat_strings [ context; ": "; message ]

  (** 位置信息模式: filename:line:column *)
  let file_position_pattern filename line column =
    concat_strings [ filename; ":"; int_to_string line; ":"; int_to_string column ]

  (** 位置信息模式: (line:column): message *)
  let line_col_message_pattern line col message =
    concat_strings [ "("; int_to_string line; ":"; int_to_string col; "): "; message ]

  (** Token位置模式: token@line:column *)
  let token_position_pattern token line column =
    concat_strings [ token; "@"; int_to_string line; ":"; int_to_string column ]

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

  (** C代码生成模式: luoyan_function_name(args) *)
  let luoyan_function_pattern func_name args =
    concat_strings [ "luoyan_"; func_name; "("; args; ")" ]

  (** C环境绑定模式: luoyan_env_bind(env, "var", expr); *)
  let luoyan_env_bind_pattern var_name expr =
    concat_strings [ "luoyan_env_bind(env, \""; var_name; "\", "; expr; ");" ]

  (** C代码结构模式: includes + functions + main *)
  let c_code_structure_pattern includes functions main =
    concat_strings [ includes; "\n\n"; functions; "\n\n"; main; "\n" ]

  (** 统计报告模式: icon category: count 个 *)
  let stat_report_pattern icon category count =
    concat_strings [ "   "; icon; " "; category; ": "; int_to_string count; " 个" ]

  (** 带换行的统计报告模式 *)
  let stat_report_line_pattern icon category count =
    concat_strings [ stat_report_pattern icon category count; "\n" ]

  (** 分析消息模式: icon message *)
  let analysis_message_pattern icon message = concat_strings [ icon; " "; message ]

  (** 带换行的分析消息模式 *)
  let analysis_message_line_pattern icon message =
    concat_strings [ analysis_message_pattern icon message; "\n\n" ]

  (** 性能分析消息模式: 创建了包含X个元素的大型Y *)
  let performance_creation_pattern count item_type =
    concat_strings [ "创建了包含"; int_to_string count; "个元素的大型"; item_type ]

  (** 性能字段分析模式: 创建了包含X个字段的大型Y *)
  let performance_field_pattern field_count record_type =
    concat_strings [ "创建了包含"; int_to_string field_count; "个字段的大型"; record_type ]

  (** 诗词字符数不匹配模式: 字符数不匹配：期望X字，实际Y字 *)
  let poetry_char_count_pattern expected actual =
    concat_strings [ "字符数不匹配：期望"; int_to_string expected; "字，实际"; int_to_string actual; "字" ]

  (** 诗词对偶不匹配模式: 对偶字数不匹配：左联X字，右联Y字 *)
  let poetry_couplet_pattern left_count right_count =
    concat_strings
      [ "对偶字数不匹配：左联"; int_to_string left_count; "字，右联"; int_to_string right_count; "字" ]

  (** 绝句格式模式: 绝句包含X句，通常为4句 *)
  let poetry_quatrain_pattern verse_count =
    concat_strings [ "绝句包含"; int_to_string verse_count; "句，通常为4句" ]

  (** 列表格式化 - 方括号包围，分号分隔 *)
  let list_format items = concat_strings [ "["; join_with_separator "; " items; "]" ]

  (** 函数调用格式化: FunctionName(arg1, arg2, ...) *)
  let function_call_format func_name args =
    concat_strings [ func_name; "("; join_with_separator ", " args; ")" ]

  (** 模块访问格式化: Module.member *)
  let module_access_format module_name member_name =
    concat_strings [ module_name; "."; member_name ]

  (** 高级模板替换函数（用于复杂场景） *)
  let template_replace template replacements =
    List.fold_left
      (fun acc (placeholder, value) -> Str.global_replace (Str.regexp_string placeholder) value acc)
      template replacements

  (** 错误消息格式化模式扩展 *)

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

  (** 位置格式化专用模式扩展 - 第三阶段Printf.sprintf统一化 *)

  (** 标准位置格式: filename:line:column *)
  let position_standard filename line column =
    concat_strings [ filename; ":"; int_to_string line; ":"; int_to_string column ]

  (** 中文行列格式: 行:line 列:column *)
  let position_chinese_format line column =
    concat_strings [ "行:"; int_to_string line; " 列:"; int_to_string column ]

  (** 括号位置格式: (行:line, 列:column) *)
  let position_parentheses line column =
    concat_strings [ "(行:"; int_to_string line; ", 列:"; int_to_string column; ")" ]

  (** 位置范围格式: start_line:start_col-end_line:end_col *)
  let position_range start_line start_col end_line end_col =
    concat_strings
      [
        int_to_string start_line;
        ":";
        int_to_string start_col;
        "-";
        int_to_string end_line;
        ":";
        int_to_string end_col;
      ]

  (** 简化行号格式: 行:line *)
  let line_only_format line = concat_strings [ "行:"; int_to_string line ]

  (** 行号带冒号格式: line: *)
  let line_with_colon_format line = concat_strings [ int_to_string line; ":" ]

  (** 带偏移的位置格式: 行:line 列:column 偏移:offset *)
  let position_with_offset_format line column offset =
    concat_strings
      [ "行:"; int_to_string line; " 列:"; int_to_string column; " 偏移:"; int_to_string offset ]

  (** 相对位置格式: 相对位置(+line_diff,+col_diff) *)
  let relative_position_format line_diff col_diff =
    concat_strings [ "相对位置(+"; int_to_string line_diff; ",+"; int_to_string col_diff; ")" ]

  (** 完整文件位置格式: 文件:filename 行:line 列:column *)
  let full_position_with_file_format filename line column =
    concat_strings [ "文件:"; filename; " 行:"; int_to_string line; " 列:"; int_to_string column ]

  (** 同行位置范围格式: 第line行 列start_col-end_col *)
  let same_line_range_format line start_col end_col =
    concat_strings
      [ "第"; int_to_string line; "行 列"; int_to_string start_col; "-"; int_to_string end_col ]

  (** 多行位置范围格式: 第start_line行第start_col列 至 第end_line行第end_col列 *)
  let multi_line_range_format start_line start_col end_line end_col =
    concat_strings
      [
        "第";
        int_to_string start_line;
        "行第";
        int_to_string start_col;
        "列 至 第";
        int_to_string end_line;
        "行第";
        int_to_string end_col;
        "列";
      ]

  (** 错误位置标记格式: >>> 错误位置: 行:line 列:column *)
  let error_position_marker_format line column =
    concat_strings [ ">>> 错误位置: 行:"; int_to_string line; " 列:"; int_to_string column ]

  (** 调试位置信息格式: [DEBUG] func_name@filename:line:column *)
  let debug_position_info_format filename line column func_name =
    concat_strings
      [ "[DEBUG] "; func_name; "@"; filename; ":"; int_to_string line; ":"; int_to_string column ]

  (** 错误类型与位置结合格式: error_type pos_str: message *)
  let error_type_with_position_format error_type pos_str message =
    concat_strings [ error_type; pos_str; ": "; message ]

  (** 可选位置包装格式: 如果有位置则返回 ( position )，否则返回空字符串 *)
  let optional_position_wrapper_format position_str =
    if position_str = "" then "" else concat_strings [ " ("; position_str; ")" ]

  (** 第三阶段Phase 3.3扩展：报告格式化和C代码生成专用模式 *)

  (** 上下文信息模式: 📍 上下文: context *)
  let context_info_pattern context = concat_strings [ "📍 上下文: "; context; "\n\n" ]

  (** 建议替换模式: 建议将「current」改为「suggestion」 *)
  let suggestion_replacement_pattern current suggestion =
    concat_strings [ "建议将「"; current; "」改为「"; suggestion; "」" ]

  (** 相似度匹配模式: 可能想使用：「match_name」(相似度: score%) *)
  let similarity_match_pattern match_name score =
    concat_strings [ "可能想使用：「"; match_name; "」(相似度: "; float_to_string (score *. 100.0); "%%)" ]

  (** 双参数函数模式: func_name(param1, param2) *)
  let binary_function_pattern func_name param1 param2 =
    concat_strings [ func_name; "("; param1; ", "; param2; ")" ]

  (** Luoyan字符串相等检查模式: luoyan_equals(expr, luoyan_string("str")) *)
  let luoyan_string_equality_pattern expr_var str =
    concat_strings [ "luoyan_equals("; expr_var; ", luoyan_string(\""; str; "\"))" ]

  (** C类型转换模式: (type)expr *)
  let c_type_cast_pattern target_type expr = concat_strings [ "("; target_type; ")"; expr ]

  (** 第六阶段扩展：C代码生成和类型系统专用模式 *)

  (** C记录字段格式: {"field_name", expr} *)
  let c_record_field_pattern field_name expr =
    concat_strings [ "{\""; field_name; "\", "; expr; "}" ]

  (** C记录构造模式: luoyan_record(count, (luoyan_field_t[]){fields}) *)
  let c_record_constructor_pattern count fields =
    concat_strings [ "luoyan_record("; int_to_string count; ", (luoyan_field_t[]){"; fields; "})" ]

  (** C记录访问模式: luoyan_record_get(record, "field") *)
  let c_record_get_pattern record field =
    concat_strings [ "luoyan_record_get("; record; ", \""; field; "\")" ]

  (** C记录更新模式: luoyan_record_update(record, count, (luoyan_field_t[]){updates}) *)
  let c_record_update_pattern record count updates =
    concat_strings
      [
        "luoyan_record_update(";
        record;
        ", ";
        int_to_string count;
        ", (luoyan_field_t[]){";
        updates;
        "})";
      ]

  (** C构造器模式: luoyan_constructor("name", count, args) *)
  let c_constructor_pattern name count args =
    concat_strings [ "luoyan_constructor(\""; name; "\", "; int_to_string count; ", "; args; ")" ]

  (** C值数组模式: (luoyan_value_t[]){values} *)
  let c_value_array_pattern values = concat_strings [ "(luoyan_value_t[]){"; values; "}" ]

  (** C变量命名模式: luoyan_var_prefix_id *)
  let c_var_name_pattern prefix id = concat_strings [ "luoyan_var_"; prefix; "_"; int_to_string id ]

  (** C标签命名模式: luoyan_label_prefix_id *)
  let c_label_name_pattern prefix id =
    concat_strings [ "luoyan_label_"; prefix; "_"; int_to_string id ]

  (** ASCII转义模式: _asciiNUM_ *)
  let ascii_escape_pattern ascii_code = concat_strings [ "_ascii"; int_to_string ascii_code; "_" ]

  (** C类型模式: luoyan_type_name_t* *)
  let c_type_pointer_pattern type_name = concat_strings [ "luoyan_"; type_name; "_t*" ]

  (** C用户类型模式: luoyan_user_name_t* *)
  let c_user_type_pattern name = concat_strings [ "luoyan_user_"; name; "_t*" ]

  (** C类模式: luoyan_class_name_t* *)
  let c_class_type_pattern name = concat_strings [ "luoyan_class_"; name; "_t*" ]

  (** C私有类型模式: luoyan_private_name_t* *)
  let c_private_type_pattern name = concat_strings [ "luoyan_private_"; name; "_t*" ]

  (** 类型转换日志模式: 将source_type转换为target_type *)
  let type_conversion_log_pattern source_type target_type =
    concat_strings [ "将"; source_type; "转换为"; target_type ]

  (** 浮点数整数转换模式: 将浮点数X转换为整数Y *)
  let float_to_int_conversion_pattern float_val int_val =
    concat_strings [ "将浮点数"; float_to_string float_val; "转换为整数"; int_to_string int_val ]

  (** 字符串整数转换模式: 将字符串"X"转换为整数Y *)
  let string_to_int_conversion_pattern string_val int_val =
    concat_strings [ "将字符串\""; string_val; "\"转换为整数"; int_to_string int_val ]

  (** 布尔值整数转换模式: 将布尔值X转换为整数Y *)
  let bool_to_int_conversion_pattern bool_val int_val =
    concat_strings [ "将布尔值"; (if bool_val then "真" else "假"); "转换为整数"; int_to_string int_val ]

  (** 整数浮点数转换模式: 将整数X转换为浮点数Y *)
  let int_to_float_conversion_pattern int_val float_val =
    concat_strings [ "将整数"; int_to_string int_val; "转换为浮点数"; float_to_string float_val ]

  (** 字符串浮点数转换模式: 将字符串"X"转换为浮点数Y *)
  let string_to_float_conversion_pattern string_val float_val =
    concat_strings [ "将字符串\""; string_val; "\"转换为浮点数"; float_to_string float_val ]

  (** 值到字符串转换模式: 将X转换为字符串"Y" *)
  let value_to_string_conversion_pattern value_type string_val =
    concat_strings [ "将"; value_type; "转换为字符串\""; string_val; "\"" ]

  (** 变量纠正模式: 将变量名"X"纠正为"Y" *)
  let variable_correction_pattern original corrected =
    concat_strings [ "将变量名\""; original; "\"纠正为\""; corrected; "\"" ]

  (** 类型缓存统计模式: 推断调用: X *)
  let cache_stat_infer_pattern count = concat_strings [ "  推断调用: "; int_to_string count ]

  (** 类型缓存统计模式: 合一调用: X *)
  let cache_stat_unify_pattern count = concat_strings [ "  合一调用: "; int_to_string count ]

  (** 类型缓存统计模式: 替换应用: X *)
  let cache_stat_subst_pattern count = concat_strings [ "  替换应用: "; int_to_string count ]

  (** 类型缓存统计模式: 缓存命中: X *)
  let cache_stat_hit_pattern count = concat_strings [ "  缓存命中: "; int_to_string count ]

  (** 类型缓存统计模式: 缓存未命中: X *)
  let cache_stat_miss_pattern count = concat_strings [ "  缓存未命中: "; int_to_string count ]

  (** 缓存命中率模式: 命中率: X% *)
  let cache_hit_rate_pattern rate = concat_strings [ "  命中率: "; float_to_string rate; "%%" ]

  (** 缓存大小模式: 缓存大小: X *)
  let cache_size_pattern size = concat_strings [ "  缓存大小: "; int_to_string size ]

  (** 语义分析报告标题模式: === 函数「name」语义分析报告 === *)
  let semantic_report_title_pattern func_name =
    concat_strings [ "=== 函数「"; func_name; "」语义分析报告 ===\n" ]

  (** 递归特性模式: 递归特性: 是/否 *)
  let recursive_feature_pattern is_recursive =
    concat_strings [ "递归特性: "; (if is_recursive then "是" else "否"); "\n" ]

  (** 复杂度级别模式: 复杂度级别: X *)
  let complexity_level_pattern level = concat_strings [ "复杂度级别: "; int_to_string level; "\n" ]

  (** 推断返回类型模式: 推断返回类型: X *)
  let inferred_return_type_pattern return_type = concat_strings [ "推断返回类型: "; return_type; "\n" ]

  (** 参数分析模式: 参数「name」: *)
  let param_analysis_pattern param_name = concat_strings [ "  参数「"; param_name; "」:\n" ]

  (** 递归上下文模式: 递归上下文: 是/否 *)
  let recursive_context_pattern is_recursive =
    concat_strings [ "    递归上下文: "; (if is_recursive then "是" else "否"); "\n" ]

  (** 使用模式模式: 使用模式: X *)
  let usage_pattern_pattern patterns = concat_strings [ "    使用模式: "; patterns; "\n" ]

  (** 违规报告编号模式: N. icon severity message *)
  let violation_numbered_pattern num icon severity message =
    concat_strings [ int_to_string (num + 1); ". "; icon; " "; severity; " "; message ]

  (** 违规建议模式: 💡 建议: X *)
  let violation_suggestion_pattern suggestion = concat_strings [ "   💡 建议: "; suggestion ]

  (** 违规置信度模式: 🎯 置信度: X% *)
  let violation_confidence_pattern confidence =
    concat_strings [ "   🎯 置信度: "; float_to_string (confidence *. 100.0); "%%" ]

  (** 错误统计模式: 🚨 错误: X 个 *)
  let error_count_pattern count = concat_strings [ "   🚨 错误: "; int_to_string count; " 个" ]

  (** 警告统计模式: ⚠️ 警告: X 个 *)
  let warning_count_pattern count = concat_strings [ "   ⚠️ 警告: "; int_to_string count; " 个" ]

  (** 风格统计模式: 🎨 风格: X 个 *)
  let style_count_pattern count = concat_strings [ "   🎨 风格: "; int_to_string count; " 个" ]

  (** 提示统计模式: 💡 提示: X 个 *)
  let info_count_pattern count = concat_strings [ "   💡 提示: "; int_to_string count; " 个" ]

  (** 第二阶段扩展：新增格式化模式已直接在unified_formatter中实现，保持base_formatter精简 *)

  (** 第八阶段扩展：错误处理基础设施相关格式化模式已在unified_formatter中直接实现，保持基础模块简洁 *)
end

include Base_formatter
(** 导出常用函数到顶层，便于使用 *)
