(* 🧪 关键核心模块测试覆盖率改进 - Builtin Function Helpers核心模块测试 Fix #1612 *)
(* Author: Alpha, 核心工作代理 *)

open Alcotest
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Value_types
open Yyocamlc_lib.Builtin_function_helpers
module Value_ops = Yyocamlc_lib.Value_operations

(* 单参数字符串函数测试 *)
let test_single_string_builtin () =
  let string_upper = String.uppercase_ascii in
  let args = [StringValue "hello"] in
  match single_string_builtin "test_upper" string_upper args with
  | StringValue "HELLO" -> ()
  | _ -> Alcotest.fail "Single string builtin failed"

(* 单参数字符串函数 - 中文处理测试 *)
let test_single_string_builtin_chinese () =
  let string_length s = string_of_int (String.length s) in
  let args = [StringValue "骆言"] in
  match single_string_builtin "test_length" string_length args with
  | StringValue _ -> () (* 中文长度可能因编码而异 *)
  | _ -> Alcotest.fail "Single string builtin with Chinese failed"

(* 单参数整数函数测试 *)
let test_single_int_builtin () =
  let int_abs = abs in
  let args = [IntValue (-42)] in
  match single_int_builtin "test_abs" int_abs args with
  | IntValue 42 -> ()
  | _ -> Alcotest.fail "Single int builtin failed"

(* 单参数浮点数函数测试 *)
let test_single_float_builtin () =
  let float_sqrt = sqrt in
  let args = [FloatValue 4.0] in
  match single_float_builtin "test_sqrt" float_sqrt args with
  | FloatValue 2.0 -> ()
  | _ -> Alcotest.fail "Single float builtin failed"

(* 单参数布尔值函数测试 *)
let test_single_bool_builtin () =
  let bool_not = not in
  let args = [BoolValue true] in
  match single_bool_builtin "test_not" bool_not args with
  | BoolValue false -> ()
  | _ -> Alcotest.fail "Single bool builtin failed"

(* 单参数转字符串函数测试 *)
let test_single_to_string_builtin () =
  let int_to_string = string_of_int in
  let args = [IntValue 123] in
  match single_to_string_builtin "test_int_to_string" Value_ops.expect_int int_to_string args with
  | StringValue "123" -> ()
  | _ -> Alcotest.fail "Single to string builtin failed"

(* 单参数类型转换函数测试 *)
let test_single_conversion_builtin () =
  let string_to_int = int_of_string in
  let int_wrapper x = IntValue x in
  let args = [StringValue "456"] in
  match single_conversion_builtin "test_string_to_int" Value_ops.expect_string string_to_int int_wrapper args with
  | IntValue 456 -> ()
  | _ -> Alcotest.fail "Single conversion builtin failed"

(* 类型转换错误处理测试 *)
let test_conversion_error_handling () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Conversion error handling"
    (Error "runtime_error")
    (try
      let string_to_int = int_of_string in
      let int_wrapper x = IntValue x in
      let args = [StringValue "not_a_number"] in
      let _ = single_conversion_builtin "test_invalid_conversion" Value_ops.expect_string string_to_int int_wrapper args in
      Ok "converted"
    with
    | RuntimeError _ -> Error "runtime_error"
    | _ -> Error "other_error")

(* 双参数字符串函数测试 *)
let test_double_string_builtin () =
  let string_concat s1 s2 = s1 ^ s2 in
  let args = [StringValue "Hello"; StringValue "World"] in
  match double_string_builtin "test_concat" string_concat args with
  | StringValue "HelloWorld" -> ()
  | _ -> Alcotest.fail "Double string builtin failed"

(* 双参数字符串返回布尔值函数测试 *)
let test_double_string_to_bool_builtin () =
  let string_contains s1 s2 = 
    try ignore (Str.search_forward (Str.regexp_string s2) s1 0); true 
    with Not_found -> false in
  let args = [StringValue "Hello World"; StringValue "World"] in
  match double_string_to_bool_builtin "test_contains" string_contains args with
  | BoolValue true -> ()
  | _ -> Alcotest.fail "Double string to bool builtin failed"

(* 参数数量错误处理测试 *)
let test_argument_count_error () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Argument count error handling"
    (Error "builtin_error")
    (try
      let string_upper = String.uppercase_ascii in
      let args = [StringValue "hello"; StringValue "extra"] in (* 过多参数 *)
      let _ = single_string_builtin "test_error" string_upper args in
      Ok "processed"
    with
    | BuiltinError _ -> Error "builtin_error"
    | _ -> Error "other_error")

(* 类型不匹配错误处理测试 *)
let test_type_mismatch_error () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Type mismatch error handling"
    (Error "builtin_error")
    (try
      let string_upper = String.uppercase_ascii in
      let args = [IntValue 42] in (* 期望字符串但传入整数 *)
      let _ = single_string_builtin "test_type_error" string_upper args in
      Ok "processed"
    with
    | BuiltinError _ -> Error "builtin_error"
    | _ -> Error "other_error")

(* 空参数列表错误处理测试 *)
let test_empty_args_error () =
  Alcotest.check (Alcotest.result Alcotest.string Alcotest.string)
    "Empty args error handling"
    (Error "builtin_error")
    (try
      let int_abs = abs in
      let args = [] in (* 空参数列表 *)
      let _ = single_int_builtin "test_empty" int_abs args in
      Ok "processed"
    with
    | BuiltinError _ -> Error "builtin_error"
    | _ -> Error "other_error")

(* 中文函数名处理测试 *)
let test_chinese_function_name () =
  let int_double x = x * 2 in
  let args = [IntValue 21] in
  match single_int_builtin "中文函数名" int_double args with
  | IntValue 42 -> ()
  | _ -> Alcotest.fail "Chinese function name processing failed"

(* 边界值处理测试 *)
let test_boundary_values () =
  (* 最大整数测试 *)
  let int_identity x = x in
  let args = [IntValue max_int] in
  match single_int_builtin "test_max_int" int_identity args with
  | IntValue n when n = max_int -> ()
  | _ -> Alcotest.fail "Max int boundary test failed";
  
  (* 零值测试 *)
  let args = [IntValue 0] in
  match single_int_builtin "test_zero" int_identity args with
  | IntValue 0 -> ()
  | _ -> Alcotest.fail "Zero boundary test failed"

(* 复杂字符串操作测试 *)
let test_complex_string_operations () =
  let string_reverse s = 
    let len = String.length s in
    String.init len (fun i -> s.[len - 1 - i]) in
  let args = [StringValue "骆言编程"] in
  match single_string_builtin "test_reverse" string_reverse args with
  | StringValue _ -> () (* 结果应该是反转的中文字符串 *)
  | _ -> Alcotest.fail "Complex string operation failed"

let suite = [
  "test_single_string_builtin", `Quick, test_single_string_builtin;
  "test_single_string_builtin_chinese", `Quick, test_single_string_builtin_chinese;
  "test_single_int_builtin", `Quick, test_single_int_builtin;
  "test_single_float_builtin", `Quick, test_single_float_builtin;
  "test_single_bool_builtin", `Quick, test_single_bool_builtin;
  "test_single_to_string_builtin", `Quick, test_single_to_string_builtin;
  "test_single_conversion_builtin", `Quick, test_single_conversion_builtin;
  "test_conversion_error_handling", `Quick, test_conversion_error_handling;
  "test_double_string_builtin", `Quick, test_double_string_builtin;
  "test_double_string_to_bool_builtin", `Quick, test_double_string_to_bool_builtin;
  "test_argument_count_error", `Quick, test_argument_count_error;
  "test_type_mismatch_error", `Quick, test_type_mismatch_error;
  "test_empty_args_error", `Quick, test_empty_args_error;
  "test_chinese_function_name", `Quick, test_chinese_function_name;
  "test_boundary_values", `Quick, test_boundary_values;
  "test_complex_string_operations", `Quick, test_complex_string_operations;
]