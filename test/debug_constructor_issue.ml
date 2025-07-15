open Yyocamlc_lib

let debug_constructor_issue () =
  Printf.printf "调试构造器表达式问题:\n";

  let test_source = "\n类型 选项 = | 无 | 有 of 整数\n让 带参数构造器 = 有 42\n打印 带参数构造器" in

  Printf.printf "源代码:\n%s\n\n" test_source;

  Printf.printf "词法分析结果:\n";
  let tokens = Lexer.tokenize test_source "test" in
  List.iteri
    (fun i (token, _) ->
      let token_name =
        match token with
        | Lexer.TypeKeyword -> "TypeKeyword"
        | Lexer.IdentifierToken s -> Printf.sprintf "IdentifierToken(%s)" s
        | Lexer.Pipe -> "Pipe"
        | Lexer.OfKeyword -> "OfKeyword"
        | Lexer.LetKeyword -> "LetKeyword"
        | Lexer.Assign -> "Assign"
        | Lexer.IntToken n -> Printf.sprintf "IntToken(%d)" n
        | Lexer.NumberKeyword -> "NumberKeyword"
        | Lexer.EOF -> "EOF"
        | _ -> "其他Token"
      in
      Printf.printf "  %d: %s\n" i token_name)
    tokens;

  Printf.printf "\n语法分析:\n";
  try
    let _ = Parser.parse_program tokens in
    Printf.printf "解析成功!\n"
  with
  | Parser.SyntaxError (msg, pos) -> Printf.printf "语法错误 (行:%d, 列:%d): %s\n" pos.line pos.column msg
  | e -> Printf.printf "其他错误: %s\n" (Printexc.to_string e)

let () = debug_constructor_issue ()

