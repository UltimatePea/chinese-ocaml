(** 模块类型和签名测试 *)

open Alcotest
open Yyocamlc_lib

(** 测试基础模块类型定义 *)
let test_basic_module_type () =
  let source = "模块类型「基础接口」= 签名
  让「加法」: 整数
  让「减法」: 整数
结束" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "基础模块类型定义编译成功" true result

(** 测试带类型定义的模块类型 *)
let test_module_type_with_types () =
  let source = "模块类型「数据接口」= 签名
  类型「元素」= 整数
  让「创建」:「元素」
  让「显示」: 字符串
结束" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "带类型定义的模块类型编译成功" true result

(** 测试复合模块类型 *)
let test_complex_module_type () =
  let source = "模块类型「集合接口」= 签名
  类型「集合类型」= |「空集」|「元素集」of 整数
  让「添加」: 整数
  让「删除」: 布尔值
  异常「空集错误」of 字符串
结束" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "复合模块类型编译成功" true result

(** 测试模块类型别名 *)
let test_module_type_alias () =
  let source = "
模块类型「基础接口」= 签名
  让「操作」: 整数
结束

模块类型「扩展接口」=「基础接口」" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "模块类型别名编译成功" true result

(** 测试带异常的模块类型 *)
let test_module_type_with_exceptions () =
  let source = "模块类型「安全接口」= 签名
  异常「输入错误」
  异常「计算错误」of 字符串
  让「安全操作」: 整数
结束" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "带异常的模块类型编译成功" true result

(** 测试抽象类型签名 *)
let test_abstract_type_signature () =
  let source = "模块类型「抽象接口」= 签名
  类型「抽象类型」
  让「创建」: 整数
  让「提取」: 整数
结束" in
  let result = Compiler.compile_string Compiler.quiet_options source in
  check bool "抽象类型签名编译成功" true result

(** 主测试套件 *)
let () =
  run "模块类型和签名测试" [
    "基础功能", [
      test_case "基础模块类型定义" `Quick test_basic_module_type;
      test_case "带类型定义的模块类型" `Quick test_module_type_with_types;
      test_case "模块类型别名" `Quick test_module_type_alias;
    ];
    "高级功能", [
      test_case "复合模块类型" `Quick test_complex_module_type;
      test_case "带异常的模块类型" `Quick test_module_type_with_exceptions;
      test_case "抽象类型签名" `Quick test_abstract_type_signature;
    ];
  ]