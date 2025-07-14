open Yyocamlc_lib.Lexer
open Yyocamlc_lib.Parser
open Yyocamlc_lib.Codegen

(* 测试多态变体的基本功能 *)
let test_basic_polymorphic_variant () =
  let test_code = "
    类型 「颜色」 = 变体 「红」 或者 「绿」 或者 「蓝」

    设 「我的颜色」 为 标签 「红」

    匹配 「我的颜色」 与
    | 标签 「红」 -> \"红色\"
    | 标签 「绿」 -> \"绿色\"
    | 标签 「蓝」 -> \"蓝色\"
  " in
  
  let tokens = tokenize test_code "test" in
  let ast = parse_program tokens in
  let result = execute_program ast in
  (match result with
   | Ok value -> print_endline ("基本多态变体测试结果: " ^ value_to_string value)
   | Error err -> print_endline ("基本多态变体测试错误: " ^ err))

(* 测试带值的多态变体 *)
let test_polymorphic_variant_with_value () =
  let test_code = "
    类型 「形状」 = 变体 「圆形」 或者 「方形」

    设 「我的形状」 为 标签 「圆形」

    匹配 「我的形状」 与
    | 标签 「圆形」 -> \"圆形\"
    | 标签 「方形」 -> \"方形\"
  " in
  
  let tokens = tokenize test_code "test" in
  let ast = parse_program tokens in
  let result = execute_program ast in
  (match result with
   | Ok value -> print_endline ("带值多态变体测试结果: " ^ value_to_string value)
   | Error err -> print_endline ("带值多态变体测试错误: " ^ err))

(* 测试多态变体在函数中的使用 *)
let test_polymorphic_variant_in_function () =
  let test_code = "
    类型 「结果」 = 变体 「成功」 或者 「失败」

    设 「结果1」 为 标签 「成功」

    匹配 「结果1」 与
    | 标签 「成功」 -> \"成功\"
    | 标签 「失败」 -> \"失败\"
  " in
  
  let tokens = tokenize test_code "test" in
  let ast = parse_program tokens in
  let result = execute_program ast in
  (match result with
   | Ok value -> print_endline ("函数中多态变体测试结果: " ^ value_to_string value)
   | Error err -> print_endline ("函数中多态变体测试错误: " ^ err))

(* 运行所有测试 *)
let () =
  print_endline "=== 多态变体系统测试 ===";
  test_basic_polymorphic_variant ();
  test_polymorphic_variant_with_value ();
  test_polymorphic_variant_in_function ();
  print_endline "=== 多态变体系统测试完成 ==="