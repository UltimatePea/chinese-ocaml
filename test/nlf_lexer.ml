open Yyocamlc_lib.Lexer

let test_natural_language_function_keywords () =
  let test_cases = [
    ("定义", DefineKeyword);
    ("接受", AcceptKeyword);
    ("时返回", ReturnWhenKeyword);
    ("否则返回", ElseReturnKeyword);
    ("乘以", MultiplyKeyword);
    ("输入", InputKeyword);
    ("输出", OutputKeyword);
    ("减一", MinusOneKeyword);
    ("其中", WhereKeyword);
    ("小", SmallKeyword);
  ] in
  
  let all_passed = ref true in
  
  List.iter (fun (text, expected_token) ->
    let tokens = tokenize text "test.ly" in
    match tokens with
    | [(token, _pos)] when token = expected_token ->
      Printf.printf "✓ 关键字 '%s' 正确识别\n" text
    | [(token, _pos); (EOF, _)] when token = expected_token ->
      Printf.printf "✓ 关键字 '%s' 正确识别\n" text
    | _ ->
      Printf.printf "✗ 关键字 '%s' 识别失败，实际tokens: " text;
      List.iter (fun (t, _) -> Printf.printf "%s " (show_token t)) tokens;
      Printf.printf "\n";
      all_passed := false
  ) test_cases;
  
  if !all_passed then
    Printf.printf "\n🎉 所有关键字测试通过！\n"
  else
    Printf.printf "\n❌ 部分关键字测试失败\n"

let () =
  Printf.printf "🧪 自然语言函数定义关键字词法测试\n\n";
  test_natural_language_function_keywords ()