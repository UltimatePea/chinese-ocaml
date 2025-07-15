(** 骆言语法分析器单元测试 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

(* 辅助函数：从字符串创建tokens *)
let tokenize_string_to_list input =
  tokenize input "<test>"

(* 测试基础parser工具函数 *)
let test_parser_utils () =
  let tokens = [(Int 42, (1, 1)); (Plus, (1, 3)); (Int 24, (1, 5))] in
  let state = create_parser_state tokens in
  
  (* 测试current_token *)
  let current, _pos = current_token state in
  check bool "当前token测试" true (current = Int 42);
  
  (* 测试advance_parser *)
  let state2 = advance_parser state in
  let current2, _pos2 = current_token state2 in
  check bool "前进parser测试" true (current2 = Plus);
  
  (* 测试peek_token *)
  let peek_result = peek_token state in
  check bool "peek_token测试" true (peek_result = Some Plus)

(* 测试标识符解析 *)
let test_parse_identifier () =
  let tokens = [(Identifier "变量名", (1, 1)); (Plus, (1, 4))] in
  let state = create_parser_state tokens in
  
  let identifier, new_state = parse_identifier state in
  check string "标识符解析测试" "变量名" identifier;
  
  let current, _pos = current_token new_state in
  check bool "标识符解析后状态测试" true (current = Plus)

(* 测试字面量解析 *)
let test_parse_literal () =
  (* 测试整数字面量 *)
  let int_tokens = [(Int 42, (1, 1))] in
  let int_state = create_parser_state int_tokens in
  let int_expr, _int_state = parse_literal int_state in
  check bool "整数字面量解析测试" true (int_expr = IntExpr 42);
  
  (* 测试浮点数字面量 *)
  let float_tokens = [(Float 3.14, (1, 1))] in
  let float_state = create_parser_state float_tokens in
  let float_expr, _float_state = parse_literal float_state in
  check bool "浮点数字面量解析测试" true (float_expr = FloatExpr 3.14);
  
  (* 测试字符串字面量 *)
  let string_tokens = [(String "测试", (1, 1))] in
  let string_state = create_parser_state string_tokens in
  let string_expr, _string_state = parse_literal string_state in
  check bool "字符串字面量解析测试" true (string_expr = StringExpr "测试");
  
  (* 测试布尔字面量 *)
  let bool_tokens = [(Bool true, (1, 1))] in
  let bool_state = create_parser_state bool_tokens in
  let bool_expr, _bool_state = parse_literal bool_state in
  check bool "布尔字面量解析测试" true (bool_expr = BoolExpr true)

(* 测试token到二元运算符的转换 *)
let test_token_to_binary_op () =
  check bool "加号转换" true (token_to_binary_op Plus = Add);
  check bool "减号转换" true (token_to_binary_op Minus = Sub);
  check bool "乘号转换" true (token_to_binary_op Star = Mul);
  check bool "除号转换" true (token_to_binary_op Slash = Div);
  check bool "等号转换" true (token_to_binary_op Equal = Eq);
  check bool "小于号转换" true (token_to_binary_op LessThan = Lt);
  check bool "大于号转换" true (token_to_binary_op GreaterThan = Gt)

(* 测试expect_token函数 *)
let test_expect_token () =
  let tokens = [(Int 42, (1, 1)); (Plus, (1, 3)); (EOF, (1, 5))] in
  let state = create_parser_state tokens in
  
  (* 测试成功的expect *)
  let state2 = expect_token (Int 42) state in
  let current, _pos = current_token state2 in
  check bool "expect_token成功测试" true (current = Plus);
  
  (* 测试失败的expect *)
  try
    let _state3 = expect_token (String "test") state in
    check bool "expect_token失败应该抛出异常" false true
  with
  | SyntaxError _ -> check bool "expect_token错误处理" true true
  | _ -> check bool "expect_token错误类型不正确" false true

(* 测试is_token函数 *)
let test_is_token () =
  let tokens = [(Int 42, (1, 1)); (Plus, (1, 3))] in
  let state = create_parser_state tokens in
  
  check bool "is_token匹配测试" true (is_token (Int 42) state);
  check bool "is_token不匹配测试" false (is_token Plus state)

(* 测试parser状态创建 *)
let test_parser_state_creation () =
  let tokens = [(Int 42, (1, 1)); (Plus, (1, 3))] in
  let state = create_parser_state tokens in
  
  let current, _pos = current_token state in
  check bool "parser状态创建测试" true (current = Int 42)

(* 测试parser异常 *)
let test_parser_exceptions () =
  try
    let tokens = [(Plus, (1, 1)); (EOF, (1, 2))] in
    let state = create_parser_state tokens in
    let _expr, _state = parse_literal state in
    check bool "应该抛出异常" false true
  with
  | SyntaxError _ -> check bool "语法错误正确处理" true true
  | _ -> check bool "错误类型不正确" false true


let () = run "Parser单元测试" [
  ("parser工具函数测试", [test_parser_utils]);
  ("标识符解析测试", [test_parse_identifier]);
  ("字面量解析测试", [test_parse_literal]);
  ("token到二元运算符转换测试", [test_token_to_binary_op]);
  ("expect_token函数测试", [test_expect_token]);
  ("is_token函数测试", [test_is_token]);
  ("parser状态创建测试", [test_parser_state_creation]);
  ("parser异常测试", [test_parser_exceptions]);
]