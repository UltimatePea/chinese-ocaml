(** 骆言编译器模块单元测试 *)

open Alcotest
open Yyocamlc_lib.Compiler

(** 测试编译器选项 *)
let test_compiler_options () =
  let default_opts = default_options in
  let quiet_opts = quiet_options in
  check bool "默认选项不启用quiet模式" false default_opts.quiet_mode;
  check bool "安静选项启用quiet模式" true quiet_opts.quiet_mode

(** 测试简单编译 *)
let test_simple_compilation () =
  let source = "让 「变量」 为 四十二" in
  let result = compile_string quiet_options source in
  check bool "简单变量声明编译成功" true result

(** 测试基本表达式编译 *)
let test_basic_expressions () =
  let test_cases =
    [ ("让 「数字」 为 一", "数字常量编译"); ("让 「字符串」 为 『你好』", "字符串常量编译"); ("让 「布尔」 为 真", "布尔常量编译") ]
  in
  List.iter
    (fun (source, desc) ->
      let result = compile_string quiet_options source in
      check bool desc true result)
    test_cases

(** 测试空程序编译 *)
let test_empty_program () =
  let empty_source = "" in
  let result = compile_string quiet_options empty_source in
  check bool "空程序编译成功" true result

(** 测试编译器选项字段 *)
let test_compiler_option_fields () =
  let opts = default_options in
  check bool "show_tokens字段存在" true (match opts.show_tokens with _ -> true);
  check bool "show_ast字段存在" true (match opts.show_ast with _ -> true);
  check bool "check_only字段存在" true (match opts.check_only with _ -> true)

(** 测试错误处理 *)
let test_syntax_error () =
  let invalid_source = "让 = 无效语法" in
  let result = compile_string quiet_options invalid_source in
  check bool "语法错误应返回false" false result

(** 测试编译器阶段 *)
let test_compilation_phases () =
  let source = "让 「变量」 为 一" in
  let result = compile_string default_options source in
  check bool "编译阶段完整执行" true result

(** 测试不同数据类型 *)
let test_different_data_types () =
  let test_cases = [
    ("让 「整数」 为 四十二", "整数编译");
    ("让 「浮点数」 为 三点一四", "浮点数编译");
    ("让 「字符串」 为 『测试』", "字符串编译");
    ("让 「布尔」 为 假", "布尔值编译");
  ] in
  List.iter (fun (source, desc) ->
    let result = compile_string quiet_options source in
    check bool desc true result
  ) test_cases

(** 测试复杂表达式编译 *)
let test_complex_expression_compilation () =
  (* 测试复杂算术表达式 *)
  let complex_source = "让 「结果」 为 一加二" in
  let result = compile_string quiet_options complex_source in
  check bool "复杂表达式编译" true result

(** 测试条件表达式编译 *)
let test_conditional_compilation () =
  let conditional_source = "如果 真 那么 一 否则 二" in
  let result = compile_string quiet_options conditional_source in
  check bool "条件表达式编译" true result

(** 测试编译器选项模式 *)
let test_compiler_modes () = 
  let source = "让 「变量」 为 一" in
  let test_result = compile_string test_options source in
  let quiet_result = compile_string quiet_options source in
  let default_result = compile_string default_options source in
  check bool "测试模式编译" true test_result;
  check bool "安静模式编译" true quiet_result;
  check bool "默认模式编译" true default_result

(** 测试套件 *)
let () =
  run "骆言编译器模块测试"
    [
      ( "编译器选项",
        [
          test_case "编译器选项配置" `Quick test_compiler_options;
          test_case "编译器选项字段" `Quick test_compiler_option_fields;
          test_case "编译器模式测试" `Quick test_compiler_modes;
        ] );
      ( "基础编译功能",
        [
          test_case "简单编译" `Quick test_simple_compilation;
          test_case "基本表达式编译" `Quick test_basic_expressions;
          test_case "空程序编译" `Quick test_empty_program;
          test_case "编译阶段测试" `Quick test_compilation_phases;
        ] );
      ( "数据类型编译",
        [
          test_case "不同数据类型" `Quick test_different_data_types;
          test_case "复杂表达式编译" `Quick test_complex_expression_compilation;
          test_case "条件表达式编译" `Quick test_conditional_compilation;
        ] );
      ( "错误处理",
        [
          test_case "语法错误处理" `Quick test_syntax_error;
        ] );
    ]
