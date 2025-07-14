(** 错误恢复系统测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试自动类型转换 - 字符串到整数 *)
let test_string_to_int_conversion () =
  let source = "\n让 「数字」 为 「一二三」\n让 「结果」 为 「数字」 加上 一\n打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "字符串到整数转换成功" true result

(** 测试自动类型转换 - 浮点数到整数 *)
let test_float_to_int_conversion () =
  let source = "\n让 「浮点」 为 三点一四\n让 「整数」 为 二\n让 「结果」 为 「浮点」 加上 「整数」\n打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "浮点数到整数转换成功" true result

(** 测试自动类型转换 - 数字到字符串 *)
let test_number_to_string_conversion () =
  let source = "\n让 「数字」 为 一二三\n让 「文本」 为 「值是」\n让 「结果」 为 「文本」 加上 「数字」\n打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "数字到字符串转换成功" true result

(** 测试布尔值到整数转换 *)
let test_bool_to_int_conversion () =
  let source =
    "\n让 「真值」 为 真\n让 「假值」 为 假\n让 「结果一」 为 「真值」 加上 十\n让 「结果二」 为 「假值」 加上 十\n打印 「结果一」\n打印 「结果二」"
  in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "布尔值到整数转换成功" true result

(** 测试混合类型运算 *)
let test_mixed_type_operations () =
  let source = "\n让 「a」 为 「五」\n让 「b」 为 三\n让 「c」 为 二点五\n让 「结果」 为 （「a」 加上 「b」） 乘以 「c」\n打印 「结果」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "混合类型运算成功" true result

(** 测试比较运算的类型转换 *)
let test_comparison_type_conversion () =
  let source =
    "\n让 「字符串数」 为 「十」\n让 「整数」 为 五\n如果 「字符串数」 大于 「整数」 那么\n  打印 「字符串数更大」\n否则\n  打印 「整数更大」"
  in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "比较运算类型转换成功" true result

(** 测试错误恢复关闭时的行为 *)
let test_recovery_disabled () =
  (* 暂时关闭错误恢复 *)
  let current_config = Codegen.get_recovery_config () in
  Codegen.set_recovery_config { current_config with enabled = false };

  let source = "\n让 「数字」 为 「一二三」\n让 「结果」 为 「数字」 加上 一\n打印 「结果」" in

  (* 使用关闭恢复模式的编译选项 *)
  let no_recovery_options = { Compiler.quiet_options with recovery_mode = false } in

  let result =
    let compile_result = Compiler.compile_string no_recovery_options source in
    not compile_result (* 期望编译失败（返回false） *)
  in

  (* 恢复设置 *)
  Codegen.set_recovery_config Codegen.default_recovery_config;

  check bool "关闭错误恢复后类型错误正确抛出" true result

(** 测试套件 *)
let () =
  run "错误恢复系统测试"
    [
      ( "类型转换",
        [
          test_case "字符串到整数" `Quick test_string_to_int_conversion;
          test_case "浮点数到整数" `Quick test_float_to_int_conversion;
          test_case "数字到字符串" `Quick test_number_to_string_conversion;
          test_case "布尔值到整数" `Quick test_bool_to_int_conversion;
          test_case "混合类型运算" `Quick test_mixed_type_operations;
          test_case "比较运算转换" `Quick test_comparison_type_conversion;
        ] );
      ("配置控制", [ test_case "关闭错误恢复" `Quick test_recovery_disabled ]);
    ]
