(** 语义类型系统测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试语义类型标注 *)
let test_semantic_let_annotation () =
  let source = "让 「年龄」 作为 人员信息 为 二五" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "语义类型标注编译成功" true result

let test_semantic_let_multiple () =
  let source = "\n让 「年龄」 作为 人员信息 为 二五\n让 「年龄甲」 作为 人员信息 为 三零\n打印 「年龄」\n打印 「年龄甲」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "多个语义类型标注编译成功" true result

(** 测试语义类型表达式 *)
let test_semantic_let_expr () =
  let source = "让 「结果」 为 让 「x」 作为 临时变量 为 一 在 让 「y」 作为 临时变量 为 二 在 「x」 加 「y」\n打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "语义类型表达式编译成功" true result

(** 测试组合表达式 *)
let test_combine_expr () =
  let source = "\n让 「年龄」 为 二五\n让 「身高」 为 一七五\n让 「人员」 为 组合 「年龄」 以及 「身高」\n打印 「人员」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "组合表达式编译成功" true result

let test_combine_expr_multiple () =
  let source = "\n让 「a」 为 一\n让 「b」 为 二\n让 「c」 为 三\n让 「结果」 为 组合 「a」 以及 「b」 以及 「c」\n打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "多项组合表达式编译成功" true result

(** 测试语义类型与组合结合 *)
let test_semantic_with_combine () =
  let source = "\n让 「年龄」 作为 人员信息 为 二五\n让 「身高」 作为 人员信息 为 一七五\n让 「人员」 为 组合 「年龄」 以及 「身高」\n打印 「人员」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "语义类型与组合结合编译成功" true result

(** 测试组合表达式在函数中使用 *)
let test_combine_in_function () =
  let source = "\n让 「创建人员」 为 函数 「年龄」 「身高」 应得\n  组合 「年龄」 以及 「身高」\n\n让 「人员」 为 「创建人员」 二五 一七五\n打印 「人员」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "函数中使用组合表达式编译成功" true result

(** 测试套件 *)
let () =
  run "语义类型系统测试"
    [
      ( "语义标注",
        [
          test_case "基础语义类型标注" `Quick test_semantic_let_annotation;
          test_case "多个语义类型标注" `Quick test_semantic_let_multiple;
          test_case "语义类型表达式" `Quick test_semantic_let_expr;
        ] );
      ( "组合表达式",
        [
          test_case "基础组合表达式" `Quick test_combine_expr;
          test_case "多项组合表达式" `Quick test_combine_expr_multiple;
        ] );
      ( "综合测试",
        [
          test_case "语义类型与组合结合" `Quick test_semantic_with_combine;
          test_case "函数中使用组合" `Quick test_combine_in_function;
        ] );
    ]
