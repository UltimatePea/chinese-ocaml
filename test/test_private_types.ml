open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Semantic

let test_private_type_parsing () =
  let input = "类型 「栈」 = 私有 列表" in
  let tokens = tokenize input "test.ly" in
  let parser_state = create_parser_state tokens in
  try
    let stmt, _ = parse_statement parser_state in

    match stmt with
    | TypeDefStmt (name, PrivateType (ListType (TypeVar "元素"))) when name = "栈" ->
        Printf.printf "✓ 私有类型定义解析成功\n"
    | TypeDefStmt (name, PrivateType _) when name = "栈" -> Printf.printf "✓ 私有类型定义解析成功（类型匹配）\n"
    | _ -> Printf.printf "✗ 私有类型定义解析失败: %s\n" (show_stmt stmt)
  with e -> Printf.printf "✗ 私有类型定义解析异常: %s\n" (Printexc.to_string e)

let test_private_type_semantic_analysis () =
  let input = "类型 「栈」 = 私有 列表" in
  let tokens = tokenize input "test.ly" in
  let parser_state = create_parser_state tokens in
  try
    let stmt, _ = parse_statement parser_state in

    let context = create_initial_context () in
    let context = add_builtin_functions context in
    let context_result, _ = analyze_statement context stmt in

    match lookup_type_definition context_result "栈" with
    | Some (PrivateType_T ("栈", _)) -> Printf.printf "✓ 私有类型语义分析成功\n"
    | Some _ -> Printf.printf "✗ 私有类型语义分析失败：类型定义不正确\n"
    | None -> Printf.printf "✗ 私有类型语义分析失败：未找到类型定义\n"
  with e -> Printf.printf "✗ 私有类型语义分析异常: %s\n" (Printexc.to_string e)

let test_private_type_access_control () =
  let input1 = "类型 「栈」 = 私有 列表" in
  let input2 = "让 「s」 = 空列表" in
  let tokens1 = tokenize input1 "test.ly" in
  let tokens2 = tokenize input2 "test.ly" in
  let parser_state1 = create_parser_state tokens1 in
  let parser_state2 = create_parser_state tokens2 in
  try
    let stmt1, _ = parse_statement parser_state1 in
    let stmt2, _ = parse_statement parser_state2 in

    let context = create_initial_context () in
    let context = add_builtin_functions context in
    let context1, _ = analyze_statement context stmt1 in
    let context2, _ = analyze_statement context1 stmt2 in

    (* 检查是否有预期的类型错误 *)
    if List.length context2.error_list > List.length context1.error_list then
      Printf.printf "✓ 私有类型访问控制正常工作\n"
    else Printf.printf "✗ 私有类型访问控制可能存在问题\n"
  with e -> Printf.printf "✗ 私有类型访问控制测试异常: %s\n" (Printexc.to_string e)

let test_private_type_unification () =
  let private_type1 = PrivateType_T ("栈", ListType_T (TypeVar_T "'a")) in
  let private_type2 = PrivateType_T ("栈", ListType_T (TypeVar_T "'b")) in
  let private_type3 = PrivateType_T ("队列", ListType_T (TypeVar_T "'a")) in

  (try
     let _ = unify private_type1 private_type2 in
     Printf.printf "✓ 同名私有类型合一成功\n"
   with TypeError _ -> Printf.printf "✗ 同名私有类型合一失败\n");

  try
    let _ = unify private_type1 private_type3 in
    Printf.printf "✗ 不同名私有类型合一应该失败但成功了\n"
  with TypeError _ -> Printf.printf "✓ 不同名私有类型合一正确失败\n"

let run_tests () =
  Printf.printf "=== 私有类型系统测试 ===\n";
  test_private_type_parsing ();
  test_private_type_semantic_analysis ();
  test_private_type_access_control ();
  test_private_type_unification ();
  Printf.printf "=== 测试完成 ===\n"

let () = run_tests ()
