open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Ast

let debug_pattern () =
  let input = "观「列表」之性 若 空空如也 则 答 零 余者 则 答 一 观毕" in
  Printf.printf "Input: %s\n" input;
  let tokens = tokenize input "test.ly" in
  Printf.printf "Tokens parsed successfully\n";
  let ast = parse_program tokens in
  Printf.printf "AST parsed successfully\n";
  match ast with
  | [ ExprStmt expr ] -> (
      match expr with
      | MatchExpr (VarExpr var_name, branches) ->
          Printf.printf "Match expression with variable: %s\n" var_name;
          Printf.printf "Number of branches: %d\n" (List.length branches);
          List.iteri
            (fun i branch ->
              Printf.printf "Branch %d pattern: %s\n" i (show_pattern branch.pattern);
              Printf.printf "Branch %d expr: %s\n" i (show_expr branch.expr))
            branches
      | _ -> Printf.printf "Not a match expression\n")
  | _ -> Printf.printf "Not a single expression statement\n"

let () = debug_pattern ()
