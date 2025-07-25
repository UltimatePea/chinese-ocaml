(** 骆言语法分析器语句解析模块增强测试覆盖 - Fix #1304
    
    本测试文件专门提升 parser_statements.ml 的测试覆盖率，
    重点测试边界情况、错误处理和复杂语句解析场景。
    
    改进目标：提升测试覆盖率从22%至50%
    
    @author 骆言编译器测试增强团队 - Issue #1304
    @version 1.0
    @since 2025-07-25 测试覆盖率提升改进 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser_utils
open Yyocamlc_lib.Parser_statements

(** 测试工具模块 *)
module TestHelpers = struct
  (** 创建测试用的parser state *)
  let create_state tokens = create_parser_state tokens
  
  (** 测试位置创建 *)
  let test_pos = { line = 1; column = 1; filename = "test_enhanced.ml" }
  
  (** 断言语法错误 *)
  let assert_syntax_error f =
    try
      ignore (f ());
      false
    with
    | SyntaxError _ -> true
    | _ -> false
    
  (** 简单token列表创建 *)
  let simple_tokens tokens = List.map (fun t -> (t, test_pos)) tokens
end

(** 测试skip_newlines函数的边界情况 *)
let test_skip_newlines_edge_cases () =
  let module TH = TestHelpers in
  
  (* 测试多个连续换行符 *)
  let tokens = TH.simple_tokens [Newline; Newline; Newline; LetKeyword; EOF] in
  let state = TH.create_state tokens in
  let state_after = skip_newlines state in
  let token, _ = current_token state_after in
  let is_let_keyword = match token with LetKeyword -> true | _ -> false in
  check bool "跳过多个换行符后应到达LetKeyword" true is_let_keyword;
  
  (* 测试没有换行符的情况 *)
  let tokens2 = TH.simple_tokens [LetKeyword; EOF] in
  let state2 = TH.create_state tokens2 in
  let state_after2 = skip_newlines state2 in
  let token2, _ = current_token state_after2 in
  let is_let_keyword2 = match token2 with LetKeyword -> true | _ -> false in
  check bool "没有换行符时应保持原位置" true is_let_keyword2

(** 测试宏参数解析的复杂情况 *)
let test_macro_params_complex () =
  let module TH = TestHelpers in
  
  (* 测试混合参数类型 *)
  let tokens = TH.simple_tokens [
    QuotedIdentifierToken "参数1"; Colon; QuotedIdentifierToken "表达式"; Comma;
    QuotedIdentifierToken "参数2"; Colon; QuotedIdentifierToken "语句"; Comma;
    QuotedIdentifierToken "参数3"; Colon; QuotedIdentifierToken "类型";
    RightParen; EOF
  ] in
  let state = TH.create_state tokens in
  let params, _final_state = parse_macro_params [] state in
  check int "应解析出3个参数" 3 (List.length params);
  
  (* 测试参数类型验证 *)
  let param_names = List.map (function
    | ExprParam n -> "表达式:" ^ n
    | StmtParam n -> "语句:" ^ n  
    | TypeParam n -> "类型:" ^ n
  ) params in
  let expected_names = ["表达式:参数1"; "语句:参数2"; "类型:参数3"] in
  let param_lists_equal = expected_names = param_names in
  check bool "参数类型和名称应正确" true param_lists_equal

(** 测试宏参数解析的错误情况 *)
let test_macro_params_error_cases () =
  let module TH = TestHelpers in
  
  (* 测试无效参数类型 *)
  let tokens = TH.simple_tokens [
    QuotedIdentifierToken "参数"; Colon; QuotedIdentifierToken "无效类型"; EOF
  ] in
  let state = TH.create_state tokens in
  let has_error = TH.assert_syntax_error (fun () -> parse_macro_params [] state) in
  check bool "无效参数类型应抛出语法错误" true has_error;
  
  (* 测试缺少参数名 *)
  let tokens2 = TH.simple_tokens [Colon; QuotedIdentifierToken "表达式"; EOF] in
  let state2 = TH.create_state tokens2 in
  let has_error2 = TH.assert_syntax_error (fun () -> parse_macro_params [] state2) in
  check bool "缺少参数名应抛出语法错误" true has_error2

(** 测试单个语句解析的复杂情况 *)
let test_statement_parsing_complex () =
  let module TH = TestHelpers in
  
  (* 测试简单Let语句解析 *)
  let tokens = TH.simple_tokens [
    LetKeyword; QuotedIdentifierToken "变量"; AsForKeyword; IntToken 42; EOF
  ] in
  let state = TH.create_state tokens in
  let stmt, _final_state = parse_statement state in
  let is_let_stmt = match stmt with LetStmt _ -> true | _ -> false in
  check bool "应解析出Let语句" true is_let_stmt

(** 测试语句终结符跳过功能 *)
let test_statement_terminator_skipping () =
  let module TH = TestHelpers in
  
  (* 测试跳过分号终结符 *)
  let tokens = TH.simple_tokens [Semicolon; LetKeyword; EOF] in
  let state = TH.create_state tokens in
  let state_after = skip_optional_statement_terminator state in
  let token, _ = current_token state_after in
  let is_let_keyword = match token with LetKeyword -> true | _ -> false in
  check bool "应跳过分号并到达Let关键字" true is_let_keyword

(** 测试套件组织 *)
let enhanced_coverage_tests = [
  test_case "跳过换行符边界情况测试" `Quick test_skip_newlines_edge_cases;
  test_case "宏参数解析复杂情况测试" `Quick test_macro_params_complex;
  test_case "宏参数解析错误情况测试" `Quick test_macro_params_error_cases;
  test_case "单个语句解析复杂情况测试" `Quick test_statement_parsing_complex;
  test_case "语句终结符跳过功能测试" `Quick test_statement_terminator_skipping;
]

(** 运行测试 *)
let () =
  run "骆言Parser语句模块增强测试覆盖 - Fix #1304" [
    ("增强测试覆盖", enhanced_coverage_tests);
  ]