(** 豫语编译器测试 *)

open Yyocamlc_lib
open Alcotest

(** 测试词法分析器 *)
let test_lexer () =
  let 输入 = "让 x = 42" in
  let 词元列表 = Lexer.词法分析 输入 "test" in
  let 期望词元 = [
    (Lexer.让关键字, { Lexer.行号 = 1; 列号 = 1; 文件名 = "test" });
    (Lexer.标识符词元 "x", { Lexer.行号 = 1; 列号 = 3; 文件名 = "test" });
    (Lexer.等号, { Lexer.行号 = 1; 列号 = 5; 文件名 = "test" });
    (Lexer.整数词元 42, { Lexer.行号 = 1; 列号 = 7; 文件名 = "test" });
    (Lexer.文件结束, { Lexer.行号 = 1; 列号 = 9; 文件名 = "test" });
  ] in
  check int "词元数量" (List.length 期望词元) (List.length 词元列表)

(** 测试解析器 *)
let test_parser () =
  let 输入 = "让 x = 42" in
  let 词元列表 = Lexer.词法分析 输入 "test" in
  let 程序 = Parser.解析程序 词元列表 in
  match 程序 with
  | [Ast.让语句 ("x", Ast.字面量表达式 (Ast.整数字面量 42))] -> ()
  | _ -> failwith "解析结果不匹配"

(** 测试基本表达式求值 *)
let test_basic_evaluation () =
  let 表达式 = Ast.二元运算表达式 (
    Ast.字面量表达式 (Ast.整数字面量 1),
    Ast.加法,
    Ast.字面量表达式 (Ast.整数字面量 2)
  ) in
  let 结果 = Codegen.求值表达式 [] 表达式 in
  match 结果 with
  | Codegen.整数值 3 -> ()
  | _ -> failwith "求值结果不正确"

(** 测试套件 *)
let () =
  run "豫语编译器测试" [
    test_case "词法分析器" `Quick test_lexer;
    test_case "语法分析器" `Quick test_parser;
    test_case "基本表达式求值" `Quick test_basic_evaluation;
  ]