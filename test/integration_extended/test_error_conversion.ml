(** 错误转换模块综合测试 - 骆言编译器 *)

open Alcotest
open Yyocamlc_lib

(** 测试统一错误转换为字符串 *)
let test_unified_error_to_string () =
  let pos = { Compiler_errors_types.filename = "test.ly"; line = 15; column = 8 } in

  (* 测试解析错误 *)
  let parse_error = Error_types.ParseError ("语法错误", 10, 5) in
  let parse_msg = Error_conversion.unified_error_to_string parse_error in
  check bool "解析错误转换成功" true (String.length parse_msg > 5);

  (* 测试运行时错误 *)
  let runtime_error = Error_types.RuntimeError "除零错误" in
  let runtime_msg = Error_conversion.unified_error_to_string runtime_error in
  check bool "运行时错误转换成功" true (String.length runtime_msg > 5);

  (* 测试类型错误 *)
  let type_error = Error_types.TypeError "类型不匹配" in
  let type_msg = Error_conversion.unified_error_to_string type_error in
  check bool "类型错误转换成功" true (String.length type_msg > 5);

  (* 测试词法错误 *)
  let lex_error = Error_types.LexError ("无效字符", pos) in
  let lex_msg = Error_conversion.unified_error_to_string lex_error in
  check bool "词法错误转换成功" true (String.length lex_msg > 5);

  (* 测试编译器错误 *)
  let compiler_error = Error_types.CompilerError "内部错误" in
  let compiler_msg = Error_conversion.unified_error_to_string compiler_error in
  check bool "编译器错误转换成功" true (String.length compiler_msg > 5);

  (* 测试系统错误 *)
  let system_error = Error_types.SystemError "文件不存在" in
  let system_msg = Error_conversion.unified_error_to_string system_error in
  check bool "系统错误转换成功" true (String.length system_msg > 5)

(** 测试统一错误转换为异常 *)
let test_unified_error_to_exception () =
  (* 测试解析错误转换 *)
  let parse_error = Error_types.ParseError ("语法错误", 10, 5) in
  let parse_exception = Error_conversion.unified_error_to_exception parse_error in
  (match parse_exception with
  | Compiler_errors_types.CompilerError info -> (
      match info.error with
      | Compiler_errors_types.ParseError (msg, _p) ->
          check bool "解析错误异常消息正确" true (String.length msg > 0)
      | _ -> fail "解析错误异常类型转换失败")
  | _ -> fail "解析错误异常类型不正确");

  (* 测试运行时错误转换 *)
  let runtime_error = Error_types.RuntimeError "除零错误" in
  let runtime_exception = Error_conversion.unified_error_to_exception runtime_error in
  (match runtime_exception with
  | Compiler_errors_types.CompilerError info -> (
      match info.error with
      | Compiler_errors_types.RuntimeError (msg, None) ->
          check bool "运行时错误异常消息正确" true (String.length msg > 0)
      | _ -> fail "运行时错误异常类型转换失败")
  | _ -> fail "运行时错误异常类型不正确");

  (* 测试类型错误转换 *)
  let type_error = Error_types.TypeError "类型不匹配" in
  let type_exception = Error_conversion.unified_error_to_exception type_error in
  (match type_exception with
  | Compiler_errors_types.CompilerError info -> (
      match info.error with
      | Compiler_errors_types.TypeError (msg, None) ->
          check bool "类型错误异常消息正确" true (String.length msg > 0)
      | _ -> fail "类型错误异常类型转换失败")
  | _ -> fail "类型错误异常类型不正确");

  (* 测试系统错误转换 *)
  let system_error = Error_types.SystemError "文件不存在" in
  let system_exception = Error_conversion.unified_error_to_exception system_error in
  match system_exception with
  | Failure msg -> check bool "系统错误异常消息正确" true (String.length msg > 0)
  | _ -> fail "系统错误异常类型不正确"

(** 测试详细错误类型转换 *)
let test_detailed_error_types () =
  (* 测试词法错误类型 *)
  let lexical_error = Error_types.LexicalError (Error_types.InvalidCharacter "@", None) in
  let lexical_msg = Error_conversion.unified_error_to_string lexical_error in
  check bool "词法错误详细类型转换成功" true (String.length lexical_msg > 5);

  (* 测试解析错误类型 *)
  let parse_error2 = Error_types.ParseError2 (Error_types.MissingExpression, None) in
  let parse_msg2 = Error_conversion.unified_error_to_string parse_error2 in
  check bool "解析错误详细类型转换成功" true (String.length parse_msg2 > 5);

  (* 测试运行时错误类型 *)
  let runtime_error2 = Error_types.RuntimeError2 (Error_types.ArithmeticError "除零", None) in
  let runtime_msg2 = Error_conversion.unified_error_to_string runtime_error2 in
  check bool "运行时错误详细类型转换成功" true (String.length runtime_msg2 > 5);

  (* 测试诗词错误类型 *)
  let poetry_error = Error_types.PoetryError (Error_types.InvalidRhymePattern "平仄", None) in
  let poetry_msg = Error_conversion.unified_error_to_string poetry_error in
  check bool "诗词错误类型转换成功" true (String.length poetry_msg > 5);

  (* 测试系统错误类型 *)
  let system_error2 = Error_types.SystemError2 (Error_types.FileSystemError "权限不足", None) in
  let system_msg2 = Error_conversion.unified_error_to_string system_error2 in
  check bool "系统错误详细类型转换成功" true (String.length system_msg2 > 5)

(** 测试套件 *)
let () =
  run "错误转换模块综合测试"
    [
      ( "统一错误转换测试",
        [
          test_case "统一错误转换为字符串" `Quick test_unified_error_to_string;
          test_case "统一错误转换为异常" `Quick test_unified_error_to_exception;
        ] );
      ("详细错误类型测试", [ test_case "详细错误类型转换" `Quick test_detailed_error_types ]);
    ]
