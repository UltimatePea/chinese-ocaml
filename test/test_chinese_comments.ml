open Yyocamlc_lib
open Lexer

let () =
  let test_suite = "中文注释语法测试" in
  Printf.printf "=== %s ===\n" test_suite;

  (* 测试1: 基本中文注释 *)
  (try
     let tokens = tokenize "「：这是注释：」让 「变量甲」 为 一" "test" in
     let code_tokens =
       List.filter
         (fun (token, _) ->
           match token with
           | LetKeyword | QuotedIdentifierToken _ | ChineseNumberToken _ | AsForKeyword | OneKeyword
             ->
               true
           | _ -> false)
         tokens
     in
     (* 应该只有: LetKeyword, QuotedIdentifierToken "变量甲", AsForKeyword, OneKeyword "一" *)
     assert (List.length code_tokens = 4);
     Printf.printf "✓ 基本中文注释测试通过\n"
   with e -> Printf.printf "✗ 基本中文注释测试失败: %s\n" (Printexc.to_string e));

  (* 测试2: 多行中文注释 *)
  (try
     let source = "「：第一行注释\n第二行注释\n第三行注释：」\n让 「变量乙」 为 二" in
     let tokens = tokenize source "test" in
     let filtered_tokens =
       List.filter
         (fun (token, _) ->
           match token with
           | LetKeyword | QuotedIdentifierToken _ | ChineseNumberToken _ | AsForKeyword | OneKeyword
             ->
               true
           | _ -> false)
         tokens
     in
     assert (List.length filtered_tokens = 4);
     Printf.printf "✓ 多行中文注释测试通过\n"
   with e -> Printf.printf "✗ 多行中文注释测试失败: %s\n" (Printexc.to_string e));

  (* 测试3: 混合注释类型 *)
  (try
     let source = "(* ASCII注释 *) 「：中文注释：」 让 「变量丙」 为 三" in
     let tokens = tokenize source "test" in
     let filtered_tokens =
       List.filter
         (fun (token, _) ->
           match token with
           | LetKeyword | QuotedIdentifierToken _ | ChineseNumberToken _ | AsForKeyword | OneKeyword
             ->
               true
           | _ -> false)
         tokens
     in
     assert (List.length filtered_tokens = 4);
     Printf.printf "✓ 混合注释类型测试通过\n"
   with e -> Printf.printf "✗ 混合注释类型测试失败: %s\n" (Printexc.to_string e));

  (* 测试4: 嵌套内容的中文注释 *)
  (try
     let source = "「：注释中包含（括号）和其他内容：」让 「变量丁」 为 四" in
     let tokens = tokenize source "test" in
     let filtered_tokens =
       List.filter
         (fun (token, _) ->
           match token with
           | LetKeyword | QuotedIdentifierToken _ | ChineseNumberToken _ | AsForKeyword | OneKeyword
             ->
               true
           | _ -> false)
         tokens
     in
     assert (List.length filtered_tokens = 4);
     Printf.printf "✓ 嵌套内容中文注释测试通过\n"
   with e -> Printf.printf "✗ 嵌套内容中文注释测试失败: %s\n" (Printexc.to_string e));

  Printf.printf "=== %s 完成 ===\n" test_suite

