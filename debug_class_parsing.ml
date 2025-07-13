#require "yyocamlc";;
open Yyocamlc_lib.Lexer;;
open Yyocamlc_lib.Parser;;

(** 调试类定义中的类型解析 *)
let debug_class_parsing () =
  let input = "类 人 = { 姓名: 字符串; 年龄: 整数; 方法 介绍自己 () = 打印 (字符串连接 \"我是\" 姓名) }" in
  Printf.printf "🔍 输入代码: %s\n" input;
  
  (* 第一步：检查词法分析 *)
  Printf.printf "\n📝 词法分析结果:\n";
  try
    let tokens = tokenize input "test" in
    List.iteri (fun i token ->
      Printf.printf "%d: %s\n" i (show_token token)
    ) tokens;
    
    (* 第二步：检查解析 *)
    Printf.printf "\n🔍 尝试解析...\n";
    let program = parse_program tokens in
    Printf.printf "✅ 解析成功！\n";
    List.iteri (fun i stmt ->
      Printf.printf "语句 %d: %s\n" i (Yyocamlc_lib.Ast.show_statement stmt)
    ) program
  with
  | exn ->
    Printf.printf "❌ 解析失败: %s\n" (Printexc.to_string exn);
    (* 尝试分析问题 *)
    Printf.printf "\n🔍 分析问题:\n";
    let test_tokens = [
      "类"; "人"; "="; "{"; "姓名"; ":"; "字符串"; ";"; "年龄"; ":"; "整数"; ";"; "方法"; "介绍自己"; "()"; "="; "打印"; "}";
    ] in
    List.iter (fun word ->
      try
        let single_tokens = tokenize word "test" in
        Printf.printf "'%s' -> %s\n" word 
          (String.concat ", " (List.map show_token single_tokens))
      with
      | ex -> Printf.printf "'%s' -> ERROR: %s\n" word (Printexc.to_string ex)
    ) test_tokens;;

debug_class_parsing ();;