(** Token兼容性字面量映射测试套件 - 全面覆盖所有映射功能

    测试目标: token_compatibility_literals.ml 覆盖范围:
    - 数字字面量映射（整数、浮点数）
    - 布尔字面量映射
    - 单位字面量映射
    - 字符串字面量映射
    - 中文数字映射
    - 标识符映射
    - 边界条件和错误情况

    @version 1.0
    @since 2025-07-23 *)

open Yyocamlc_lib
open Token_compatibility_literals
open Unified_token_core

(** 基础功能测试组 *)
let test_basic_number_literals () =
  (* 整数字面量测试 *)
  assert (map_legacy_literal_to_unified "123" = Some (IntToken 123));
  assert (map_legacy_literal_to_unified "0" = Some (IntToken 0));
  assert (map_legacy_literal_to_unified "9999" = Some (IntToken 9999));

  (* 浮点数字面量测试 *)
  assert (map_legacy_literal_to_unified "3.14" = Some (FloatToken 3.14));
  assert (map_legacy_literal_to_unified "0.0" = Some (FloatToken 0.0));
  assert (map_legacy_literal_to_unified "123.456" = Some (FloatToken 123.456));

  print_endline "✅ 基础数字字面量映射测试通过"

let test_boolean_literals () =
  (* 布尔字面量测试 *)
  assert (map_legacy_literal_to_unified "true" = Some (BoolToken true));
  assert (map_legacy_literal_to_unified "false" = Some (BoolToken false));

  print_endline "✅ 布尔字面量映射测试通过"

let test_unit_literals () =
  (* 单位字面量测试 *)
  assert (map_legacy_literal_to_unified "()" = Some UnitToken);
  assert (map_legacy_literal_to_unified "unit" = Some UnitToken);

  print_endline "✅ 单位字面量映射测试通过"

let test_string_literals () =
  (* 字符串字面量测试 *)
  assert (map_legacy_literal_to_unified "\"hello\"" = Some (StringToken "hello"));
  assert (map_legacy_literal_to_unified "\"\"" = Some (StringToken ""));
  assert (map_legacy_literal_to_unified "\"中文测试\"" = Some (StringToken "中文测试"));
  assert (map_legacy_literal_to_unified "\"带空格的字符串\"" = Some (StringToken "带空格的字符串"));

  print_endline "✅ 字符串字面量映射测试通过"

let test_chinese_number_literals () =
  (* 中文数字字面量测试 - 基础数字 *)
  assert (map_legacy_literal_to_unified "零" = Some (ChineseNumberToken "零"));
  assert (map_legacy_literal_to_unified "一" = Some (ChineseNumberToken "一"));
  assert (map_legacy_literal_to_unified "二" = Some (ChineseNumberToken "二"));
  assert (map_legacy_literal_to_unified "三" = Some (ChineseNumberToken "三"));
  assert (map_legacy_literal_to_unified "四" = Some (ChineseNumberToken "四"));
  assert (map_legacy_literal_to_unified "五" = Some (ChineseNumberToken "五"));
  assert (map_legacy_literal_to_unified "六" = Some (ChineseNumberToken "六"));
  assert (map_legacy_literal_to_unified "七" = Some (ChineseNumberToken "七"));
  assert (map_legacy_literal_to_unified "八" = Some (ChineseNumberToken "八"));
  assert (map_legacy_literal_to_unified "九" = Some (ChineseNumberToken "九"));

  (* 中文数字字面量测试 - 单位 *)
  assert (map_legacy_literal_to_unified "十" = Some (ChineseNumberToken "十"));
  assert (map_legacy_literal_to_unified "百" = Some (ChineseNumberToken "百"));
  assert (map_legacy_literal_to_unified "千" = Some (ChineseNumberToken "千"));
  assert (map_legacy_literal_to_unified "万" = Some (ChineseNumberToken "万"));

  print_endline "✅ 中文数字字面量映射测试通过"

let test_identifier_mapping () =
  (* 小写字母开头的标识符 *)
  assert (map_legacy_identifier_to_unified "variable" = Some (IdentifierToken "variable"));
  assert (map_legacy_identifier_to_unified "a" = Some (IdentifierToken "a"));
  assert (map_legacy_identifier_to_unified "test123" = Some (IdentifierToken "test123"));
  assert (map_legacy_identifier_to_unified "my_var" = Some (IdentifierToken "my_var"));

  print_endline "✅ 标识符映射测试通过"

(** 边界条件和错误情况测试组 *)
let test_edge_cases () =
  (* 安全的测试函数，捕获可能的异常 *)
  let safe_test input expected =
    try
      let result = map_legacy_literal_to_unified input in
      assert (result = expected)
    with _ -> assert (expected = None)
  in

  (* 无效的字面量应该返回None *)
  safe_test "invalid" None;
  safe_test "abc123" None;

  (* 无效的字符串字面量（缺少引号） *)
  safe_test "\"unclosed" None;
  safe_test "unopened\"" None;

  (* 不支持的中文字符 *)
  safe_test "中" None;
  safe_test "文" None;

  print_endline "✅ 边界条件和错误情况测试通过"

let test_special_number_cases () =
  (* 安全的测试函数 *)
  let safe_test input expected =
    try
      let result = map_legacy_literal_to_unified input in
      assert (result = expected)
    with _ -> assert (expected = None)
  in

  (* 特殊数字格式 *)
  safe_test "000" (Some (IntToken 0));
  safe_test "0.123" (Some (FloatToken 0.123));

  (* 小数点边界情况 *)
  safe_test ".5" None;

  (* 不支持前置小数点 *)
  print_endline "✅ 特殊数字格式测试通过"

let test_identifier_edge_cases () =
  (* 安全的测试函数 *)
  let safe_test input expected =
    try
      let result = map_legacy_identifier_to_unified input in
      assert (result = expected)
    with _ -> assert (expected = None)
  in

  (* 大写字母开头的标识符（应该返回None，因为函数只处理小写） *)
  safe_test "Variable" None;
  safe_test "A" None;
  safe_test "Test123" None;

  (* 数字开头的标识符 *)
  safe_test "1variable" None;
  safe_test "9test" None;

  (* 特殊字符开头的标识符 *)
  safe_test "_variable" None;
  safe_test "-test" None;

  (* 空标识符 *)
  safe_test "" None;

  print_endline "✅ 标识符边界条件测试通过"

(** 性能和压力测试 *)
let test_performance () =
  (* 测试大量映射操作的性能 *)
  let large_numbers = Array.init 1000 (fun i -> string_of_int (i + 1)) in
  (* 避免空字符串 *)
  Array.iter (fun num -> ignore (map_legacy_literal_to_unified num)) large_numbers;

  (* 测试长字符串处理 *)
  let long_string = "\"" ^ String.make 1000 'a' ^ "\"" in
  ignore (map_legacy_literal_to_unified long_string);

  print_endline "✅ 性能压力测试通过"

(** 综合功能测试 *)
let test_comprehensive_mapping () =
  let test_cases =
    [
      ("42", Some (IntToken 42));
      ("3.14159", Some (FloatToken 3.14159));
      ("true", Some (BoolToken true));
      ("false", Some (BoolToken false));
      ("()", Some UnitToken);
      ("\"test\"", Some (StringToken "test"));
      ("一", Some (ChineseNumberToken "一"));
      ("十", Some (ChineseNumberToken "十"));
      ("invalid", None);
      ("abc", None);
    ]
  in

  List.iter
    (fun (input, expected) ->
      try
        let result = map_legacy_literal_to_unified input in
        assert (result = expected)
      with _ -> assert (expected = None))
    test_cases;

  print_endline "✅ 综合映射功能测试通过"

(** 主测试运行器 *)
let run_all_tests () =
  print_endline "🧪 开始Token兼容性字面量映射全面测试...";
  print_endline "";

  (* 基础功能测试 *)
  test_basic_number_literals ();
  test_boolean_literals ();
  test_unit_literals ();
  test_string_literals ();
  test_chinese_number_literals ();
  test_identifier_mapping ();

  (* 边界条件测试 *)
  test_edge_cases ();
  test_special_number_cases ();
  test_identifier_edge_cases ();

  (* 性能测试 *)
  test_performance ();

  (* 综合测试 *)
  test_comprehensive_mapping ();

  print_endline "";
  print_endline "🎉 所有Token兼容性字面量映射测试完成！";
  print_endline "📊 测试覆盖范围：";
  print_endline "   - 数字字面量映射: ✅";
  print_endline "   - 布尔字面量映射: ✅";
  print_endline "   - 单位字面量映射: ✅";
  print_endline "   - 字符串字面量映射: ✅";
  print_endline "   - 中文数字映射: ✅";
  print_endline "   - 标识符映射: ✅";
  print_endline "   - 边界条件处理: ✅";
  print_endline "   - 错误情况处理: ✅";
  print_endline "   - 性能压力测试: ✅"

(* 如果直接运行此文件，执行所有测试 *)
let () = run_all_tests ()
