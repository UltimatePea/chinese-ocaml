open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

let test_type_annotation_parsing () =
  let input = "(42 ：： 整数)" in
  let tokens = tokenize input "test.ly" in
  let parser_state = create_parser_state tokens in
  try
    let expr, _ = parse_expression parser_state in

    match expr with
    | TypeAnnotationExpr (LitExpr (IntLit 42), BaseTypeExpr IntType) -> Printf.printf "✓ 类型注解解析成功\n"
    | _ -> Printf.printf "✗ 类型注解解析失败: %s\n" (show_expr expr)
  with e -> Printf.printf "✗ 类型注解解析异常: %s\n" (Printexc.to_string e)

let test_type_annotation_inference () =
  let input = "(42 ：： 整数)" in
  let tokens = tokenize input "test.ly" in
  let parser_state = create_parser_state tokens in
  try
    let expr, _ = parse_expression parser_state in

    let env = builtin_env in
    let _, inferred_type = infer_type env expr in

    match inferred_type with
    | IntType_T -> Printf.printf "✓ 类型注解推断成功\n"
    | _ -> Printf.printf "✗ 类型注解推断失败: %s\n" (show_typ inferred_type)
  with e -> Printf.printf "✗ 类型注解推断异常: %s\n" (Printexc.to_string e)

let test_function_with_type_annotations () =
  let input = "让 「add」 ：： (整数 → 整数 → 整数) = 函数 「x」 → 函数 「y」 → 「x」 加 「y」" in
  let tokens = tokenize input "test.ly" in
  let parser_state = create_parser_state tokens in
  try
    let stmt, _ = parse_statement parser_state in

    match stmt with
    | LetStmtWithType (name, _, _) when name = "add" -> Printf.printf "✓ 函数类型注解解析成功\n"
    | _ -> Printf.printf "✗ 函数类型注解解析失败: %s\n" (show_stmt stmt)
  with e -> Printf.printf "✗ 函数类型注解解析异常: %s\n" (Printexc.to_string e)

let run_tests () =
  Printf.printf "=== 类型注解测试 ===\n";
  test_type_annotation_parsing ();
  test_type_annotation_inference ();
  test_function_with_type_annotations ();
  Printf.printf "=== 测试完成 ===\n"

let () = run_tests ()
