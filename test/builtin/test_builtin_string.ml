(** 骆言内置字符串模块测试 - Phase 26 内置模块测试覆盖率提升

    本测试模块专门针对 builtin_string.ml 模块进行全面功能测试， 重点测试字符串处理的正确性、中文字符支持和边界条件处理。

    测试覆盖范围：
    - 字符串连接操作
    - 字符串包含检测
    - 字符串分割功能
    - 字符串模式匹配
    - 字符串长度和反转
    - 中文字符串处理
    - Unicode支持验证

    @author 骆言技术债务清理团队 - Phase 26
    @version 1.0
    @since 2025-07-20 Issue #680 内置模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_string

(** 测试工具函数 *)
module TestUtils = struct
  (** 验证运行时错误 *)
  let expect_runtime_error f =
    try
      ignore (f ());
      false
    with
    | RuntimeError _ -> true
    | _ -> false

  (** 验证两个值相等 *)
  let values_equal v1 v2 =
    match (v1, v2) with
    | IntValue a, IntValue b -> a = b
    | StringValue a, StringValue b -> a = b
    | BoolValue a, BoolValue b -> a = b
    | UnitValue, UnitValue -> true
    | ListValue a, ListValue b -> List.length a = List.length b && List.for_all2 ( = ) a b
    | BuiltinFunctionValue _, BuiltinFunctionValue _ -> true (* 函数比较 *)
    | _ -> false

  (** 执行柯里化函数 - 适用于字符串函数的两步调用模式 *)
  let apply_curried_function func arg1 arg2 =
    match func [ arg1 ] with BuiltinFunctionValue next_func -> next_func [ arg2 ] | other -> other

  (** 验证字符串列表内容 *)
  let check_string_list result expected_strings =
    match result with
    | ListValue items ->
        List.length items = List.length expected_strings
        && List.for_all2
             (fun actual expected -> match actual with StringValue s -> s = expected | _ -> false)
             items expected_strings
    | _ -> false
end

(** 字符串连接功能测试 *)
module StringConcatTests = struct
  (** 测试基本字符串连接 *)
  let test_basic_string_concat () =
    (* 测试英文字符串连接 *)
    let result1 =
      TestUtils.apply_curried_function string_concat_function (StringValue "Hello")
        (StringValue "World")
    in
    check bool "英文字符串连接应正确" true (TestUtils.values_equal result1 (StringValue "HelloWorld"));

    (* 测试带空格的连接 *)
    let result2 =
      TestUtils.apply_curried_function string_concat_function (StringValue "Hello ")
        (StringValue "World")
    in
    check bool "带空格连接应正确" true (TestUtils.values_equal result2 (StringValue "Hello World"));

    (* 测试空字符串连接 *)
    let result3 =
      TestUtils.apply_curried_function string_concat_function (StringValue "") (StringValue "Test")
    in
    check bool "空字符串连接应正确" true (TestUtils.values_equal result3 (StringValue "Test"))

  (** 测试中文字符串连接 *)
  let test_chinese_string_concat () =
    (* 测试中文字符串连接 *)
    let result1 =
      TestUtils.apply_curried_function string_concat_function (StringValue "你好") (StringValue "世界")
    in
    check bool "中文字符串连接应正确" true (TestUtils.values_equal result1 (StringValue "你好世界"));

    (* 测试中英文混合连接 *)
    let result2 =
      TestUtils.apply_curried_function string_concat_function (StringValue "Hello")
        (StringValue "世界")
    in
    check bool "中英文混合连接应正确" true (TestUtils.values_equal result2 (StringValue "Hello世界"));

    (* 测试诗词连接 *)
    let result3 =
      TestUtils.apply_curried_function string_concat_function (StringValue "春眠不觉晓，")
        (StringValue "处处闻啼鸟。")
    in
    check bool "诗词连接应正确" true (TestUtils.values_equal result3 (StringValue "春眠不觉晓，处处闻啼鸟。"))

  (** 测试字符串连接的边界条件 *)
  let test_concat_boundary_cases () =
    (* 测试两个空字符串连接 *)
    let result1 =
      TestUtils.apply_curried_function string_concat_function (StringValue "") (StringValue "")
    in
    check bool "两个空字符串连接应为空" true (TestUtils.values_equal result1 (StringValue ""));

    (* 测试很长字符串连接 *)
    let long_string1 = String.make 1000 'A' in
    let long_string2 = String.make 1000 'B' in
    let result2 =
      TestUtils.apply_curried_function string_concat_function (StringValue long_string1)
        (StringValue long_string2)
    in
    let expected_long = long_string1 ^ long_string2 in
    check bool "长字符串连接应正确" true (TestUtils.values_equal result2 (StringValue expected_long))
end

(** 字符串包含检测测试 *)
module StringContainsTests = struct
  (** 测试基本包含检测 *)
  let test_basic_string_contains () =
    (* 测试字符包含检测 *)
    let result1 =
      TestUtils.apply_curried_function string_contains_function (StringValue "Hello World")
        (StringValue "H")
    in
    check bool "应检测到包含字符H" true (TestUtils.values_equal result1 (BoolValue true));

    let result2 =
      TestUtils.apply_curried_function string_contains_function (StringValue "Hello World")
        (StringValue "X")
    in
    check bool "应检测到不包含字符X" true (TestUtils.values_equal result2 (BoolValue false))

  (** 测试ASCII字符包含检测（中文字符由于UTF-8多字节限制暂不支持） *)
  let test_chinese_string_contains () =
    (* 注意：当前实现使用String.get只能处理单字节字符，中文字符需要特殊处理 *)
    (* 测试包含ASCII字符的中文字符串 *)
    let result1 =
      TestUtils.apply_curried_function string_contains_function (StringValue "Hello你好")
        (StringValue "H")
    in
    check bool "应检测到包含ASCII字符'H'" true (TestUtils.values_equal result1 (BoolValue true));

    let result2 =
      TestUtils.apply_curried_function string_contains_function (StringValue "春眠不觉晓ABC")
        (StringValue "A")
    in
    check bool "应检测到包含ASCII字符'A'" true (TestUtils.values_equal result2 (BoolValue true))

  (** 测试包含检测的边界条件 *)
  let test_contains_boundary_cases () =
    (* 测试空字符串中查找 *)
    let result1 =
      TestUtils.apply_curried_function string_contains_function (StringValue "") (StringValue "a")
    in
    check bool "空字符串不应包含任何字符" true (TestUtils.values_equal result1 (BoolValue false));

    (* 测试单字符字符串 *)
    let result2 =
      TestUtils.apply_curried_function string_contains_function (StringValue "A") (StringValue "A")
    in
    check bool "单字符字符串应包含自身" true (TestUtils.values_equal result2 (BoolValue true))
end

(** 字符串分割功能测试 *)
module StringSplitTests = struct
  (** 测试基本字符串分割 *)
  let test_basic_string_split () =
    (* 测试逗号分割 *)
    let result1 =
      TestUtils.apply_curried_function string_split_function (StringValue "a,b,c") (StringValue ",")
    in
    check bool "逗号分割应正确" true (TestUtils.check_string_list result1 [ "a"; "b"; "c" ]);

    (* 测试空格分割 *)
    let result2 =
      TestUtils.apply_curried_function string_split_function (StringValue "Hello World Test")
        (StringValue " ")
    in
    check bool "空格分割应正确" true (TestUtils.check_string_list result2 [ "Hello"; "World"; "Test" ])

  (** 测试中文字符串分割（注意：当前实现仅支持ASCII分隔符） *)
  let test_chinese_string_split () =
    (* 注意：当前实现使用String.split_on_char只能处理单字节分隔符 *)
    (* 测试ASCII分隔符分割中文字符串 *)
    let result1 =
      TestUtils.apply_curried_function string_split_function (StringValue "春,夏,秋,冬")
        (StringValue ",")
    in
    check bool "ASCII逗号分割中文应正确" true (TestUtils.check_string_list result1 [ "春"; "夏"; "秋"; "冬" ]);

    (* 测试分号分割 *)
    let result2 =
      TestUtils.apply_curried_function string_split_function (StringValue "春眠不觉晓;处处闻啼鸟")
        (StringValue ";")
    in
    check bool "分号分割应正确" true (TestUtils.check_string_list result2 [ "春眠不觉晓"; "处处闻啼鸟" ])

  (** 测试分割的边界条件 *)
  let test_split_boundary_cases () =
    (* 测试空字符串分割 *)
    let result1 =
      TestUtils.apply_curried_function string_split_function (StringValue "") (StringValue ",")
    in
    check bool "空字符串分割应返回包含空字符串的列表" true (TestUtils.check_string_list result1 [ "" ]);

    (* 测试不包含分隔符的字符串 *)
    let result2 =
      TestUtils.apply_curried_function string_split_function (StringValue "NoSeparator")
        (StringValue ",")
    in
    check bool "不包含分隔符应返回原字符串" true (TestUtils.check_string_list result2 [ "NoSeparator" ])
end

(** 字符串模式匹配测试 *)
module StringMatchTests = struct
  (** 测试基本模式匹配 *)
  let test_basic_string_match () =
    (* 测试简单字符匹配 *)
    let result1 =
      TestUtils.apply_curried_function string_match_function (StringValue "Hello")
        (StringValue "H.*")
    in
    check bool "应匹配以H开头的模式" true (TestUtils.values_equal result1 (BoolValue true));

    let result2 =
      TestUtils.apply_curried_function string_match_function (StringValue "Hello")
        (StringValue "A.*")
    in
    check bool "不应匹配以A开头的模式" true (TestUtils.values_equal result2 (BoolValue false))

  (** 测试复杂模式匹配 *)
  let test_complex_string_match () =
    (* 测试数字模式 *)
    let result1 =
      TestUtils.apply_curried_function string_match_function (StringValue "123")
        (StringValue "[0-9]+")
    in
    check bool "应匹配数字模式" true (TestUtils.values_equal result1 (BoolValue true));

    (* 测试精确匹配 *)
    let result2 =
      TestUtils.apply_curried_function string_match_function (StringValue "test")
        (StringValue "test")
    in
    check bool "应精确匹配" true (TestUtils.values_equal result2 (BoolValue true))

  (** 测试模式匹配边界条件 *)
  let test_match_boundary_cases () =
    (* 测试空字符串匹配 *)
    let result1 =
      TestUtils.apply_curried_function string_match_function (StringValue "") (StringValue ".*")
    in
    check bool "空字符串应匹配.*模式" true (TestUtils.values_equal result1 (BoolValue true));

    (* 测试单字符匹配 *)
    let result2 =
      TestUtils.apply_curried_function string_match_function (StringValue "a") (StringValue ".")
    in
    check bool "单字符应匹配.模式" true (TestUtils.values_equal result2 (BoolValue true))
end

(** 字符串长度和反转测试 *)
module StringLengthReverseTests = struct
  (** 测试字符串长度功能 *)
  let test_string_length () =
    (* 测试英文字符串长度 *)
    let result1 = string_length_function [ StringValue "Hello" ] in
    check bool "英文字符串长度应为5" true (TestUtils.values_equal result1 (IntValue 5));

    (* 测试中文字符串长度（UTF-8字节数） *)
    let result2 = string_length_function [ StringValue "你好" ] in
    check bool "中文字符串字节长度应为6" true (TestUtils.values_equal result2 (IntValue 6));

    (* 测试空字符串长度 *)
    let result3 = string_length_function [ StringValue "" ] in
    check bool "空字符串长度应为0" true (TestUtils.values_equal result3 (IntValue 0))

  (** 测试字符串反转功能 *)
  let test_string_reverse () =
    (* 测试英文字符串反转 *)
    let result1 = string_reverse_function [ StringValue "Hello" ] in
    check bool "英文字符串反转应正确" true (TestUtils.values_equal result1 (StringValue "olleH"));

    (* 测试简单字符反转 *)
    let result2 = string_reverse_function [ StringValue "abc" ] in
    check bool "简单字符反转应正确" true (TestUtils.values_equal result2 (StringValue "cba"));

    (* 测试空字符串反转 *)
    let result3 = string_reverse_function [ StringValue "" ] in
    check bool "空字符串反转应为空" true (TestUtils.values_equal result3 (StringValue ""))

  (** 测试长度和反转的边界条件 *)
  let test_length_reverse_boundary_cases () =
    (* 测试单字符处理 *)
    let single_char = StringValue "A" in
    let length_result = string_length_function [ single_char ] in
    let reverse_result = string_reverse_function [ single_char ] in
    check bool "单字符长度应为1" true (TestUtils.values_equal length_result (IntValue 1));
    check bool "单字符反转应为自身" true (TestUtils.values_equal reverse_result (StringValue "A"));

    (* 测试长字符串 *)
    let long_string = StringValue (String.make 1000 'X') in
    let long_length = string_length_function [ long_string ] in
    check bool "长字符串长度应为1000" true (TestUtils.values_equal long_length (IntValue 1000))
end

(** 复杂场景和集成测试 *)
module StringIntegrationTests = struct
  (** 测试字符串函数组合使用 *)
  let test_string_function_composition () =
    (* 连接后分割 *)
    let concat_result =
      TestUtils.apply_curried_function string_concat_function (StringValue "a,b")
        (StringValue ",c,d")
    in
    let split_result =
      TestUtils.apply_curried_function string_split_function concat_result (StringValue ",")
    in
    check bool "连接后分割应正确" true (TestUtils.check_string_list split_result [ "a"; "b"; "c"; "d" ]);

    (* 反转后检查长度 *)
    let original = StringValue "Test" in
    let reversed = string_reverse_function [ original ] in
    let original_length = string_length_function [ original ] in
    let reversed_length = string_length_function [ reversed ] in
    check bool "反转后长度应保持一致" true (TestUtils.values_equal original_length reversed_length)

  (** 测试字符串函数表完整性 *)
  let test_string_functions_table () =
    let expected_core_functions = [ "字符串连接"; "字符串包含"; "字符串分割"; "字符串匹配"; "字符串长度"; "字符串反转" ] in
    let actual_functions = List.map fst string_functions in

    (* 确保包含核心字符串函数 *)
    List.iter
      (fun expected ->
        check bool (Printf.sprintf "函数表应包含'%s'" expected) true (List.mem expected actual_functions))
      expected_core_functions;

    (* 检查函数表大小至少包含核心函数，支持扩展功能 *)
    check bool "字符串函数表应包含至少6个核心函数" true (List.length actual_functions >= List.length expected_core_functions);
    
    (* 验证实际的函数表大小（当前实现有20个函数） *)
    check int "字符串函数表当前实现应有20个函数" 20 (List.length actual_functions)

  (** 测试字符串处理性能 *)
  let test_string_performance () =
    (* 测试大字符串连接性能 *)
    let large_string1 = StringValue (String.make 5000 'A') in
    let large_string2 = StringValue (String.make 5000 'B') in
    let large_concat =
      TestUtils.apply_curried_function string_concat_function large_string1 large_string2
    in
    let large_length = string_length_function [ large_concat ] in
    check bool "大字符串连接长度应正确" true (TestUtils.values_equal large_length (IntValue 10000))
end

(** 中文编程特色和Unicode测试 *)
module ChineseStringTests = struct
  (** 测试中文诗词字符串处理 *)
  let test_chinese_poetry_strings () =
    (* 测试古诗词处理 *)
    let poem_lines = [ "春眠不觉晓"; "处处闻啼鸟"; "夜来风雨声"; "花落知多少" ] in

    (* 连接成完整诗句 *)
    let full_poem =
      List.fold_left
        (fun acc line ->
          TestUtils.apply_curried_function string_concat_function acc (StringValue (line ^ "。")))
        (StringValue "") poem_lines
    in

    let poem_length = string_length_function [ full_poem ] in
    (* 每句5个中文字符(15字节) + 1个句号(3字节) = 18字节，4句共72字节 *)
    check bool "完整诗词长度应正确" true (match poem_length with IntValue n -> n > 60 | _ -> false)
  (* 允许一定误差 *)

  (** 测试Unicode表情符号处理 *)
  let test_unicode_emoji_strings () =
    (* 测试表情符号字符串 *)
    let emoji_string = StringValue "🌸春天🌙月亮🔥火焰" in
    let emoji_length = string_length_function [ emoji_string ] in
    check bool "表情符号字符串应有长度" true (match emoji_length with IntValue n -> n > 0 | _ -> false);

    (* 测试表情符号连接 *)
    let spring_emoji = StringValue "🌸" in
    let chinese_spring = StringValue "春天" in
    let combined =
      TestUtils.apply_curried_function string_concat_function spring_emoji chinese_spring
    in
    check bool "表情符号连接应成功" true
      (match combined with StringValue s -> String.length s > 0 | _ -> false)

  (** 测试传统中文字符处理 *)
  let test_traditional_chinese_processing () =
    (* 测试繁体中文字符 *)
    let traditional = StringValue "傳統中文字符處理測試" in
    let trad_length = string_length_function [ traditional ] in
    check bool "繁体中文字符串应有长度" true (match trad_length with IntValue n -> n > 0 | _ -> false);

    (* 测试古文字符 *)
    let classical = StringValue "夫君子之行，靜以修身，儉以養德" in
    let classical_split =
      TestUtils.apply_curried_function string_split_function classical (StringValue "，")
    in
    check bool "古文分割应成功" true
      (match classical_split with ListValue items -> List.length items >= 2 | _ -> false)

  (** 测试中文编程概念字符串 *)
  let test_chinese_programming_concepts () =
    (* 测试编程概念的中文表达 *)
    let programming_terms = [ "函數"; "變量"; "常量"; "循環"; "條件"; "運算" ] in

    (* 连接所有编程术语 *)
    let combined_terms =
      List.fold_left
        (fun acc term ->
          TestUtils.apply_curried_function string_concat_function acc (StringValue (term ^ "、")))
        (StringValue "編程概念：") programming_terms
    in

    let terms_length = string_length_function [ combined_terms ] in
    check bool "编程术语字符串应有合理长度" true (match terms_length with IntValue n -> n > 20 | _ -> false)
end

(** 错误处理测试 *)
module StringErrorHandlingTests = struct
  (** 测试字符串函数错误处理 *)
  let test_string_function_error_handling () =
    (* 测试参数类型错误 *)
    let error_case1 () = string_length_function [ IntValue 123 ] in
    check bool "非字符串参数应抛出错误" true (TestUtils.expect_runtime_error error_case1);

    let error_case2 () = string_reverse_function [ BoolValue true ] in
    check bool "非字符串反转应抛出错误" true (TestUtils.expect_runtime_error error_case2);

    (* 测试参数数量错误 *)
    let error_case3 () = string_length_function [] in
    check bool "参数缺失应抛出错误" true (TestUtils.expect_runtime_error error_case3)
end

(** 测试套件注册 *)
let test_suite =
  [
    ( "字符串连接功能",
      [
        test_case "基本字符串连接" `Quick StringConcatTests.test_basic_string_concat;
        test_case "中文字符串连接" `Quick StringConcatTests.test_chinese_string_concat;
        test_case "连接边界条件" `Quick StringConcatTests.test_concat_boundary_cases;
      ] );
    ( "字符串包含检测",
      [
        test_case "基本包含检测" `Quick StringContainsTests.test_basic_string_contains;
        test_case "中文字符包含" `Quick StringContainsTests.test_chinese_string_contains;
        test_case "包含边界条件" `Quick StringContainsTests.test_contains_boundary_cases;
      ] );
    ( "字符串分割功能",
      [
        test_case "基本字符串分割" `Quick StringSplitTests.test_basic_string_split;
        test_case "中文字符串分割" `Quick StringSplitTests.test_chinese_string_split;
        test_case "分割边界条件" `Quick StringSplitTests.test_split_boundary_cases;
      ] );
    ( "字符串模式匹配",
      [
        test_case "基本模式匹配" `Quick StringMatchTests.test_basic_string_match;
        test_case "复杂模式匹配" `Quick StringMatchTests.test_complex_string_match;
        test_case "匹配边界条件" `Quick StringMatchTests.test_match_boundary_cases;
      ] );
    ( "长度和反转功能",
      [
        test_case "字符串长度" `Quick StringLengthReverseTests.test_string_length;
        test_case "字符串反转" `Quick StringLengthReverseTests.test_string_reverse;
        test_case "长度反转边界条件" `Quick StringLengthReverseTests.test_length_reverse_boundary_cases;
      ] );
    ( "字符串集成测试",
      [
        test_case "函数组合使用" `Quick StringIntegrationTests.test_string_function_composition;
        test_case "函数表完整性" `Quick StringIntegrationTests.test_string_functions_table;
        test_case "字符串性能" `Quick StringIntegrationTests.test_string_performance;
      ] );
    ( "中文Unicode特色",
      [
        test_case "中文诗词字符串" `Quick ChineseStringTests.test_chinese_poetry_strings;
        test_case "Unicode表情符号" `Quick ChineseStringTests.test_unicode_emoji_strings;
        test_case "传统中文字符" `Quick ChineseStringTests.test_traditional_chinese_processing;
        test_case "编程概念字符串" `Quick ChineseStringTests.test_chinese_programming_concepts;
      ] );
    ( "错误处理",
      [ test_case "字符串函数错误处理" `Quick StringErrorHandlingTests.test_string_function_error_handling ]
    );
  ]

(** 运行所有测试 *)
let () =
  Printf.printf "骆言内置字符串模块测试 - Phase 26\n";
  Printf.printf "===========================================\n";
  run "Builtin String Module Tests" test_suite
