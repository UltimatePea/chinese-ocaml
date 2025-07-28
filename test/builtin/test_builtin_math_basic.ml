(** 内置数学函数基础测试模块

    简化版测试，专注于基本功能验证

    @author 骆言测试团队
    @version 1.0
    @since 2025-07-23 Fix #915 测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Builtin_math
open Yyocamlc_lib.Value_operations

let test_math_functions_exist () =
  let functions = math_functions in
  check bool "数学函数表应该包含函数" true (List.length functions > 0);
  let function_names = List.map fst functions in
  check bool "应该包含范围函数" true (List.mem "范围" function_names);
  check bool "应该包含求和函数" true (List.mem "求和" function_names)

let test_range_function_basic () =
  (* 测试范围函数基本功能 *)
  let args = [ IntValue 1; IntValue 3 ] in
  let result = range_function args in
  match result with
  | ListValue items -> check int "范围应该包含正确数量的元素" 3 (List.length items)
  | _ -> fail "范围函数应该返回列表"

let test_sum_function_basic () =
  (* 测试求和函数基本功能 *)
  let test_list = ListValue [ IntValue 1; IntValue 2 ] in
  let args = [ test_list ] in
  let result = sum_function args in
  match result with IntValue n -> check int "求和结果应该正确" 3 n | _ -> fail "求和函数应该返回整数"

let test_max_min_functions () =
  (* 测试最大值最小值函数 *)
  let test_list = ListValue [ IntValue 1; IntValue 5; IntValue 3 ] in
  let max_result = max_function [ test_list ] in
  let min_result = min_function [ test_list ] in

  match (max_result, min_result) with
  | IntValue max_val, IntValue min_val ->
      check int "最大值应该正确" 5 max_val;
      check int "最小值应该正确" 1 min_val
  | _ -> fail "最大值最小值函数应该返回整数"

let () =
  run "Builtin_math_basic tests"
    [
      ("functions_exist", [ test_case "数学函数存在性检查" `Quick test_math_functions_exist ]);
      ("range_function", [ test_case "范围函数基础测试" `Quick test_range_function_basic ]);
      ("sum_function", [ test_case "求和函数基础测试" `Quick test_sum_function_basic ]);
      ("max_min_functions", [ test_case "最大值最小值函数" `Quick test_max_min_functions ]);
    ]
