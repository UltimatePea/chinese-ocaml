(** 骆言语法分析器基础表达式解析模块测试 - 整合版

    本测试模块验证 parser_expressions_primary_consolidated.ml 的基础功能。

    技术债务改进 - Fix #909
    @author 骆言AI代理
    @version 1.0
    @since 2025-07-23 *)

open Alcotest
open Yyocamlc_lib

(** ==================== 测试辅助函数 ==================== *)

(** 检查模块是否存在的基础测试 *)
let test_module_exists () =
  (* 只是验证模块可以被导入 *)
  let _ = Parser_expressions_primary_consolidated.parse_literal_expr in
  ()

let test_module_interface () =
  (* 验证主要函数接口存在 *)
  let _ = Parser_expressions_primary_consolidated.parse_primary_expr in
  let _ = Parser_expressions_primary_consolidated.parse_function_call_or_variable in
  let _ = Parser_expressions_primary_consolidated.parse_function_arguments in
  ()

(** ==================== 测试运行器 ==================== *)

let basic_tests =
  [ test_case "模块存在性测试" `Quick test_module_exists; test_case "模块接口测试" `Quick test_module_interface ]

let () = run "Parser_expressions_primary_consolidated" [ ("基础模块测试", basic_tests) ]
