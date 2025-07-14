(** 测试wenyan风格变量声明语法 *)

open Alcotest
open Yyocamlc_lib

(** 测试wenyan风格"设"关键字变量声明 *)
let test_she_variable_declaration () =
  let input = "设数值为42" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [Ast.LetStmt ("数值", Ast.LitExpr (Ast.IntLit 42))] -> ()
  | _ -> failwith "wenyan风格'设'变量声明解析失败"

(** 测试混合使用传统语法和wenyan语法 *)
let test_mixed_syntax () =
  let input = "让 传统 = 100\n设wenyan为200" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [Ast.LetStmt ("传统", Ast.LitExpr (Ast.IntLit 100));
     Ast.LetStmt ("wenyan", Ast.LitExpr (Ast.IntLit 200))] -> ()
  | _ -> failwith "混合语法解析失败"

(** 测试wenyan风格关键字词法分析 *)
let test_wenyan_keywords_lexer () =
  let input = "吾有 设 为 名曰 其值 也 乃" in
  let token_list = Lexer.tokenize input "test" in
  let expected_keywords = [
    Lexer.HaveKeyword;
    Lexer.SetKeyword;
    Lexer.AsForKeyword;
    Lexer.NameKeyword;
    Lexer.ValueKeyword;
    Lexer.AlsoKeyword;
    Lexer.ThenGetKeyword;
  ] in
  let actual_keywords = List.map (fun (token, _) -> token) token_list in
  let wenyan_declaration_tokens = List.filter (function
    | Lexer.HaveKeyword | Lexer.SetKeyword | Lexer.AsForKeyword
    | Lexer.NameKeyword | Lexer.ValueKeyword | Lexer.AlsoKeyword
    | Lexer.ThenGetKeyword -> true
    | _ -> false) actual_keywords in
  check int "wenyan变量声明关键字数量" (List.length expected_keywords) (List.length wenyan_declaration_tokens)

(** 测试wenyan风格字符串变量声明 *)
let test_she_string_declaration () =
  let input = "设问候为『你好世界』" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [Ast.LetStmt ("问候", Ast.LitExpr (Ast.StringLit "你好世界"))] -> ()
  | _ -> failwith "wenyan风格字符串变量声明解析失败"

(** 测试wenyan风格复杂表达式声明 *)
let test_she_complex_expression () =
  let input = "设计算为5 + 3 * 2" in
  let token_list = Lexer.tokenize input "test" in
  let program = Parser.parse_program token_list in
  match program with
  | [Ast.LetStmt ("计算", _)] -> () (* 只要能解析出LetStmt就行，具体表达式结构暂不验证 *)
  | _ -> failwith "wenyan风格复杂表达式声明解析失败"

(** 测试套件 *)
let tests = [
  ("基础功能", [
    ("wenyan风格'设'变量声明", `Quick, test_she_variable_declaration);
    ("混合语法使用", `Quick, test_mixed_syntax);
    ("wenyan关键字词法分析", `Quick, test_wenyan_keywords_lexer);
    ("wenyan字符串变量声明", `Quick, test_she_string_declaration);
    ("wenyan复杂表达式声明", `Quick, test_she_complex_expression);
  ])
]

let () = run "Wenyan变量声明语法测试" tests