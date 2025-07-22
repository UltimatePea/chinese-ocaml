(** 骆言编译器统一格式化工具 - Fix #853: Printf.sprintf模式统一优化

    此模块提供统一的字符串格式化接口，消除项目中Printf.sprintf重复使用。 现已使用基础格式化器实现，零Printf.sprintf依赖。

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

  (** 变量拼写纠正消息 *)
  let variable_spell_correction original corrected = 
    concat_strings ["变量名'"; original; "'未找到，使用最接近的'"; corrected; "'"]
  
  (** 错误分析专用格式化 - 第八阶段扩展 *)
  
  (** 函数参数数量不匹配错误消息 *)
  let function_arity_mismatch expected actual = 
    concat_strings ["函数参数数量不匹配: 期望 "; int_to_string expected; " 个，提供了 "; int_to_string actual; " 个"]
    
  (** 函数参数修复提示 *)
  let function_missing_params_hint missing_count = 
    concat_strings ["添加缺失的 "; int_to_string missing_count; " 个参数"]
    
  let function_excess_params_hint excess_count = 
    concat_strings ["移除多余的 "; int_to_string excess_count; " 个参数"]
    
  (** 模式匹配相关错误格式化 *)
  let missing_pattern_case pattern = 
    concat_strings ["缺少模式: "; pattern]
    
  let pattern_match_branch_hint pattern = 
    concat_strings ["添加分支: ｜ "; pattern; " → 结果"]
    
  (** 编译器错误创建专用格式化 *)
  let unsupported_keyword keyword = concat_strings ["不支持的关键字: "; keyword]
  let unsupported_feature feature = concat_strings ["不支持的功能: "; feature]
  let invalid_character char = concat_strings ["无效字符: "; char_to_string char]
  let unexpected_state state context = concat_strings ["意外的状态: "; state; " (上下文: "; context; ")"]
  let pattern_match_failure_with_desc pattern_desc = concat_strings ["模式匹配失败: "; pattern_desc]
  
  (** 错误工具类专用格式化 *)
  let unsupported_type context_desc = concat_strings ["不支持的"; context_desc; "类型"]
  let function_unsupported_type func_name context_desc = concat_strings [func_name; ": 不支持的"; context_desc; "类型"]
  let detailed_unsupported_type func_name context_desc details = concat_strings [func_name; ": 不支持的"; context_desc; "类型: "; details]
end

(** 编译器状态消息格式化 *)
module CompilerMessages = struct
  let compiling_file filename = context_message_pattern "正在编译文件" filename
  let compilation_complete filename = context_message_pattern "编译完成" filename
  let compilation_failed filename error = concat_strings [ "编译失败: "; filename; " - "; error ]

  (** 符号禁用消息 *)
  let unsupported_chinese_symbol char_bytes =
    concat_strings [ "非支持的中文符号已禁用，只支持「」『』：，。（）。禁用符号: "; char_bytes ]
end

(** C代码生成格式化 *)
module CCodegen = struct
  (** 函数调用 *)
  let function_call func_name args = function_call_format func_name args

  let binary_function_call func_name left right = function_call_format func_name [ left; right ]
  let unary_function_call func_name operand = function_call_format func_name [ operand ]

  (** 骆言特定格式 *)
  let luoyan_call func_code arg_count args_code =
    function_call_format "luoyan_call" [ func_code; int_to_string arg_count; args_code ]

  let luoyan_bind_var var_name value =
    concat_strings [ "luoyan_bind_var(\""; var_name; "\", "; value; ")" ]

  let luoyan_string s = concat_strings [ "luoyan_string(\""; String.escaped s; "\")" ]
  let luoyan_int i = function_call_format "luoyan_int" [ int_to_string i ]
  let luoyan_float f = function_call_format "luoyan_float" [ float_to_string f ]
  let luoyan_bool b = function_call_format "luoyan_bool" [ (if b then "true" else "false") ]
  let luoyan_unit () = "luoyan_unit()"
  let luoyan_equals expr_var value = function_call_format "luoyan_equals" [ expr_var; value ]

  let luoyan_let var_name value_code body_code =
    function_call_format "luoyan_let" [ "\"" ^ var_name ^ "\""; value_code; body_code ]

  let luoyan_function_create func_name first_param =
    concat_strings
      [ "luoyan_function_create("; func_name; "_impl_"; first_param; ", env, \""; func_name; "\")" ]

  let luoyan_pattern_match expr_var = function_call_format "luoyan_pattern_match" [ expr_var ]

  let luoyan_var_expr expr_var expr_code =
    concat_strings
      [ "({ luoyan_value_t* "; expr_var; " = "; expr_code; "; luoyan_match("; expr_var; "); })" ]

  (** 环境绑定格式化 *)
  let luoyan_env_bind var_name expr_code = luoyan_env_bind_pattern var_name expr_code

  let luoyan_function_create_with_args func_code func_name =
    concat_strings
      [ "luoyan_function_create("; func_code; ", env, \""; String.escaped func_name; "\")" ]

  (** 字符串相等性检查 *)
  let luoyan_string_equality_check expr_var escaped_string =
    concat_strings [ "luoyan_equals("; expr_var; ", luoyan_string(\""; escaped_string; "\"))" ]

  (** 编译日志消息 *)
  let compilation_start_message output_file = concat_strings [ "开始编译为C代码，输出文件："; output_file ]

  let compilation_status_message action details = context_message_pattern action details

  (** 异常处理格式化 - Phase 3 新增 *)
  let luoyan_catch branch_code = function_call_format "luoyan_catch" [ branch_code ]
  
  let luoyan_try_catch try_code catch_code finally_code =
    function_call_format "luoyan_try_catch" [ try_code; catch_code; finally_code ]
  
  let luoyan_raise expr_code = function_call_format "luoyan_raise" [ expr_code ]
  
  (** 组合表达式格式化 - Phase 3 新增 *)
  let luoyan_combine expr_codes = 
    function_call_format "luoyan_combine" [ join_with_separator ", " expr_codes ]
  
  (** 模式匹配格式化 - Phase 3 新增 *)
  let luoyan_match_constructor expr_var constructor_name =
    function_call_format "luoyan_match_constructor" [ expr_var; "\"" ^ constructor_name ^ "\"" ]
  
  (** 模块操作格式化 - Phase 3 新增 *)  
  let luoyan_include_module module_code =
    concat_strings [ "luoyan_include_module("; module_code; ");" ]
  
  (** C语句格式化 - Phase 3 新增 *)
  let c_statement expr_code = concat_strings [ expr_code; ";" ]
  
  let c_statement_sequence stmt1 stmt2 = concat_strings [ stmt1; "; "; stmt2 ]
  
  let c_statement_block statements_with_newlines = 
    join_with_separator "\n" statements_with_newlines

  (** C模板格式化 *)
  let c_template_with_includes include_part main_part footer_part =
    c_code_structure_pattern include_part main_part footer_part
end

(** 调试和日志格式化 *)
module LogMessages = struct
  let debug module_name message =
    context_message_pattern "[DEBUG]" (context_message_pattern module_name message)

  let info module_name message =
    context_message_pattern "[INFO]" (context_message_pattern module_name message)

  let warning module_name message =
    context_message_pattern "[WARNING]" (context_message_pattern module_name message)

  let error module_name message =
    context_message_pattern "[ERROR]" (context_message_pattern module_name message)

  let trace func_name message =
    context_message_pattern "[TRACE]" (context_message_pattern func_name message)
end

(** 位置信息格式化 *)
module Position = struct
  let format_position filename line column = file_position_pattern filename line column

  let format_error_with_position position error_type message =
    concat_strings [ error_type; " "; position; ": "; message ]

  let format_optional_position = function
    | Some (filename, line, column) ->
        concat_strings [ " ("; format_position filename line column; ")" ]
    | None -> ""
end

(** 通用格式化工具 *)
module General = struct
  let format_identifier name = concat_strings [ "「"; name; "」" ]
  let format_function_signature name params = function_call_format name params

  let format_type_signature name type_params =
    concat_strings [ name; "<"; join_with_separator ", " type_params; ">" ]

  let format_module_path path = join_with_separator "." path
  let format_list items separator = join_with_separator separator items
  let format_key_value key value = context_message_pattern key value

  (** 中文语法相关 *)
  let format_chinese_list items = join_with_separator "、" items

  let format_variable_definition var_name = concat_strings [ "让 「"; var_name; "」 = 值" ]

  let format_context_info count item_type =
    concat_strings [ "当前作用域中有 "; int_to_string count; " 个可用"; item_type ]
    
  (** 函数上下文格式化 - 第八阶段扩展 *)
  let format_function_context func_name = 
    concat_strings ["函数: "; func_name]
end

(** 索引和数组操作格式化 *)
module Collections = struct
  let index_out_of_bounds index length = index_out_of_bounds_pattern index length

  let array_access_error array_name index =
    concat_strings [ "数组 "; array_name; " 索引 "; int_to_string index; " 访问错误" ]

  let array_bounds_error index array_length =
    concat_strings [ "数组索引越界: "; int_to_string index; " (数组长度: "; int_to_string array_length; ")" ]

  let list_operation_error operation = context_message_pattern "列表操作错误" operation
end

(** 转换和类型转换格式化 *)
module Conversions = struct
  let type_conversion target_type expr = concat_strings [ "("; target_type; ")"; expr ]

  let casting_error from_type to_type = concat_strings [ "无法将 "; from_type; " 转换为 "; to_type ]
end

(** 错误处理和安全操作格式化 *)
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
  
  (** 错误处理格式化增强 - 第八阶段扩展 *)
  let error_context_info source_file module_name function_name timestamp = 
    concat_strings ["\n[上下文] 文件: "; source_file; " | 模块: "; module_name; " | 函数: "; 
                    function_name; " | 时间: "; float_to_string timestamp]
end

(** Token格式化 - 第二阶段扩展 *)
module TokenFormatting = struct
  (** 基础Token类型格式化 *)
  let format_int_token i = concat_strings [ "IntToken("; int_to_string i; ")" ]
  let format_float_token f = concat_strings [ "FloatToken("; float_to_string f; ")" ]
  let format_string_token s = concat_strings [ "StringToken(\""; s; "\")" ]
  let format_identifier_token name = concat_strings [ "IdentifierToken("; name; ")" ]
  let format_quoted_identifier_token name = concat_strings [ "QuotedIdentifierToken(\""; name; "\")" ]

  (** Token错误消息 *)
  let token_expectation expected actual = concat_strings [ "期望token "; expected; "，实际 "; actual ]
  let unexpected_token token = concat_strings [ "意外的token: "; token ]

  (** 复合Token格式化 *)
  let format_keyword_token keyword = token_pattern "KeywordToken" keyword
  let format_operator_token op = token_pattern "OperatorToken" op
  let format_delimiter_token delim = token_pattern "DelimiterToken" delim
  let format_boolean_token b = token_pattern "BooleanToken" (bool_to_string b)

  (** 特殊Token格式化 *)
  let format_eof_token () = "EOFToken"
  let format_newline_token () = "NewlineToken"
  let format_whitespace_token () = "WhitespaceToken"
  let format_comment_token content = token_pattern "CommentToken" content

  (** Token位置信息结合格式化 *)
  let format_token_with_position token line col = 
    token_position_pattern token line col
end

(** 增强错误消息 - 第二阶段扩展 *)
module EnhancedErrorMessages = struct
  (** 变量相关增强错误 *)
  let undefined_variable_enhanced var_name = concat_strings [ "未定义的变量: "; var_name ]
  let variable_already_defined_enhanced var_name = concat_strings [ "变量已定义: "; var_name ]
  
  (** 模块相关增强错误 *)
  let module_member_not_found mod_name member_name = 
    concat_strings [ "模块 "; mod_name; " 中未找到成员: "; member_name ]
  
  (** 文件相关增强错误 *)
  let file_not_found_enhanced filename = concat_strings [ "文件未找到: "; filename ]
  
  (** Token相关增强错误 - 直接使用TokenFormatting模块 *)
  let token_expectation_error = TokenFormatting.token_expectation
  let unexpected_token_error = TokenFormatting.unexpected_token
end

(** 增强位置信息 - 第二阶段扩展 *)
module EnhancedPosition = struct
  (** 基础位置格式化变体 *)
  let simple_line_col line col = 
    concat_strings [ "行:"; int_to_string line; " 列:"; int_to_string col ]
  let parenthesized_line_col line col = 
    concat_strings [ "(行:"; int_to_string line; ", 列:"; int_to_string col; ")" ]
  
  (** 范围位置格式化 *)
  let range_position start_line start_col end_line end_col = 
    concat_strings [ 
      "第"; int_to_string start_line; "行第"; int_to_string start_col; "列 至 ";
      "第"; int_to_string end_line; "行第"; int_to_string end_col; "列"
    ]
  
  (** 错误位置标记 *)
  let error_position_marker line col = 
    concat_strings [ ">>> 错误位置: 行:"; int_to_string line; " 列:"; int_to_string col ]
  
  (** 与现有格式兼容的包装函数 *)
  let format_position_enhanced filename line column = 
    file_position_pattern filename line column
  
  let format_error_with_enhanced_position position error_type message =
    concat_strings [ error_type; " "; position; ": "; message ]
end

(** C代码生成增强 - 第二阶段扩展 *)
module EnhancedCCodegen = struct
  (** 类型转换 *)
  let type_cast target_type expr = concat_strings [ "("; target_type; ")"; expr ]
  
  (** 构造器匹配 *)
  let constructor_match expr_var constructor = 
    concat_strings [ "luoyan_match_constructor("; expr_var; ", \""; String.escaped constructor; "\")" ]
  
  (** 字符串相等性检查（转义版本）*)
  let string_equality_escaped expr_var escaped_string = 
    concat_strings [ "luoyan_equals("; expr_var; ", luoyan_string(\""; escaped_string; "\"))" ]
  
  (** 扩展的骆言函数调用 *)
  let luoyan_call_with_cast func_name cast_type args = 
    concat_strings [ "("; cast_type; ")"; function_call_format func_name args ]
  
  (** 复合C代码模式 *)
  let luoyan_conditional_binding var_name condition true_expr false_expr =
    concat_strings [ 
      "luoyan_value_t* "; var_name; " = "; condition; " ? "; 
      true_expr; " : "; false_expr; ";" 
    ]
end

(** 诗词分析格式化 - Phase 3C 扩展 *)
module PoetryFormatting = struct
  (** 诗词评价报告 *)
  let evaluation_report title overall_grade score = 
    concat_strings [ "《"; title; "》评价报告：\n总评："; overall_grade; "（"; float_to_string score; "分）" ]
  
  (** 韵组格式化 *)
  let rhyme_group rhyme_group = concat_strings [ "平声 "; rhyme_group; "韵" ]
  
  (** 字调错误 *)
  let tone_error position char_str needed_tone = 
    concat_strings [ "第"; int_to_string position; "字'"; char_str; "'应为"; needed_tone ]
  
  (** 诗句分析 *)
  let verse_analysis verse_num verse ending_str rhyme_group = 
    concat_strings [ "第"; int_to_string verse_num; "句："; verse; "，韵脚："; ending_str; "，韵组："; rhyme_group ]
  
  (** 诗词结构分析 *)
  let poetry_structure_analysis poem_type expected_lines actual_lines = 
    concat_strings [ 
      poem_type; "结构分析：期望"; int_to_string expected_lines; 
      "句，实际"; int_to_string actual_lines; "句" 
    ]

  (** Phase 3C 新增格式化函数 *)
  
  (** 文本长度信息格式化 *)
  let format_text_length_info length =
    concat_strings [ "文本长度: "; int_to_string length; " 字符\n" ]
  
  (** 分类统计项格式化 *)
  let format_category_count category_name count =
    concat_strings [ "  "; category_name; ": "; int_to_string count; "\n" ]
  
  (** 韵组统计项格式化 *)
  let format_rhyme_group_count group_name count =
    concat_strings [ "  "; group_name; ": "; int_to_string count; "\n" ]
  
  (** 字符查找错误格式化 *)
  let format_character_lookup_error char error_msg =
    concat_strings [ "查找字符「"; char; "」韵律信息时出错: "; error_msg ]
  
  (** 韵律数据统计格式化 *)
  let format_rhyme_data_stats series_count char_count =
    concat_strings [ "韵律数据统计: "; int_to_string series_count; "个系列, "; int_to_string char_count; "个字符" ]
  
  (** 诗词评价详细报告格式化 *)
  let format_evaluation_detailed_report title overall_grade score details =
    concat_strings [ "《"; title; "》评价报告：\n总评："; overall_grade; "（"; float_to_string score; "分）\n详细评分：\n"; details ]
  
  (** 评分维度格式化 *)
  let format_dimension_score dim_name score =
    concat_strings [ "- "; dim_name; "："; float_to_string score; "分" ]
  
  (** 韵律验证错误格式化 *)
  let format_rhyme_validation_error count error_type =
    concat_strings [ "存在 "; int_to_string count; " 个"; error_type ]
  
  (** 缓存管理错误格式化 *)
  let format_cache_duplicate_error char count =
    concat_strings [ "重复字符: "; char; " (出现"; int_to_string count; "次)" ]
  
  (** 数据加载错误格式化 *)
  let format_data_loading_error context error_msg =
    concat_strings [ context; ": "; error_msg ]
  
  (** 字符组查找错误格式化 *)
  let format_group_not_found_error group_name =
    concat_strings [ "字符组 '"; group_name; "' 不存在" ]
  
  (** JSON解析错误格式化 *)
  let format_json_parse_error operation error_msg =
    concat_strings [ operation; ": "; error_msg ]
  
  (** 灰韵组数据统计格式化 *)
  let format_hui_rhyme_stats version total_chars series_count description =
    concat_strings [ 
      "灰韵组数据统计:\n- 版本: "; version; "\n- 总字符数: "; int_to_string total_chars; 
      "\n- 系列数: "; int_to_string series_count; "\n- 描述: "; description
    ]
  
  (** 数据完整性验证格式化 *)
  let format_data_integrity_success count =
    concat_strings [ "✅ 数据完整性验证通过: "; int_to_string count; "个字符" ]
  
  let format_data_integrity_failure expected actual =
    concat_strings [ "❌ 数据完整性验证失败: 期望"; int_to_string expected; "个字符，实际"; int_to_string actual; "个字符" ]
  
  let format_data_integrity_exception error_msg =
    concat_strings [ "❌ 数据完整性验证异常: "; error_msg ]
end

(** 编译和日志增强 - Printf.sprintf统一化阶段2 *)
module EnhancedLogMessages = struct
  (** 编译状态增强消息 *)
  let compiling_file filename = concat_strings [ "正在编译文件: "; filename ]
  let compilation_complete_stats files_count time_taken = 
    concat_strings [ "编译完成: "; int_to_string files_count; " 个文件，耗时 "; float_to_string time_taken; " 秒" ]
  
  (** 操作状态消息 - Phase 2 统一的高频模式 *)
  let operation_start operation_name = concat_strings [ "开始 "; operation_name ]
  let operation_complete operation_name duration = 
    concat_strings [ "完成 "; operation_name; " (耗时: "; float_to_string duration; "秒)" ]
  let operation_failed operation_name duration error_msg = 
    concat_strings [ "失败 "; operation_name; " (耗时: "; float_to_string duration; "秒): "; error_msg ]
  
  (** 时间戳格式化 - 统一日期时间格式 *)
  let format_timestamp year month day hour min sec = 
    let pad_int n width =
      let s = int_to_string n in
      let len = String.length s in
      if len >= width then s
      else String.make (width - len) '0' ^ s
    in
    concat_strings [ 
      pad_int year 4; "-";
      pad_int month 2; "-";
      pad_int day 2; " ";
      pad_int hour 2; ":";
      pad_int min 2; ":";
      pad_int sec 2
    ]
    
  (** Unix时间结构格式化 *)
  let format_unix_time tm = 
    format_timestamp (tm.Unix.tm_year + 1900) (tm.Unix.tm_mon + 1) tm.Unix.tm_mday
      tm.Unix.tm_hour tm.Unix.tm_min tm.Unix.tm_sec
      
  (** 完整日志消息格式化 - 支持时间戳、模块名、颜色 *)
  let format_log_entry timestamp_part module_part color_part level_str message reset_color =
    concat_strings [ timestamp_part; module_part; color_part; "["; level_str; "] "; message; reset_color ]
    
  (** 简化日志消息格式化（不含颜色重置） *)
  let format_simple_log_entry timestamp_part module_part color_part level_str message =
    concat_strings [ timestamp_part; module_part; color_part; level_str; "["; level_str; "] "; message ]
  
  (** 带模块名的日志消息增强 *)
  let debug_enhanced module_name operation detail = 
    concat_strings [ "[DEBUG]["; module_name; "] "; operation; ": "; detail ]
  
  let info_enhanced module_name operation detail = 
    concat_strings [ "[INFO]["; module_name; "] "; operation; ": "; detail ]
  
  let warning_enhanced module_name operation detail = 
    concat_strings [ "[WARNING]["; module_name; "] "; operation; ": "; detail ]
  
  let error_enhanced module_name operation detail = 
    concat_strings [ "[ERROR]["; module_name; "] "; operation; ": "; detail ]
end

module ReportFormatting = struct
  (** Token注册器统计报告 *)
  let token_registry_stats total categories_count categories_detail =
    concat_strings [
      "\n=== Token注册器统计 ===\n";
      "注册Token数: "; int_to_string total; " 个\n";
      "分类数: "; int_to_string categories_count; " 个\n";
      "分类详情: "; categories_detail; "\n  "
    ]

  (** 分类统计项格式化 *)
  let category_count_item category count =
    concat_strings [category; "("; int_to_string count; ")"]

  (** Token兼容性基础报告 *)
  let token_compatibility_report total_count timestamp =
    concat_strings [
      "Token兼容性报告\n================\n";
      "总支持Token数量: "; int_to_string total_count; "\n";
      "兼容性状态: 良好\n";
      "报告生成时间: "; timestamp
    ]

  (** 详细Token兼容性报告 *)
  let detailed_token_compatibility_report total_count report_timestamp =
    concat_strings [
      "详细Token兼容性报告\n";
      "=====================\n\n";
      "支持的Token类型:\n";
      "- 基础关键字: 19个\n";
      "- 文言文关键字: 12个\n";
      "- 古雅体关键字: 8个\n";
      "- 运算符: 22个\n";
      "- 分隔符: 23个\n\n";
      "总计: "; int_to_string total_count; "个Token类型\n";
      "兼容性覆盖率: 良好\n\n";
      "报告生成时间: "; report_timestamp
    ]
end

(** 类型系统格式化 - Phase 3B 新增 *)
module TypeFormatter = struct
  (** 函数类型格式化 *)
  let format_function_type param_type ret_type = 
    concat_strings [ "("; param_type; " -> "; ret_type; ")" ]
  
  (** 列表类型格式化 *)
  let format_list_type element_type = 
    concat_strings [ "["; element_type; "]" ]
  
  (** 构造类型格式化 *)
  let format_construct_type name type_args = 
    concat_strings [ name; "<"; join_with_separator ", " type_args; ">" ]
  
  (** 引用类型格式化 *)
  let format_reference_type inner_type = 
    concat_strings [ "ref<"; inner_type; ">" ]
  
  (** 数组类型格式化 *)
  let format_array_type element_type = 
    concat_strings [ "[|"; element_type; "|]" ]
  
  (** 类类型格式化 *)
  let format_class_type name methods_str = 
    concat_strings [ "class "; name; " {"; methods_str; "}" ]
  
  (** 元组类型格式化 *)
  let format_tuple_type type_list = 
    concat_strings [ "("; join_with_separator " * " type_list; ")" ]
  
  (** 记录类型格式化 *)
  let format_record_type fields_str = 
    concat_strings [ "{"; fields_str; "}" ]
  
  (** 对象类型格式化 *)
  let format_object_type methods_str = 
    concat_strings [ "{"; methods_str; "}" ]
  
  (** 多态变体类型格式化 *)
  let format_variant_type variants_str = 
    concat_strings [ "["; variants_str; "]" ]
end

(** Phase 4: 错误处理专用格式化 *)
module ErrorHandlingFormatter = struct
  (** 错误统计格式化 *)
  let format_error_statistics error_type count = 
    concat_strings [error_type; "错误统计: "; int_to_string count; " 个"]
  
  (** 错误消息和上下文组合格式化 *)
  let format_error_message error_type detail = 
    concat_strings [error_type; ": "; detail]
  
  (** 错误恢复信息格式化 *)
  let format_recovery_info recovery_action = 
    concat_strings ["恢复操作: "; recovery_action]
  
  (** 错误上下文格式化 *)
  let format_error_context source_info line_number = 
    concat_strings ["错误位置: "; source_info; " 第"; int_to_string line_number; "行"]
  
  (** 统一错误格式化 *)
  let format_unified_error error_category specific_message = 
    concat_strings [error_category; " - "; specific_message]
  
  (** 错误建议格式化 *)
  let format_error_suggestion suggestion_number suggestion_text = 
    concat_strings ["   "; int_to_string suggestion_number; ". "; suggestion_text]
  
  (** 错误提示格式化 *)
  let format_error_hint hint_number hint_text = 
    concat_strings ["   "; int_to_string hint_number; ". "; hint_text]
  
  (** AI置信度格式化 *)
  let format_confidence_score confidence_percent = 
    concat_strings ["\n🎯 AI置信度: "; int_to_string confidence_percent; "%"]
end

(** Phase 4: 日志记录专用格式化 *)
module LoggingFormatter = struct
  (** 基础日志条目格式化 *)
  let format_log_entry level_str message = 
    concat_strings ["["; level_str; "] "; message]
  
  (** 日志级别格式化 *)
  let format_log_level level = 
    concat_strings ["["; level; "]"]
  
  (** 迁移信息格式化 *)
  let format_migration_info operation status = 
    concat_strings ["迁移"; operation; ": "; status]
  
  (** 传统日志格式化 *)
  let format_legacy_log module_name message = 
    concat_strings ["[LEGACY]["; module_name; "] "; message]
  
  (** 核心日志消息格式化 *)
  let format_core_log_message component_name log_content = 
    concat_strings ["[CORE]["; component_name; "] "; log_content]
  
  (** 上下文键值对格式化 *)
  let format_context_pair key value = 
    concat_strings [key; "="; value]
  
  (** 上下文组格式化 *)
  let format_context_group context_pairs = 
    concat_strings [" ["; String.concat ", " context_pairs; "]"]
  
  (** 迁移进度报告格式化 *)
  let format_migration_progress total_files migrated_count progress_percent = 
    concat_strings [
      "迁移进度报告:\n总文件数: "; int_to_string total_files; 
      "\n已迁移: "; int_to_string migrated_count; 
      "\n待迁移: "; int_to_string (total_files - migrated_count);
      "\n进度: "; float_to_string progress_percent; "%"
    ]
  
  (** 迁移建议格式化 *)
  let format_migration_suggestions priority_modules core_modules other_modules = 
    concat_strings [
      "建议迁移顺序:\n1. 优先级模块: "; priority_modules; 
      "\n2. 核心模块: "; core_modules; 
      "\n3. 其他模块: "; other_modules
    ]
end

(** Phase 4: 字符串处理基础设施格式化 *)
module StringProcessingFormatter = struct
  (** 错误模板格式化 *)
  let format_error_template template_name error_detail = 
    concat_strings [template_name; "模板错误: "; error_detail]
  
  (** 位置信息格式化 *)
  let format_position_info line column = 
    concat_strings ["第"; int_to_string line; "行第"; int_to_string column; "列"]
  
  (** Token信息格式化 *)
  let format_token_info token_name token_value = 
    concat_strings [token_name; "("; token_value; ")"]
  
  (** 报告段落格式化 *)
  let format_report_section section_title section_content = 
    concat_strings ["=== "; section_title; " ===\n"; section_content]
  
  (** 消息模板格式化 *)
  let format_message_template template_text parameters = 
    let replace_placeholder text params =
      List.fold_left (fun acc param -> 
        let index = 
          try String.index acc '%' 
          with Not_found -> -1
        in
        if index >= 0 && index < String.length acc - 1 && acc.[index+1] = 's' then
          String.sub acc 0 index ^ param ^ String.sub acc (index+2) (String.length acc - index - 2)
        else acc
      ) text params
    in
    replace_placeholder template_text parameters
end

(** 报告和统计格式化 *)
