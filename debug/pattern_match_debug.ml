open Yyocamlc_lib

let debug_pattern_match () =
  let input = "匹配 「x」 与 ｜ ０ → 『零』 ｜ １ → 『一』 ｜ 其他 → 『其他』" in
  Printf.printf "输入字符串: %s\n\n" input;

  (* 调试词法分析 *)
  Printf.printf "=== 词法分析调试 ===\n";
  let tokens = Lexer.tokenize input "debug" in
  Printf.printf "Token数量: %d\n" (List.length tokens);
  List.iteri (fun i (token, _pos) -> Printf.printf "%d: %s\n" i (Lexer.show_token token)) tokens;

  Printf.printf "\n=== 语法分析调试 ===\n";
  try
    let program = Parser.parse_program tokens in
    Printf.printf "解析成功！AST节点数量: %d\n" (List.length program);
    List.iteri (fun i stmt -> Printf.printf "%d: %s\n" i (Ast.show_stmt stmt)) program
  with
  | Parser.SyntaxError (msg, pos) ->
      Printf.printf "解析错误: %s\n" msg;
      Printf.printf "问题位置: %s\n" (Lexer.show_position pos)
  | exn ->
      Printf.printf "其他错误: %s\n" (Printexc.to_string exn);
<<<<<<< HEAD
=======

  Printf.printf "\n=== 期望的AST结构 ===\n";
  let open Ast in
  let expected_ast = [ExprStmt (MatchExpr (VarExpr "x", [
    {pattern = LitPattern (IntLit 0); guard = None; expr = LitExpr (StringLit "零")};
    {pattern = LitPattern (IntLit 1); guard = None; expr = LitExpr (StringLit "一")};
    {pattern = WildcardPattern; guard = None; expr = LitExpr (StringLit "其他")}
  ]))] in
  List.iteri (fun i stmt ->
    Printf.printf "%d: %s\n" i (show_stmt stmt)
  ) expected_ast
>>>>>>> 493dc5d8 (Fix #90: 完全清理项目中所有文件的行尾空格)

      Printf.printf "\n=== 期望的AST结构 ===\n";
      let open Ast in
      let expected_ast =
        [
          ExprStmt
            (MatchExpr
               ( VarExpr "x",
                 [
                   { pattern = LitPattern (IntLit 0); guard = None; expr = LitExpr (StringLit "零") };
                   { pattern = LitPattern (IntLit 1); guard = None; expr = LitExpr (StringLit "一") };
                   { pattern = WildcardPattern; guard = None; expr = LitExpr (StringLit "其他") };
                 ] ));
        ]
      in
      List.iteri (fun i stmt -> Printf.printf "%d: %s\n" i (show_stmt stmt)) expected_ast

let () = debug_pattern_match ()

