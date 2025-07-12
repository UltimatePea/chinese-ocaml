(** 类型定义测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试类型别名解析 *)
let test_type_alias () =
  let source = "类型 整数别名 = 整数" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "类型别名编译成功" true result

(** 测试简单变体类型解析 *)
let test_simple_variant () =
  let source = "类型 选项 = | 无 | 有" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "简单变体类型编译成功" true result

(** 测试带参数的变体类型解析 *)
let test_variant_with_params () =
  let source = "类型 选项 = | 无 | 有 of 整数" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "带参数变体类型编译成功" true result

(** 测试复杂变体类型解析 *)
let test_complex_variant () =
  let source = "类型 二叉树 = | 空 | 节点 of 整数" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "复杂变体类型编译成功" true result

(** 主测试套件 *)
let () =
  run "类型定义测试" [
    "基础功能", [
      test_case "类型别名" `Quick test_type_alias;
      test_case "简单变体类型" `Quick test_simple_variant;
      test_case "带参数变体类型" `Quick test_variant_with_params;
      test_case "复杂变体类型" `Quick test_complex_variant;
    ];
  ]