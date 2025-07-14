open Alcotest
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Ast

(** Test ancient pattern matching with quoted identifiers *)

let test_ancient_pattern_quoted_identifier () =
  let input = "观 lst 之性 若 空 则 答 零 余者 则 答 1 观毕" in
  let tokens = tokenize input "test.ly" in
  let ast = parse_program tokens in
  match ast with
  | [ExprStmt expr] ->
    (match expr with
     | MatchExpr (VarExpr "lst", branches) ->
       check int "Should have 2 branches" 2 (List.length branches);
       (* Check first branch: 若 空 则 答 零 *)
       let first_branch = List.hd branches in
       check bool "First branch should be variable pattern '空'" 
         true (first_branch.pattern = VarPattern "空");
       (match first_branch.expr with
        | VarExpr "零" -> () (* 零 is parsed as a variable, not literal 0 *)
        | _ -> fail "First branch should return 零");
       (* Check second branch: 余者 则 答 1 *)
       let second_branch = List.hd (List.tl branches) in
       check bool "Second branch should be wildcard pattern"
         true (second_branch.pattern = WildcardPattern);
       (match second_branch.expr with
        | LitExpr (IntLit 1) -> ()
        | _ -> fail "Second branch should return 1")
     | _ -> fail "Should parse as match expression")
  | _ -> fail "Should parse as single expression statement"

let test_ancient_pattern_simple_identifier () =
  let input = "观 lst 之性 若 空 则 答 零 余者 则 答 1 观毕" in
  let tokens = tokenize input "test.ly" in
  let ast = parse_program tokens in
  match ast with
  | [ExprStmt expr] ->
    (match expr with
     | MatchExpr (VarExpr "lst", _) -> ()
     | _ -> fail "Should parse as match expression with 'lst' variable")
  | _ -> fail "Should parse as single expression"

let test_ancient_pattern_parsing_no_space () =
  (* Test that the fix actually works: simple identifier parsing *)
  let input = "观 x 之性 若 空 则 答 0 观毕" in
  try
    let tokens = tokenize input "test.ly" in
    let _ast = parse_program tokens in
    (* If we get here, parsing succeeded *)
    check bool "Parsing should succeed" true true
  with
  | _ -> fail "Parsing should not fail for simple identifier"

let test_set = [
  test_case "Ancient pattern with quoted identifier" `Quick test_ancient_pattern_quoted_identifier;
  test_case "Ancient pattern with simple identifier" `Quick test_ancient_pattern_simple_identifier;
  test_case "Ancient pattern parsing no space" `Quick test_ancient_pattern_parsing_no_space;
]

let () = run "Ancient Pattern Match Tests" [
  "古雅体模式匹配测试", test_set;
]