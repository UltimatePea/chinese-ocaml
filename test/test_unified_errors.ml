(** 统一错误处理系统主入口模块测试 - 骆言编译器 *)

open Alcotest
open Yyocamlc_lib

(** 测试错误类型重新导出 *)
let test_error_types_export () =
  let pos = { Compiler_errors_types.filename = "test.ly"; line = 5; column = 10 } in

  (* 测试能否创建各种错误类型 *)
  let lex_error = Unified_errors.LexError ("无效字符", pos) in
  let parse_error = Unified_errors.ParseError ("语法错误", 10, 5) in
  let runtime_error = Unified_errors.RuntimeError "运行时错误" in
  let type_error = Unified_errors.TypeError "类型错误" in
  let compiler_error = Unified_errors.CompilerError "编译器错误" in
  let system_error = Unified_errors.SystemError "系统错误" in

  (* 测试错误类型匹配 *)
  (match lex_error with
  | Unified_errors.LexError (msg, p) ->
      check string "词法错误消息正确" "无效字符" msg;
      check string "词法错误文件名正确" "test.ly" p.filename
  | _ -> fail "词法错误类型匹配失败");

  (match parse_error with
  | Unified_errors.ParseError (msg, line, col) ->
      check string "解析错误消息正确" "语法错误" msg;
      check int "解析错误行号正确" 10 line;
      check int "解析错误列号正确" 5 col
  | _ -> fail "解析错误类型匹配失败");

  (match runtime_error with
  | Unified_errors.RuntimeError msg -> check string "运行时错误消息正确" "运行时错误" msg
  | _ -> fail "运行时错误类型匹配失败");

  (match type_error with
  | Unified_errors.TypeError msg -> check string "类型错误消息正确" "类型错误" msg
  | _ -> fail "类型错误类型匹配失败");

  (match compiler_error with
  | Unified_errors.CompilerError msg -> check string "编译器错误消息正确" "编译器错误" msg
  | _ -> fail "编译器错误类型匹配失败");

  match system_error with
  | Unified_errors.SystemError msg -> check string "系统错误消息正确" "系统错误" msg
  | _ -> fail "系统错误类型匹配失败"

(** 测试转换函数重新导出 *)
let test_conversion_functions_export () =
  (* 测试统一错误转换为字符串 *)
  let runtime_error = Unified_errors.RuntimeError "除零错误" in
  let error_string = Unified_errors.unified_error_to_string runtime_error in
  check bool "错误转换为字符串功能正常" true (String.length error_string > 0);

  (* 测试统一错误转换为异常 *)
  let parse_error = Unified_errors.ParseError ("缺少分号", 10, 5) in
  let error_exception = Unified_errors.unified_error_to_exception parse_error in
  match error_exception with
  | Compiler_errors_types.CompilerError info -> (
      match info.error with
      | Compiler_errors_types.ParseError (msg, p) ->
          check bool "异常消息包含原始信息" true (String.length msg > 0);
          check int "异常位置行号正确" 10 p.line;
          check int "异常位置列号正确" 5 p.column
      | _ -> fail "异常错误类型转换失败")
  | _ -> fail "异常类型转换失败"

(** 测试基本函数导出 *)
let test_basic_functions_export () =
  (* 测试无效字符错误创建 *)
  let invalid_char_error = Unified_errors.invalid_character_error "@" in
  let error_string = Unified_errors.unified_error_to_string invalid_char_error in
  check bool "无效字符错误创建成功" true (String.length error_string > 0);

  (* 测试算术错误创建 *)
  let arith_error = Unified_errors.arithmetic_error "除零" in
  let arith_string = Unified_errors.unified_error_to_string arith_error in
  check bool "算术错误创建成功" true (String.length arith_string > 0)

(** 测试套件 *)
let () =
  run "统一错误处理系统主入口模块测试"
    [
      ("错误类型重新导出测试", [ test_case "错误类型重新导出" `Quick test_error_types_export ]);
      ("转换函数重新导出测试", [ test_case "转换函数重新导出" `Quick test_conversion_functions_export ]);
      ("基本函数导出测试", [ test_case "基本函数导出" `Quick test_basic_functions_export ]);
    ]
