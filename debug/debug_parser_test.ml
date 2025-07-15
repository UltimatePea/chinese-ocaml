open Yyocamlc_lib
open Lexer
open Parser
open Ast

let test_basic_parsing () =
  let input = "设 「结果」 为 一 并加 二" in
  Printf.printf "Testing input: %s\n" input;
  
  let tokens = tokenize input "test" in
  Printf.printf "Tokens: ";
  List.iter (fun (token, _) ->
    Printf.printf "%s " (show_token token)
  ) tokens;
  Printf.printf "\n";
  
  let program = parse_program tokens in
  Printf.printf "Program length: %d\n" (List.length program);
  
  match program with
  | [LetStmt (name, expr)] ->
    Printf.printf "LetStmt: name='%s'\n" name;
    Printf.printf "Expression type: %s\n" (match expr with
      | VarExpr v -> "VarExpr(" ^ v ^ ")"
      | BinaryOpExpr (left, Add, right) -> 
          Printf.sprintf "BinaryOpExpr(left=%s, op=Add, right=%s)"
            (match left with | LitExpr (IntLit n) -> "IntLit(" ^ string_of_int n ^ ")" | VarExpr v -> "VarExpr(" ^ v ^ ")" | _ -> "Other")
            (match right with | LitExpr (IntLit n) -> "IntLit(" ^ string_of_int n ^ ")" | VarExpr v -> "VarExpr(" ^ v ^ ")" | _ -> "Other")
      | _ -> "Other expression")
  | _ ->
    Printf.printf "Multiple statements or other statement type\n"

let () = test_basic_parsing ()