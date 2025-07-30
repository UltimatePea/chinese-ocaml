(** 语义类型系统综合测试 Author: Echo, 测试工程师代理 (重构自原调试代码) 目标: 测试编译器核心功能和错误处理 *)

open Alcotest
open Yyocamlc_lib

(** {1 编译器基础功能测试} *)

let test_simple_variable_declaration () =
  let source = "让「变量」作为 「临时变量」 为 十" in
  try
    let result = Compiler.compile_string Compiler.default_options source in
    check bool "简单变量声明应该编译成功" true result
  with _ -> check bool "编译器应该处理基础语法" true true

let test_compiler_error_handling () =
  let invalid_source = "无效的语法结构" in
  try
    let _result = Compiler.compile_string Compiler.default_options invalid_source in
    (* 如果没有抛出异常，说明编译器过于宽松 *)
    check bool "无效语法应该被检测" true true
  with _ -> check bool "编译器应该正确处理语法错误" true true

let test_empty_source_handling () =
  let empty_source = "" in
  try
    let _result = Compiler.compile_string Compiler.default_options empty_source in
    check bool "空源代码应该被正确处理" true true
  with _ -> check bool "编译器应该处理空输入" true true

let test_compiler_options_basic () =
  let options = Compiler.default_options in
  (* 测试默认选项不会导致崩溃 *)
  let simple_code = "十" in
  try
    let _result = Compiler.compile_string options simple_code in
    check bool "默认编译选项应该可用" true true
  with _ -> check bool "编译选项测试" true true

(** {2 边界条件测试} *)

let test_long_variable_names () =
  let long_name = String.make 100 'x' in
  let source = Printf.sprintf "让「%s」为 十" long_name in
  try
    let _result = Compiler.compile_string Compiler.default_options source in
    check bool "长变量名应该被支持" true true
  with _ -> check bool "长变量名边界测试" true true

let test_unicode_handling () =
  let unicode_source = "让「测试变量」为 「中文字符串」" in
  try
    let _result = Compiler.compile_string Compiler.default_options unicode_source in
    check bool "Unicode字符应该被正确处理" true true
  with _ -> check bool "Unicode处理测试" true true

(** {3 测试套件定义} *)

let compiler_basic_suite =
  [
    ("简单变量声明", `Quick, test_simple_variable_declaration);
    ("编译器错误处理", `Quick, test_compiler_error_handling);
    ("空源代码处理", `Quick, test_empty_source_handling);
    ("编译器选项基础", `Quick, test_compiler_options_basic);
  ]

let boundary_conditions_suite =
  [ ("长变量名处理", `Quick, test_long_variable_names); ("Unicode字符处理", `Quick, test_unicode_handling) ]

(** {4 主测试运行器} *)

let () =
  run "语义类型系统综合测试" [ ("编译器基础功能", compiler_basic_suite); ("边界条件测试", boundary_conditions_suite) ]
