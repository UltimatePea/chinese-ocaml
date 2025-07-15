open Yyocamlc_lib

let () =
  let input = "递归 让 「阶乘」 为 函数 「n」 → 如果 「n」 ＜＝ １ 那么 １ 否则 「n」 ＊ 「阶乘」 （「n」 － １）" in
  Printf.printf "测试输入: %s\n" input;

  try
    let tokens = Lexer.tokenize input "test" in
    Printf.printf "词法分析结果:\n";
    List.iter
      (fun (token, _pos) ->
        let token_str =
          match token with
          | Lexer.LetKeyword -> "LetKeyword"
          | Lexer.RecKeyword -> "RecKeyword"
          | Lexer.QuotedIdentifierToken s -> "QuotedIdentifierToken(\"" ^ s ^ "\")"
          | Lexer.AsForKeyword -> "AsForKeyword"
          | Lexer.Assign -> "Assign"
          | Lexer.IntToken i -> "IntToken(" ^ string_of_int i ^ ")"
          | Lexer.FunKeyword -> "FunKeyword"
          | Lexer.Arrow -> "Arrow"
          | Lexer.ChineseArrow -> "ChineseArrow"
          | Lexer.IfKeyword -> "IfKeyword"
          | Lexer.LessEqual -> "LessEqual"
          | Lexer.ThenKeyword -> "ThenKeyword"
          | Lexer.ElseKeyword -> "ElseKeyword"
          | Lexer.Multiply -> "Multiply"
          | Lexer.LeftParen -> "LeftParen"
          | Lexer.RightParen -> "RightParen"
          | Lexer.ChineseLeftParen -> "ChineseLeftParen"
          | Lexer.ChineseRightParen -> "ChineseRightParen"
          | Lexer.Minus -> "Minus"
          | Lexer.EOF -> "EOF"
          | _ -> "Other"
        in
        Printf.printf "  %s\n" token_str)
      tokens;
    Printf.printf "\n";

    let program = Parser.parse_program tokens in
    Printf.printf "语法分析成功!\n";
    Printf.printf "AST: ";
    match program with
    | [ Ast.RecLetStmt (name, _expr) ] -> Printf.printf "RecLetStmt(\"%s\", ...)\n" name
    | [ _stmt ] -> Printf.printf "单个语句，但不是RecLetStmt\n"
    | [] -> Printf.printf "空程序\n"
    | _ -> Printf.printf "多个语句\n"
  with e -> Printf.printf "错误: %s\n" (Printexc.to_string e)
