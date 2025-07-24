(** 针对builtin_array模块的测试覆盖率提升 - 骆言编程语言 *)

open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_array

(** 创建数组函数测试 *)
let test_create_array () =
  let args = [IntValue 3; StringValue "测试"] in
  let result = create_array_function args in
  match result with
  | ArrayValue arr -> 
      assert (Array.length arr = 3);
      assert (arr.(0) = StringValue "测试");
      assert (arr.(1) = StringValue "测试");
      assert (arr.(2) = StringValue "测试")
  | _ -> assert false

(** 数组长度函数测试 *)
let test_array_length () =
  let arr = [|IntValue 1; IntValue 2; IntValue 3; IntValue 4|] in
  let args = [ArrayValue arr] in
  let result = array_length_function args in
  assert (result = IntValue 4)

(** 复制数组函数测试 *)
let test_copy_array () =
  let original = [|IntValue 1; IntValue 2|] in
  let args = [ArrayValue original] in
  let result = copy_array_function args in
  match result with
  | ArrayValue copied ->
      assert (Array.length copied = Array.length original);
      assert (copied.(0) = original.(0));
      assert (copied.(1) = original.(1));
      (* 确保是真正的复制，不是同一个引用 *)
      copied.(0) <- IntValue 99;
      assert (original.(0) = IntValue 1)
  | _ -> assert false

(** 数组获取元素函数测试 *)
let test_array_get () =
  let arr = [|StringValue "零"; StringValue "一"; StringValue "二"|] in
  let args = [ArrayValue arr; IntValue 1] in
  let result = array_get_function args in
  assert (result = StringValue "一")

(** 数组设置元素函数测试 *)
let test_array_set () =
  let arr = [|IntValue 0; IntValue 1; IntValue 2|] in
  let args = [ArrayValue arr; IntValue 1; StringValue "新值"] in
  let result = array_set_function args in
  assert (result = UnitValue);
  assert (arr.(1) = StringValue "新值")

(** 数组转列表函数测试 *)
let test_array_to_list () =
  let arr = [|StringValue "甲"; StringValue "乙"; StringValue "丙"|] in
  let args = [ArrayValue arr] in
  let result = array_to_list_function args in
  match result with
  | ListValue lst ->
      assert (lst = [StringValue "甲"; StringValue "乙"; StringValue "丙"])
  | _ -> assert false

(** 列表转数组函数测试 *)
let test_list_to_array () =
  let lst = [IntValue 10; IntValue 20; IntValue 30] in
  let args = [ListValue lst] in
  let result = list_to_array_function args in
  match result with
  | ArrayValue arr ->
      assert (Array.length arr = 3);
      assert (arr.(0) = IntValue 10);
      assert (arr.(1) = IntValue 20);
      assert (arr.(2) = IntValue 30)
  | _ -> assert false

(** 运行所有测试 *)
let run_tests () =
  test_create_array ();
  test_array_length ();
  test_copy_array ();
  test_array_get ();
  test_array_set ();
  test_array_to_list ();  
  test_list_to_array ();
  print_endline "✅ builtin_array 模块测试全部通过！"

let () = run_tests ()