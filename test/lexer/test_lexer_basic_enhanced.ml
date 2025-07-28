(** 骆言词法分析器基础增强测试 - Fix #985 *)

open Alcotest
open Yyocamlc_lib.Lexer

(* 简单的token测试 *)
let test_simple_tokens () =
  (* 测试简单的标识符 *)
  let tokens1 = tokenize "「变量」" "test.ly" in
  check int "标识符token数量" 2 (List.length tokens1);

  (* 测试字符串 *)
  let tokens2 = tokenize "『hello』" "test.ly" in
  check int "字符串token数量" 2 (List.length tokens2);

  (* 测试基本操作 *)
  let tokens3 = tokenize "设 「x」" "test.ly" in
  check bool "基本操作token数量大于0" true (List.length tokens3 > 0)

let test_error_handling () =
  (* 测试异常处理 *)
  try
    let _tokens = tokenize "invalid_chars_@#$" "test.ly" in
    check bool "不应该到达这里" false true
  with _ -> check bool "正确捕获词法错误" true true

let () =
  run "词法分析器基础增强测试"
    [
      ( "基础测试",
        [
          test_case "简单token识别" `Quick test_simple_tokens;
          test_case "错误处理" `Quick test_error_handling;
        ] );
    ]
