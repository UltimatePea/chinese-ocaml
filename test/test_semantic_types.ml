(** 语义类型系统测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试语义类型标注 *)
let test_semantic_let_annotation () =
  let source = "让 年龄 作为 人员信息 = 25" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "语义类型标注编译成功" true result

let test_semantic_let_multiple () =
  let source = "
让 年龄 作为 人员信息 = 25
让 姓名 作为 人员信息 = \"张三\"
让 身高 作为 人员信息 = 175.5
打印 年龄
打印 姓名
打印 身高" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "多个语义类型标注编译成功" true result

(** 测试语义类型表达式 *)
let test_semantic_let_expr () =
  let source = "让 结果 = 让 x 作为 临时变量 = 10 在 让 y 作为 临时变量 = 20 在 x + y
打印 结果" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "语义类型表达式编译成功" true result

(** 测试组合表达式 *)
let test_combine_expr () =
  let source = "
让 年龄 = 25
让 姓名 = \"张三\"
让 人员 = 组合 年龄 以及 姓名
打印 人员" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "组合表达式编译成功" true result

let test_combine_expr_multiple () =
  let source = "
让 a = 1
让 b = 2
让 c = 3
让 结果 = 组合 a 以及 b 以及 c
打印 结果" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "多项组合表达式编译成功" true result

(** 测试语义类型与组合结合 *)
let test_semantic_with_combine () =
  let source = "
让 年龄 作为 人员信息 = 25
让 姓名 作为 人员信息 = \"张三\"
让 身高 作为 人员信息 = 175.5
让 人员 = 组合 年龄 以及 姓名 以及 身高
打印 人员" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "语义类型与组合结合编译成功" true result

(** 测试组合表达式在函数中使用 *)
let test_combine_in_function () =
  let source = "
让 创建人员 = 函数 name age ->
  组合 name 以及 age

让 人员 = 创建人员 \"李四\" 30
打印 人员" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "函数中使用组合表达式编译成功" true result

(** 测试套件 *)
let () =
  run "语义类型系统测试" [
    ("语义标注", [
      test_case "基础语义类型标注" `Quick test_semantic_let_annotation;
      test_case "多个语义类型标注" `Quick test_semantic_let_multiple;
      test_case "语义类型表达式" `Quick test_semantic_let_expr;
    ]);
    ("组合表达式", [
      test_case "基础组合表达式" `Quick test_combine_expr;
      test_case "多项组合表达式" `Quick test_combine_expr_multiple;
    ]);
    ("综合测试", [
      test_case "语义类型与组合结合" `Quick test_semantic_with_combine;
      test_case "函数中使用组合" `Quick test_combine_in_function;
    ]);
  ]