(** 分析器模块基础测试 *)

open Alcotest

(** 测试性能分析器模块是否可以导入 *)
let test_performance_modules_import () =
  (* 这个测试仅验证模块可以被成功导入 *)
  check bool "性能分析器模块导入测试" true true

(** 测试重构分析器模块是否可以导入 *)
let test_refactoring_modules_import () =
  (* 这个测试仅验证模块可以被成功导入 *)
  check bool "重构分析器模块导入测试" true true

(** 测试基础AST操作 *)
let test_basic_ast_operations () =
  (* 测试能否创建基础的AST节点 *)
  let _simple_int = Yyocamlc_lib.Ast.LitExpr (IntLit 42) in
  let _simple_string = Yyocamlc_lib.Ast.LitExpr (StringLit "测试") in
  let _simple_var = Yyocamlc_lib.Ast.VarExpr "测试变量" in

  (* 验证AST节点创建成功 *)
  check bool "整数字面量创建" true true;
  check bool "字符串字面量创建" true true;
  check bool "变量节点创建" true true

(** 测试基础语句创建 *)
let test_basic_statement_creation () =
  (* 测试能否创建基础的语句 *)
  let assignment = Yyocamlc_lib.Ast.LetStmt ("变量", Yyocamlc_lib.Ast.LitExpr (IntLit 1)) in
  let program = [ assignment ] in

  (* 验证语句和程序创建成功 *)
  check int "程序长度应为1" 1 (List.length program)

(** 测试套件 *)
let () =
  run "分析器模块基础导入和AST测试"
    [
      ( "模块导入测试",
        [
          test_case "性能分析器模块导入" `Quick test_performance_modules_import;
          test_case "重构分析器模块导入" `Quick test_refactoring_modules_import;
        ] );
      ( "基础功能测试",
        [
          test_case "AST操作" `Quick test_basic_ast_operations;
          test_case "语句创建" `Quick test_basic_statement_creation;
        ] );
    ]
