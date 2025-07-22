(** 骆言编译器统一错误格式化器 - Printf.sprintf重复消除架构重构
    
    此模块合并了之前冲突的三个错误格式化模块：
    1. constants/error_constants.ml - 常量错误消息
    2. string_processing/error_message_formatter.ml - 通用错误格式化
    3. utils/formatting/error_formatter.ml - 格式化工具
    
    使用Base_formatter底层基础设施，实现零Printf.sprintf依赖的统一错误处理。
    
    架构改进：
    - 消除模块功能重叠冲突
    - 统一错误消息格式标准
    - 基于Base_formatter实现无重复格式化
    - 提供完整的错误消息覆盖 
*)

open Base_formatter

(** 统一错误格式化器模块 *)
module Unified_error_formatter = struct

  (** 变量和模块相关错误 *)
  let undefined_variable var_name = context_message_pattern "未定义的变量" var_name
  let module_not_found mod_name = context_message_pattern "未找到模块" mod_name
  let member_not_found mod_name member_name = 
    context_message_pattern (concat_strings ["模块 "; mod_name; " 中未找到成员"]) member_name
  let variable_already_defined var_name = context_message_pattern "变量已定义" var_name
  
  (** 常量错误消息 *)
  let empty_scope_stack = "尝试退出空作用域栈"
  let empty_variable_name = "空变量名"
  let unterminated_comment = "Unterminated comment"
  let unterminated_chinese_comment = "Unterminated Chinese comment"
  let unterminated_string = "Unterminated string"
  let unterminated_quoted_identifier = "未闭合的引用标识符"
  let invalid_char_in_quoted_identifier = "引用标识符中的无效字符"
  
  (** 符号和数字相关错误 *)
  let ascii_symbols_disabled = "ASCII符号已禁用，请使用中文标点符号"
  let fullwidth_numbers_disabled = "只允许半角阿拉伯数字，请勿使用全角数字"
  let arabic_numbers_disabled = "阿拉伯数字已禁用"
  let unsupported_chinese_symbol = "非支持的中文符号已禁用，只支持「」『』：，。（）"
  let identifiers_must_be_quoted = "标识符必须使用「」引用"
  let ascii_letters_as_keywords_only = "ASCII字母已禁用，只允许作为关键字使用"
  
  (** 类型相关错误 *)
  let type_mismatch expected actual = type_mismatch_pattern expected actual
  let unknown_type type_name = context_message_pattern "未知类型" type_name
  let invalid_type_operation op_name = context_message_pattern "无效的类型操作" op_name
  let type_mismatch_info type_info = context_message_pattern "类型不匹配" type_info
  
  (** 函数相关错误 *)
  let function_not_found func_name = context_message_pattern "未找到函数" func_name
  let invalid_argument_count expected actual = param_count_pattern expected actual
  let invalid_argument_type expected actual = type_mismatch_pattern expected actual
  let function_param_mismatch func_name expected actual = 
    context_message_pattern 
      (concat_strings ["函数「"; func_name; "」参数数量不匹配"])
      (param_count_pattern expected actual)
  
  (** 解析器错误 *)
  let unexpected_token token = context_message_pattern "意外的token" token
  let expected_token expected actual = 
    context_message_pattern (concat_strings ["期望token "; expected]) actual
  let syntax_error message = context_message_pattern "语法错误" message
  let parse_failure format msg = context_message_pattern (concat_strings [format; "解析失败"]) msg
  
  (** 专用解析错误 *)
  let json_parse_error msg = context_message_pattern "测试配置JSON格式错误" msg
  let json_parse_failure msg = context_message_pattern "JSON解析失败" msg
  let test_case_parse_error msg = context_message_pattern "解析测试用例失败" msg
  let config_parse_error msg = context_message_pattern "配置解析错误" msg
  let config_list_parse_error msg = context_message_pattern "解析测试配置列表失败" msg
  let comprehensive_test_parse_error msg = context_message_pattern "解析综合测试用例失败" msg
  let summary_items_parse_error msg = context_message_pattern "解析测试摘要项目失败" msg
  
  (** 古雅体语法相关错误 *)
  let ancient_list_syntax_error = 
    join_with_separator "\n" [
      "请使用古雅体列表语法替代 [...]。";
      "空列表：空空如也";
      "有元素的列表：列开始 元素1 其一 元素2 其二 元素3 其三 列结束";
      "模式匹配：有首有尾 首名为「变量名」尾名为「尾部变量名」"
    ]
  
  (** 运行时错误 *)
  let division_by_zero = "除零错误"
  let stack_overflow = "栈溢出"
  let out_of_memory = "内存不足"
  let invalid_operation operation = context_message_pattern "无效操作" operation
  
  (** 文件I/O错误 *)
  let file_not_found filename = context_message_pattern "文件未找到" filename
  let file_read_error filename = file_operation_error_pattern "读取" filename
  let file_write_error filename = file_operation_error_pattern "写入" filename
  let file_operation_error operation filename = file_operation_error_pattern operation filename
  
  (** 检查器错误 *)
  let unknown_checker_type checker_type = context_message_pattern "未知的检查器类型" checker_type
  
  (** 通用异常处理 *)
  let unexpected_exception exn = context_message_pattern "意外异常" (Printexc.to_string exn)
  let generic_error context message = context_message_pattern context message
  let empty_json_failure exn = context_message_pattern "空JSON处理失败" (Printexc.to_string exn)
  let error_type_mismatch exn = context_message_pattern "错误类型不匹配" (Printexc.to_string exn)
  
  (** 通用错误模板 *)
  let unsupported_char_error char_bytes = context_message_pattern "不支持的字符" char_bytes
  
  (** 位置相关错误格式化 *)
  let format_position filename line col = file_position_pattern filename line col
  let format_position_no_col filename line = 
    concat_strings [filename; ":"; int_to_string line]
  let position_error filename line col message = 
    context_message_pattern (format_position filename line col) message
  let line_col_error line col message = line_col_message_pattern line col message
  
  (** 测试相关错误消息 *)
  module Test_errors = struct
    let should_produce_error desc = concat_strings [desc; " 应该产生错误"]
    let wrong_error_type desc exn = 
      context_message_pattern 
        (concat_strings [desc; " 错误类型不正确"]) 
        (Printexc.to_string exn)
    
    (** 韵律相关测试错误 *)
    let structure_validation_failure exn = 
      context_message_pattern "韵组结构验证失败" (Printexc.to_string exn)
    let classification_test_failure exn = 
      context_message_pattern "韵类分类测试失败" (Printexc.to_string exn)
    let uniqueness_test_failure exn = 
      context_message_pattern "字符唯一性测试失败" (Printexc.to_string exn)
    
    (** 字符相关测试消息 *)
    let character_found_message char = concat_strings ["找到字符 "; char]
    let character_should_exist char = concat_strings ["字符 "; char; " 应该存在"]
    let character_should_not_exist char = concat_strings ["字符 "; char; " 不应该存在"]
    let character_rhyme_group char = concat_strings ["字符 "; char; " 应属于鱼韵"]
    let character_rhyme_match char1 char2 should_match =
      concat_strings [char1; " 和 "; char2; " "; (if should_match then "应该押韵" else "不应该押韵")]
    
    (** Unicode测试消息 *)
    let unicode_processing_message char = concat_strings ["Unicode字符 "; char; " 被正确处理"]
    let unicode_test_failure exn = context_message_pattern "Unicode测试失败" (Printexc.to_string exn)
    let simplified_recognition simp = concat_strings ["简体字 "; simp; " 被识别"]
    let traditional_recognition trad = concat_strings ["繁体字 "; trad; " 被识别"]
    let traditional_simplified_failure exn = 
      context_message_pattern "繁简字符测试失败" (Printexc.to_string exn)
    
    (** 性能测试消息 *)
    let large_data_failure exn = context_message_pattern "大规模数据测试失败" (Printexc.to_string exn)
    let query_performance_failure exn = context_message_pattern "查询性能测试失败" (Printexc.to_string exn)
    let memory_usage_failure exn = context_message_pattern "内存使用测试失败" (Printexc.to_string exn)
    let long_name_failure exn = context_message_pattern "长字符名测试失败" (Printexc.to_string exn)
    let special_char_failure exn = context_message_pattern "特殊字符测试失败" (Printexc.to_string exn)
    let error_recovery_failure exn = context_message_pattern "错误恢复失败" (Printexc.to_string exn)
    
    (** 艺术性评价测试消息 *)
    let score_range_message desc dimension = 
      concat_strings [desc; " - "; dimension; "评分在有效范围"]
  end
  
  (** 配置相关错误 *)
  let invalid_config_value key value = 
    context_message_pattern (concat_strings ["无效配置值 "; key]) value
  
  (** 复合格式化函数 *)
  let format_key_value key value = concat_strings [key; "："; value]
  let format_context_info count suffix = concat_strings [int_to_string count; suffix]
  let format_triple_with_dash pos severity message = 
    join_with_separator " - " [pos; concat_strings [severity; "："; message]]
  let format_category_error category details = concat_strings [category; "："; details]
  
end

(** 导出主要函数到顶层，便于使用 *)
include Unified_error_formatter