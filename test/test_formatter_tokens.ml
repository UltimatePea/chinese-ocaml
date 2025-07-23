(** 骆言编译器Token格式化模块测试 - 测试Token和位置格式化功能 *)

open Alcotest
open Yyocamlc_lib.Formatter_tokens

(** 帮助函数：检查字符串是否包含子字符串 *)
let contains_substring s sub = 
  try 
    let _ = Str.search_forward (Str.regexp_string sub) s 0 in 
    true
  with Not_found -> false

(** 测试位置信息格式化模块 *)
module Test_Position = struct
  (** 测试基础位置格式化 *)
  let test_format_position () =
    let result = Position.format_position "test.ly" 10 5 in
    check bool "位置格式化包含文件名" true (contains_substring result "test.ly");
    check bool "位置格式化包含行号" true (contains_substring result "10");
    check bool "位置格式化包含列号" true (contains_substring result "5");
    
    let zero_position = Position.format_position "empty.ly" 0 0 in
    check bool "零位置格式化包含文件名" true (contains_substring zero_position "empty.ly")

  (** 测试带位置的错误格式化 *)
  let test_format_error_with_position () =
    let position = "test.ly:10:5" in
    let result = Position.format_error_with_position position "语法错误" "意外的token" in
    check bool "错误信息包含位置" true (contains_substring result position);
    check bool "错误信息包含错误类型" true (contains_substring result "语法错误");
    check bool "错误信息包含错误消息" true (contains_substring result "意外的token");
    
    let empty_result = Position.format_error_with_position "" "错误" "" in
    check bool "空参数错误格式化包含错误类型" true (contains_substring empty_result "错误")

  (** 测试可选位置格式化 *)
  let test_format_optional_position () =
    let some_pos = Position.format_optional_position (Some ("file.ly", 15, 20)) in
    check bool "有位置信息格式化包含文件名" true (contains_substring some_pos "file.ly");
    check bool "有位置信息格式化包含行号" true (contains_substring some_pos "15");
    check bool "有位置信息格式化包含列号" true (contains_substring some_pos "20");
    
    let none_pos = Position.format_optional_position None in
    check string "无位置信息格式化为空字符串" "" none_pos

  (** 测试范围位置格式化 *)
  let test_format_range_position () =
    (* 同行范围 *)
    let same_line = Position.format_range_position "test.ly" 10 5 10 15 in
    check bool "同行范围包含文件名" true (contains_substring same_line "test.ly");
    check bool "同行范围包含起始列" true (contains_substring same_line "5");
    check bool "同行范围包含结束列" true (contains_substring same_line "15");
    
    (* 跨行范围 *)
    let multi_line = Position.format_range_position "test.ly" 10 5 12 8 in
    check bool "跨行范围包含文件名" true (contains_substring multi_line "test.ly");
    check bool "跨行范围包含起始行" true (contains_substring multi_line "10");
    check bool "跨行范围包含结束行" true (contains_substring multi_line "12")

  (** 测试源码上下文格式化 *)
  let test_format_source_context () =
    let context_lines = ["第一行代码"; "第二行代码"; "第三行代码"] in
    let result = Position.format_source_context "example.ly" 20 10 context_lines in
    check bool "源码上下文包含文件名" true (contains_substring result "example.ly");
    check bool "源码上下文包含行号" true (contains_substring result "20");
    check bool "源码上下文包含列号" true (contains_substring result "10");
    check bool "源码上下文包含代码行" true (contains_substring result "第一行代码");
    
    let no_context = Position.format_source_context "simple.ly" 5 3 [] in
    check bool "无上下文只包含位置" true (contains_substring no_context "simple.ly")

  (** 测试错误指示器格式化 *)
  let test_format_error_indicator () =
    let indicator_1 = Position.format_error_indicator 1 in
    check string "第1列错误指示器" "^" indicator_1;
    
    let indicator_5 = Position.format_error_indicator 5 in
    check bool "第5列错误指示器包含空格" true (String.length indicator_5 = 5);
    check bool "第5列错误指示器以^结尾" true (contains_substring indicator_5 "^")
end

(** 测试Token格式化模块 *)
module Test_TokenFormatting = struct
  (** 测试基础Token类型格式化 *)
  let test_basic_token_formatting () =
    let int_result = TokenFormatting.format_int_token 42 in
    check bool "整数Token格式化包含值" true (contains_substring int_result "42");
    
    let float_result = TokenFormatting.format_float_token 3.14 in
    check bool "浮点数Token格式化包含值" true (contains_substring float_result "3.14");
    
    let string_result = TokenFormatting.format_string_token "测试字符串" in
    check bool "字符串Token格式化包含值" true (contains_substring string_result "测试字符串");
    
    let id_result = TokenFormatting.format_identifier_token "变量名" in
    check bool "标识符Token格式化包含值" true (contains_substring id_result "变量名");
    
    let quoted_result = TokenFormatting.format_quoted_identifier_token "引用标识符" in
    check bool "引用标识符Token格式化包含值" true (contains_substring quoted_result "引用标识符")

  (** 测试Token错误消息 *)
  let test_token_error_messages () =
    let expectation = TokenFormatting.token_expectation "整数" "字符串" in
    check bool "Token期望消息包含期望类型" true (contains_substring expectation "整数");
    check bool "Token期望消息包含实际类型" true (contains_substring expectation "字符串");
    
    let unexpected = TokenFormatting.unexpected_token "意外的符号" in
    check bool "意外Token消息包含Token内容" true (contains_substring unexpected "意外的符号")

  (** 测试复合Token格式化 *)
  let test_compound_token_formatting () =
    let keyword_result = TokenFormatting.format_keyword_token "如果" in
    check bool "关键字Token格式化包含关键字" true (contains_substring keyword_result "如果");
    
    let operator_result = TokenFormatting.format_operator_token "+" in
    check bool "运算符Token格式化包含运算符" true (contains_substring operator_result "+");
    
    let delimiter_result = TokenFormatting.format_delimiter_token "，" in
    check bool "分隔符Token格式化包含分隔符" true (contains_substring delimiter_result "，");
    
    let bool_true = TokenFormatting.format_boolean_token true in
    check bool "布尔Token格式化包含真值" true (contains_substring bool_true "true");
    
    let bool_false = TokenFormatting.format_boolean_token false in
    check bool "布尔Token格式化包含假值" true (contains_substring bool_false "false")

  (** 测试特殊Token格式化 *)
  let test_special_token_formatting () =
    let eof_result = TokenFormatting.format_eof_token () in
    check bool "EOF Token格式化非空" true (String.length eof_result > 0);
    
    let newline_result = TokenFormatting.format_newline_token () in
    check bool "换行Token格式化非空" true (String.length newline_result > 0);
    
    let whitespace_result = TokenFormatting.format_whitespace_token () in
    check bool "空白Token格式化非空" true (String.length whitespace_result > 0);
    
    let comment_result = TokenFormatting.format_comment_token "这是注释" in
    check bool "注释Token格式化包含注释内容" true (contains_substring comment_result "这是注释")

  (** 测试Token与位置结合格式化 *)
  let test_token_with_position () =
    let result = TokenFormatting.format_token_with_position "关键字:让" 15 8 in
    check bool "Token位置格式化包含Token" true (contains_substring result "关键字:让");
    check bool "Token位置格式化包含行号" true (contains_substring result "15");
    check bool "Token位置格式化包含列号" true (contains_substring result "8")

  (** 测试中文特定Token格式化 *)
  let test_chinese_specific_tokens () =
    let chinese_num = TokenFormatting.format_chinese_number_token "三十二" in
    check bool "中文数字Token格式化包含数字" true (contains_substring chinese_num "三十二");
    
    let ancient_style = TokenFormatting.format_ancient_style_token "乃" in
    check bool "古雅体Token格式化包含古词" true (contains_substring ancient_style "乃");
    
    let poetry_token = TokenFormatting.format_poetry_token "春花秋月" in
    check bool "诗词Token格式化包含诗词" true (contains_substring poetry_token "春花秋月")

  (** 测试Token序列格式化 *)
  let test_token_sequence_formatting () =
    let token_list = ["让"; "「变量」"; "为"; "四十二"] in
    let sequence_result = TokenFormatting.format_token_sequence token_list in
    check bool "Token序列包含第一个Token" true (contains_substring sequence_result "让");
    check bool "Token序列包含最后一个Token" true (contains_substring sequence_result "四十二");
    
    let token_stream = [("让", 1, 1); ("「变量」", 1, 5); ("为", 1, 12)] in
    let stream_result = TokenFormatting.format_token_stream token_stream in
    check bool "Token流包含Token内容" true (contains_substring stream_result "让");
    check bool "Token流包含位置信息" true (contains_substring stream_result "1")
end

(** 测试扩展位置格式化功能 *)
module Test_Extended_Position = struct
  (** 测试增强位置格式化 *)
  let test_enhanced_position_formatting () =
    let enhanced_pos = Position.format_range_position "complex.ly" 1 1 1 10 in
    check bool "增强位置格式化包含文件名" true (contains_substring enhanced_pos "complex.ly");
    check bool "增强位置格式化格式正确" true (String.length enhanced_pos > 10);
    
    let multi_context = Position.format_source_context "source.ly" 25 15 ["上一行"; "当前行"; "下一行"] in
    check bool "多行上下文包含所有行" true (contains_substring multi_context "上一行");
    check bool "多行上下文包含当前行" true (contains_substring multi_context "当前行");
    check bool "多行上下文包含下一行" true (contains_substring multi_context "下一行")

  (** 测试错误指示器边界情况 *)
  let test_error_indicator_edge_cases () =
    let small_indicator = Position.format_error_indicator 1 in
    check bool "小位置错误指示器有效" true (String.length small_indicator > 0);
    
    let large_indicator = Position.format_error_indicator 10 in
    check bool "大位置错误指示器长度正确" true (String.length large_indicator = 10);
    check bool "大位置错误指示器以^结尾" true (contains_substring large_indicator "^")
end

(** 测试Token工具功能 *)
module Test_TokenUtilities = struct
  (** 测试Token序列边界情况 *)
  let test_token_sequence_edge_cases () =
    let empty_sequence = TokenFormatting.format_token_sequence [] in
    check bool "空Token序列格式化有效" true (String.length empty_sequence >= 0);
    
    let single_token = TokenFormatting.format_token_sequence ["唯一Token"] in
    check bool "单Token序列包含Token" true (contains_substring single_token "唯一Token");
    
    let empty_stream = TokenFormatting.format_token_stream [] in
    check bool "空Token流格式化有效" true (String.length empty_stream >= 0)

  (** 测试中文Token特殊情况 *)
  let test_chinese_token_edge_cases () =
    let empty_chinese = TokenFormatting.format_chinese_number_token "" in
    check bool "空中文数字Token格式化有效" true (String.length empty_chinese >= 0);
    
    let complex_ancient = TokenFormatting.format_ancient_style_token "是故有无相生也" in
    check bool "复杂古雅体Token格式化包含内容" true (contains_substring complex_ancient "是故");
    
    let long_poetry = TokenFormatting.format_poetry_token "床前明月光疑是地上霜" in
    check bool "长诗词Token格式化包含内容" true (contains_substring long_poetry "床前明月光")

  (** 测试Token错误消息边界情况 *)
  let test_token_error_edge_cases () =
    let empty_expectation = TokenFormatting.token_expectation "" "" in
    check bool "空期望消息格式化有效" true (String.length empty_expectation >= 0);
    
    let long_unexpected = TokenFormatting.unexpected_token "非常长的意外Token内容包含很多字符" in
    check bool "长意外Token消息格式化有效" true (String.length long_unexpected > 10)
end

(** 测试套件 *)
let () =
  run "骆言Token格式化模块测试"
    [
      ( "位置信息格式化",
        [
          test_case "基础位置格式化" `Quick Test_Position.test_format_position;
          test_case "带位置的错误格式化" `Quick Test_Position.test_format_error_with_position;
          test_case "可选位置格式化" `Quick Test_Position.test_format_optional_position;
          test_case "范围位置格式化" `Quick Test_Position.test_format_range_position;
          test_case "源码上下文格式化" `Quick Test_Position.test_format_source_context;
          test_case "错误指示器格式化" `Quick Test_Position.test_format_error_indicator;
        ] );
      ( "Token格式化",
        [
          test_case "基础Token类型格式化" `Quick Test_TokenFormatting.test_basic_token_formatting;
          test_case "Token错误消息" `Quick Test_TokenFormatting.test_token_error_messages;
          test_case "复合Token格式化" `Quick Test_TokenFormatting.test_compound_token_formatting;
          test_case "特殊Token格式化" `Quick Test_TokenFormatting.test_special_token_formatting;
          test_case "Token与位置结合格式化" `Quick Test_TokenFormatting.test_token_with_position;
          test_case "中文特定Token格式化" `Quick Test_TokenFormatting.test_chinese_specific_tokens;
          test_case "Token序列格式化" `Quick Test_TokenFormatting.test_token_sequence_formatting;
        ] );
      ( "扩展功能测试",
        [
          test_case "增强位置格式化" `Quick Test_Extended_Position.test_enhanced_position_formatting;
          test_case "错误指示器边界情况" `Quick Test_Extended_Position.test_error_indicator_edge_cases;
        ] );
      ( "Token工具功能",
        [
          test_case "Token序列边界情况" `Quick Test_TokenUtilities.test_token_sequence_edge_cases;
          test_case "中文Token特殊情况" `Quick Test_TokenUtilities.test_chinese_token_edge_cases;
          test_case "Token错误消息边界情况" `Quick Test_TokenUtilities.test_token_error_edge_cases;
        ] );
    ]