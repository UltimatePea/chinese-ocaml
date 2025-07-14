open Yyocamlc_lib
open Lexer

let () =
  let test_suite = "中文注释语法测试" in
  Printf.printf "=== %s ===\n" test_suite;

  (* 测试1: 基本中文注释 *)
  (try
    let tokens = tokenize "「：这是注释：」让 x 为 1" "test" in
    let code_tokens = List.filter (fun (token, _) ->
      match token with
      | LetKeyword | IdentifierToken _ | IntToken _ | Assign -> true
      | _ -> false) tokens in
    (* 应该只有: LetKeyword, IdentifierToken "x", Assign, IntToken 1 *)
    assert (List.length code_tokens = 4);
    Printf.printf "✓ 基本中文注释测试通过\n"
  with e -> Printf.printf "✗ 基本中文注释测试失败: %s\n" (Printexc.to_string e));

  (* 测试2: 多行中文注释 *)
  (try
    let source = "「：第一行注释\n第二行注释\n第三行注释：」\n让 y 为 2" in
    let tokens = tokenize source "test" in
    let filtered_tokens = List.filter (fun (token, _) ->
      match token with
      | LetKeyword | IdentifierToken _ | IntToken _ | Assign -> true
      | _ -> false) tokens in
    assert (List.length filtered_tokens = 4);
    Printf.printf "✓ 多行中文注释测试通过\n"
  with e -> Printf.printf "✗ 多行中文注释测试失败: %s\n" (Printexc.to_string e));

  (* 测试3: 混合注释类型 *)
  (try
    let source = "(* ASCII注释 *) 「：中文注释：」 让 z 为 3" in
    let tokens = tokenize source "test" in
    let filtered_tokens = List.filter (fun (token, _) ->
      match token with
      | LetKeyword | IdentifierToken _ | IntToken _ | Assign -> true
      | _ -> false) tokens in
    assert (List.length filtered_tokens = 4);
    Printf.printf "✓ 混合注释类型测试通过\n"
  with e -> Printf.printf "✗ 混合注释类型测试失败: %s\n" (Printexc.to_string e));

  (* 测试4: 嵌套内容的中文注释 *)
  (try
    let source = "「：注释中包含（括号）和【方括号】：」让 a 为 4" in
    let tokens = tokenize source "test" in
    let filtered_tokens = List.filter (fun (token, _) ->
      match token with
      | LetKeyword | IdentifierToken _ | IntToken _ | Assign -> true
      | _ -> false) tokens in
    assert (List.length filtered_tokens = 4);
    Printf.printf "✓ 嵌套内容中文注释测试通过\n"
  with e -> Printf.printf "✗ 嵌套内容中文注释测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "=== %s 完成 ===\n" test_suite