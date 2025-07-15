(** 骆言语法分析器单元测试 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser

(* 辅助函数：创建测试用的parser状态 *)
let create_test_parser_state tokens =
  let state = create_parser_state tokens in
  state

(* 辅助函数：从字符串创建tokens *)
let tokenize_string input =
  let tokens = ref [] in
  let token_stream = tokenize input in
  let rec collect_tokens () =
    match token_stream () with
    | Some token -> tokens := token :: !tokens; collect_tokens ()
    | None -> List.rev !tokens
  in
  collect_tokens ()

(* 测试基础parser工具函数 *)
let test_parser_utils () =
  let tokens = [(Int 42, (1, 1)); (Plus, (1, 3)); (Int 24, (1, 5))] in
  let state = create_test_parser_state tokens in
  
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
  let state = create_test_parser_state tokens in
  
  let identifier, new_state = parse_identifier state in
  check string "标识符解析测试" "变量名" identifier;
  
  let current, _pos = current_token new_state in
  check bool "标识符解析后状态测试" true (current = Plus)

(* 测试字面量解析 *)
let test_parse_literal () =
  (* 测试整数字面量 *)
  let int_tokens = [(Int 42, (1, 1))] in
  let int_state = create_test_parser_state int_tokens in
  let int_expr, _int_state = parse_literal int_state in
  check bool "整数字面量解析测试" true (int_expr = IntExpr 42);
  
  (* 测试浮点数字面量 *)
  let float_tokens = [(Float 3.14, (1, 1))] in
  let float_state = create_test_parser_state float_tokens in
  let float_expr, _float_state = parse_literal float_state in
  check bool "浮点数字面量解析测试" true (float_expr = FloatExpr 3.14);
  
  (* 测试字符串字面量 *)
  let string_tokens = [(String "测试", (1, 1))] in
  let string_state = create_test_parser_state string_tokens in
  let string_expr, _string_state = parse_literal string_state in
  check bool "字符串字面量解析测试" true (string_expr = StringExpr "测试");
  
  (* 测试布尔字面量 *)
  let bool_tokens = [(Bool true, (1, 1))] in
  let bool_state = create_test_parser_state bool_tokens in
  let bool_expr, _bool_state = parse_literal bool_state in
  check bool "布尔字面量解析测试" true (bool_expr = BoolExpr true)

(* 测试简单表达式解析 *)
let test_simple_expression_parsing () =
  (* 测试整数表达式 *)
  let tokens = [(Int 42, (1, 1)); (EOF, (1, 3))] in
  let state = create_test_parser_state tokens in
  let expr, _new_state = parse_expression state in
  check bool "简单整数表达式解析" true (expr = IntExpr 42);
  
  (* 测试变量表达式 *)
  let var_tokens = [(Identifier "x", (1, 1)); (EOF, (1, 2))] in
  let var_state = create_test_parser_state var_tokens in
  let var_expr, _var_state = parse_expression var_state in
  check bool "变量表达式解析" true (var_expr = VarExpr "x")

(* 测试二元运算表达式解析 *)
let test_binary_expression_parsing () =
  (* 测试加法表达式 *)
  let add_tokens = [(Int 1, (1, 1)); (Plus, (1, 3)); (Int 2, (1, 5)); (EOF, (1, 7))] in
  let add_state = create_test_parser_state add_tokens in
  let add_expr, _add_state = parse_expression add_state in
  check bool "加法表达式解析" true (add_expr = BinOpExpr (Add, IntExpr 1, IntExpr 2));
  
  (* 测试减法表达式 *)
  let sub_tokens = [(Int 5, (1, 1)); (Minus, (1, 3)); (Int 3, (1, 5)); (EOF, (1, 7))] in
  let sub_state = create_test_parser_state sub_tokens in
  let sub_expr, _sub_state = parse_expression sub_state in
  check bool "减法表达式解析" true (sub_expr = BinOpExpr (Sub, IntExpr 5, IntExpr 3));
  
  (* 测试乘法表达式 *)
  let mul_tokens = [(Int 2, (1, 1)); (Star, (1, 3)); (Int 3, (1, 5)); (EOF, (1, 7))] in
  let mul_state = create_test_parser_state mul_tokens in
  let mul_expr, _mul_state = parse_expression mul_state in
  check bool "乘法表达式解析" true (mul_expr = BinOpExpr (Mul, IntExpr 2, IntExpr 3))

(* 测试比较运算表达式解析 *)
let test_comparison_expression_parsing () =
  (* 测试相等比较 *)
  let eq_tokens = [(Int 1, (1, 1)); (Equal, (1, 3)); (Int 1, (1, 5)); (EOF, (1, 7))] in
  let eq_state = create_test_parser_state eq_tokens in
  let eq_expr, _eq_state = parse_expression eq_state in
  check bool "相等比较表达式解析" true (eq_expr = BinOpExpr (Equal, IntExpr 1, IntExpr 1));
  
  (* 测试小于比较 *)
  let lt_tokens = [(Int 1, (1, 1)); (LessThan, (1, 3)); (Int 2, (1, 5)); (EOF, (1, 7))] in
  let lt_state = create_test_parser_state lt_tokens in
  let lt_expr, _lt_state = parse_expression lt_state in
  check bool "小于比较表达式解析" true (lt_expr = BinOpExpr (LessThan, IntExpr 1, IntExpr 2))

(* 测试条件表达式解析 *)
let test_conditional_expression_parsing () =
  (* 基础条件表达式 *)
  let if_tokens = [
    (If, (1, 1)); (Bool true, (1, 3)); (Then, (1, 8)); (Int 1, (1, 13));
    (Else, (1, 15)); (Int 0, (1, 20)); (EOF, (1, 22))
  ] in
  let if_state = create_test_parser_state if_tokens in
  let if_expr, _if_state = parse_expression if_state in
  check bool "条件表达式解析" true (if_expr = IfExpr (BoolExpr true, IntExpr 1, IntExpr 0))

(* 测试函数相关表达式解析 *)
let test_function_expression_parsing () =
  (* 简单函数定义 *)
  let fun_tokens = [
    (Fun, (1, 1)); (Identifier "x", (1, 5)); (Arrow, (1, 7)); (Identifier "x", (1, 10)); (EOF, (1, 12))
  ] in
  let fun_state = create_test_parser_state fun_tokens in
  let fun_expr, _fun_state = parse_expression fun_state in
  check bool "函数表达式解析" true (fun_expr = FunExpr (["x"], VarExpr "x"))

(* 测试Let表达式解析 *)
let test_let_expression_parsing () =
  (* 基础Let表达式 *)
  let let_tokens = [
    (Let, (1, 1)); (Identifier "x", (1, 5)); (Equal, (1, 7)); (Int 42, (1, 9));
    (In, (1, 12)); (Identifier "x", (1, 15)); (EOF, (1, 17))
  ] in
  let let_state = create_test_parser_state let_tokens in
  let let_expr, _let_state = parse_expression let_state in
  check bool "Let表达式解析" true (let_expr = LetExpr ("x", IntExpr 42, VarExpr "x"))

(* 测试语句解析 *)
let test_statement_parsing () =
  (* Let语句 *)
  let let_stmt_tokens = [
    (Let, (1, 1)); (Identifier "x", (1, 5)); (Equal, (1, 7)); (Int 42, (1, 9)); (EOF, (1, 12))
  ] in
  let let_stmt_state = create_test_parser_state let_stmt_tokens in
  let let_stmt, _let_stmt_state = parse_statement let_stmt_state in
  check bool "Let语句解析" true (let_stmt = LetStmt ("x", IntExpr 42));
  
  (* 表达式语句 *)
  let expr_stmt_tokens = [(Int 42, (1, 1)); (EOF, (1, 3))] in
  let expr_stmt_state = create_test_parser_state expr_stmt_tokens in
  let expr_stmt, _expr_stmt_state = parse_statement expr_stmt_state in
  check bool "表达式语句解析" true (expr_stmt = ExprStmt (IntExpr 42))

(* 测试程序解析 *)
let test_program_parsing () =
  (* 简单程序 *)
  let program_tokens = [
    (Let, (1, 1)); (Identifier "x", (1, 5)); (Equal, (1, 7)); (Int 42, (1, 9));
    (Let, (2, 1)); (Identifier "y", (2, 5)); (Equal, (2, 7)); (Int 24, (2, 9));
    (EOF, (2, 12))
  ] in
  let program_state = create_test_parser_state program_tokens in
  let program, _program_state = parse_program program_state in
  
  check int "程序语句数量" 2 (List.length program);
  
  (* 检查第一个语句 *)
  let first_stmt = List.hd program in
  check bool "程序第一个语句" true (first_stmt = LetStmt ("x", IntExpr 42));
  
  (* 检查第二个语句 *)
  let second_stmt = List.nth program 1 in
  check bool "程序第二个语句" true (second_stmt = LetStmt ("y", IntExpr 24))

(* 测试错误处理 *)
let test_error_handling () =
  (* 测试语法错误 *)
  try
    let invalid_tokens = [(Plus, (1, 1)); (EOF, (1, 2))] in
    let invalid_state = create_test_parser_state invalid_tokens in
    let _expr, _state = parse_expression invalid_state in
    check bool "语法错误应该被捕获" false true
  with
  | SyntaxError _ -> check bool "语法错误正确处理" true true
  | _ -> check bool "错误类型不正确" false true

(* 测试token到二元运算符的转换 *)
let test_token_to_binary_op () =
  check bool "加号转换" true (token_to_binary_op Plus = Add);
  check bool "减号转换" true (token_to_binary_op Minus = Sub);
  check bool "乘号转换" true (token_to_binary_op Star = Mul);
  check bool "除号转换" true (token_to_binary_op Slash = Div);
  check bool "等号转换" true (token_to_binary_op Equal = Equal);
  check bool "小于号转换" true (token_to_binary_op LessThan = LessThan);
  check bool "大于号转换" true (token_to_binary_op GreaterThan = GreaterThan)

(* 测试expect_token函数 *)
let test_expect_token () =
  let tokens = [(Int 42, (1, 1)); (Plus, (1, 3)); (EOF, (1, 5))] in
  let state = create_test_parser_state tokens in
  
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
  let state = create_test_parser_state tokens in
  
  check bool "is_token匹配测试" true (is_token (Int 42) state);
  check bool "is_token不匹配测试" false (is_token Plus state)

(* 测试套件 *)
let test_suite = [
  ("parser工具函数测试", `Quick, test_parser_utils);
  ("标识符解析测试", `Quick, test_parse_identifier);
  ("字面量解析测试", `Quick, test_parse_literal);
  ("简单表达式解析测试", `Quick, test_simple_expression_parsing);
  ("二元运算表达式解析测试", `Quick, test_binary_expression_parsing);
  ("比较运算表达式解析测试", `Quick, test_comparison_expression_parsing);
  ("条件表达式解析测试", `Quick, test_conditional_expression_parsing);
  ("函数表达式解析测试", `Quick, test_function_expression_parsing);
  ("Let表达式解析测试", `Quick, test_let_expression_parsing);
  ("语句解析测试", `Quick, test_statement_parsing);
  ("程序解析测试", `Quick, test_program_parsing);
  ("错误处理测试", `Quick, test_error_handling);
  ("token到二元运算符转换测试", `Quick, test_token_to_binary_op);
  ("expect_token函数测试", `Quick, test_expect_token);
  ("is_token函数测试", `Quick, test_is_token);
]

let () = run "Parser单元测试" test_suite