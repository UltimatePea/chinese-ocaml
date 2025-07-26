(** 统一Token系统测试 - 技术债务清理 Issue #1375
    
    测试新的统一Token系统的基本功能和兼容性。
    
    Author: Beta, 代码审查专员
    Date: 2025-07-26 *)

open Yyocamlc_lib.Token_unified
open Yyocamlc_lib.Token_converter_unified

(** 基础Token转换测试 *)
let test_basic_conversion () =
  let test_cases = [
    ("让", Some (BasicKeyword `Let));
    ("函数", Some (BasicKeyword `Fun));
    ("如果", Some (ControlKeyword `If));
    ("整数", Some (TypeKeyword `Int));
    ("有", Some (ClassicalKeyword `Have));
    ("+", Some (OperatorToken `Plus));
    ("(", Some (DelimiterToken `LeftParen));
    ("42", Some (IntToken 42));
    ("3.14", Some (FloatToken 3.14));
    ("真", Some (BoolToken true));
    ("\"hello\"", Some (StringToken "hello"));
  ] in
  
  List.iter (fun (input, expected) ->
    let result = convert input in
    match expected, result with
    | Some exp, Some res when exp = res -> 
        Printf.printf "✓ '%s' -> %s\n" input (Utils.token_to_string res)
    | Some exp, Some res ->
        Printf.printf "✗ '%s': expected %s, got %s\n" 
          input (Utils.token_to_string exp) (Utils.token_to_string res)
    | Some exp, None ->
        Printf.printf "✗ '%s': expected %s, got None\n" 
          input (Utils.token_to_string exp)
    | None, Some res ->
        Printf.printf "✗ '%s': expected None, got %s\n" 
          input (Utils.token_to_string res)
    | None, None ->
        Printf.printf "✓ '%s' -> None (as expected)\n" input
  ) test_cases

(** 中文数字转换测试 *)
let test_chinese_numbers () =
  let test_cases = [
    ("一", IntToken 1);
    ("二", IntToken 2);
    ("十", IntToken 10);
    ("三点一四", ChineseNumberToken "三点一四");
  ] in
  
  List.iter (fun (input, expected) ->
    match Literal.convert_chinese_number input with
    | Some result when result = expected ->
        Printf.printf "✓ 中文数字 '%s' -> %s\n" input (Utils.token_to_string result)
    | Some result ->
        Printf.printf "✗ 中文数字 '%s': expected %s, got %s\n" 
          input (Utils.token_to_string expected) (Utils.token_to_string result)
    | None ->
        Printf.printf "✗ 中文数字 '%s': expected %s, got None\n" 
          input (Utils.token_to_string expected)
  ) test_cases

(** 标识符识别测试 *)
let test_identifier_recognition () =
  let test_cases = [
    ("「变量名」", QuotedIdentifierToken "变量名");
    ("Constructor", ConstructorToken "Constructor");
    ("Module.function", ModuleNameToken "Module.function");
    ("simple_var", IdentifierToken "simple_var");
  ] in
  
  List.iter (fun (input, expected) ->
    match Identifier.convert input with
    | Some result when result = expected ->
        Printf.printf "✓ 标识符 '%s' -> %s\n" input (Utils.token_to_string result)
    | Some result ->
        Printf.printf "✗ 标识符 '%s': expected %s, got %s\n" 
          input (Utils.token_to_string expected) (Utils.token_to_string result)
    | None ->
        Printf.printf "✗ 标识符 '%s': expected %s, got None\n" 
          input (Utils.token_to_string expected)
  ) test_cases

(** 转换策略测试 *)
let test_conversion_strategies () =
  let test_input = "有" in
  
  (* 直接转换策略 *)
  let direct_context = {default_context with strategy = `Direct} in
  let direct_result = convert_token test_input direct_context in
  
  (* 古典语言转换策略 *)
  let classical_context = {default_context with strategy = `Classical} in
  let classical_result = convert_token test_input classical_context in
  
  (* 自然语言转换策略 *)
  let natural_context = {default_context with strategy = `Natural} in
  let natural_result = convert_token test_input natural_context in
  
  Printf.printf "转换策略测试 - 输入: '%s'\n" test_input;
  
  (match direct_result with
   | Some token -> Printf.printf "  直接策略: %s\n" (Utils.token_to_string token)
   | None -> Printf.printf "  直接策略: None\n");
  
  (match classical_result with
   | Some token -> Printf.printf "  古典策略: %s\n" (Utils.token_to_string token)
   | None -> Printf.printf "  古典策略: None\n");
  
  (match natural_result with
   | Some token -> Printf.printf "  自然策略: %s\n" (Utils.token_to_string token)
   | None -> Printf.printf "  自然策略: None\n")

(** 批量转换测试 *)
let test_batch_conversion () =
  let input_list = ["让"; "x"; "="; "42"; "在"; "x"; "+"; "1"] in
  let context = default_context in
  let results = convert_tokens input_list context in
  
  Printf.printf "批量转换测试:\n";
  List.iter2 (fun input result ->
    Printf.printf "  '%s' -> %s\n" input (Utils.token_to_string result)
  ) input_list results

(** Token工具函数测试 *)
let test_utility_functions () =
  let test_tokens = [
    BasicKeyword `Let;
    IntToken 42;
    OperatorToken `Plus;
    DelimiterToken `LeftParen;
    EOF;
  ] in
  
  Printf.printf "工具函数测试:\n";
  List.iter (fun token ->
    let str_repr = Utils.token_to_string token in
    let category = Utils.get_category token in
    let chinese_name = Utils.get_chinese_name token in
    let deprecated = Utils.is_deprecated token in
    
    Printf.printf "  Token: %s\n" str_repr;
    Printf.printf "    类别: %s\n" (match category with
      | `Literal -> "字面量"
      | `Identifier -> "标识符"
      | `Keyword -> "关键字"
      | `Operator -> "操作符"
      | `Delimiter -> "分隔符"
      | `Special -> "特殊");
    Printf.printf "    中文名: %s\n" (match chinese_name with Some n -> n | None -> "无");
    Printf.printf "    已弃用: %b\n\n" deprecated
  ) test_tokens

(** 主测试函数 *)
let run_tests () =
  Printf.printf "=== 统一Token系统测试开始 ===\n\n";
  
  Printf.printf "1. 基础转换测试\n";
  test_basic_conversion ();
  Printf.printf "\n";
  
  Printf.printf "2. 中文数字转换测试\n";
  test_chinese_numbers ();
  Printf.printf "\n";
  
  Printf.printf "3. 标识符识别测试\n";
  test_identifier_recognition ();
  Printf.printf "\n";
  
  Printf.printf "4. 转换策略测试\n";
  test_conversion_strategies ();
  Printf.printf "\n";
  
  Printf.printf "5. 批量转换测试\n";
  test_batch_conversion ();
  Printf.printf "\n";
  
  Printf.printf "6. 工具函数测试\n";
  test_utility_functions ();
  
  Printf.printf "=== 统一Token系统测试完成 ===\n"

(** 测试入口 *)
let () = run_tests ()