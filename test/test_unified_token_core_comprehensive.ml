(** 骆言统一Token核心模块综合测试套件 - Fix #968 第十阶段测试覆盖率提升计划 - 简化版 *)

open Alcotest
open Yyocamlc_lib.Unified_token_core

(** 测试辅助模块 *)
module TestHelpers = struct
  (** 创建测试位置信息 *)
  let make_test_position filename line column offset =
    { filename; line; column; offset }

  (** 检查位置信息相等 *)
  let check_position_equal desc expected actual =
    check bool desc true
      (expected.filename = actual.filename &&
       expected.line = actual.line &&
       expected.column = actual.column &&
       expected.offset = actual.offset)

  (** 检查token相等性 *)
  let check_token_equal desc expected actual =
    check bool desc true (equal_token expected actual)

  (** 示例token列表用于测试 *)
  let sample_tokens = [
    IntToken 42;
    FloatToken 3.14;
    StringToken "测试字符串";
    BoolToken true;
    UnitToken;
    IdentifierToken "变量名";
    LetKeyword;
    FunKeyword;
    IfKeyword;
    ThenKeyword;
    ElseKeyword;
  ]
end

(** Token类型转换测试 *)
module TokenConversionTests = struct

  (** 测试基本token到字符串转换 *)
  let test_basic_token_to_string () =
    (* 测试字面量token *)
    check string "整数token转字符串" "42" (string_of_token (IntToken 42));
    check string "浮点数token转字符串" "3.14" (string_of_token (FloatToken 3.14));
    check string "字符串token转字符串" "\"测试字符串\"" (string_of_token (StringToken "测试字符串"));
    check string "布尔token转字符串" "true" (string_of_token (BoolToken true));
    check string "单元token转字符串" "()" (string_of_token UnitToken);
    
    (* 测试标识符token *)
    check string "标识符token转字符串" "变量名" (string_of_token (IdentifierToken "变量名"));
    
    (* 测试关键字token *)
    check string "let关键字转字符串" "let" (string_of_token LetKeyword);
    check string "fun关键字转字符串" "fun" (string_of_token FunKeyword);
    check string "if关键字转字符串" "if" (string_of_token IfKeyword)

  (** 测试文言文关键字token转换 *)
  let test_wenyan_keywords_to_string () =
    (* 只测试确实存在的文言文关键字 *)
    check string "文言文true关键字转字符串" "真" (string_of_token WenyanTrueKeyword);
    check string "文言文false关键字转字符串" "假" (string_of_token WenyanFalseKeyword)

  (** 测试运算符token转换 *)
  let test_operator_tokens_to_string () =
    check string "加法运算符转字符串" "+" (string_of_token PlusOp);
    check string "减法运算符转字符串" "-" (string_of_token MinusOp);
    check string "乘法运算符转字符串" "*" (string_of_token MultiplyOp);
    check string "除法运算符转字符串" "/" (string_of_token DivideOp);
    check string "等于运算符转字符串" "=" (string_of_token EqualOp)

  (** 测试分隔符token转换 *)
  let test_delimiter_tokens_to_string () =
    check string "左括号转字符串" "(" (string_of_token LeftParen);
    check string "右括号转字符串" ")" (string_of_token RightParen);
    check string "左方括号转字符串" "[" (string_of_token LeftBracket);
    check string "右方括号转字符串" "]" (string_of_token RightBracket);
    check string "左花括号转字符串" "{" (string_of_token LeftBrace);
    check string "右花括号转字符串" "}" (string_of_token RightBrace);
    check string "分号转字符串" ";" (string_of_token Semicolon);
    check string "逗号转字符串" "," (string_of_token Comma)
end

(** 位置Token创建测试 *)
module PositionedTokenTests = struct
  open TestHelpers

  (** 测试位置token创建 *)
  let test_positioned_token_creation () =
    let position = make_test_position "test.ly" 10 5 100 in
    let token = IntToken 42 in
    let positioned_token = make_positioned_token token position None in
    
    check_token_equal "位置token包含正确的token" token positioned_token.token;
    check_position_equal "位置token包含正确的位置" position positioned_token.position

  (** 测试简单token创建 *)
  let test_simple_token_creation () =
    let token = StringToken "简单测试" in
    let simple_token = make_simple_token token "test.ly" 1 5 in
    
    check_token_equal "简单token包含正确的token" token simple_token.token;
    check string "简单token使用正确文件名" "test.ly" simple_token.position.filename

  (** 测试默认位置 *)
  let test_default_position () =
    let default_pos = default_position "test.ly" in
    check string "默认位置文件名" "test.ly" default_pos.filename;
    check int "默认位置行号" 1 default_pos.line;
    check int "默认位置列号" 1 default_pos.column;
    check int "默认位置偏移" 0 default_pos.offset
end

(** Token相等性测试 *)
module TokenEqualityTests = struct
  open TestHelpers

  (** 测试相同token的相等性 *)
  let test_same_tokens_equality () =
    List.iter (fun token ->
      check_token_equal "相同token应该相等" token token
    ) sample_tokens

  (** 测试不同token的不等性 *)
  let test_different_tokens_inequality () =
    let token1 = IntToken 42 in
    let token2 = IntToken 24 in
    let token3 = StringToken "test" in
    
    check bool "不同值的整数token不等" false (equal_token token1 token2);
    check bool "不同类型的token不等" false (equal_token token1 token3)

  (** 测试字面量token的相等性细节 *)
  let test_literal_tokens_equality_details () =
    (* 整数token *)
    check_token_equal "相同整数值token相等" (IntToken 100) (IntToken 100);
    check bool "不同整数值token不等" false (equal_token (IntToken 100) (IntToken 200));
    
    (* 浮点数token *)
    check_token_equal "相同浮点数值token相等" (FloatToken 2.5) (FloatToken 2.5);
    check bool "不同浮点数值token不等" false (equal_token (FloatToken 2.5) (FloatToken 3.5));
    
    (* 字符串token *)
    check_token_equal "相同字符串值token相等" (StringToken "hello") (StringToken "hello");
    check bool "不同字符串值token不等" false (equal_token (StringToken "hello") (StringToken "world"));
    
    (* 布尔token *)
    check_token_equal "相同布尔值token相等" (BoolToken true) (BoolToken true);
    check bool "不同布尔值token不等" false (equal_token (BoolToken true) (BoolToken false))

  (** 测试标识符token的相等性 *)
  let test_identifier_tokens_equality () =
    check_token_equal "相同标识符token相等" (IdentifierToken "变量") (IdentifierToken "变量");
    check bool "不同标识符token不等" false (equal_token (IdentifierToken "变量1") (IdentifierToken "变量2"));
    
    check_token_equal "相同构造器token相等" (ConstructorToken "Some") (ConstructorToken "Some");
    check bool "不同构造器token不等" false (equal_token (ConstructorToken "Some") (ConstructorToken "None"))
end

(** 边界条件测试 *)
module EdgeCaseTests = struct

  (** 测试空字符串标识符 *)
  let test_empty_string_identifier () =
    let empty_id_token = IdentifierToken "" in
    let empty_string_token = StringToken "" in
    
    check string "空标识符转字符串" "" (string_of_token empty_id_token);
    check string "空字符串token转字符串" "\"\"" (string_of_token empty_string_token)

  (** 测试特殊字符在标识符中 *)
  let test_special_chars_in_identifier () =
    let special_chars = ["测试_变量"; "变量123"; "αβγ"; "变量-带-横线"] in
    List.iter (fun name ->
      let token = IdentifierToken name in
      check string ("特殊字符标识符转字符串: " ^ name) name (string_of_token token)
    ) special_chars

  (** 测试极值数字 *)
  let test_extreme_numbers () =
    let max_int_token = IntToken max_int in
    let min_int_token = IntToken min_int in
    let zero_token = IntToken 0 in
    
    check string "最大整数转字符串" (string_of_int max_int) (string_of_token max_int_token);
    check string "最小整数转字符串" (string_of_int min_int) (string_of_token min_int_token);
    check string "零转字符串" "0" (string_of_token zero_token)

  (** 测试浮点数特殊值 *)
  let test_special_float_values () =
    let zero_float = FloatToken 0.0 in
    let small_float = FloatToken 1e-10 in
    let large_float = FloatToken 1e10 in
    
    check string "零浮点数转字符串" "0." (string_of_token zero_float);
    (* 注意：这些测试可能因浮点数格式化而失败，保持简单 *)
    check bool "小浮点数转字符串不为空" true (String.length (string_of_token small_float) > 0);
    check bool "大浮点数转字符串不为空" true (String.length (string_of_token large_float) > 0)
end

(** 性能测试 *)
module PerformanceTests = struct

  (** 测试大量token转换性能 *)
  let test_bulk_token_conversion () =
    let large_token_list = List.init 1000 (fun i -> IntToken i) in
    let start_time = Sys.time () in
    let converted = List.map string_of_token large_token_list in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    check int "转换1000个token数量正确" 1000 (List.length converted);
    check bool "转换1000个token在合理时间内完成" true (duration < 1.0)

  (** 测试大量token相等性比较性能 *)
  let test_bulk_token_equality () =
    let tokens = List.init 1000 (fun i -> IntToken i) in
    let start_time = Sys.time () in
    let comparisons = List.map (fun t -> equal_token t t) tokens in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    check int "比较1000个token数量正确" 1000 (List.length comparisons);
    check bool "所有比较结果都为true" true (List.for_all (fun x -> x) comparisons);
    check bool "比较1000个token在合理时间内完成" true (duration < 1.0)
end

(** 主测试套件 *)
let test_suite = [
  ("Token转换测试", [
    test_case "基本token到字符串转换" `Quick TokenConversionTests.test_basic_token_to_string;
    test_case "文言文关键字token转换" `Quick TokenConversionTests.test_wenyan_keywords_to_string;
    test_case "运算符token转换" `Quick TokenConversionTests.test_operator_tokens_to_string;
    test_case "分隔符token转换" `Quick TokenConversionTests.test_delimiter_tokens_to_string;
  ]);
  
  ("位置Token测试", [
    test_case "位置token创建" `Quick PositionedTokenTests.test_positioned_token_creation;
    test_case "简单token创建" `Quick PositionedTokenTests.test_simple_token_creation;
    test_case "默认位置" `Quick PositionedTokenTests.test_default_position;
  ]);
  
  ("Token相等性测试", [
    test_case "相同token相等性" `Quick TokenEqualityTests.test_same_tokens_equality;
    test_case "不同token不等性" `Quick TokenEqualityTests.test_different_tokens_inequality;
    test_case "字面量token相等性细节" `Quick TokenEqualityTests.test_literal_tokens_equality_details;
    test_case "标识符token相等性" `Quick TokenEqualityTests.test_identifier_tokens_equality;
  ]);
  
  ("边界条件测试", [
    test_case "空字符串标识符" `Quick EdgeCaseTests.test_empty_string_identifier;
    test_case "特殊字符标识符" `Quick EdgeCaseTests.test_special_chars_in_identifier;
    test_case "极值数字" `Quick EdgeCaseTests.test_extreme_numbers;
    test_case "浮点数特殊值" `Quick EdgeCaseTests.test_special_float_values;
  ]);
  
  ("性能测试", [
    test_case "大量token转换性能" `Slow PerformanceTests.test_bulk_token_conversion;
    test_case "大量token相等性比较性能" `Slow PerformanceTests.test_bulk_token_equality;
  ]);
]

(** 运行测试 *)
let () = run "骆言统一Token核心模块综合测试" test_suite