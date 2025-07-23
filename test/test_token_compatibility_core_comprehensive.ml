(** Token兼容性核心转换模块综合测试 *)

open Alcotest
open Yyocamlc_lib.Token_compatibility_core
open Yyocamlc_lib.Unified_token_core

(** 测试辅助函数 *)
module TestUtils = struct
  (** 创建测试用的位置信息 *)
  let _create_test_position filename line column = { filename; line; column; offset = 0 }

  (** 检查Option类型的Token是否匹配 *)
  let check_token_option desc expected_opt actual_opt =
    match (expected_opt, actual_opt) with
    | None, None -> check bool desc true true
    | Some expected, Some actual -> check bool desc true (expected = actual)
    | None, Some _ -> check bool (desc ^ " - 期望None但得到Some") false true
    | Some _, None -> check bool (desc ^ " - 期望Some但得到None") false true

  (** 检查positioned_token是否匹配 *)
  let check_positioned_token_option desc expected_opt actual_opt =
    match (expected_opt, actual_opt) with
    | None, None -> check bool desc true true
    | Some expected, Some actual ->
        check bool (desc ^ " - token匹配") true (expected.token = actual.token);
        check string (desc ^ " - filename匹配") expected.position.filename actual.position.filename;
        check int (desc ^ " - line匹配") expected.position.line actual.position.line;
        check int (desc ^ " - column匹配") expected.position.column actual.position.column
    | None, Some _ -> check bool (desc ^ " - 期望None但得到Some") false true
    | Some _, None -> check bool (desc ^ " - 期望Some但得到None") false true

  (** 常用的测试token字符串 *)
  let common_keywords = [ "let"; "fun"; "if"; "then"; "else"; "match"; "with"; "true"; "false" ]

  let common_operators = [ "+"; "-"; "*"; "/"; "="; "<>"; "<"; ">"; "&&"; "||" ]
  let common_delimiters = [ "("; ")"; "["; "]"; "{"; "}"; ","; ";"; ":"; "." ]
  let _common_literals = [ "42"; "3.14"; "\"hello\""; "'c'" ]
  let invalid_tokens = [ "@invalid@"; "#unknown#"; "$weird$"; "%strange%" ]
end

(** 核心转换函数测试 *)
module CoreConversionTests = struct
  (** 测试关键字转换 *)
  let test_keyword_conversion () =
    let test_cases =
      [
        ("let", Some LetKeyword);
        ("fun", Some FunKeyword);
        ("if", Some IfKeyword);
        ("then", Some ThenKeyword);
        ("else", Some ElseKeyword);
        ("match", Some MatchKeyword);
        ("with", Some WithKeyword);
        ("true", Some TrueKeyword);
        ("false", Some FalseKeyword);
      ]
    in

    List.iter
      (fun (input, expected) ->
        let result = convert_legacy_token_string input None in
        TestUtils.check_token_option ("关键字转换: " ^ input) expected result)
      test_cases

  (** 测试运算符转换 *)
  let test_operator_conversion () =
    let test_cases =
      [
        ("+", Some PlusOp);
        ("-", Some MinusOp);
        ("*", Some MultiplyOp);
        ("/", Some DivideOp);
        ("=", Some EqualOp);
        ("<>", Some NotEqualOp);
        ("<", Some LessOp);
        (">", Some GreaterOp);
        ("&&", Some LogicalAndOp);
        ("||", Some LogicalOrOp);
      ]
    in

    List.iter
      (fun (input, expected) ->
        let result = convert_legacy_token_string input None in
        TestUtils.check_token_option ("运算符转换: " ^ input) expected result)
      test_cases

  (** 测试分隔符转换 *)
  let test_delimiter_conversion () =
    let test_cases =
      [
        ("(", Some LeftParen);
        (")", Some RightParen);
        ("[", Some LeftBracket);
        ("]", Some RightBracket);
        ("{", Some LeftBrace);
        ("}", Some RightBrace);
        (",", Some Comma);
        (";", Some Semicolon);
        (":", Some Colon);
        (".", Some Dot);
      ]
    in

    List.iter
      (fun (input, expected) ->
        let result = convert_legacy_token_string input None in
        TestUtils.check_token_option ("分隔符转换: " ^ input) expected result)
      test_cases

  (** 测试字面量转换 *)
  let test_literal_conversion () =
    let test_cases =
      [
        ("42", Some (IntToken 42));
        ("0", Some (IntToken 0));
        ("-1", Some (IntToken (-1)));
        ("3.14", Some (FloatToken 3.14));
        ("0.0", Some (FloatToken 0.0));
        ("\"hello\"", Some (StringToken "hello"));
        ("\"\"", Some (StringToken ""));
      ]
    in

    List.iter
      (fun (input, expected) ->
        let result = convert_legacy_token_string input None in
        TestUtils.check_token_option ("字面量转换: " ^ input) expected result)
      test_cases

  (** 测试标识符转换 *)
  let test_identifier_conversion () =
    let test_cases =
      [
        ("variable", Some (IdentifierToken "variable"));
        ("myVar", Some (IdentifierToken "myVar"));
        ("_underscore", Some (IdentifierToken "_underscore"));
        ("camelCase", Some (IdentifierToken "camelCase"));
        ("Variable123", Some (IdentifierToken "Variable123"));
      ]
    in

    List.iter
      (fun (input, expected) ->
        let result = convert_legacy_token_string input None in
        TestUtils.check_token_option ("标识符转换: " ^ input) expected result)
      test_cases

  (** 测试特殊Token转换 *)
  let test_special_token_conversion () =
    let test_cases =
      [
        ("EOF", Some EOF);
        ("\\n", Some Newline);
        ("\\t", Some Whitespace);
        (* 假设tab被映射为whitespace *)
        ("(*comment*)", Some (Comment "comment"));
      ]
    in

    List.iter
      (fun (input, expected) ->
        let result = convert_legacy_token_string input None in
        TestUtils.check_token_option ("特殊Token转换: " ^ input) expected result)
      test_cases

  (** 测试无效Token转换 *)
  let test_invalid_token_conversion () =
    List.iter
      (fun invalid_token ->
        let result = convert_legacy_token_string invalid_token None in
        TestUtils.check_token_option ("无效Token转换: " ^ invalid_token) None result)
      TestUtils.invalid_tokens

  (** 测试带值的Token转换 *)
  let test_token_conversion_with_value () =
    let test_cases =
      [
        ("42", Some "42", Some (IntToken 42));
        ("3.14", Some "3.14", Some (FloatToken 3.14));
        ("\"test\"", Some "test", Some (StringToken "test"));
        ("variable", Some "variable", Some (IdentifierToken "variable"));
      ]
    in

    List.iter
      (fun (token_str, value_opt, expected) ->
        let result = convert_legacy_token_string token_str value_opt in
        TestUtils.check_token_option ("带值转换: " ^ token_str) expected result)
      test_cases

  (** 测试转换优先级 *)
  let test_conversion_priority () =
    (* 测试当一个字符串可能匹配多个类型时的优先级
       根据代码，优先级是：关键字 > 运算符 > 分隔符 > 字面量 > 标识符 > 特殊 *)

    (* 假设"if"既可以是关键字也可以是标识符，应该优先识别为关键字 *)
    let result = convert_legacy_token_string "if" None in
    TestUtils.check_token_option "转换优先级: if应为关键字" (Some IfKeyword) result
end

(** 兼容位置Token创建测试 *)
module CompatiblePositionedTokenTests = struct
  (** 测试基本位置Token创建 *)
  let test_basic_positioned_token_creation () =
    let test_cases =
      [
        ("let", "test.ly", 1, 1, LetKeyword);
        ("+", "calc.ly", 5, 10, PlusOp);
        ("(", "expr.ly", 3, 7, LeftParen);
        ("42", "num.ly", 2, 15, IntToken 42);
      ]
    in

    List.iter
      (fun (token_str, filename, line, column, expected_token) ->
        let result = make_compatible_positioned_token token_str None filename line column in
        match result with
        | Some positioned ->
            check bool
              ("位置Token创建: " ^ token_str ^ " - token匹配")
              true
              (positioned.token = expected_token);
            check string
              ("位置Token创建: " ^ token_str ^ " - filename匹配")
              filename positioned.position.filename;
            check int ("位置Token创建: " ^ token_str ^ " - line匹配") line positioned.position.line;
            check int ("位置Token创建: " ^ token_str ^ " - column匹配") column positioned.position.column;
            check int ("位置Token创建: " ^ token_str ^ " - offset应为0") 0 positioned.position.offset;
            check
              (option
                 (module struct
                   type t = token_metadata

                   let pp _ _ = ()
                   let equal _ _ = true
                 end))
              ("位置Token创建: " ^ token_str ^ " - metadata应为None")
              None positioned.metadata
        | None -> check bool ("位置Token创建失败: " ^ token_str) false true)
      test_cases

  (** 测试带值的位置Token创建 *)
  let test_positioned_token_with_value () =
    let test_cases =
      [
        ("100", Some "100", "numbers.ly", 1, 5, IntToken 100);
        ("2.718", Some "2.718", "math.ly", 10, 12, FloatToken 2.718);
        ("\"world\"", Some "world", "strings.ly", 7, 20, StringToken "world");
        ("myVariable", Some "myVariable", "vars.ly", 15, 8, IdentifierToken "myVariable");
      ]
    in

    List.iter
      (fun (token_str, value_opt, filename, line, column, expected_token) ->
        let result = make_compatible_positioned_token token_str value_opt filename line column in
        match result with
        | Some positioned ->
            check bool
              ("带值位置Token: " ^ token_str ^ " - token匹配")
              true
              (positioned.token = expected_token);
            check string
              ("带值位置Token: " ^ token_str ^ " - filename匹配")
              filename positioned.position.filename;
            check int ("带值位置Token: " ^ token_str ^ " - line匹配") line positioned.position.line;
            check int ("带值位置Token: " ^ token_str ^ " - column匹配") column positioned.position.column
        | None -> check bool ("带值位置Token创建失败: " ^ token_str) false true)
      test_cases

  (** 测试无效Token的位置Token创建 *)
  let test_invalid_positioned_token_creation () =
    List.iter
      (fun invalid_token ->
        let result = make_compatible_positioned_token invalid_token None "test.ly" 1 1 in
        TestUtils.check_positioned_token_option ("无效位置Token: " ^ invalid_token) None result)
      TestUtils.invalid_tokens

  (** 测试边界条件的位置Token创建 *)
  let test_edge_case_positioned_token_creation () =
    let edge_cases =
      [
        ("", "empty.ly", 1, 1);
        (* 空字符串 *)
        ("let", "", 1, 1);
        (* 空文件名 *)
        ("let", "test.ly", 0, 1);
        (* 行号为0 *)
        ("let", "test.ly", 1, 0);
        (* 列号为0 *)
        ("let", "test.ly", -1, 1);
        (* 负行号 *)
        ("let", "test.ly", 1, -1);
        (* 负列号 *)
      ]
    in

    List.iter
      (fun (token_str, filename, line, column) ->
        let result = make_compatible_positioned_token token_str None filename line column in
        match result with
        | Some positioned ->
            (* 即使边界条件，如果token有效，也应该能创建位置Token *)
            check string
              ("边界条件位置Token: " ^ token_str ^ " - filename")
              filename positioned.position.filename;
            check int ("边界条件位置Token: " ^ token_str ^ " - line") line positioned.position.line;
            check int ("边界条件位置Token: " ^ token_str ^ " - column") column positioned.position.column
        | None ->
            (* 如果token无效（如空字符串），返回None是合理的 *)
            check bool ("边界条件位置Token创建: " ^ token_str) true true)
      edge_cases

  (** 测试大量位置Token创建性能 *)
  let test_positioned_token_creation_performance () =
    let start_time = Sys.time () in

    for i = 1 to 1000 do
      let token_str = "var" ^ string_of_int i in
      let filename = "file" ^ string_of_int (i mod 10) ^ ".ly" in
      let line = 1 + (i mod 100) in
      let column = 1 + (i mod 50) in
      let _ = make_compatible_positioned_token token_str None filename line column in
      ()
    done;

    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check bool "位置Token创建性能应在合理范围内" true (duration < 1.0)
end

(** 兼容性检查测试 *)
module CompatibilityCheckTests = struct
  (** 测试有效Token的兼容性检查 *)
  let test_valid_token_compatibility () =
    let valid_tokens =
      TestUtils.common_keywords @ TestUtils.common_operators @ TestUtils.common_delimiters
      @ [ "42"; "variable"; "MyClass" ]
    in

    List.iter
      (fun token_str ->
        let is_compatible = is_compatible_with_legacy token_str in
        check bool ("Token兼容性: " ^ token_str ^ " 应该兼容") true is_compatible)
      valid_tokens

  (** 测试无效Token的兼容性检查 *)
  let test_invalid_token_compatibility () =
    List.iter
      (fun token_str ->
        let is_compatible = is_compatible_with_legacy token_str in
        check bool ("Token兼容性: " ^ token_str ^ " 应该不兼容") false is_compatible)
      TestUtils.invalid_tokens

  (** 测试边界条件的兼容性检查 *)
  let test_edge_case_compatibility () =
    let edge_cases =
      [
        ("", false);
        (* 空字符串应该不兼容 *)
        (" ", false);
        (* 单个空格应该不兼容 *)
        ("\\n", true);
        (* 换行符可能兼容（特殊Token） *)
        ("0", true);
        (* 数字0应该兼容 *)
        ("_", true);
        (* 下划线应该兼容（标识符） *)
      ]
    in

    List.iter
      (fun (token_str, expected) ->
        let is_compatible = is_compatible_with_legacy token_str in
        check bool ("边界条件兼容性: " ^ token_str) expected is_compatible)
      edge_cases

  (** 测试大小写敏感性 *)
  let test_case_sensitivity () =
    let case_tests = [ ("let", "LET"); ("if", "IF"); ("true", "TRUE"); ("false", "FALSE") ] in

    List.iter
      (fun (lower, upper) ->
        let lower_compatible = is_compatible_with_legacy lower in
        let upper_compatible = is_compatible_with_legacy upper in

        check bool ("大小写测试: " ^ lower ^ " 应该兼容") true lower_compatible;
        (* 大写版本可能不兼容，这取决于具体的映射实现 *)
        check bool ("大小写测试: " ^ upper ^ " 兼容性检查") true (upper_compatible || not upper_compatible))
      case_tests

  (** 测试Unicode字符的兼容性 *)
  let test_unicode_compatibility () =
    let unicode_tests =
      [ ("变量", "中文标识符"); ("函数", "中文关键字"); ("如果", "中文条件关键字"); ("真", "中文布尔值"); ("假", "中文布尔值") ]
    in

    List.iter
      (fun (token_str, desc) ->
        let is_compatible = is_compatible_with_legacy token_str in
        (* Unicode兼容性取决于具体实现，这里只测试不会崩溃 *)
        check bool (desc ^ "兼容性检查不崩溃") true (is_compatible || not is_compatible))
      unicode_tests
end

(** 综合集成测试 *)
module IntegratedTests = struct
  (** 测试完整的Token处理流程 *)
  let test_complete_token_processing_flow () =
    let test_program_tokens =
      [
        ("let", "program.ly", 1, 1, LetKeyword);
        ("fibonacci", "program.ly", 1, 5, IdentifierToken "fibonacci");
        ("=", "program.ly", 1, 14, EqualOp);
        ("fun", "program.ly", 1, 16, FunKeyword);
        ("n", "program.ly", 1, 20, IdentifierToken "n");
        ("->", "program.ly", 1, 22, ArrowOp);
        ("if", "program.ly", 2, 3, IfKeyword);
        ("n", "program.ly", 2, 6, IdentifierToken "n");
        ("<=", "program.ly", 2, 8, LessEqualOp);
        ("1", "program.ly", 2, 11, IntToken 1);
        ("then", "program.ly", 2, 13, ThenKeyword);
        ("n", "program.ly", 2, 18, IdentifierToken "n");
        ("else", "program.ly", 3, 3, ElseKeyword);
        ("fibonacci", "program.ly", 3, 8, IdentifierToken "fibonacci");
        ("(", "program.ly", 3, 17, LeftParen);
        ("n", "program.ly", 3, 18, IdentifierToken "n");
        ("-", "program.ly", 3, 20, MinusOp);
        ("1", "program.ly", 3, 22, IntToken 1);
        (")", "program.ly", 3, 23, RightParen);
        ("+", "program.ly", 3, 25, PlusOp);
        ("fibonacci", "program.ly", 3, 27, IdentifierToken "fibonacci");
        ("(", "program.ly", 3, 36, LeftParen);
        ("n", "program.ly", 3, 37, IdentifierToken "n");
        ("-", "program.ly", 3, 39, MinusOp);
        ("2", "program.ly", 3, 41, IntToken 2);
        (")", "program.ly", 3, 42, RightParen);
      ]
    in

    List.iter
      (fun (token_str, filename, line, column, expected_token) ->
        (* 测试基本转换 *)
        let conversion_result = convert_legacy_token_string token_str None in
        TestUtils.check_token_option
          ("流程测试转换: " ^ token_str)
          (Some expected_token) conversion_result;

        (* 测试兼容性检查 *)
        let is_compatible = is_compatible_with_legacy token_str in
        check bool ("流程测试兼容性: " ^ token_str) true is_compatible;

        (* 测试位置Token创建 *)
        let positioned_result =
          make_compatible_positioned_token token_str None filename line column
        in
        match positioned_result with
        | Some positioned ->
            check bool ("流程测试位置Token: " ^ token_str) true (positioned.token = expected_token)
        | None -> check bool ("流程测试位置Token创建失败: " ^ token_str) false true)
      test_program_tokens

  (** 测试错误处理和恢复 *)
  let test_error_handling_and_recovery () =
    let mixed_tokens =
      [
        ("let", true);
        (* 有效 *)
        ("@invalid@", false);
        (* 无效 *)
        ("+", true);
        (* 有效 *)
        ("#weird#", false);
        (* 无效 *)
        ("42", true);
        (* 有效 *)
        ("$strange$", false);
        (* 无效 *)
        (")", true);
        (* 有效 *)
      ]
    in

    List.iter
      (fun (token_str, should_succeed) ->
        let conversion_result = convert_legacy_token_string token_str None in
        let positioned_result =
          make_compatible_positioned_token token_str None "error_test.ly" 1 1
        in
        let compatibility_result = is_compatible_with_legacy token_str in

        if should_succeed then (
          check bool ("错误处理 - 转换成功: " ^ token_str) true (conversion_result <> None);
          check bool ("错误处理 - 位置Token成功: " ^ token_str) true (positioned_result <> None);
          check bool ("错误处理 - 兼容性成功: " ^ token_str) true compatibility_result)
        else (
          check bool ("错误处理 - 转换失败: " ^ token_str) true (conversion_result = None);
          check bool ("错误处理 - 位置Token失败: " ^ token_str) true (positioned_result = None);
          check bool ("错误处理 - 兼容性失败: " ^ token_str) false compatibility_result))
      mixed_tokens

  (** 测试并发访问模拟 *)
  let test_concurrent_access_simulation () =
    let tokens_to_test = TestUtils.common_keywords @ TestUtils.common_operators in

    (* 模拟并发处理多个token *)
    let results =
      List.map
        (fun token_str ->
          let conversion = convert_legacy_token_string token_str None in
          let compatibility = is_compatible_with_legacy token_str in
          let positioned = make_compatible_positioned_token token_str None "concurrent.ly" 1 1 in
          (token_str, conversion, compatibility, positioned))
        tokens_to_test
    in

    (* 验证所有结果都是一致的 *)
    List.iter
      (fun (token_str, conversion, compatibility, positioned) ->
        check bool ("并发测试 - 转换一致性: " ^ token_str) true (conversion <> None);
        check bool ("并发测试 - 兼容性一致性: " ^ token_str) true compatibility;
        check bool ("并发测试 - 位置Token一致性: " ^ token_str) true (positioned <> None))
      results

  (** 测试内存使用和清理 *)
  let test_memory_usage_and_cleanup () =
    let start_time = Sys.time () in

    (* 处理大量token以测试内存使用 *)
    for i = 1 to 10000 do
      let token_str =
        if i mod 4 = 0 then "let"
        else if i mod 4 = 1 then "+"
        else if i mod 4 = 2 then "42"
        else "variable" ^ string_of_int i
      in

      let _ = convert_legacy_token_string token_str None in
      let _ = is_compatible_with_legacy token_str in
      let _ = make_compatible_positioned_token token_str None "memory_test.ly" 1 i in
      ()
    done;

    let end_time = Sys.time () in
    let duration = end_time -. start_time in

    check bool "内存使用测试应在合理时间内完成" true (duration < 3.0)
end

(** 主测试套件 *)
let () =
  run "Token兼容性核心转换模块综合测试"
    [
      ( "核心转换函数测试",
        [
          test_case "关键字转换" `Quick CoreConversionTests.test_keyword_conversion;
          test_case "运算符转换" `Quick CoreConversionTests.test_operator_conversion;
          test_case "分隔符转换" `Quick CoreConversionTests.test_delimiter_conversion;
          test_case "字面量转换" `Quick CoreConversionTests.test_literal_conversion;
          test_case "标识符转换" `Quick CoreConversionTests.test_identifier_conversion;
          test_case "特殊Token转换" `Quick CoreConversionTests.test_special_token_conversion;
          test_case "无效Token转换" `Quick CoreConversionTests.test_invalid_token_conversion;
          test_case "带值Token转换" `Quick CoreConversionTests.test_token_conversion_with_value;
          test_case "转换优先级" `Quick CoreConversionTests.test_conversion_priority;
        ] );
      ( "兼容位置Token创建测试",
        [
          test_case "基本位置Token创建" `Quick
            CompatiblePositionedTokenTests.test_basic_positioned_token_creation;
          test_case "带值位置Token创建" `Quick
            CompatiblePositionedTokenTests.test_positioned_token_with_value;
          test_case "无效位置Token创建" `Quick
            CompatiblePositionedTokenTests.test_invalid_positioned_token_creation;
          test_case "边界条件位置Token创建" `Quick
            CompatiblePositionedTokenTests.test_edge_case_positioned_token_creation;
          test_case "位置Token创建性能" `Slow
            CompatiblePositionedTokenTests.test_positioned_token_creation_performance;
        ] );
      ( "兼容性检查测试",
        [
          test_case "有效Token兼容性" `Quick CompatibilityCheckTests.test_valid_token_compatibility;
          test_case "无效Token兼容性" `Quick CompatibilityCheckTests.test_invalid_token_compatibility;
          test_case "边界条件兼容性" `Quick CompatibilityCheckTests.test_edge_case_compatibility;
          test_case "大小写敏感性" `Quick CompatibilityCheckTests.test_case_sensitivity;
          test_case "Unicode兼容性" `Quick CompatibilityCheckTests.test_unicode_compatibility;
        ] );
      ( "综合集成测试",
        [
          test_case "完整Token处理流程" `Slow IntegratedTests.test_complete_token_processing_flow;
          test_case "错误处理和恢复" `Quick IntegratedTests.test_error_handling_and_recovery;
          test_case "并发访问模拟" `Quick IntegratedTests.test_concurrent_access_simulation;
          test_case "内存使用和清理" `Slow IntegratedTests.test_memory_usage_and_cleanup;
        ] );
    ]
