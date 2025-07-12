(** 错误恢复系统测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试自动类型转换 - 字符串到整数 *)
let test_string_to_int_conversion () =
  let source = "
让 数字 = \"123\"
让 结果 = 数字 + 1
打印 结果" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "字符串到整数转换成功" true result

(** 测试自动类型转换 - 浮点数到整数 *)
let test_float_to_int_conversion () =
  let source = "
让 浮点 = 3.14
让 整数 = 2
让 结果 = 浮点 + 整数
打印 结果" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "浮点数到整数转换成功" true result

(** 测试自动类型转换 - 数字到字符串 *)
let test_number_to_string_conversion () =
  let source = "
让 数字 = 123
让 文本 = \"值是: \"
让 结果 = 文本 + 数字
打印 结果" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "数字到字符串转换成功" true result

(** 测试布尔值到整数转换 *)
let test_bool_to_int_conversion () =
  let source = "
让 真值 = 真
让 假值 = 假
让 结果1 = 真值 + 10
让 结果2 = 假值 + 10
打印 结果1
打印 结果2" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "布尔值到整数转换成功" true result

(** 测试混合类型运算 *)
let test_mixed_type_operations () =
  let source = "
让 a = \"5\"
让 b = 3
让 c = 2.5
让 结果 = (a + b) * c
打印 结果" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "混合类型运算成功" true result

(** 测试比较运算的类型转换 *)
let test_comparison_type_conversion () =
  let source = "
让 字符串数 = \"10\"
让 整数 = 5
如果 字符串数 > 整数 那么
  打印 \"字符串数更大\"
否则
  打印 \"整数更大\"" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "比较运算类型转换成功" true result

(** 测试错误恢复关闭时的行为 *)
let test_recovery_disabled () =
  (* 暂时关闭错误恢复 *)
  Codegen.recovery_config := { 
    !Codegen.recovery_config with 
    enabled = false 
  };
  
  let source = "
让 数字 = \"123\"
让 结果 = 数字 + 1
打印 结果" in
  
  (* 使用关闭恢复模式的编译选项 *)
  let no_recovery_options = { 
    Compiler.quiet_options with 
    recovery_mode = false 
  } in
  
  let result = 
    let compile_result = Compiler.compile_string no_recovery_options source in
    not compile_result  (* 期望编译失败（返回false） *)
  in
  
  (* 恢复设置 *)
  Codegen.recovery_config := Codegen.default_recovery_config;
  
  check bool "关闭错误恢复后类型错误正确抛出" true result

(** 测试套件 *)
let () =
  run "错误恢复系统测试" [
    ("类型转换", [
      test_case "字符串到整数" `Quick test_string_to_int_conversion;
      test_case "浮点数到整数" `Quick test_float_to_int_conversion;
      test_case "数字到字符串" `Quick test_number_to_string_conversion;
      test_case "布尔值到整数" `Quick test_bool_to_int_conversion;
      test_case "混合类型运算" `Quick test_mixed_type_operations;
      test_case "比较运算转换" `Quick test_comparison_type_conversion;
    ]);
    ("配置控制", [
      test_case "关闭错误恢复" `Quick test_recovery_disabled;
    ]);
  ]