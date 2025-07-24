(** 字面量解析模块基础测试 - Fix #1034 Phase 1
    验证从大型模块分离出的parser_literals模块功能完整性 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_literals

(** 创建解析器状态辅助函数 *)
let create_parser_state tokens =
  let positioned_tokens = Array.of_list (List.mapi (fun i token -> 
    (token, { line = 1; column = i + 1; filename = "test" })) tokens) in
  { token_array = positioned_tokens; array_length = Array.length positioned_tokens; current_pos = 0 }

(** 测试整数字面量解析 *)
let test_int_literal () =
  let tokens = [IntToken(42); EOF] in
  let state = create_parser_state tokens in
  let expr, _new_state = parse_literal_expr state in
  check (Alcotest.string) "int literal" "(Ast.LitExpr (Ast.IntLit 42))" (show_expr expr)

(** 测试中文数字字面量解析 *)  
let test_chinese_int_literal () =
  let tokens = [ChineseNumberToken("五"); EOF] in
  let state = create_parser_state tokens in
  let expr, _new_state = parse_literal_expr state in
  check (Alcotest.string) "chinese int literal" "(Ast.LitExpr (Ast.IntLit 5))" (show_expr expr)

(** 测试字符串字面量解析 *)
let test_string_literal () =
  let tokens = [StringToken("骆言"); EOF] in
  let state = create_parser_state tokens in
  let expr, _new_state = parse_literal_expr state in
  check (Alcotest.string) "string literal" "(Ast.LitExpr (Ast.StringLit \"\\233\\170\\134\\232\\168\\128\"))" (show_expr expr)

(** 测试布尔字面量解析 *)
let test_bool_literal () =
  let tokens = [TrueKeyword; EOF] in
  let state = create_parser_state tokens in
  let expr, _new_state = parse_literal_expr state in
  check (Alcotest.string) "bool literal" "(Ast.LitExpr (Ast.BoolLit true))" (show_expr expr)

(** 测试字面量token识别 *)
let test_is_literal_token () =
  check (Alcotest.bool) "int token" true (is_literal_token (IntToken 42));
  check (Alcotest.bool) "string token" true (is_literal_token (StringToken "test"));
  check (Alcotest.bool) "bool token" true (is_literal_token TrueKeyword);
  check (Alcotest.bool) "non-literal token" false (is_literal_token (QuotedIdentifierToken "x"))

(** 测试字面量类型名称获取 *)
let test_literal_type_names () =
  check (Alcotest.string) "int type name" "整数" (get_literal_type_name (IntToken 42));
  check (Alcotest.string) "string type name" "字符串" (get_literal_type_name (StringToken "test"));
  check (Alcotest.string) "bool type name" "布尔值" (get_literal_type_name TrueKeyword)

let tests = [
  ("整数字面量解析", `Quick, test_int_literal);
  ("中文数字字面量解析", `Quick, test_chinese_int_literal);  
  ("字符串字面量解析", `Quick, test_string_literal);
  ("布尔字面量解析", `Quick, test_bool_literal);
  ("字面量token识别", `Quick, test_is_literal_token);
  ("字面量类型名称", `Quick, test_literal_type_names);
]

let () = Alcotest.run "Parser Literals Basic Tests" [ ("parser_literals", tests) ]