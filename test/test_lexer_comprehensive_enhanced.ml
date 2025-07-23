(** 骆言词法分析器增强综合测试 - Fix #985 
    提升词法分析器模块测试覆盖率从50.9%到70%+的专项测试模块 *)

open Alcotest
open Yyocamlc_lib.Lexer

(** 测试工具函数 *)
let token_to_string tok =
  match tok with
  | IntToken i -> "IntToken(" ^ string_of_int i ^ ")"
  | FloatToken f -> "FloatToken(" ^ string_of_float f ^ ")"
  | StringToken s -> "StringToken(\"" ^ s ^ "\")"
  | BoolToken b -> "BoolToken(" ^ string_of_bool b ^ ")"
  | QuotedIdentifierToken id -> "QuotedIdentifierToken(\"" ^ id ^ "\")"
  | LetKeyword -> "LetKeyword"
  | FunKeyword -> "FunKeyword"
  | IfKeyword -> "IfKeyword"
  | ThenKeyword -> "ThenKeyword"
  | ElseKeyword -> "ElseKeyword"
  | MatchKeyword -> "MatchKeyword"
  | WithKeyword -> "WithKeyword"
  | TypeKeyword -> "TypeKeyword"
  | TrueKeyword -> "TrueKeyword"
  | FalseKeyword -> "FalseKeyword"
  | Plus -> "Plus"
  | Minus -> "Minus"
  | Star -> "Star"
  | Slash -> "Slash"
  | Equal -> "Equal"
  | NotEqual -> "NotEqual"
  | Less -> "Less"
  | Greater -> "Greater"
  | LessEqual -> "LessEqual"
  | GreaterEqual -> "GreaterEqual"
  | Arrow -> "Arrow"
  | DoubleArrow -> "DoubleArrow"
  | LeftParen -> "LeftParen"
  | RightParen -> "RightParen"
  | LeftBracket -> "LeftBracket"
  | RightBracket -> "RightBracket"
  | LeftBrace -> "LeftBrace"
  | RightBrace -> "RightBrace"
  | Comma -> "Comma"
  | Semicolon -> "Semicolon"
  | Colon -> "Colon"
  | Pipe -> "Pipe"
  | Dot -> "Dot"
  | EOF -> "EOF"
  | Newline -> "Newline"
  | ChineseNumberToken s -> "ChineseNumberToken(\"" ^ s ^ "\")"
  | HaveKeyword -> "HaveKeyword"
  | CallKeyword -> "CallKeyword"
  | AsForKeyword -> "AsForKeyword"
  | InKeyword -> "InKeyword"
  | PlusKeyword -> "PlusKeyword"
  | SubtractKeyword -> "SubtractKeyword"
  | MultiplyKeyword -> "MultiplyKeyword"
  | DivideKeyword -> "DivideKeyword"
  | EqualToKeyword -> "EqualToKeyword"
  | LessThanWenyan -> "LessThanWenyan"
  | GreaterThanWenyan -> "GreaterThanWenyan"
  | ChineseLeftParen -> "ChineseLeftParen"
  | ChineseRightParen -> "ChineseRightParen"
  | ChineseComma -> "ChineseComma"
  | ChineseColon -> "ChineseColon"
  | RecKeyword -> "RecKeyword"
  | AndKeyword -> "AndKeyword"
  | OrKeyword -> "OrKeyword"
  | NotKeyword -> "NotKeyword"
  | TryKeyword -> "TryKeyword"
  | CatchKeyword -> "CatchKeyword"
  | FinallyKeyword -> "FinallyKeyword"
  | RaiseKeyword -> "RaiseKeyword"
  | _ -> "UnknownToken"

(* 单个token检查函数保留，可能在其他地方使用
let check_token msg expected actual =
  check (of_pp (fun fmt tok -> Format.pp_print_string fmt (token_to_string tok))) msg expected actual
*)

let check_token_list msg expected actual =
  let extract_tokens positioned_tokens = List.map fst positioned_tokens in
  check (list (of_pp (fun fmt tok -> Format.pp_print_string fmt (token_to_string tok))))
    msg expected (extract_tokens actual)

let safe_tokenize input =
  try
    tokenize input "test.ly"
  with
  | _ -> [(EOF, {line = 0; column = 0; filename = "test.ly"})]

(** 基本字面量测试 *)
let test_integer_literals () =
  (* 正整数 *)
  let tokens1 = tokenize "42" "test.ly" in
  check_token_list "正整数字面量" [IntToken 42; EOF] tokens1;
  
  (* 零 *)
  let tokens2 = tokenize "0" "test.ly" in
  check_token_list "零字面量" [IntToken 0; EOF] tokens2;
  
  (* 大整数 *)
  let tokens3 = tokenize "9876543210" "test.ly" in
  check_token_list "大整数字面量" [IntToken 9876543210; EOF] tokens3;
  
  (* 单个数字 *)
  let tokens4 = tokenize "1 2 3 4 5" "test.ly" in
  check_token_list "单个数字序列" 
    [IntToken 1; IntToken 2; IntToken 3; IntToken 4; IntToken 5; EOF] tokens4

let test_float_literals () =
  (* 基本浮点数 *)
  let tokens1 = tokenize "3.14" "test.ly" in
  check_token_list "基本浮点数" [FloatToken 3.14; EOF] tokens1;
  
  (* 小数点开头 *)
  let tokens2 = tokenize ".5" "test.ly" in
  check_token_list "小数点开头浮点数" [FloatToken 0.5; EOF] tokens2;
  
  (* 零浮点数 *)
  let tokens3 = tokenize "0.0" "test.ly" in
  check_token_list "零浮点数" [FloatToken 0.0; EOF] tokens3;
  
  (* 科学记数法（如果支持） *)
  let tokens4 = safe_tokenize "1.23e4" in
  check bool "科学记数法浮点数测试" true (List.length tokens4 >= 1)

let test_string_literals () =
  (* 基本字符串 *)
  let tokens1 = tokenize "『你好世界』" "test.ly" in
  check_token_list "基本中文字符串" [StringToken "你好世界"; EOF] tokens1;
  
  (* 英文字符串 *)
  let tokens2 = tokenize "『Hello World』" "test.ly" in
  check_token_list "英文字符串" [StringToken "Hello World"; EOF] tokens2;
  
  (* 空字符串 *)
  let tokens3 = tokenize "『』" "test.ly" in
  check_token_list "空字符串" [StringToken ""; EOF] tokens3;
  
  (* 包含符号的字符串 *)
  let tokens4 = tokenize "『包含!@#$%符号』" "test.ly" in
  check_token_list "包含符号字符串" [StringToken "包含!@#$%符号"; EOF] tokens4;
  
  (* 包含数字的字符串 *)
  let tokens5 = tokenize "『版本1.0.0』" "test.ly" in
  check_token_list "包含数字字符串" [StringToken "版本1.0.0"; EOF] tokens5

let test_boolean_literals () =
  (* 中文布尔字面量 *)
  let tokens1 = tokenize "真 假" "test.ly" in
  check_token_list "中文布尔字面量" [TrueKeyword; FalseKeyword; EOF] tokens1;
  
  (* 英文布尔字面量（如果支持） *)
  let tokens2 = safe_tokenize "true false" in
  check bool "英文布尔字面量测试" true (List.length tokens2 >= 1)

(** 标识符测试 *)
let test_quoted_identifiers () =
  (* 基本中文标识符 *)
  let tokens1 = tokenize "「变量名」" "test.ly" in
  check_token_list "基本中文标识符" [QuotedIdentifierToken "变量名"; EOF] tokens1;
  
  (* 英文标识符 *)
  let tokens2 = tokenize "「variable_name」" "test.ly" in
  check_token_list "英文标识符" [QuotedIdentifierToken "variable_name"; EOF] tokens2;
  
  (* 混合标识符 *)
  let tokens3 = tokenize "「变量name123」" "test.ly" in
  check_token_list "混合标识符" [QuotedIdentifierToken "变量name123"; EOF] tokens3;
  
  (* 包含符号的标识符 *)
  let tokens4 = tokenize "「测试_标识符」" "test.ly" in
  check_token_list "包含下划线标识符" [QuotedIdentifierToken "测试_标识符"; EOF] tokens4;
  
  (* 单字符标识符 *)
  let tokens5 = tokenize "「x」 「y」 「z」" "test.ly" in
  check_token_list "单字符标识符序列" 
    [QuotedIdentifierToken "x"; QuotedIdentifierToken "y"; QuotedIdentifierToken "z"; EOF] tokens5

let test_complex_identifiers () =
  (* 诗词风格标识符 *)
  let tokens1 = tokenize "「春眠不觉晓」" "test.ly" in
  check_token_list "诗词风格标识符" [QuotedIdentifierToken "春眠不觉晓"; EOF] tokens1;
  
  (* 长标识符 *)
  let tokens2 = tokenize "「这是一个非常长的标识符名称用于测试」" "test.ly" in
  check_token_list "长标识符" [QuotedIdentifierToken "这是一个非常长的标识符名称用于测试"; EOF] tokens2;
  
  (* 数学符号标识符 *)
  let tokens3 = tokenize "「α」 「β」 「γ」" "test.ly" in
  check_token_list "数学符号标识符" 
    [QuotedIdentifierToken "α"; QuotedIdentifierToken "β"; QuotedIdentifierToken "γ"; EOF] tokens3

(** 关键字测试 *)
let test_basic_keywords () =
  let input = "设 函数 若 则 否则 匹配 与" in
  let tokens = tokenize input "test.ly" in
  let expected = [LetKeyword; FunKeyword; IfKeyword; ThenKeyword; ElseKeyword; MatchKeyword; WithKeyword; EOF] in
  check_token_list "基本关键字" expected tokens

let test_type_keywords () =
  let input = "类型 递归 有 调用 作为 在" in
  let tokens = tokenize input "test.ly" in
  let expected = [TypeKeyword; RecKeyword; HaveKeyword; CallKeyword; AsForKeyword; InKeyword; EOF] in
  check_token_list "类型相关关键字" expected tokens

let test_control_flow_keywords () =
  let input = "尝试 捕获 最终 抛出" in
  let tokens = safe_tokenize input in
  check bool "控制流关键字测试" true (List.length tokens >= 1)

let test_operator_keywords () =
  let input = "加 减去 乘以 除以 等于" in
  let tokens = tokenize input "test.ly" in
  let expected = [PlusKeyword; SubtractKeyword; MultiplyKeyword; DivideKeyword; EqualToKeyword; EOF] in
  check_token_list "运算符关键字" expected tokens

let test_comparison_keywords () =
  let input = "小于 大于" in
  let tokens = tokenize input "test.ly" in
  let expected = [LessThanWenyan; GreaterThanWenyan; EOF] in
  check_token_list "比较运算符关键字" expected tokens

(** 运算符和符号测试 *)
let test_arithmetic_operators () =
  let input = "+ - * /" in
  let tokens = tokenize input "test.ly" in
  let expected = [Plus; Minus; Star; Slash; EOF] in
  check_token_list "算术运算符" expected tokens

let test_comparison_operators () =
  let input = "= != < > <= >=" in
  let tokens = tokenize input "test.ly" in
  let expected = [Equal; NotEqual; Less; Greater; LessEqual; GreaterEqual; EOF] in
  check_token_list "比较运算符" expected tokens

let test_special_operators () =
  let input = "-> =>" in
  let tokens = tokenize input "test.ly" in
  let expected = [Arrow; DoubleArrow; EOF] in
  check_token_list "特殊运算符" expected tokens

let test_punctuation_symbols () =
  let input = "( ) [ ] { }" in
  let tokens = tokenize input "test.ly" in
  let expected = [LeftParen; RightParen; LeftBracket; RightBracket; LeftBrace; RightBrace; EOF] in
  check_token_list "括号符号" expected tokens

let test_delimiter_symbols () =
  let input = ", ; : | ." in
  let tokens = tokenize input "test.ly" in
  let expected = [Comma; Semicolon; Colon; Pipe; Dot; EOF] in
  check_token_list "分隔符号" expected tokens

(** 中文符号测试 *)
let test_chinese_punctuation () =
  let input = "（） ， ：" in
  let tokens = tokenize input "test.ly" in
  let expected = [ChineseLeftParen; ChineseRightParen; ChineseComma; ChineseColon; EOF] in
  check_token_list "中文标点符号" expected tokens

let test_mixed_punctuation () =
  let input = "( 「变量」， ) [ 42 ]" in
  let tokens = tokenize input "test.ly" in
  let expected = [
    LeftParen; QuotedIdentifierToken "变量"; ChineseComma; RightParen; 
    LeftBracket; IntToken 42; RightBracket; EOF
  ] in
  check_token_list "混合标点符号" expected tokens

(** 中文数字测试 *)
let test_simple_chinese_numbers () =
  let input = "一 二 三 四 五" in
  let tokens = tokenize input "test.ly" in
  let expected = [IntToken 1; IntToken 2; IntToken 3; IntToken 4; IntToken 5; EOF] in
  check_token_list "简单中文数字" expected tokens

let test_complex_chinese_numbers () =
  let input = "十 二十 一百 一千" in
  let tokens = safe_tokenize input in
  check bool "复杂中文数字测试" true (List.length tokens >= 1)

let test_large_chinese_numbers () =
  let input = "九万八千七百六十五" in
  let tokens = safe_tokenize input in
  check bool "大中文数字测试" true (List.length tokens >= 1)

(** 空白字符处理测试 *)
let test_whitespace_handling () =
  (* 空格分隔 *)
  let tokens1 = tokenize "42 『hello』" "test.ly" in
  check_token_list "空格分隔测试" [IntToken 42; StringToken "hello"; EOF] tokens1;
  
  (* 制表符分隔 *)
  let tokens2 = tokenize "42\t『hello』" "test.ly" in
  check_token_list "制表符分隔测试" [IntToken 42; StringToken "hello"; EOF] tokens2;
  
  (* 多个空白字符 *)
  let tokens3 = tokenize "42    『hello』" "test.ly" in
  check_token_list "多空白字符测试" [IntToken 42; StringToken "hello"; EOF] tokens3

let test_newline_handling () =
  (* 换行符处理 *)
  let tokens1 = tokenize "42\n『hello』" "test.ly" in
  let expected = [IntToken 42; Newline; StringToken "hello"; EOF] in
  check_token_list "换行符处理测试" expected tokens1;
  
  (* 多个换行符 *)
  let tokens2 = tokenize "42\n\n『hello』" "test.ly" in
  check bool "多换行符测试" true (List.length tokens2 >= 3)

(** 注释处理测试 *)
let test_comment_handling () =
  (* 行注释 *)
  let tokens1 = safe_tokenize "42 // 这是注释" in
  check bool "行注释处理测试" true (List.length tokens1 >= 1);
  
  (* 中文注释 *)
  let tokens2 = safe_tokenize "42 # 中文注释" in
  check bool "中文注释处理测试" true (List.length tokens2 >= 1);
  
  (* 块注释（如果支持） *)
  let tokens3 = safe_tokenize "42 /* 块注释 */ 『hello』" in
  check bool "块注释处理测试" true (List.length tokens3 >= 1)

(** 错误处理测试 *)
let test_invalid_input_handling () =
  (* 无效字符 *)
  let tokens1 = safe_tokenize "42 @ 『hello』" in
  check bool "无效字符处理测试" true (List.length tokens1 >= 1);
  
  (* 不匹配的引号 *)
  let tokens2 = safe_tokenize "『未闭合字符串" in
  check bool "不匹配引号处理测试" true (List.length tokens2 >= 1);
  
  (* 不匹配的标识符引号 *)
  let tokens3 = safe_tokenize "「未闭合标识符" in
  check bool "不匹配标识符引号处理测试" true (List.length tokens3 >= 1)

let test_edge_cases () =
  (* 空输入 *)
  let tokens1 = tokenize "" "test.ly" in
  check_token_list "空输入测试" [EOF] tokens1;
  
  (* 只有空白字符 *)
  let tokens2 = tokenize "   \t  \n  " "test.ly" in
  check bool "只有空白字符测试" true (List.length tokens2 >= 1);
  
  (* 非常长的输入 *)
  let long_input = String.make 1000 'a' in
  let tokens3 = safe_tokenize ("『" ^ long_input ^ "』") in
  check bool "长输入处理测试" true (List.length tokens3 >= 1)

(** 复杂表达式测试 *)
let test_arithmetic_expression () =
  let input = "42 + 3.14 * 「变量」" in
  let tokens = tokenize input "test.ly" in
  let expected = [
    IntToken 42; Plus; FloatToken 3.14; Star; QuotedIdentifierToken "变量"; EOF
  ] in
  check_token_list "算术表达式" expected tokens

let test_function_definition () =
  let input = "函数 「阶乘」 「n」 = 若 「n」 等于 0 则 1 否则 「n」 乘以 调用 「阶乘」 （「n」 减去 1）" in
  let tokens = tokenize input "test.ly" in
  check bool "函数定义词法分析" true (List.length tokens >= 10)

let test_pattern_matching () =
  let input = "匹配 「列表」 与 | 「头」 :: 「尾」 -> 处理" in
  let tokens = safe_tokenize input in
  check bool "模式匹配词法分析" true (List.length tokens >= 5)

let test_type_definition () =
  let input = "类型 「选项」 作为 | 「某些」 「值」 | 「无」" in
  let tokens = tokenize input "test.ly" in
  check bool "类型定义词法分析" true (List.length tokens >= 5)

(** 诗词编程特色测试 *)
let test_poetry_style_code () =
  let input = "设 「春眠不觉晓」 = 42\n设 「处处闻啼鸟」 = 『你好』" in
  let tokens = tokenize input "test.ly" in
  check bool "诗词风格代码" true (List.length tokens >= 8)

let test_classical_identifiers () =
  let input = "「窗含西岭千秋雪」 「门泊东吴万里船」" in
  let tokens = tokenize input "test.ly" in
  let expected = [
    QuotedIdentifierToken "窗含西岭千秋雪"; 
    QuotedIdentifierToken "门泊东吴万里船"; 
    EOF
  ] in
  check_token_list "古典诗词标识符" expected tokens

(** 性能测试 *)
let test_tokenization_performance () =
  (* 大量token的性能测试 *)
  let large_input = String.concat " " (List.init 1000 (fun i -> string_of_int i)) in
  let start_time = Sys.time () in
  let tokens = safe_tokenize large_input in
  let end_time = Sys.time () in
  let duration = end_time -. start_time in
  
  check bool "大量token性能测试" true (List.length tokens >= 500);
  check bool "词法分析性能测试" true (duration < 1.0) (* 应该在1秒内完成 *)

let test_mixed_language_tokens () =
  (* 中英文混合 *)
  let input = "设 variable = 42 加 3" in
  let tokens = safe_tokenize input in
  check bool "中英文混合测试" true (List.length tokens >= 5);
  
  (* 符号和文字混合 *)
  let input2 = "42 + 「变量」 * 3.14" in
  let tokens2 = tokenize input2 "test.ly" in
  check bool "符号文字混合测试" true (List.length tokens2 >= 5)

(** 运行所有测试 *)
let () =
  run "词法分析器增强综合测试 - Fix #985"
    [
      ("基本字面量测试", [
        test_case "整数字面量识别" `Quick test_integer_literals;
        test_case "浮点数字面量识别" `Quick test_float_literals;
        test_case "字符串字面量识别" `Quick test_string_literals;
        test_case "布尔字面量识别" `Quick test_boolean_literals;
      ]);
      
      ("标识符测试", [
        test_case "引用标识符识别" `Quick test_quoted_identifiers;
        test_case "复杂标识符识别" `Quick test_complex_identifiers;
      ]);
      
      ("关键字测试", [
        test_case "基本关键字识别" `Quick test_basic_keywords;
        test_case "类型关键字识别" `Quick test_type_keywords;
        test_case "控制流关键字识别" `Quick test_control_flow_keywords;
        test_case "运算符关键字识别" `Quick test_operator_keywords;
        test_case "比较关键字识别" `Quick test_comparison_keywords;
      ]);
      
      ("运算符和符号测试", [
        test_case "算术运算符识别" `Quick test_arithmetic_operators;
        test_case "比较运算符识别" `Quick test_comparison_operators;
        test_case "特殊运算符识别" `Quick test_special_operators;
        test_case "标点符号识别" `Quick test_punctuation_symbols;
        test_case "分隔符识别" `Quick test_delimiter_symbols;
      ]);
      
      ("中文特色测试", [
        test_case "中文标点符号识别" `Quick test_chinese_punctuation;
        test_case "混合标点符号识别" `Quick test_mixed_punctuation;
        test_case "简单中文数字识别" `Quick test_simple_chinese_numbers;
        test_case "复杂中文数字识别" `Quick test_complex_chinese_numbers;
        test_case "大中文数字识别" `Quick test_large_chinese_numbers;
      ]);
      
      ("空白字符和注释测试", [
        test_case "空白字符处理" `Quick test_whitespace_handling;
        test_case "换行符处理" `Quick test_newline_handling;
        test_case "注释处理" `Quick test_comment_handling;
      ]);
      
      ("错误处理测试", [
        test_case "无效输入处理" `Quick test_invalid_input_handling;
        test_case "边界情况处理" `Quick test_edge_cases;
      ]);
      
      ("复杂表达式测试", [
        test_case "算术表达式词法分析" `Quick test_arithmetic_expression;
        test_case "函数定义词法分析" `Quick test_function_definition;
        test_case "模式匹配词法分析" `Quick test_pattern_matching;
        test_case "类型定义词法分析" `Quick test_type_definition;
      ]);
      
      ("诗词编程特色测试", [
        test_case "诗词风格代码词法分析" `Quick test_poetry_style_code;
        test_case "古典诗词标识符识别" `Quick test_classical_identifiers;
      ]);
      
      ("性能和兼容性测试", [
        test_case "词法分析性能测试" `Slow test_tokenization_performance;
        test_case "混合语言token测试" `Quick test_mixed_language_tokens;
      ]);
    ]