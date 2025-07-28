(** 骆言Builtin_Array内置数组操作模块增强测试覆盖 - Fix #1313

    本测试模块为 builtin_array.ml 提供全面的增强测试覆盖，作为提升项目测试覆盖率 从26.21%到50%目标的第四阶段实施。专注于内置数组操作函数的核心功能测试。

    测试内容涵盖：
    - 创建数组函数（大小验证、初始值设置）
    - 数组长度函数（空数组、大数组处理）
    - 复制数组函数（深拷贝验证、独立性测试）
    - 数组元素获取函数（边界检查、索引验证）
    - 数组元素设置函数（就地修改、类型安全）
    - 数组列表转换函数（双向转换、数据完整性）
    - 数组函数表（函数注册和查找）
    - 边界情况和错误处理机制

    测试策略：边界情况验证、错误处理、数据完整性、类型安全 *)

open Alcotest
open Yyocamlc_lib.Builtin_array
open Yyocamlc_lib.Builtin_common

(** 断言运行时错误被正确抛出 *)
let assert_runtime_error f =
  try
    let _ = f () in
    check bool "应该抛出RuntimeError异常" false true
  with
  | RuntimeError _ -> check bool "正确抛出RuntimeError" true true
  | _ -> check bool "应该抛出RuntimeError异常，但抛出了其他异常" false true

(** 测试用例：创建数组函数基础功能测试 *)
let test_create_array_function_basic () =
  (* 测试创建基本整数数组 *)
  let result1 = create_array_function [ IntValue 5; IntValue 42 ] in
  (match result1 with
  | ArrayValue arr ->
      check bool "数组长度正确" true (Array.length arr = 5);
      check bool "数组元素初始化正确" true (arr.(0) = IntValue 42);
      check bool "数组元素初始化正确" true (arr.(4) = IntValue 42)
  | _ -> check bool "应该返回ArrayValue" false true);

  (* 测试创建空数组 *)
  let result2 = create_array_function [ IntValue 0; StringValue "初始值" ] in
  (match result2 with
  | ArrayValue arr -> check bool "空数组长度为0" true (Array.length arr = 0)
  | _ -> check bool "应该返回ArrayValue" false true);

  (* 测试创建单元素数组 *)
  let result3 = create_array_function [ IntValue 1; BoolValue true ] in
  match result3 with
  | ArrayValue arr ->
      check bool "单元素数组长度为1" true (Array.length arr = 1);
      check bool "单元素数组值正确" true (arr.(0) = BoolValue true)
  | _ -> check bool "应该返回ArrayValue" false true

(** 测试用例：创建数组函数错误处理测试 *)
let test_create_array_function_error_handling () =
  (* 测试负数大小 *)
  assert_runtime_error (fun () -> create_array_function [ IntValue (-1); IntValue 0 ]);

  (* 测试非整数大小参数 *)
  assert_runtime_error (fun () -> create_array_function [ StringValue "错误"; IntValue 0 ]);
  assert_runtime_error (fun () -> create_array_function [ BoolValue true; IntValue 0 ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> create_array_function [ IntValue 5 ]);
  assert_runtime_error (fun () -> create_array_function []);
  assert_runtime_error (fun () -> create_array_function [ IntValue 5; IntValue 1; IntValue 2 ])

(** 测试用例：数组长度函数基础功能测试 *)
let test_array_length_function_basic () =
  (* 测试非空数组长度 *)
  let arr1 = [| IntValue 1; IntValue 2; IntValue 3; IntValue 4 |] in
  let result1 = array_length_function [ ArrayValue arr1 ] in
  check bool "非空数组长度" true (result1 = IntValue 4);

  (* 测试空数组长度 *)
  let arr2 = [||] in
  let result2 = array_length_function [ ArrayValue arr2 ] in
  check bool "空数组长度" true (result2 = IntValue 0);

  (* 测试单元素数组长度 *)
  let arr3 = [| StringValue "单元素" |] in
  let result3 = array_length_function [ ArrayValue arr3 ] in
  check bool "单元素数组长度" true (result3 = IntValue 1);

  (* 测试大数组长度 *)
  let arr4 = Array.make 1000 (IntValue 0) in
  let result4 = array_length_function [ ArrayValue arr4 ] in
  check bool "大数组长度" true (result4 = IntValue 1000)

(** 测试用例：数组长度函数错误处理测试 *)
let test_array_length_function_error_handling () =
  (* 测试非数组参数 *)
  assert_runtime_error (fun () -> array_length_function [ IntValue 42 ]);
  assert_runtime_error (fun () -> array_length_function [ ListValue [ IntValue 1; IntValue 2 ] ]);
  assert_runtime_error (fun () -> array_length_function [ StringValue "错误" ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> array_length_function []);
  assert_runtime_error (fun () -> array_length_function [ ArrayValue [||]; ArrayValue [||] ])

(** 测试用例：复制数组函数基础功能测试 *)
let test_copy_array_function_basic () =
  (* 测试基本数组复制 *)
  let original = [| IntValue 1; IntValue 2; IntValue 3 |] in
  let result1 = copy_array_function [ ArrayValue original ] in
  (match result1 with
  | ArrayValue copied ->
      check bool "复制数组长度相同" true (Array.length copied = Array.length original);
      check bool "复制数组内容相同" true (copied.(0) = original.(0));
      check bool "复制数组内容相同" true (copied.(2) = original.(2));
      (* 验证是深拷贝 - 修改原数组不影响复制 *)
      original.(0) <- IntValue 999;
      check bool "深拷贝独立性" true (copied.(0) = IntValue 1)
  | _ -> check bool "应该返回ArrayValue" false true);

  (* 测试空数组复制 *)
  let empty = [||] in
  let result2 = copy_array_function [ ArrayValue empty ] in
  (match result2 with
  | ArrayValue copied -> check bool "空数组复制长度" true (Array.length copied = 0)
  | _ -> check bool "应该返回ArrayValue" false true);

  (* 测试单元素数组复制 *)
  let single = [| StringValue "单元素" |] in
  let result3 = copy_array_function [ ArrayValue single ] in
  match result3 with
  | ArrayValue copied -> check bool "单元素数组复制" true (copied.(0) = StringValue "单元素")
  | _ -> check bool "应该返回ArrayValue" false true

(** 测试用例：复制数组函数错误处理测试 *)
let test_copy_array_function_error_handling () =
  (* 测试非数组参数 *)
  assert_runtime_error (fun () -> copy_array_function [ IntValue 42 ]);
  assert_runtime_error (fun () -> copy_array_function [ ListValue [ IntValue 1 ] ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> copy_array_function []);
  assert_runtime_error (fun () -> copy_array_function [ ArrayValue [||]; ArrayValue [||] ])

(** 测试用例：数组获取元素函数基础功能测试 *)
let test_array_get_function_basic () =
  (* 测试基本元素获取 *)
  let arr = [| IntValue 10; StringValue "测试"; BoolValue true; FloatValue 3.14 |] in
  let result1 = array_get_function [ ArrayValue arr; IntValue 0 ] in
  check bool "获取第0个元素" true (result1 = IntValue 10);

  let result2 = array_get_function [ ArrayValue arr; IntValue 1 ] in
  check bool "获取第1个元素" true (result2 = StringValue "测试");

  let result3 = array_get_function [ ArrayValue arr; IntValue 3 ] in
  check bool "获取最后一个元素" true (result3 = FloatValue 3.14);

  (* 测试单元素数组获取 *)
  let single_arr = [| IntValue 42 |] in
  let result4 = array_get_function [ ArrayValue single_arr; IntValue 0 ] in
  check bool "单元素数组获取" true (result4 = IntValue 42)

(** 测试用例：数组获取元素函数错误处理测试 *)
let test_array_get_function_error_handling () =
  let arr = [| IntValue 1; IntValue 2; IntValue 3 |] in

  (* 测试索引越界 *)
  assert_runtime_error (fun () -> array_get_function [ ArrayValue arr; IntValue 3 ]);
  assert_runtime_error (fun () -> array_get_function [ ArrayValue arr; IntValue (-1) ]);
  assert_runtime_error (fun () -> array_get_function [ ArrayValue arr; IntValue 100 ]);

  (* 测试空数组访问 *)
  let empty_arr = [||] in
  assert_runtime_error (fun () -> array_get_function [ ArrayValue empty_arr; IntValue 0 ]);

  (* 测试非数组参数 *)
  assert_runtime_error (fun () -> array_get_function [ IntValue 42; IntValue 0 ]);

  (* 测试非整数索引 *)
  assert_runtime_error (fun () -> array_get_function [ ArrayValue arr; StringValue "错误" ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> array_get_function [ ArrayValue arr ]);
  assert_runtime_error (fun () -> array_get_function [])

(** 测试用例：数组设置元素函数基础功能测试 *)
let test_array_set_function_basic () =
  (* 测试基本元素设置 *)
  let arr = [| IntValue 1; IntValue 2; IntValue 3 |] in
  let result1 = array_set_function [ ArrayValue arr; IntValue 0; StringValue "新值" ] in
  check bool "设置函数返回UnitValue" true (result1 = UnitValue);
  check bool "元素设置成功" true (arr.(0) = StringValue "新值");
  check bool "其他元素未受影响" true (arr.(1) = IntValue 2);

  (* 测试设置最后一个元素 *)
  let result2 = array_set_function [ ArrayValue arr; IntValue 2; BoolValue false ] in
  check bool "设置最后元素返回UnitValue" true (result2 = UnitValue);
  check bool "最后元素设置成功" true (arr.(2) = BoolValue false);

  (* 测试单元素数组设置 *)
  let single_arr = [| IntValue 0 |] in
  let _result3 = array_set_function [ ArrayValue single_arr; IntValue 0; FloatValue 2.5 ] in
  check bool "单元素设置成功" true (single_arr.(0) = FloatValue 2.5)

(** 测试用例：数组设置元素函数错误处理测试 *)
let test_array_set_function_error_handling () =
  let arr = [| IntValue 1; IntValue 2; IntValue 3 |] in

  (* 测试索引越界 *)
  assert_runtime_error (fun () -> array_set_function [ ArrayValue arr; IntValue 3; IntValue 999 ]);
  assert_runtime_error (fun () ->
      array_set_function [ ArrayValue arr; IntValue (-1); IntValue 999 ]);

  (* 测试空数组设置 *)
  let empty_arr = [||] in
  assert_runtime_error (fun () ->
      array_set_function [ ArrayValue empty_arr; IntValue 0; IntValue 1 ]);

  (* 测试非数组参数 *)
  assert_runtime_error (fun () -> array_set_function [ IntValue 42; IntValue 0; IntValue 1 ]);

  (* 测试非整数索引 *)
  assert_runtime_error (fun () ->
      array_set_function [ ArrayValue arr; StringValue "错误"; IntValue 1 ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> array_set_function [ ArrayValue arr; IntValue 0 ]);
  assert_runtime_error (fun () -> array_set_function [ ArrayValue arr ]);
  assert_runtime_error (fun () -> array_set_function [])

(** 测试用例：数组转列表函数基础功能测试 *)
let test_array_to_list_function_basic () =
  (* 测试基本数组转列表 *)
  let arr1 = [| IntValue 1; IntValue 2; IntValue 3 |] in
  let result1 = array_to_list_function [ ArrayValue arr1 ] in
  check bool "数组转列表基础功能" true (result1 = ListValue [ IntValue 1; IntValue 2; IntValue 3 ]);

  (* 测试空数组转列表 *)
  let arr2 = [||] in
  let result2 = array_to_list_function [ ArrayValue arr2 ] in
  check bool "空数组转列表" true (result2 = ListValue []);

  (* 测试单元素数组转列表 *)
  let arr3 = [| StringValue "单元素" |] in
  let result3 = array_to_list_function [ ArrayValue arr3 ] in
  check bool "单元素数组转列表" true (result3 = ListValue [ StringValue "单元素" ]);

  (* 测试混合类型数组转列表 *)
  let arr4 = [| IntValue 42; StringValue "测试"; BoolValue true |] in
  let result4 = array_to_list_function [ ArrayValue arr4 ] in
  check bool "混合类型数组转列表" true (result4 = ListValue [ IntValue 42; StringValue "测试"; BoolValue true ])

(** 测试用例：数组转列表函数错误处理测试 *)
let test_array_to_list_function_error_handling () =
  (* 测试非数组参数 *)
  assert_runtime_error (fun () -> array_to_list_function [ IntValue 42 ]);
  assert_runtime_error (fun () -> array_to_list_function [ ListValue [ IntValue 1 ] ]);
  assert_runtime_error (fun () -> array_to_list_function [ StringValue "错误" ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> array_to_list_function []);
  assert_runtime_error (fun () -> array_to_list_function [ ArrayValue [||]; ArrayValue [||] ])

(** 测试用例：列表转数组函数基础功能测试 *)
let test_list_to_array_function_basic () =
  (* 测试基本列表转数组 *)
  let result1 = list_to_array_function [ ListValue [ IntValue 1; IntValue 2; IntValue 3 ] ] in
  (match result1 with
  | ArrayValue arr ->
      check bool "列表转数组长度" true (Array.length arr = 3);
      check bool "列表转数组内容" true (arr.(0) = IntValue 1);
      check bool "列表转数组内容" true (arr.(2) = IntValue 3)
  | _ -> check bool "应该返回ArrayValue" false true);

  (* 测试空列表转数组 *)
  let result2 = list_to_array_function [ ListValue [] ] in
  (match result2 with
  | ArrayValue arr -> check bool "空列表转数组" true (Array.length arr = 0)
  | _ -> check bool "应该返回ArrayValue" false true);

  (* 测试单元素列表转数组 *)
  let result3 = list_to_array_function [ ListValue [ StringValue "单元素" ] ] in
  (match result3 with
  | ArrayValue arr -> check bool "单元素列表转数组" true (arr.(0) = StringValue "单元素")
  | _ -> check bool "应该返回ArrayValue" false true);

  (* 测试混合类型列表转数组 *)
  let result4 =
    list_to_array_function [ ListValue [ IntValue 42; BoolValue false; FloatValue 1.5 ] ]
  in
  match result4 with
  | ArrayValue arr ->
      check bool "混合类型列表转数组长度" true (Array.length arr = 3);
      check bool "混合类型列表转数组内容" true (arr.(1) = BoolValue false)
  | _ -> check bool "应该返回ArrayValue" false true

(** 测试用例：列表转数组函数错误处理测试 *)
let test_list_to_array_function_error_handling () =
  (* 测试非列表参数 *)
  assert_runtime_error (fun () -> list_to_array_function [ IntValue 42 ]);
  assert_runtime_error (fun () -> list_to_array_function [ ArrayValue [||] ]);
  assert_runtime_error (fun () -> list_to_array_function [ StringValue "错误" ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> list_to_array_function []);
  assert_runtime_error (fun () -> list_to_array_function [ ListValue []; ListValue [] ])

(** 测试用例：数组列表双向转换一致性测试 *)
let test_array_list_conversion_consistency () =
  (* 测试数组->列表->数组转换一致性 *)
  let original_arr = [| IntValue 1; StringValue "测试"; BoolValue true |] in
  let to_list = array_to_list_function [ ArrayValue original_arr ] in
  let back_to_array = list_to_array_function [ to_list ] in
  (match back_to_array with
  | ArrayValue converted_arr ->
      check bool "双向转换长度一致" true (Array.length converted_arr = Array.length original_arr);
      check bool "双向转换内容一致" true (converted_arr.(0) = original_arr.(0));
      check bool "双向转换内容一致" true (converted_arr.(2) = original_arr.(2))
  | _ -> check bool "转换结果应为ArrayValue" false true);

  (* 测试列表->数组->列表转换一致性 *)
  let original_list = ListValue [ IntValue 5; FloatValue 2.5; StringValue "往返" ] in
  let to_array = list_to_array_function [ original_list ] in
  let back_to_list = array_to_list_function [ to_array ] in
  check bool "列表双向转换一致性" true (back_to_list = original_list)

(** 测试用例：数组函数表完整性测试 *)
let test_array_functions_table () =
  (* 验证所有预期的函数都在表中 *)
  let expected_functions = [ "创建数组"; "数组长度"; "复制数组"; "数组获取"; "数组设置"; "数组转列表"; "列表转数组" ] in
  let actual_functions = List.map fst array_functions in

  List.iter
    (fun name -> check bool (Printf.sprintf "函数表包含 %s" name) true (List.mem name actual_functions))
    expected_functions;

  (* 验证函数表长度 *)
  check bool "函数表包含7个函数" true (List.length array_functions = 7);

  (* 验证每个函数都是BuiltinFunctionValue *)
  List.iter
    (fun (name, value) ->
      match value with
      | BuiltinFunctionValue _ -> check bool (Printf.sprintf "%s 是内置函数值" name) true true
      | _ -> check bool (Printf.sprintf "%s 应该是内置函数值" name) false true)
    array_functions

(** 主测试套件 *)
let () =
  run "骆言Builtin_Array内置数组操作模块增强测试覆盖 - Fix #1313"
    [
      ( "创建数组函数测试",
        [
          test_case "基础功能测试" `Quick test_create_array_function_basic;
          test_case "错误处理测试" `Quick test_create_array_function_error_handling;
        ] );
      ( "数组长度函数测试",
        [
          test_case "基础功能测试" `Quick test_array_length_function_basic;
          test_case "错误处理测试" `Quick test_array_length_function_error_handling;
        ] );
      ( "复制数组函数测试",
        [
          test_case "基础功能测试" `Quick test_copy_array_function_basic;
          test_case "错误处理测试" `Quick test_copy_array_function_error_handling;
        ] );
      ( "数组获取函数测试",
        [
          test_case "基础功能测试" `Quick test_array_get_function_basic;
          test_case "错误处理测试" `Quick test_array_get_function_error_handling;
        ] );
      ( "数组设置函数测试",
        [
          test_case "基础功能测试" `Quick test_array_set_function_basic;
          test_case "错误处理测试" `Quick test_array_set_function_error_handling;
        ] );
      ( "数组转列表函数测试",
        [
          test_case "基础功能测试" `Quick test_array_to_list_function_basic;
          test_case "错误处理测试" `Quick test_array_to_list_function_error_handling;
        ] );
      ( "列表转数组函数测试",
        [
          test_case "基础功能测试" `Quick test_list_to_array_function_basic;
          test_case "错误处理测试" `Quick test_list_to_array_function_error_handling;
        ] );
      ("数组列表转换一致性测试", [ test_case "双向转换一致性验证" `Quick test_array_list_conversion_consistency ]);
      ("数组函数表测试", [ test_case "函数表完整性验证" `Quick test_array_functions_table ]);
    ]
