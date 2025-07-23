(** 骆言Token兼容性系统增强测试套件 - Fix #968 第十阶段测试覆盖率提升计划 - 简化版 *)

open Alcotest
open Yyocamlc_lib.Unified_token_core

(** 测试辅助模块 *)
module TestHelpers = struct
  (** 示例token列表用于测试 *)
  let sample_tokens = [
    IntToken 42;
    FloatToken 3.14;
    StringToken "测试";
    BoolToken true;
    UnitToken;
    IdentifierToken "变量";
    LetKeyword;
    FunKeyword;
    IfKeyword;
    PlusOp;
    MinusOp;
    LeftParen;
    RightParen;
  ]
end

(** Token字符串转换测试 *)
module TokenStringConversionTests = struct
  open TestHelpers

  (** 测试基本token到字符串转换 *)
  let test_basic_token_to_string_conversion () =
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

  (** 测试特殊token转换 *)
  let test_special_token_conversion () =
    (* 测试可用的特殊token *)
    check string "加法运算符转字符串" "+" (string_of_token PlusOp);
    check string "减法运算符转字符串" "-" (string_of_token MinusOp);
    check string "左括号转字符串" "(" (string_of_token LeftParen);
    check string "右括号转字符串" ")" (string_of_token RightParen)

  (** 测试批量token转换 *)
  let test_bulk_token_conversion () =
    let converted = List.map string_of_token sample_tokens in
    check int "批量转换数量正确" (List.length sample_tokens) (List.length converted);
    
    (* 检查所有转换结果都不为空 *)
    List.iter (fun str ->
      check bool "转换结果不为空" true (String.length str > 0)
    ) converted
end

(** 边界条件测试 *)
module BoundaryConditionTests = struct
  (** 测试空字符串标识符 *)
  let test_empty_string_identifier () =
    let empty_id_token = IdentifierToken "" in
    let result = string_of_token empty_id_token in
    check string "空标识符转字符串" "" result

  (** 测试极值数字 *)
  let test_extreme_numbers () =
    let max_int_token = IntToken max_int in
    let min_int_token = IntToken min_int in
    let zero_token = IntToken 0 in
    
    check string "最大整数转字符串" (string_of_int max_int) (string_of_token max_int_token);
    check string "最小整数转字符串" (string_of_int min_int) (string_of_token min_int_token);
    check string "零转字符串" "0" (string_of_token zero_token)

  (** 测试特殊字符串内容 *)
  let test_special_string_content () =
    let special_strings = [
      "";
      "\n";
      "\t";
      "\"";
      "\\";
      "测试中文";
      "αβγ";
      "🐫🦀";
    ] in
    
    List.iter (fun s ->
      let token = StringToken s in
      let result = string_of_token token in
      check bool ("特殊字符串token转换: " ^ s) true (String.length result >= 2)  (* 至少包含引号 *)
    ) special_strings
end

(** 性能测试 *)
module PerformanceTests = struct
  (** 测试大量token转换性能 *)
  let test_bulk_conversion_performance () =
    let large_token_list = List.init 10000 (fun i -> IntToken i) in
    let start_time = Sys.time () in
    let converted = List.map string_of_token large_token_list in
    let end_time = Sys.time () in
    let duration = end_time -. start_time in
    
    check int "转换10000个token数量正确" 10000 (List.length converted);
    check bool "转换10000个token在合理时间内完成" true (duration < 2.0)
end

(** 主测试套件 *)
let test_suite = [
  ("Token字符串转换测试", [
    test_case "基本token到字符串转换" `Quick TokenStringConversionTests.test_basic_token_to_string_conversion;
    test_case "特殊token转换" `Quick TokenStringConversionTests.test_special_token_conversion;
    test_case "批量token转换" `Quick TokenStringConversionTests.test_bulk_token_conversion;
  ]);
  
  ("边界条件测试", [
    test_case "空字符串标识符" `Quick BoundaryConditionTests.test_empty_string_identifier;
    test_case "极值数字" `Quick BoundaryConditionTests.test_extreme_numbers;
    test_case "特殊字符串内容" `Quick BoundaryConditionTests.test_special_string_content;
  ]);
  
  ("性能测试", [
    test_case "大量token转换性能" `Slow PerformanceTests.test_bulk_conversion_performance;
  ]);
]

(** 运行测试 *)
let () = run "骆言Token兼容性系统增强测试" test_suite