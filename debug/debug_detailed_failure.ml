open Yyocamlc_lib

let parse_and_eval source =
  try
    let tokens = Lexer.tokenize source "<test>" in
    let program = Parser.parse_program tokens in
    let result = Codegen.execute_program program in
    Ok result
  with
  | Parser.SyntaxError (msg, _) -> Error ("语法错误: " ^ msg)
  | Codegen.RuntimeError msg -> Error ("运行时错误: " ^ msg)
  | e -> Error ("其他错误: " ^ Printexc.to_string e)

let test_detailed () =
  let source = "
  让 原始 = \"  Hello World  \"
  让 去空白 = 去除空白 原始
  让 大写 = 大写转换 去空白
  " in
  Printf.printf "测试完整场景\n";
  match parse_and_eval source with
  | Ok _ -> Printf.printf "成功\n"
  | Error msg -> Printf.printf "失败: %s\n" msg

let () = test_detailed ()