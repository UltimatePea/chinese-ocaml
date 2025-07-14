open Yyocamlc_lib.Lexer
open Alcotest

let test_zhe_token_is_wenyan_then () =
  let input = "者" in
  let token_list = Yyocamlc_lib.Lexer.tokenize input "test" in
  let token, _ = List.hd token_list in
  match token with
  | ThenWenyanKeyword -> ()
  | AncientDefineKeyword -> fail "关键字冲突未修复：'者'仍然映射到AncientDefineKeyword"
  | _ -> fail "关键字冲突修复：'者'映射到未知token"

let test_ancient_function_uses_wenyan_then () =
  let input = "夫 函数名 者" in
  let token_list = Yyocamlc_lib.Lexer.tokenize input "test" in
  let tokens = List.map (fun (token, _) -> token) token_list in
  (* 根据实际的token序列：AncientDefineKeyword Other IdentifierToken(名) ThenWenyanKeyword EOF *)
  (* 找到ThenWenyanKeyword token *)
  let rec find_then_token tokens =
    match tokens with
    | [] -> None
    | ThenWenyanKeyword :: _ -> Some ThenWenyanKeyword
    | _ :: rest -> find_then_token rest
  in
  match find_then_token tokens with
  | Some ThenWenyanKeyword -> ()
  | Some AncientDefineKeyword -> fail "古雅体中的'者'错误映射到AncientDefineKeyword"
  | _ -> fail "古雅体测试中没有找到'者'对应的ThenWenyanKeyword"

let test_wenyan_conditional_uses_then () =
  let input = "若 条件 者 结果" in
  let token_list = Yyocamlc_lib.Lexer.tokenize input "test" in
  let tokens = List.map (fun (token, _) -> token) token_list in
  let third_token = List.nth tokens 2 in
  (* 者 - ThenWenyanKeyword *)
  match third_token with
  | ThenWenyanKeyword -> ()
  | _ -> fail "wenyan条件语句中的'者'映射错误"

let keyword_conflict_tests =
  [
    ("关键字冲突修复：'者'唯一映射到ThenWenyanKeyword", `Quick, test_zhe_token_is_wenyan_then);
    ("古雅体函数定义正确使用ThenWenyanKeyword", `Quick, test_ancient_function_uses_wenyan_then);
    ("wenyan条件语句正确使用ThenWenyanKeyword", `Quick, test_wenyan_conditional_uses_then);
  ]

let () = run "关键字冲突修复测试" [ ("词法分析器关键字冲突修复", keyword_conflict_tests) ]
