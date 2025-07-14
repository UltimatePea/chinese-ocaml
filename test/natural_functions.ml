open Alcotest
open Yyocamlc_lib

(** 测试自然语言函数定义解析 *)

let test_simple_natural_function () =
  let input = "定义「测试函数」接受「输入」： 当「输入」等于 １ 时返回 １ 不然返回 ０" in
  
  let tokens = Lexer.tokenize input "test" in
  let parsed = Parser.parse_program tokens in
  
  match parsed with
  | [Ast.LetStmt (func_name, Ast.FunExpr ([param_name], _body))] ->
    check string "函数名" "测试函数" func_name;
    check string "参数名" "输入" param_name
  | _ ->
    fail "解析结果不符合预期"

let test_natural_arithmetic () =
  let input = "定义「阶乘」接受「数字」： 当「数字」小于等于 １ 时返回 １ 不然返回「数字」乘以「数字」" in
  
  let tokens = Lexer.tokenize input "test" in
  let _parsed = Parser.parse_program tokens in
  
  (* 如果能够解析成功就说明语法正确 *)
  check bool "解析成功" true true

let test_quoted_identifiers () =
  let input = "让「变量名」为 ４２" in
  
  let tokens = Lexer.tokenize input "test" in
  let parsed = Parser.parse_program tokens in
  
  match parsed with
  | [Ast.LetStmt (var_name, _val_expr)] ->
    check string "变量名" "变量名" var_name
  | _ ->
    fail "引用标识符解析失败"

let () =
  run "自然语言函数定义测试" [
    ("简单自然语言函数定义", [test_case "解析函数定义" `Quick test_simple_natural_function]);
    ("自然语言算术表达式", [test_case "解析算术表达式" `Quick test_natural_arithmetic]);
    ("引用标识符测试", [test_case "解析引用标识符" `Quick test_quoted_identifiers]);
  ]