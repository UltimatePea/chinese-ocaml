(** 骆言Builtin_Collections内置集合函数模块增强测试覆盖 - Fix #1310

    本测试模块为 builtin_collections.ml 提供全面的增强测试覆盖，作为提升项目测试覆盖率 从26.21%到50%目标的第三阶段实施。专注于内置集合操作函数的核心功能测试。

    测试内容涵盖：
    - 长度函数（列表和字符串长度计算）
    - 连接函数（柯里化列表连接操作）
    - 过滤函数（高阶函数谓词过滤）
    - 映射函数（高阶函数元素变换）
    - 折叠函数（左折叠累积计算）
    - 排序函数（多类型排序支持）
    - 反转函数（列表和字符串反转）
    - 包含函数（柯里化查找操作）
    - 集合函数表（函数注册和查找）
    - 边界情况和错误处理机制

    测试策略：柯里化接口、高阶函数、类型安全、边界情况验证 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_collections
open Yyocamlc_lib.Builtin_error

(** 创建测试用的简单整数加一函数 *)
let create_add_one_function () =
  BuiltinFunctionValue
    (fun args ->
      match args with [ IntValue i ] -> IntValue (i + 1) | _ -> runtime_error "加一函数期望一个整数参数")

(** 创建测试用的大于阈值判断函数 *)
let create_greater_than_function threshold =
  BuiltinFunctionValue
    (fun args ->
      match args with
      | [ IntValue i ] -> BoolValue (i > threshold)
      | _ -> runtime_error "大于函数期望一个整数参数")

(** 创建测试用的整数相加函数 *)
let create_add_function () =
  BuiltinFunctionValue
    (fun args ->
      match args with
      | [ IntValue a; IntValue b ] -> IntValue (a + b)
      | _ -> runtime_error "相加函数期望两个整数参数")

(** 断言运行时错误被正确抛出 *)
let assert_runtime_error f =
  try
    let _ = f () in
    check bool "应该抛出RuntimeError异常" false true
  with
  | RuntimeError _ -> check bool "正确抛出RuntimeError" true true
  | _ -> check bool "应该抛出RuntimeError异常，但抛出了其他异常" false true

(** 测试用例：长度函数基础功能测试 *)
let test_length_function_basic () =
  (* 测试列表长度 *)
  let result1 = length_function [ ListValue [ IntValue 1; IntValue 2; IntValue 3 ] ] in
  check bool "列表长度计算" true (result1 = IntValue 3);

  (* 测试空列表长度 *)
  let result2 = length_function [ ListValue [] ] in
  check bool "空列表长度" true (result2 = IntValue 0);

  (* 测试字符串长度 - 注意：当前实现使用String.length，返回字节数而非字符数 *)
  let result3 = length_function [ StringValue "测试" ] in
  check bool "中文字符串字节长度" true (result3 = IntValue 6);

  (* 测试空字符串长度 *)
  let result4 = length_function [ StringValue "" ] in
  check bool "空字符串长度" true (result4 = IntValue 0)

(** 测试用例：长度函数错误处理测试 *)
let test_length_function_error_handling () =
  (* 测试错误的参数类型 *)
  assert_runtime_error (fun () -> length_function [ IntValue 42 ]);
  assert_runtime_error (fun () -> length_function [ BoolValue true ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> length_function []);
  assert_runtime_error (fun () -> length_function [ ListValue []; ListValue [] ])

(** 测试用例：连接函数基础功能测试 *)
let test_concat_function_basic () =
  (* 测试正常列表连接 *)
  let first_func = concat_function [ ListValue [ IntValue 1; IntValue 2 ] ] in
  (match first_func with
  | BuiltinFunctionValue func ->
      let result = func [ ListValue [ IntValue 3; IntValue 4 ] ] in
      check bool "列表连接功能" true
        (result = ListValue [ IntValue 1; IntValue 2; IntValue 3; IntValue 4 ])
  | _ -> check bool "连接函数应该返回函数" false true);

  (* 测试空列表连接 *)
  let empty_func = concat_function [ ListValue [] ] in
  match empty_func with
  | BuiltinFunctionValue func ->
      let result = func [ ListValue [ IntValue 1; IntValue 2 ] ] in
      check bool "空列表连接" true (result = ListValue [ IntValue 1; IntValue 2 ])
  | _ -> check bool "连接函数应该返回函数" false true

(** 测试用例：连接函数错误处理测试 *)
let test_concat_function_error_handling () =
  (* 测试第一个参数类型错误 *)
  assert_runtime_error (fun () -> concat_function [ IntValue 42 ]);

  (* 测试柯里化后第二个参数类型错误 *)
  let func = concat_function [ ListValue [ IntValue 1 ] ] in
  match func with
  | BuiltinFunctionValue f -> assert_runtime_error (fun () -> f [ StringValue "错误" ])
  | _ -> check bool "应该返回函数" false true

(** 测试用例：过滤函数基础功能测试 *)
let test_filter_function_basic () =
  (* 测试基本过滤功能 *)
  let predicate = create_greater_than_function 2 in
  let filter_func = filter_function [ predicate ] in
  (match filter_func with
  | BuiltinFunctionValue func ->
      let result = func [ ListValue [ IntValue 1; IntValue 2; IntValue 3; IntValue 4 ] ] in
      check bool "过滤大于2的元素" true (result = ListValue [ IntValue 3; IntValue 4 ])
  | _ -> check bool "过滤函数应该返回函数" false true);

  (* 测试空列表过滤 *)
  let filter_func2 = filter_function [ predicate ] in
  match filter_func2 with
  | BuiltinFunctionValue func ->
      let result = func [ ListValue [] ] in
      check bool "空列表过滤" true (result = ListValue [])
  | _ -> check bool "过滤函数应该返回函数" false true

(** 测试用例：过滤函数错误处理测试 *)
let test_filter_function_error_handling () =
  (* 测试谓词函数参数错误 *)
  assert_runtime_error (fun () -> filter_function [ IntValue 42 ]);

  (* 测试谓词返回非布尔值 *)
  let bad_predicate = create_add_one_function () in
  let filter_func = filter_function [ bad_predicate ] in
  match filter_func with
  | BuiltinFunctionValue func -> assert_runtime_error (fun () -> func [ ListValue [ IntValue 1 ] ])
  | _ -> check bool "应该返回函数" false true

(** 测试用例：映射函数基础功能测试 *)
let test_map_function_basic () =
  (* 测试基本映射功能 *)
  let transform = create_add_one_function () in
  let map_func = map_function [ transform ] in
  (match map_func with
  | BuiltinFunctionValue func ->
      let result = func [ ListValue [ IntValue 1; IntValue 2; IntValue 3 ] ] in
      check bool "映射加一操作" true (result = ListValue [ IntValue 2; IntValue 3; IntValue 4 ])
  | _ -> check bool "映射函数应该返回函数" false true);

  (* 测试空列表映射 *)
  let map_func2 = map_function [ transform ] in
  match map_func2 with
  | BuiltinFunctionValue func ->
      let result = func [ ListValue [] ] in
      check bool "空列表映射" true (result = ListValue [])
  | _ -> check bool "映射函数应该返回函数" false true

(** 测试用例：映射函数错误处理测试 *)
let test_map_function_error_handling () =
  (* 测试映射函数参数错误 *)
  assert_runtime_error (fun () -> map_function [ IntValue 42 ]);

  (* 测试列表参数错误 *)
  let transform = create_add_one_function () in
  let map_func = map_function [ transform ] in
  match map_func with
  | BuiltinFunctionValue func -> assert_runtime_error (fun () -> func [ StringValue "错误" ])
  | _ -> check bool "应该返回函数" false true

(** 测试用例：折叠函数基础功能测试 *)
let test_fold_function_basic () =
  (* 测试基本折叠功能 *)
  let add_func = create_add_function () in
  let fold_func = fold_function [ add_func ] in
  (match fold_func with
  | BuiltinFunctionValue func1 -> (
      let init_func = func1 [ IntValue 0 ] in
      match init_func with
      | BuiltinFunctionValue func2 ->
          let result = func2 [ ListValue [ IntValue 1; IntValue 2; IntValue 3 ] ] in
          check bool "折叠求和操作" true (result = IntValue 6)
      | _ -> check bool "初始化后应该返回函数" false true)
  | _ -> check bool "折叠函数应该返回函数" false true);

  (* 测试空列表折叠 *)
  let fold_func2 = fold_function [ add_func ] in
  match fold_func2 with
  | BuiltinFunctionValue func1 -> (
      let init_func = func1 [ IntValue 10 ] in
      match init_func with
      | BuiltinFunctionValue func2 ->
          let result = func2 [ ListValue [] ] in
          check bool "空列表折叠返回初始值" true (result = IntValue 10)
      | _ -> check bool "初始化后应该返回函数" false true)
  | _ -> check bool "折叠函数应该返回函数" false true

(** 测试用例：折叠函数错误处理测试 *)
let test_fold_function_error_handling () =
  (* 测试折叠函数参数错误 *)
  assert_runtime_error (fun () -> fold_function [ IntValue 42 ])

(** 测试用例：排序函数基础功能测试 *)
let test_sort_function_basic () =
  (* 测试整数排序 *)
  let result1 = sort_function [ ListValue [ IntValue 3; IntValue 1; IntValue 4; IntValue 2 ] ] in
  check bool "整数列表排序" true (result1 = ListValue [ IntValue 1; IntValue 2; IntValue 3; IntValue 4 ]);

  (* 测试浮点数排序 *)
  let result2 = sort_function [ ListValue [ FloatValue 3.5; FloatValue 1.2; FloatValue 2.8 ] ] in
  check bool "浮点数列表排序" true (result2 = ListValue [ FloatValue 1.2; FloatValue 2.8; FloatValue 3.5 ]);

  (* 测试字符串排序 *)
  let result3 = sort_function [ ListValue [ StringValue "c"; StringValue "a"; StringValue "b" ] ] in
  check bool "字符串排序" true (result3 = ListValue [ StringValue "a"; StringValue "b"; StringValue "c" ]);

  (* 测试空列表排序 *)
  let result4 = sort_function [ ListValue [] ] in
  check bool "空列表排序" true (result4 = ListValue [])

(** 测试用例：排序函数错误处理测试 *)
let test_sort_function_error_handling () =
  (* 测试非列表参数 *)
  assert_runtime_error (fun () -> sort_function [ IntValue 42 ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> sort_function [])

(** 测试用例：反转函数基础功能测试 *)
let test_reverse_function_basic () =
  (* 测试列表反转 *)
  let result1 = reverse_function [ ListValue [ IntValue 1; IntValue 2; IntValue 3 ] ] in
  check bool "列表反转功能" true (result1 = ListValue [ IntValue 3; IntValue 2; IntValue 1 ]);

  (* 测试空列表反转 *)
  let result2 = reverse_function [ ListValue [] ] in
  check bool "空列表反转" true (result2 = ListValue []);

  (* 测试字符串反转 - 使用ASCII字符避免UTF-8问题 *)
  let result3 = reverse_function [ StringValue "abc" ] in
  check bool "字符串反转功能" true (result3 = StringValue "cba");

  (* 测试空字符串反转 *)
  let result4 = reverse_function [ StringValue "" ] in
  check bool "空字符串反转" true (result4 = StringValue "")

(** 测试用例：反转函数错误处理测试 *)
let test_reverse_function_error_handling () =
  (* 测试错误的参数类型 *)
  assert_runtime_error (fun () -> reverse_function [ IntValue 42 ]);
  assert_runtime_error (fun () -> reverse_function [ BoolValue true ]);

  (* 测试参数数量错误 *)
  assert_runtime_error (fun () -> reverse_function []);
  assert_runtime_error (fun () -> reverse_function [ ListValue []; ListValue [] ])

(** 测试用例：包含函数基础功能测试 *)
let test_contains_function_basic () =
  (* 测试列表包含检查 *)
  let contains_func1 = contains_function [ IntValue 2 ] in
  (match contains_func1 with
  | BuiltinFunctionValue func ->
      let result1 = func [ ListValue [ IntValue 1; IntValue 2; IntValue 3 ] ] in
      check bool "列表包含元素" true (result1 = BoolValue true);

      let result2 = func [ ListValue [ IntValue 1; IntValue 3; IntValue 4 ] ] in
      check bool "列表不包含元素" true (result2 = BoolValue false)
  | _ -> check bool "包含函数应该返回函数" false true);

  (* 测试字符串包含检查 - 使用ASCII字符 *)
  let contains_func2 = contains_function [ StringValue "a" ] in
  (match contains_func2 with
  | BuiltinFunctionValue func ->
      let result1 = func [ StringValue "abc" ] in
      check bool "字符串包含字符" true (result1 = BoolValue true);

      let result2 = func [ StringValue "def" ] in
      check bool "字符串不包含字符" true (result2 = BoolValue false)
  | _ -> check bool "包含函数应该返回函数" false true);

  (* 测试空列表包含 *)
  let contains_func3 = contains_function [ IntValue 1 ] in
  match contains_func3 with
  | BuiltinFunctionValue func ->
      let result = func [ ListValue [] ] in
      check bool "空列表不包含任何元素" true (result = BoolValue false)
  | _ -> check bool "包含函数应该返回函数" false true

(** 测试用例：包含函数错误处理测试 *)
let test_contains_function_error_handling () =
  (* 测试集合参数类型错误 *)
  let contains_func = contains_function [ IntValue 1 ] in
  match contains_func with
  | BuiltinFunctionValue func -> assert_runtime_error (fun () -> func [ IntValue 42 ])
  | _ -> check bool "应该返回函数" false true

(** 测试用例：集合函数表完整性测试 *)
let test_collection_functions_table () =
  (* 验证所有预期的函数都在表中 *)
  let expected_functions = [ "长度"; "连接"; "过滤"; "映射"; "折叠"; "排序"; "反转"; "包含" ] in
  let actual_functions = List.map fst collection_functions in

  List.iter
    (fun name -> check bool (Printf.sprintf "函数表包含 %s" name) true (List.mem name actual_functions))
    expected_functions;

  (* 验证函数表长度 *)
  check bool "函数表包含8个函数" true (List.length collection_functions = 8);

  (* 验证每个函数都是BuiltinFunctionValue *)
  List.iter
    (fun (name, value) ->
      match value with
      | BuiltinFunctionValue _ -> check bool (Printf.sprintf "%s 是内置函数值" name) true true
      | _ -> check bool (Printf.sprintf "%s 应该是内置函数值" name) false true)
    collection_functions

(** 主测试套件 *)
let () =
  run "骆言Builtin_Collections内置集合函数模块增强测试覆盖 - Fix #1310"
    [
      ( "长度函数测试",
        [
          test_case "基础功能测试" `Quick test_length_function_basic;
          test_case "错误处理测试" `Quick test_length_function_error_handling;
        ] );
      ( "连接函数测试",
        [
          test_case "基础功能测试" `Quick test_concat_function_basic;
          test_case "错误处理测试" `Quick test_concat_function_error_handling;
        ] );
      ( "过滤函数测试",
        [
          test_case "基础功能测试" `Quick test_filter_function_basic;
          test_case "错误处理测试" `Quick test_filter_function_error_handling;
        ] );
      ( "映射函数测试",
        [
          test_case "基础功能测试" `Quick test_map_function_basic;
          test_case "错误处理测试" `Quick test_map_function_error_handling;
        ] );
      ( "折叠函数测试",
        [
          test_case "基础功能测试" `Quick test_fold_function_basic;
          test_case "错误处理测试" `Quick test_fold_function_error_handling;
        ] );
      ( "排序函数测试",
        [
          test_case "基础功能测试" `Quick test_sort_function_basic;
          test_case "错误处理测试" `Quick test_sort_function_error_handling;
        ] );
      ( "反转函数测试",
        [
          test_case "基础功能测试" `Quick test_reverse_function_basic;
          test_case "错误处理测试" `Quick test_reverse_function_error_handling;
        ] );
      ( "包含函数测试",
        [
          test_case "基础功能测试" `Quick test_contains_function_basic;
          test_case "错误处理测试" `Quick test_contains_function_error_handling;
        ] );
      ("集合函数表测试", [ test_case "函数表完整性验证" `Quick test_collection_functions_table ]);
    ]
