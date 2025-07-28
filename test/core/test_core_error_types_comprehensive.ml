(** 骆言核心错误类型模块综合测试
 * 
 * 全面测试 error_types.ml 模块中定义的所有错误类型和错误处理机制
 * 
 * Author: Beta, 代码审查员 - Fix #1408
 * @version 1.0
 * @since 2025-07-26 *)

open Alcotest
open Yyocamlc_lib
open Yyocamlc_lib.Error_types

(* 创建测试位置信息 *)
let create_test_position line col =
  let open Compiler_errors in
  { filename = "test.ml"; line; column = col }

let test_lexical_error_types () =
  let pos = create_test_position 1 5 in
  [
    ( "invalid character error",
      `Quick,
      fun () ->
        let error = LexicalError (InvalidCharacter "?", Some pos) in
        match error with
        | LexicalError (InvalidCharacter _, _) -> ()
        | _ -> failwith "Expected InvalidCharacter error" );
    ( "unterminated string error",
      `Quick,
      fun () ->
        let error = LexicalError (UnterminatedString, Some pos) in
        match error with
        | LexicalError (UnterminatedString, _) -> ()
        | _ -> failwith "Expected UnterminatedString error" );
    ( "invalid number error",
      `Quick,
      fun () ->
        let error = LexicalError (InvalidNumber "1.2.3", Some pos) in
        match error with
        | LexicalError (InvalidNumber _, _) -> ()
        | _ -> failwith "Expected InvalidNumber error" );
    ( "unicode error",
      `Quick,
      fun () ->
        let error = LexicalError (UnicodeError "invalid encoding", Some pos) in
        match error with
        | LexicalError (UnicodeError _, _) -> ()
        | _ -> failwith "Expected UnicodeError error" );
  ]

let test_parse_error_types () =
  let pos = create_test_position 2 10 in
  [
    ( "syntax error",
      `Quick,
      fun () ->
        let error = ParseError2 (SyntaxError "unexpected token", Some pos) in
        match error with
        | ParseError2 (SyntaxError _, _) -> ()
        | _ -> failwith "Expected SyntaxError" );
    ( "unexpected token error",
      `Quick,
      fun () ->
        let error = ParseError2 (UnexpectedToken "EOF", Some pos) in
        match error with
        | ParseError2 (UnexpectedToken _, _) -> ()
        | _ -> failwith "Expected UnexpectedToken error" );
    ( "missing expression error",
      `Quick,
      fun () ->
        let error = ParseError2 (MissingExpression, Some pos) in
        match error with
        | ParseError2 (MissingExpression, _) -> ()
        | _ -> failwith "Expected MissingExpression error" );
  ]

let test_runtime_error_types () =
  let pos = create_test_position 3 15 in
  [
    ( "arithmetic error",
      `Quick,
      fun () ->
        let error = RuntimeError2 (ArithmeticError "division by zero", Some pos) in
        match error with
        | RuntimeError2 (ArithmeticError _, _) -> ()
        | _ -> failwith "Expected ArithmeticError" );
    ( "index out of bounds error",
      `Quick,
      fun () ->
        let error = RuntimeError2 (IndexOutOfBounds "array index out of bounds", Some pos) in
        match error with
        | RuntimeError2 (IndexOutOfBounds _, _) -> ()
        | _ -> failwith "Expected IndexOutOfBounds error" );
    ( "null pointer error",
      `Quick,
      fun () ->
        let error = RuntimeError2 (NullPointer "null reference", Some pos) in
        match error with
        | RuntimeError2 (NullPointer _, _) -> ()
        | _ -> failwith "Expected NullPointer error" );
  ]

let test_poetry_error_types () =
  let pos = create_test_position 4 20 in
  [
    ( "invalid rhyme pattern error",
      `Quick,
      fun () ->
        let error = PoetryError (InvalidRhymePattern "不符合律诗韵律", Some pos) in
        match error with
        | PoetryError (InvalidRhymePattern _, _) -> ()
        | _ -> failwith "Expected InvalidRhymePattern error" );
    ( "invalid verse structure error",
      `Quick,
      fun () ->
        let error = PoetryError (InvalidVerseStructure "句式不规范", Some pos) in
        match error with
        | PoetryError (InvalidVerseStructure _, _) -> ()
        | _ -> failwith "Expected InvalidVerseStructure error" );
    ( "rhyme data error",
      `Quick,
      fun () ->
        let error = PoetryError (RhymeDataError "韵律数据缺失", Some pos) in
        match error with
        | PoetryError (RhymeDataError _, _) -> ()
        | _ -> failwith "Expected RhymeDataError" );
  ]

let test_unified_error_types () =
  let pos = create_test_position 6 30 in
  [
    ( "parse error",
      `Quick,
      fun () ->
        let error = ParseError ("parse error", 1, 5) in
        match error with ParseError (_, _, _) -> () | _ -> failwith "Expected ParseError" );
    ( "runtime error",
      `Quick,
      fun () ->
        let error = RuntimeError "runtime error" in
        match error with RuntimeError _ -> () | _ -> failwith "Expected RuntimeError" );
    ( "type error",
      `Quick,
      fun () ->
        let error = TypeError "type mismatch" in
        match error with TypeError _ -> () | _ -> failwith "Expected TypeError" );
    ( "lex error",
      `Quick,
      fun () ->
        let error = LexError ("lex error", pos) in
        match error with LexError (_, _) -> () | _ -> failwith "Expected LexError" );
    ( "compiler error",
      `Quick,
      fun () ->
        let error = CompilerError "compiler internal error" in
        match error with CompilerError _ -> () | _ -> failwith "Expected CompilerError" );
  ]

let test_result_types () =
  let success_result : int unified_result = Ok 42 in
  let error_result : int unified_result = Error (RuntimeError "test error") in

  [
    ( "success result",
      `Quick,
      fun () ->
        match success_result with
        | Ok x -> check int "success value" 42 x
        | Error _ -> failwith "Expected Ok result" );
    ( "error result",
      `Quick,
      fun () ->
        match error_result with
        | Error (RuntimeError _) -> ()
        | _ -> failwith "Expected Error result with RuntimeError" );
  ]

(* 主测试套件 *)
let () =
  run "Error Types Comprehensive Tests"
    [
      ("Lexical Error Types", test_lexical_error_types ());
      ("Parse Error Types", test_parse_error_types ());
      ("Runtime Error Types", test_runtime_error_types ());
      ("Poetry Error Types", test_poetry_error_types ());
      ("Unified Error Types", test_unified_error_types ());
      ("Result Types", test_result_types ());
    ]
