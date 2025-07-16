open Yyocamlc_lib

(** Test a simple recursive function to see what AST it produces *)
let test_simple_recursive () =
  let input = "递归 让 「f」 为 函数 「x」 故 「x」" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [ Ast.RecLetStmt ("f", expr) ] -> (
      Printf.printf "SUCCESS: Got RecLetStmt with expr\n";
      (* Let's see what the expr looks like *)
      match expr with
      | Ast.FunExpr (params, body) ->
          Printf.printf "FunExpr with params: [%s]\n" (String.concat "; " params)
      | _ -> Printf.printf "Not a FunExpr, got: %s\n" (Ast.expr_to_string expr))
  | [ Ast.LetStmt ("f", expr) ] -> Printf.printf "ISSUE: Got LetStmt instead of RecLetStmt\n"
  | [] -> Printf.printf "ISSUE: Got empty program\n"
  | _ ->
      Printf.printf "ISSUE: Got unexpected AST structure with %d statements\n" (List.length program)

let () = test_simple_recursive ()
