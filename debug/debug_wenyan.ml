(** 调试文言风格语法问题 *)

open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

let debug_wenyan_parse source =
  Printf.printf "正在分析文言语法: %s\n" source;
  try
    let tokens = tokenize source "<debug>" in
    Printf.printf "词法分析成功，词元数量: %d\n" (List.length tokens);
    List.iteri (fun i (token, pos) ->
      Printf.printf "  [%d] %s (行 %d, 列 %d)\n"
        i (show_token token) pos.line pos.column
    ) tokens;

    let state = create_parser_state tokens in
    let (first_token, _) = current_token state in
    if first_token = SetKeyword then
      (* 设语法作为语句解析 *)
      let (_stmt, _) = parse_statement state in
      Printf.printf "语句解析成功！\n"
    else
      (* 其他作为表达式解析 *)
      let (_ast, _) = parse_expression state in
      Printf.printf "表达式解析成功！\n";
    Printf.printf "\n"
  with
  | Yyocamlc_lib.Parser.SyntaxError (msg, pos) ->
    Printf.printf "语法错误: %s (行 %d, 列 %d)\n\n" msg pos.line pos.column
  | Yyocamlc_lib.Lexer.LexError (msg, pos) ->
    Printf.printf "词法错误: %s (行 %d, 列 %d)\n\n" msg pos.line pos.column
  | e ->
    Printf.printf "其他错误: %s\n\n" (Printexc.to_string e)

let () =
  (* 测试文言风格语法 *)
  debug_wenyan_parse "吾有一数名曰数值其值42也在数值";

  (* 测试wenyan设置语法 *)
  debug_wenyan_parse "设数值为42";
  debug_wenyan_parse "设wenyan为200";