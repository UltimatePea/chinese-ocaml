(** 骆言编译器Token格式化模块全面测试 - Stage 2.2: Specialized formatter tests
    
    本测试文件针对formatter_tokens.ml提供全面的测试覆盖率，特别关注：
    - Position模块的完整测试
    - TokenFormatting模块的测试
    - EnhancedPosition模块的测试
    - TokenUtilities模块的测试
    
    Author: Alpha, 主工作代理
    Fix #1692 - 测试覆盖率提升计划第二阶段
    @since 2025-07-29 *)

open Alcotest
open Yyocamlc_lib.Formatter_tokens

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub =
  try
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in
    true
  with Not_found -> false

(** 帮助函数：检查字符串是否是有效的格式化结果 *)
let is_valid_format result = String.length result > 0

(** 测试Position模块 *)
module Test_Position = struct
  (** 测试基础位置格式化 *)
  let test_format_position () =
    let result = Position.format_position "main.ml" 10 25 in
    check bool "位置格式化包含文件名" true (contains_substring result "main.ml");
    check bool "位置格式化包含行号" true (contains_substring result "10");
    check bool "位置格式化包含列号" true (contains_substring result "25");
    
    let zero_pos = Position.format_position "test.ml" 0 0 in
    check bool "零位置格式化有效" true (is_valid_format zero_pos)

  (** 测试带位置的错误格式化 *)
  let test_format_error_with_position () =
    let position = "main.ml:15:30" in
    let result = Position.format_error_with_position position "语法错误" "缺少分号" in
    check bool "带位置错误包含位置" true (contains_substring result position);
    check bool "带位置错误包含错误类型" true (contains_substring result "语法错误");
    check bool "带位置错误包含错误消息" true (contains_substring result "缺少分号");
    
    let empty_msg = Position.format_error_with_position "file.ml:1:1" "错误" "" in
    check bool "空消息错误格式化有效" true (is_valid_format empty_msg)

  (** 测试可选位置格式化 *)
  let test_format_optional_position () =
    let some_pos = Position.format_optional_position (Some ("test.ml", 5, 10)) in
    check bool "有位置信息包含括号" true (contains_substring some_pos "(");
    check bool "有位置信息包含文件名" true (contains_substring some_pos "test.ml");
    check bool "有位置信息包含行号" true (contains_substring some_pos "5");
    
    let none_pos = Position.format_optional_position None in
    check string "无位置信息返回空字符串" "" none_pos

  (** 测试范围位置格式化 *)
  let test_format_range_position () =
    let same_line = Position.format_range_position "source.ml" 10 5 10 15 in
    check bool "同行范围包含文件名" true (contains_substring same_line "source.ml");
    check bool "同行范围包含起始列" true (contains_substring same_line "5");
    check bool "同行范围包含结束列" true (contains_substring same_line "15");
    check bool "同行范围包含短横线" true (contains_substring same_line "-");
    
    let multi_line = Position.format_range_position "code.ml" 10 5 12 8 in
    check bool "多行范围包含起始行" true (contains_substring multi_line "10");
    check bool "多行范围包含结束行" true (contains_substring multi_line "12");
    check bool "多行范围包含起始列" true (contains_substring multi_line "5");
    check bool "多行范围包含结束列" true (contains_substring multi_line "8")

  (** 测试源码上下文格式化 *)
  let test_format_source_context () =
    let context_lines = ["    let x = 5"; "    let y = 10"; "    x + y"] in
    let result = Position.format_source_context "calc.ml" 2 8 context_lines in
    check bool "源码上下文包含文件名" true (contains_substring result "calc.ml");
    check bool "源码上下文包含行号" true (contains_substring result "2");
    check bool "源码上下文包含列号" true (contains_substring result "8");
    check bool "源码上下文包含代码行" true (contains_substring result "let x = 5");
    
    let no_context = Position.format_source_context "empty.ml" 1 1 [] in
    check bool "无上下文源码格式化包含位置" true (contains_substring no_context "empty.ml")

  (** 测试错误指示器 *)
  let test_format_error_indicator () =
    let indicator = Position.format_error_indicator 5 in
    check bool "错误指示器包含尖号" true (contains_substring indicator "^");
    check int "错误指示器位置正确" 5 (String.length indicator);
    
    let first_col = Position.format_error_indicator 1 in
    check string "第一列错误指示器" "^" first_col
end

(** 测试TokenFormatting模块 *)
module Test_TokenFormatting = struct
  (** 测试基础Token类型格式化 *)
  let test_basic_token_formatting () =
    let int_token = TokenFormatting.format_int_token 42 in
    check bool "整数Token包含类型" true (contains_substring int_token "IntToken");
    check bool "整数Token包含值" true (contains_substring int_token "42");
    
    let float_token = TokenFormatting.format_float_token 3.14 in
    check bool "浮点Token包含类型" true (contains_substring float_token "FloatToken");
    check bool "浮点Token包含值" true (contains_substring float_token "3.14");
    
    let string_token = TokenFormatting.format_string_token "hello" in
    check bool "字符串Token包含类型" true (contains_substring string_token "StringToken");
    check bool "字符串Token包含值" true (contains_substring string_token "hello");
    check bool "字符串Token包含引号" true (contains_substring string_token "\"");
    
    let id_token = TokenFormatting.format_identifier_token "variable_name" in
    check bool "标识符Token包含类型" true (contains_substring id_token "IdentifierToken");
    check bool "标识符Token包含名称" true (contains_substring id_token "variable_name");
    
    let quoted_id = TokenFormatting.format_quoted_identifier_token "quoted name" in
    check bool "引号标识符Token包含类型" true (contains_substring quoted_id "QuotedIdentifierToken");
    check bool "引号标识符Token包含引号" true (contains_substring quoted_id "\"")

  (** 测试Token错误消息 *)
  let test_token_error_messages () =
    let expectation = TokenFormatting.token_expectation "SEMICOLON" "COMMA" in
    check bool "Token期望错误包含期望值" true (contains_substring expectation "SEMICOLON");
    check bool "Token期望错误包含实际值" true (contains_substring expectation "COMMA");
    check bool "Token期望错误包含期望标识" true (contains_substring expectation "期望");
    
    let unexpected = TokenFormatting.unexpected_token "EOF" in
    check bool "意外Token包含Token名" true (contains_substring unexpected "EOF");
    check bool "意外Token包含意外标识" true (contains_substring unexpected "意外")

  (** 测试复合Token格式化 *)
  let test_compound_token_formatting () =
    let keyword_token = TokenFormatting.format_keyword_token "if" in
    check bool "关键字Token包含类型" true (contains_substring keyword_token "KeywordToken");
    check bool "关键字Token包含关键字" true (contains_substring keyword_token "if");
    
    let operator_token = TokenFormatting.format_operator_token "+" in
    check bool "运算符Token包含类型" true (contains_substring operator_token "OperatorToken");
    check bool "运算符Token包含运算符" true (contains_substring operator_token "+");
    
    let delimiter_token = TokenFormatting.format_delimiter_token ";" in
    check bool "分隔符Token包含类型" true (contains_substring delimiter_token "DelimiterToken");
    check bool "分隔符Token包含分隔符" true (contains_substring delimiter_token ";");
    
    let bool_token = TokenFormatting.format_boolean_token true in
    check bool "布尔Token包含类型" true (contains_substring bool_token "BooleanToken");
    check bool "布尔Token包含真值" true (contains_substring bool_token "true")

  (** 测试特殊Token格式化 *)
  let test_special_token_formatting () =
    let eof_token = TokenFormatting.format_eof_token () in
    check string "EOF Token格式正确" "EOFToken" eof_token;
    
    let newline_token = TokenFormatting.format_newline_token () in
    check string "换行Token格式正确" "NewlineToken" newline_token;
    
    let whitespace_token = TokenFormatting.format_whitespace_token () in
    check string "空白Token格式正确" "WhitespaceToken" whitespace_token;
    
    let comment_token = TokenFormatting.format_comment_token "// 这是注释" in
    check bool "注释Token包含类型" true (contains_substring comment_token "CommentToken");
    check bool "注释Token包含内容" true (contains_substring comment_token "这是注释")

  (** 测试Token位置信息结合格式化 *)
  let test_token_with_position () =
    let result = TokenFormatting.format_token_with_position "IDENTIFIER" 5 10 in
    check bool "Token位置包含Token名" true (contains_substring result "IDENTIFIER");
    check bool "Token位置包含行号" true (contains_substring result "5");
    check bool "Token位置包含列号" true (contains_substring result "10")

  (** 测试中文特定Token格式化 *)
  let test_chinese_specific_tokens () =
    let chinese_num = TokenFormatting.format_chinese_number_token "三十五" in
    check bool "中文数字Token包含类型" true (contains_substring chinese_num "ChineseNumberToken");
    check bool "中文数字Token包含数字" true (contains_substring chinese_num "三十五");
    
    let ancient_style = TokenFormatting.format_ancient_style_token "之乎者也" in
    check bool "古雅体Token包含类型" true (contains_substring ancient_style "AncientStyleToken");
    check bool "古雅体Token包含内容" true (contains_substring ancient_style "之乎者也");
    
    let poetry_token = TokenFormatting.format_poetry_token "春眠不觉晓" in
    check bool "诗词Token包含类型" true (contains_substring poetry_token "PoetryToken");
    check bool "诗词Token包含诗句" true (contains_substring poetry_token "春眠不觉晓")

  (** 测试Token序列格式化 *)
  let test_token_sequence_formatting () =
    let tokens = ["IntToken(42)"; "OperatorToken(+)"; "IntToken(58)"] in
    let result = TokenFormatting.format_token_sequence tokens in
    check bool "Token序列包含标题" true (contains_substring result "Token序列");
    check bool "Token序列包含第一个Token" true (contains_substring result "IntToken(42)");
    check bool "Token序列包含最后一个Token" true (contains_substring result "IntToken(58)");
    
    let empty_seq = TokenFormatting.format_token_sequence [] in
    check bool "空Token序列包含标题" true (contains_substring empty_seq "Token序列");
    
    let tokens_with_pos = [("IDENTIFIER", 1, 5); ("OPERATOR", 1, 15); ("NUMBER", 1, 17)] in
    let stream_result = TokenFormatting.format_token_stream tokens_with_pos in
    check bool "Token流包含第一个Token" true (contains_substring stream_result "IDENTIFIER");
    check bool "Token流包含位置信息" true (contains_substring stream_result "1:5")
end

(** 测试EnhancedPosition模块 *)
module Test_EnhancedPosition = struct
  (** 测试基础位置格式化变体 *)
  let test_basic_position_variants () =
    let simple = EnhancedPosition.simple_line_col 10 25 in
    check bool "简单行列格式包含行" true (contains_substring simple "行:10");
    check bool "简单行列格式包含列" true (contains_substring simple "列:25");
    
    let parenthesized = EnhancedPosition.parenthesized_line_col 5 15 in
    check bool "括号行列格式包含括号" true (contains_substring parenthesized "(");
    check bool "括号行列格式包含行" true (contains_substring parenthesized "行:5");
    check bool "括号行列格式包含列" true (contains_substring parenthesized "列:15")

  (** 测试范围位置格式化 *)
  let test_range_position () =
    let range = EnhancedPosition.range_position 5 10 8 20 in
    check bool "范围位置包含起始行" true (contains_substring range "第5行");
    check bool "范围位置包含起始列" true (contains_substring range "第10列");
    check bool "范围位置包含结束行" true (contains_substring range "第8行");
    check bool "范围位置包含结束列" true (contains_substring range "第20列");
    check bool "范围位置包含至标识" true (contains_substring range "至")

  (** 测试错误位置标记 *)
  let test_error_position_marker () =
    let marker = EnhancedPosition.error_position_marker 12 35 in
    check bool "错误位置标记包含错误标识" true (contains_substring marker "错误位置");
    check bool "错误位置标记包含箭头" true (contains_substring marker ">>>");
    check bool "错误位置标记包含行号" true (contains_substring marker "12");
    check bool "错误位置标记包含列号" true (contains_substring marker "35")

  (** 测试详细位置信息 *)
  let test_detailed_position () =
    let detailed = EnhancedPosition.format_detailed_position "source.ml" 20 30 1024 in
    check bool "详细位置包含文件名" true (contains_substring detailed "source.ml");
    check bool "详细位置包含行号" true (contains_substring detailed "20");
    check bool "详细位置包含列号" true (contains_substring detailed "30");
    check bool "详细位置包含字节偏移" true (contains_substring detailed "1024");
    check bool "详细位置包含偏移标识" true (contains_substring detailed "字节偏移")

  (** 测试相对位置格式化 *)
  let test_relative_position () =
    let same_line = EnhancedPosition.format_relative_position 10 15 10 25 in
    check bool "同行相对位置包含同行标识" true (contains_substring same_line "同行");
    check bool "同行相对位置包含偏移" true (contains_substring same_line "10");
    
    let down_lines = EnhancedPosition.format_relative_position 10 15 12 20 in
    check bool "向下相对位置包含向下标识" true (contains_substring down_lines "向下");
    check bool "向下相对位置包含行数" true (contains_substring down_lines "2");
    
    let up_lines = EnhancedPosition.format_relative_position 15 10 12 5 in
    check bool "向上相对位置包含向上标识" true (contains_substring up_lines "向上");
    check bool "向上相对位置包含行数" true (contains_substring up_lines "3")

  (** 测试位置范围格式化 *)
  let test_span_info () =
    let same_file_same_line = EnhancedPosition.format_span_info ("test.ml", 10, 5) ("test.ml", 10, 15) in
    check bool "同文件同行包含文件名" true (contains_substring same_file_same_line "test.ml");
    check bool "同文件同行包含行号" true (contains_substring same_file_same_line "10");
    check bool "同文件同行包含起始列" true (contains_substring same_file_same_line "5");
    check bool "同文件同行包含结束列" true (contains_substring same_file_same_line "15");
    
    let same_file_diff_line = EnhancedPosition.format_span_info ("code.ml", 5, 10) ("code.ml", 8, 20) in
    check bool "同文件不同行包含到标识" true (contains_substring same_file_diff_line "到");
    
    let diff_files = EnhancedPosition.format_span_info ("file1.ml", 1, 1) ("file2.ml", 10, 20) in
    check bool "不同文件包含第一个文件" true (contains_substring diff_files "file1.ml");
    check bool "不同文件包含第二个文件" true (contains_substring diff_files "file2.ml")

  (** 测试源码摘录和多行错误显示 *)
  let test_source_excerpt_and_multiline () =
    let excerpt = EnhancedPosition.format_source_excerpt "example.ml" 15 "    let result = calculate x y" 20 in
    check bool "源码摘录包含文件名" true (contains_substring excerpt "example.ml");
    check bool "源码摘录包含行号" true (contains_substring excerpt "15");
    check bool "源码摘录包含代码行" true (contains_substring excerpt "let result = calculate");
    check bool "源码摘录包含指针" true (contains_substring excerpt "^");
    
    let source_lines = ["let x = 5"; "let y = 10"; "x + y + z"] in
    let multiline = EnhancedPosition.format_multiline_error "bug.ml" 10 12 source_lines "变量z未定义" in
    check bool "多行错误包含文件名" true (contains_substring multiline "bug.ml");
    check bool "多行错误包含起始行" true (contains_substring multiline "10");
    check bool "多行错误包含结束行" true (contains_substring multiline "12");
    check bool "多行错误包含错误消息" true (contains_substring multiline "变量z未定义");
    check bool "多行错误包含代码行" true (contains_substring multiline "let x = 5")
end

(** 测试TokenUtilities模块 *)
module Test_TokenUtilities = struct
  (** 测试Token类型分类 *)
  let test_token_type_classification () =
    check bool "整数Token是字面量" true (TokenUtilities.is_literal_token "IntToken");
    check bool "浮点Token是字面量" true (TokenUtilities.is_literal_token "FloatToken");
    check bool "字符串Token是字面量" true (TokenUtilities.is_literal_token "StringToken");
    check bool "布尔Token是字面量" true (TokenUtilities.is_literal_token "BooleanToken");
    check bool "中文数字Token是字面量" true (TokenUtilities.is_literal_token "ChineseNumberToken");
    check bool "标识符Token不是字面量" false (TokenUtilities.is_literal_token "IdentifierToken");
    
    check bool "标识符Token是标识符" true (TokenUtilities.is_identifier_token "IdentifierToken");
    check bool "引号标识符Token是标识符" true (TokenUtilities.is_identifier_token "QuotedIdentifierToken");
    check bool "整数Token不是标识符" false (TokenUtilities.is_identifier_token "IntToken");
    
    check bool "关键字Token是关键字" true (TokenUtilities.is_keyword_token "KeywordToken");
    check bool "标识符Token不是关键字" false (TokenUtilities.is_keyword_token "IdentifierToken");
    
    check bool "运算符Token是运算符" true (TokenUtilities.is_operator_token "OperatorToken");
    check bool "关键字Token不是运算符" false (TokenUtilities.is_operator_token "KeywordToken");
    
    check bool "分隔符Token是分隔符" true (TokenUtilities.is_delimiter_token "DelimiterToken");
    check bool "运算符Token不是分隔符" false (TokenUtilities.is_delimiter_token "OperatorToken")

  (** 测试Token验证消息 *)
  let test_token_validation () =
    let type_match = TokenUtilities.validate_token_type "IntToken" "IntToken" in
    check string "相同类型验证返回空字符串" "" type_match;
    
    let type_mismatch = TokenUtilities.validate_token_type "IntToken" "StringToken" in
    check bool "类型不匹配包含期望类型" true (contains_substring type_mismatch "IntToken");
    check bool "类型不匹配包含实际类型" true (contains_substring type_mismatch "StringToken");
    check bool "类型不匹配包含不匹配标识" true (contains_substring type_mismatch "不匹配");
    
    let value_match = TokenUtilities.validate_token_value "hello" "hello" in
    check string "相同值验证返回空字符串" "" value_match;
    
    let value_mismatch = TokenUtilities.validate_token_value "expected" "actual" in
    check bool "值不匹配包含期望值" true (contains_substring value_mismatch "expected");
    check bool "值不匹配包含实际值" true (contains_substring value_mismatch "actual");
    check bool "值不匹配包含不匹配标识" true (contains_substring value_mismatch "不匹配")

  (** 测试Token统计信息 *)
  let test_token_statistics () =
    let stats = TokenUtilities.format_token_statistics 100 25 30 15 in
    check bool "Token统计包含总计" true (contains_substring stats "总计 100");
    check bool "Token统计包含字面量计数" true (contains_substring stats "字面量: 25");
    check bool "Token统计包含标识符计数" true (contains_substring stats "标识符: 30");
    check bool "Token统计包含关键字计数" true (contains_substring stats "关键字: 15");
    
    let zero_stats = TokenUtilities.format_token_statistics 0 0 0 0 in
    check bool "零统计包含总计0" true (contains_substring zero_stats "总计 0")

  (** 测试Token转换助手 *)
  let test_token_conversion_helpers () =
    let token_str = TokenUtilities.token_to_string "IntToken" "42" in
    check bool "Token字符串包含类型" true (contains_substring token_str "IntToken");
    check bool "Token字符串包含值" true (contains_substring token_str "42");
    check bool "Token字符串包含括号" true (contains_substring token_str "(");
    
    let token_list = [("IntToken", "1"); ("OperatorToken", "+"); ("IntToken", "2")] in
    let list_str = TokenUtilities.token_list_to_string token_list in
    check bool "Token列表字符串包含方括号" true (contains_substring list_str "[");
    check bool "Token列表字符串包含第一个Token" true (contains_substring list_str "IntToken(1)");
    check bool "Token列表字符串包含分号分隔符" true (contains_substring list_str ";");
    
    let empty_list = TokenUtilities.token_list_to_string [] in
    check string "空Token列表字符串" "[]" empty_list

  (** 测试词法分析辅助 *)
  let test_lexer_assistance () =
    let lexer_state = TokenUtilities.format_lexer_state 15 "c" "const" in
    check bool "词法分析器状态包含位置" true (contains_substring lexer_state "15");
    check bool "词法分析器状态包含当前字符" true (contains_substring lexer_state "c");
    check bool "词法分析器状态包含缓冲区内容" true (contains_substring lexer_state "const");
    check bool "词法分析器状态包含状态标识" true (contains_substring lexer_state "词法分析器状态");
    
    let progress = TokenUtilities.format_tokenization_progress 250 1000 "IDENTIFIER" in
    check bool "词法分析进度包含已处理字符数" true (contains_substring progress "250");
    check bool "词法分析进度包含总字符数" true (contains_substring progress "1000");
    check bool "词法分析进度包含百分比" true (contains_substring progress "25%");
    check bool "词法分析进度包含当前Token" true (contains_substring progress "IDENTIFIER");
    
    let zero_total_progress = TokenUtilities.format_tokenization_progress 0 0 "EOF" in
    check bool "零总数进度包含EOF" true (contains_substring zero_total_progress "EOF")
end

let () =
  run "骆言Token格式化模块全面测试"
    [
      ( "位置信息格式化",
        [
          test_case "基础位置格式化" `Quick Test_Position.test_format_position;
          test_case "带位置的错误格式化" `Quick Test_Position.test_format_error_with_position;
          test_case "可选位置格式化" `Quick Test_Position.test_format_optional_position;
          test_case "范围位置格式化" `Quick Test_Position.test_format_range_position;
          test_case "源码上下文格式化" `Quick Test_Position.test_format_source_context;
          test_case "错误指示器" `Quick Test_Position.test_format_error_indicator;
        ] );
      ( "Token格式化",
        [
          test_case "基础Token类型格式化" `Quick Test_TokenFormatting.test_basic_token_formatting;
          test_case "Token错误消息" `Quick Test_TokenFormatting.test_token_error_messages;
          test_case "复合Token格式化" `Quick Test_TokenFormatting.test_compound_token_formatting;
          test_case "特殊Token格式化" `Quick Test_TokenFormatting.test_special_token_formatting;
          test_case "Token位置信息结合格式化" `Quick Test_TokenFormatting.test_token_with_position;
          test_case "中文特定Token格式化" `Quick Test_TokenFormatting.test_chinese_specific_tokens;
          test_case "Token序列格式化" `Quick Test_TokenFormatting.test_token_sequence_formatting;
        ] );
      ( "增强位置格式化",
        [
          test_case "基础位置格式化变体" `Quick Test_EnhancedPosition.test_basic_position_variants;
          test_case "范围位置格式化" `Quick Test_EnhancedPosition.test_range_position;
          test_case "错误位置标记" `Quick Test_EnhancedPosition.test_error_position_marker;
          test_case "详细位置信息" `Quick Test_EnhancedPosition.test_detailed_position;
          test_case "相对位置格式化" `Quick Test_EnhancedPosition.test_relative_position;
          test_case "位置范围格式化" `Quick Test_EnhancedPosition.test_span_info;
          test_case "源码摘录和多行错误显示" `Quick Test_EnhancedPosition.test_source_excerpt_and_multiline;
        ] );
      ( "Token工具",
        [
          test_case "Token类型分类" `Quick Test_TokenUtilities.test_token_type_classification;
          test_case "Token验证消息" `Quick Test_TokenUtilities.test_token_validation;
          test_case "Token统计信息" `Quick Test_TokenUtilities.test_token_statistics;
          test_case "Token转换助手" `Quick Test_TokenUtilities.test_token_conversion_helpers;
          test_case "词法分析辅助" `Quick Test_TokenUtilities.test_lexer_assistance;
        ] );
    ]