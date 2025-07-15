open Yyocamlc_lib.Lexer

(* 测试 Issue #176: 所有标识符必须用「」引用，关键字不能用「」引用 *)

let test_quoted_identifiers () =
  Printf.printf "=== 测试Issue #176: 标识符引用规则 ===\n";
  
  (* 测试1: 引用标识符应该正常工作 *)
  Printf.printf "\n1. 测试引用标识符「变量」:\n";
  (try
    let tokens = tokenize "「变量」" "test" in
    match tokens with
    | [(QuotedIdentifierToken "变量", _); (EOF, _)] ->
        Printf.printf "✓ 引用标识符「变量」正确识别\n"
    | _ -> Printf.printf "✗ 引用标识符「变量」识别错误\n"
  with e -> Printf.printf "✗ 错误: %s\n" (Printexc.to_string e));
  
  (* 测试2: 未引用的标识符应该抛出错误 *)
  Printf.printf "\n2. 测试未引用标识符 变量:\n";
  (try
    let _tokens = tokenize "变量" "test" in
    Printf.printf "✗ 未引用标识符「变量」应该抛出错误，但没有\n"
  with 
  | LexError (msg, _) -> 
      Printf.printf "✓ 未引用标识符正确抛出错误: %s\n" msg
  | e -> Printf.printf "✗ 未引用标识符抛出了意外错误: %s\n" (Printexc.to_string e));

  (* 测试3: 关键字应该正常工作（不需要引用） *)
  Printf.printf "\n3. 测试关键字 让:\n";
  (try
    let tokens = tokenize "让" "test" in
    match tokens with
    | [(LetKeyword, _); (EOF, _)] ->
        Printf.printf "✓ 关键字「让」正确识别\n"
    | _ -> Printf.printf "✗ 关键字「让」识别错误\n"
  with e -> Printf.printf "✗ 错误: %s\n" (Printexc.to_string e));

  (* 测试4: 关键字不应该能用引用 *)
  Printf.printf "\n4. 测试引用的关键字「让」:\n";
  (try
    let tokens = tokenize "「让」" "test" in
    match tokens with
    | [(QuotedIdentifierToken "让", _); (EOF, _)] ->
        Printf.printf "✓ 引用的关键字「让」被识别为标识符（符合预期）\n"
    | _ -> Printf.printf "✗ 引用的关键字「让」识别结果不符合预期\n"
  with e -> Printf.printf "✗ 错误: %s\n" (Printexc.to_string e));

  (* 测试5: 复杂表达式 *)
  Printf.printf "\n5. 测试复杂表达式 让「变量」为一:\n";
  (try
    let tokens = tokenize "让「变量」为一" "test" in
    let token_types = List.map (fun (token, _) -> token) tokens in
    match token_types with
    | [LetKeyword; QuotedIdentifierToken "变量"; AncientAsOneKeyword; EOF] ->
        Printf.printf "✓ 复杂表达式正确解析\n"
    | _ -> 
        Printf.printf "✗ 复杂表达式解析错误，得到的token列表:\n";
        List.iter (fun token -> Printf.printf "  %s\n" (show_token token)) token_types
  with e -> Printf.printf "✗ 错误: %s\n" (Printexc.to_string e));

  Printf.printf "\n=== Issue #176测试完成 ===\n"

let () = test_quoted_identifiers ()