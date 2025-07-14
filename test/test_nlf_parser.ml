open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Ast

let test_natural_language_function_parsing () =
  let test_cases = [
    (* 基础阶乘函数测试 *)
    "定义「阶乘计算」接受「正整数」：\n当「正整数」小于等于「1」时返回「1」\n否则返回「正整数」乘以「正整数减一」之「阶乘计算」";

    (* 简单条件函数 *)
    "定义「是否为零」接受「数值」：\n当「数值」为「0」时返回「真」\n否则返回「假」";

    (* 输入模式测试 *)
    "定义「减一函数」接受「输入」：\n输入减一";
  ] in

  let all_passed = ref true in

  List.iteri (fun i test_code ->
    Printf.printf "🧪 测试 %d: 自然语言函数定义解析\n" (i + 1);
    Printf.printf "代码: %s\n" test_code;

    try
      let tokens = tokenize test_code "test.ly" in
      let state = create_parser_state tokens in
      let (ast, _final_state) = parse_statement state in

      match ast with
      | LetStmt (func_name, FunExpr (_params, _body)) ->
        Printf.printf "✓ 成功解析为函数定义: %s\n" func_name
      | _ ->
        Printf.printf "✗ 解析结果不是函数定义\n";
        all_passed := false
    with
    | SyntaxError (msg, _pos) ->
      Printf.printf "✗ 语法错误: %s\n" msg;
      all_passed := false
    | e ->
      Printf.printf "✗ 解析失败: %s\n" (Printexc.to_string e);
      all_passed := false;

    Printf.printf "\n"
  ) test_cases;

  if !all_passed then
    Printf.printf "🎉 所有自然语言函数解析测试通过！\n"
  else
    Printf.printf "❌ 部分自然语言函数解析测试失败\n"

let () =
  Printf.printf "🧪 自然语言函数定义解析测试\n\n";
  test_natural_language_function_parsing ()