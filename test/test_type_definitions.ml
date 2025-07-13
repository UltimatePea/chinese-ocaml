(** 类型定义测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试类型别名解析 *)
let test_type_alias () =
  let source = "类型 「整数别名」 = 整数" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "类型别名编译成功" true result

(** 测试简单变体类型解析 *)
let test_simple_variant () =
  let source = "类型 「选项」 = | 「无」 | 「有」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "简单变体类型编译成功" true result

(** 测试带参数的变体类型解析 *)
let test_variant_with_params () =
  let source = "类型 「选项」 = | 「无」 | 「有」 of 整数" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "带参数变体类型编译成功" true result

(** 测试复杂变体类型解析 *)
let test_complex_variant () =
  let source = "类型 「二叉树」 = | 「空」 | 「节点」 of 整数" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "复杂变体类型编译成功" true result

(** 测试构造器表达式基础功能 *)
let test_constructor_expression_basic () =
  let source = "
类型 「选项」 = | 「无」 | 「有」 of 整数
让 「构造器值」 = 「无」
打印 「构造器值」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "基础构造器表达式编译成功" true result

(** 测试带参数的构造器表达式 *)
let test_constructor_with_params () =
  let source = "
类型 「选项」 = | 「无」 | 「有」 of 整数
让 「带参数构造器」 = 「有」 42
打印 「带参数构造器」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "带参数构造器表达式编译成功" true result

(** 测试基础构造器模式匹配 *)
let test_constructor_pattern_matching_basic () =
  let source = "
类型 「选项」 = | 「无」 | 「有」 of 整数
让 「值1」 = 「无」
让 「值2」 = 「有」 42
让 「结果1」 = 匹配 「值1」 与 | 「无」 -> \"空值\" | 「有」 _ -> \"非空\"
让 「结果2」 = 匹配 「值2」 与 | 「无」 -> \"空值\" | 「有」 _ -> \"非空\"
打印 「结果1」
打印 「结果2」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "基础构造器模式匹配编译成功" true result

(** 测试带参数的构造器模式匹配 *)
let test_constructor_pattern_matching_with_params () =
  let source = "
类型 「选项」 = | 「无」 | 「有」 of 整数
让 「值」 = 「有」 42
让 「结果」 = 匹配 「值」 与 | 「无」 -> 0 | 「有」 「n」 -> 「n」
打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "带参数构造器模式匹配编译成功" true result

(** 测试嵌套构造器模式匹配 *)
let test_constructor_pattern_matching_nested () =
  let source = "
类型 「二叉树」 = | 「空」 | 「节点」 of 整数
让 「树」 = 「节点」 5
让 「结果」 = 匹配 「树」 与 
  | 「空」 -> 0 
  | 「节点」 「值」 -> 「值」
打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "嵌套构造器模式匹配编译成功" true result

(** 主测试套件 *)
let () =
  run "类型定义测试" [
    "基础功能", [
      test_case "类型别名" `Quick test_type_alias;
      test_case "简单变体类型" `Quick test_simple_variant;
      test_case "带参数变体类型" `Quick test_variant_with_params;
      test_case "复杂变体类型" `Quick test_complex_variant;
    ];
    "构造器表达式", [
      test_case "基础构造器表达式" `Quick test_constructor_expression_basic;
      test_case "带参数构造器表达式" `Quick test_constructor_with_params;
    ];
    "构造器模式匹配", [
      test_case "基础构造器模式匹配" `Quick test_constructor_pattern_matching_basic;
      test_case "带参数构造器模式匹配" `Quick test_constructor_pattern_matching_with_params;
      test_case "嵌套构造器模式匹配" `Quick test_constructor_pattern_matching_nested;
    ];
  ]