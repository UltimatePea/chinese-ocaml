(** 语义类型系统词法分析器测试 *)

open Alcotest
open Yyocamlc_lib.Lexer

(** 测试新的语义关键字 *)
let test_semantic_keywords () =
  let test_cases = [
    ("作为", AsKeyword);
    ("组合", CombineKeyword);
    ("以及", WithOpKeyword);
    ("当", WhenKeyword);
  ] in

  List.iter (fun (input, expected) ->
    let tokens = tokenize input "<test>" in
    match tokens with
    | [(token, _)] ->
      check bool ("关键字 " ^ input ^ " 应该正确识别") true (token = expected)
    | [] ->
      check bool ("关键字 " ^ input ^ " 不应该为空") false true
    | _ ->
      (* 多个词元，检查是否包含期望的词元 *)
      let has_expected = List.exists (fun (t, _) -> t = expected) tokens in
      check bool ("关键字 " ^ input ^ " 应该包含期望的词元") true has_expected
  ) test_cases

(** 测试语义类型语法示例 *)
let test_semantic_syntax () =
  let source = "让 「年龄」 作为 「人员信息」 为 ２５" in
  let tokens = tokenize source "<test>" in

  let actual_tokens = List.map fst tokens in
  let has_let = List.exists (fun t -> t = LetKeyword) actual_tokens in
  let has_as = List.exists (fun t -> t = AsKeyword) actual_tokens in

  check bool "应该包含 LetKeyword" true has_let;
  check bool "应该包含 AsKeyword" true has_as

(** 测试组合语法 *)
let test_combine_syntax () =
  let source = "组合 「年龄」 以及 「姓名」" in
  let tokens = tokenize source "<test>" in
  let actual_tokens = List.map fst tokens in

  let has_combine = List.exists (fun t -> t = CombineKeyword) actual_tokens in
  let has_with_op = List.exists (fun t -> t = WithOpKeyword) actual_tokens in

  check bool "应该包含 CombineKeyword" true has_combine;
  check bool "应该包含 WithOpKeyword" true has_with_op

(** 语义词法分析器测试套件 *)
let () =
  run "语义类型系统词法分析器测试" [
    ("语义关键字", [
      test_case "新关键字识别" `Quick test_semantic_keywords;
      test_case "语义类型语法" `Quick test_semantic_syntax;
      test_case "组合语法" `Quick test_combine_syntax;
    ]);
  ]