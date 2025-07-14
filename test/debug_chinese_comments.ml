open Yyocamlc_lib
open Lexer

let () =
  Printf.printf "=== 调试中文注释 ===\n";

  let test_cases = [ ("基本注释", "「：这是注释：」让 x = 1"); ("简单代码", "让 x = 1") ] in

  List.iter
    (fun (name, source) ->
      Printf.printf "\n--- %s ---\n" name;
      Printf.printf "源代码: %s\n" source;
      try
        let tokens = tokenize source "test" in
        Printf.printf "生成 %d 个token:\n" (List.length tokens);
        List.iteri
          (fun i (token, pos) ->
            Printf.printf "  %d: %s (第%d行，第%d列)\n" i (show_token token) pos.line pos.column)
          tokens;

        let code_tokens =
          List.filter
            (fun (token, _) -> match token with EOF | Newline -> false | _ -> true)
            tokens
        in
        Printf.printf "过滤后有效token数量: %d\n" (List.length code_tokens)
      with e -> Printf.printf "错误: %s\n" (Printexc.to_string e))
    test_cases

