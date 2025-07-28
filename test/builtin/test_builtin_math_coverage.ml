(** 针对builtin_math模块的测试覆盖率提升 - 骆言编程语言 *)

open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_math

(** 范围生成函数测试 *)
let test_range_function () =
  let args = [ IntValue 1; IntValue 5 ] in
  let result = range_function args in
  match result with
  | ListValue lst -> assert (lst = [ IntValue 1; IntValue 2; IntValue 3; IntValue 4; IntValue 5 ])
  | _ -> assert false

(** 测试反向范围 *)
let test_range_function_reverse () =
  let args = [ IntValue 5; IntValue 1 ] in
  let result = range_function args in
  match result with ListValue lst -> assert (lst = []) | _ -> assert false

(** 求和函数测试 *)
let test_sum_function () =
  let lst = [ IntValue 1; IntValue 2; IntValue 3; IntValue 4; IntValue 5 ] in
  let args = [ ListValue lst ] in
  let result = sum_function args in
  assert (result = IntValue 15)

(** 求和函数空列表测试 *)
let test_sum_function_empty () =
  let args = [ ListValue [] ] in
  let result = sum_function args in
  assert (result = IntValue 0)

(** 最大值函数测试 *)
let test_max_function () =
  let lst = [ IntValue 3; IntValue 1; IntValue 7; IntValue 2; IntValue 5 ] in
  let args = [ ListValue lst ] in
  let result = max_function args in
  assert (result = IntValue 7)

(** 最大值函数单元素测试 *)
let test_max_function_single () =
  let lst = [ IntValue 42 ] in
  let args = [ ListValue lst ] in
  let result = max_function args in
  assert (result = IntValue 42)

(** 最小值函数测试 *)
let test_min_function () =
  let lst = [ IntValue 8; IntValue 3; IntValue 12; IntValue 1; IntValue 6 ] in
  let args = [ ListValue lst ] in
  let result = min_function args in
  assert (result = IntValue 1)

(** 运行所有测试 *)
let run_tests () =
  test_range_function ();
  test_range_function_reverse ();
  test_sum_function ();
  test_sum_function_empty ();
  test_max_function ();
  test_max_function_single ();
  test_min_function ();
  print_endline "✅ builtin_math 模块测试全部通过！"

let () = run_tests ()
