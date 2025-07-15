(** 调试词法分析器的复合标识符问题 *)

open Yyocamlc_lib.Lexer

let debug_tokenization source =
  Printf.printf "正在分析: %s\n" source;
  let tokens = tokenize source "<debug>" in
  List.iter
    (fun (token, pos) ->
      Printf.printf "  Token: %s (行 %d, 列 %d)\n" (show_token token) pos.line pos.column)
    tokens;
  Printf.printf "\n"

let () =
  (* 测试"对数"是否被正确识别 *)
  debug_tokenization "对数";
  debug_tokenization "对数 10";
  debug_tokenization "让 结果 = 对数 10";

  (* 测试其他复合标识符 *)
  debug_tokenization "自然对数";
  debug_tokenization "十进制对数";
  debug_tokenization "平方根"

