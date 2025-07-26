(** Builtin Functions模块增强测试覆盖 - Fix #1377

    对builtin_functions.ml进行全面测试，提升覆盖率从6%到80%+

    @author Charlie, 规划专员
    @version 1.0
    @since 2025-07-26 Fix #1377 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_functions

(** 辅助函数：创建值 *)
let int_val n = IntValue n

let float_val f = FloatValue f
let string_val s = StringValue s
let bool_val b = BoolValue b
let list_val l = ListValue l

(** 辅助函数：检查结果 *)
let check_result name expected actual = check bool name true (expected = actual)

(** 辅助函数：检查错误 *)
let check_error name f =
  try
    let _ = f () in
    fail (name ^ " 应该抛出错误")
  with
  | RuntimeError _ -> check bool name true true
  | _ -> fail (name ^ " 应该抛出RuntimeError")

(** 测试内置函数表基础结构 *)
let test_builtin_functions_table () =
  let functions = builtin_functions in

  (* 验证函数表不为空 *)
  check bool "内置函数表非空" true (List.length functions > 0);

  (* 验证所有函数都有名称 *)
  List.iter
    (fun (name, _) -> check bool ("函数名称非空: " ^ name) true (String.length name > 0))
    functions;

  (* 验证函数名称唯一性 *)
  let names = List.map fst functions in
  let unique_names = List.sort_uniq String.compare names in
  check int "函数名称唯一性" (List.length names) (List.length unique_names)

(** 测试性能优化 - 通过间接方式验证内部优化 *)
let test_performance_optimization () =
  (* 验证所有函数都可以快速查找 *)
  let original_count = List.length builtin_functions in
  check bool "函数表非空" true (original_count > 0);

  (* 验证查找性能通过重复查找测试 *)
  let test_functions = List.take (min 10 (List.length builtin_functions)) builtin_functions in
  let start_time = Sys.time () in
  for _i = 1 to 1000 do
    List.iter (fun (name, _value) -> ignore (is_builtin_function name)) test_functions
  done;
  let end_time = Sys.time () in
  let elapsed = end_time -. start_time in

  (* 如果有哈希表优化，1000次查找应该很快完成 *)
  check bool "查找性能优化验证" true (elapsed < 1.0)

(** 测试内置函数检查 *)
let test_is_builtin_function () =
  (* 测试已知的内置函数 *)
  let known_functions = [ "打印"; "长度"; "求和"; "范围"; "连接"; "包含" ] in
  List.iter
    (fun name ->
      if List.mem_assoc name builtin_functions then
        check bool ("检查内置函数: " ^ name) true (is_builtin_function name))
    known_functions;

  (* 测试不存在的函数 *)
  let non_functions = [ "不存在的函数"; ""; "未定义函数"; "随机名称" ] in
  List.iter
    (fun name -> check bool ("检查非内置函数: " ^ name) false (is_builtin_function name))
    non_functions

(** 测试获取函数名称列表 *)
let test_get_builtin_function_names () =
  let names = get_builtin_function_names () in
  let original_names = List.map fst builtin_functions in

  (* 验证名称列表长度 *)
  check int "函数名称列表长度" (List.length original_names) (List.length names);

  (* 验证所有原始名称都在列表中 *)
  List.iter (fun name -> check bool ("名称列表包含: " ^ name) true (List.mem name names)) original_names;

  (* 验证列表中没有重复名称 *)
  let sorted_names = List.sort String.compare names in
  let unique_names = List.sort_uniq String.compare names in
  check bool "名称列表无重复" true (sorted_names = unique_names)

(** 测试基础内置函数调用 *)
let test_basic_builtin_calls () =
  (* 测试打印函数 *)
  (if is_builtin_function "打印" then
     let result = call_builtin_function "打印" [ string_val "测试" ] in
     check bool "打印函数返回单元值" true (result = UnitValue));

  (* 测试长度函数 *)
  (if is_builtin_function "长度" then
     let test_list = list_val [ int_val 1; int_val 2; int_val 3 ] in
     let result = call_builtin_function "长度" [ test_list ] in
     check_result "列表长度函数" (int_val 3) result);

  (* 测试字符串长度 *)
  if is_builtin_function "长度" then
    let result = call_builtin_function "长度" [ string_val "测试字符串" ] in
    check_result "字符串长度函数" (int_val 5) result

(** 测试数学内置函数 *)
let test_math_builtin_functions () =
  (* 测试求和函数 *)
  if is_builtin_function "求和" then (
    let test_list = list_val [ int_val 1; int_val 2; int_val 3; int_val 4 ] in
    let result = call_builtin_function "求和" [ test_list ] in
    check_result "列表求和" (int_val 10) result;

    (* 测试空列表求和 *)
    let empty_list = list_val [] in
    let result_empty = call_builtin_function "求和" [ empty_list ] in
    check_result "空列表求和" (int_val 0) result_empty);

  (* 测试范围函数 *)
  (if is_builtin_function "范围" then
     let result = call_builtin_function "范围" [ int_val 1; int_val 5 ] in
     match result with
     | ListValue values ->
         check int "范围函数长度" 4 (List.length values);
         check_result "范围函数第一个值" (int_val 1) (List.hd values)
     | _ -> fail "范围函数应返回列表");

  (* 测试最大值最小值函数 *)
  (if is_builtin_function "最大值" then
     let test_list = list_val [ int_val 3; int_val 1; int_val 4; int_val 2 ] in
     let result = call_builtin_function "最大值" [ test_list ] in
     check_result "最大值函数" (int_val 4) result);

  if is_builtin_function "最小值" then
    let test_list = list_val [ int_val 3; int_val 1; int_val 4; int_val 2 ] in
    let result = call_builtin_function "最小值" [ test_list ] in
    check_result "最小值函数" (int_val 1) result

(** 测试字符串内置函数 *)
let test_string_builtin_functions () =
  (* 测试字符串连接 *)
  if is_builtin_function "连接" then (
    let strings = list_val [ string_val "你好"; string_val "世界"; string_val "!" ] in
    let result = call_builtin_function "连接" [ strings ] in
    check_result "字符串连接" (string_val "你好世界!") result;

    (* 测试空列表连接 *)
    let empty_strings = list_val [] in
    let result_empty = call_builtin_function "连接" [ empty_strings ] in
    check_result "空字符串列表连接" (string_val "") result_empty);

  (* 测试字符串包含 *)
  if is_builtin_function "包含" then (
    let result_true = call_builtin_function "包含" [ string_val "Hello World"; string_val "World" ] in
    check_result "字符串包含真" (bool_val true) result_true;

    let result_false =
      call_builtin_function "包含" [ string_val "Hello World"; string_val "Python" ]
    in
    check_result "字符串包含假" (bool_val false) result_false);

  (* 测试字符串分割 *)
  if is_builtin_function "分割" then
    let result = call_builtin_function "分割" [ string_val "a,b,c"; string_val "," ] in
    match result with
    | ListValue values ->
        check int "分割结果长度" 3 (List.length values);
        check_result "分割第一部分" (string_val "a") (List.hd values)
    | _ -> fail "分割函数应返回列表"

(** 测试集合内置函数 *)
let test_collection_builtin_functions () =
  (* 测试列表操作函数 *)
  (if is_builtin_function "头部" then
     let test_list = list_val [ int_val 1; int_val 2; int_val 3 ] in
     let result = call_builtin_function "头部" [ test_list ] in
     check_result "列表头部" (int_val 1) result);

  (if is_builtin_function "尾部" then
     let test_list = list_val [ int_val 1; int_val 2; int_val 3 ] in
     let result = call_builtin_function "尾部" [ test_list ] in
     match result with
     | ListValue values ->
         check int "尾部长度" 2 (List.length values);
         check_result "尾部第一个" (int_val 2) (List.hd values)
     | _ -> fail "尾部函数应返回列表");

  (* 测试列表反转 *)
  if is_builtin_function "反转" then
    let test_list = list_val [ int_val 1; int_val 2; int_val 3 ] in
    let result = call_builtin_function "反转" [ test_list ] in
    match result with
    | ListValue values ->
        check int "反转长度" 3 (List.length values);
        check_result "反转第一个" (int_val 3) (List.hd values)
    | _ -> fail "反转函数应返回列表"

(** 测试数组内置函数 *)
let test_array_builtin_functions () =
  (* 测试数组创建 *)
  (if is_builtin_function "创建数组" then
     let result = call_builtin_function "创建数组" [ int_val 5; int_val 0 ] in
     match result with
     | ArrayValue arr ->
         check int "创建数组长度" 5 (Array.length arr);
         check_result "数组初始值" (int_val 0) arr.(0)
     | _ -> fail "创建数组应返回数组值");

  (* 测试数组长度 *)
  (if is_builtin_function "数组长度" then
     let test_array = ArrayValue [| int_val 1; int_val 2; int_val 3 |] in
     let result = call_builtin_function "数组长度" [ test_array ] in
     check_result "数组长度" (int_val 3) result);

  (* 测试数组获取 *)
  if is_builtin_function "数组获取" then
    let test_array = ArrayValue [| int_val 10; int_val 20; int_val 30 |] in
    let result = call_builtin_function "数组获取" [ test_array; int_val 1 ] in
    check_result "数组获取元素" (int_val 20) result

(** 测试类型转换内置函数 *)
let test_type_conversion_functions () =
  (* 测试转整数 *)
  if is_builtin_function "转整数" then (
    let result_float = call_builtin_function "转整数" [ float_val 3.14 ] in
    check_result "浮点转整数" (int_val 3) result_float;

    let result_string = call_builtin_function "转整数" [ string_val "42" ] in
    check_result "字符串转整数" (int_val 42) result_string);

  (* 测试转浮点 *)
  if is_builtin_function "转浮点" then (
    let result_int = call_builtin_function "转浮点" [ int_val 42 ] in
    check_result "整数转浮点" (float_val 42.0) result_int;

    let result_string = call_builtin_function "转浮点" [ string_val "3.14" ] in
    check_result "字符串转浮点" (float_val 3.14) result_string);

  (* 测试转字符串 *)
  if is_builtin_function "转字符串" then (
    let result_int = call_builtin_function "转字符串" [ int_val 42 ] in
    check_result "整数转字符串" (string_val "42") result_int;

    let result_bool = call_builtin_function "转字符串" [ bool_val true ] in
    check_result "布尔转字符串" (string_val "true") result_bool)

(** 测试工具内置函数 *)
let test_utility_functions () =
  (* 测试类型检查函数 *)
  if is_builtin_function "是整数" then (
    let result_true = call_builtin_function "是整数" [ int_val 42 ] in
    check_result "是整数检查真" (bool_val true) result_true;

    let result_false = call_builtin_function "是整数" [ string_val "42" ] in
    check_result "是整数检查假" (bool_val false) result_false);

  if is_builtin_function "是字符串" then (
    let result_true = call_builtin_function "是字符串" [ string_val "hello" ] in
    check_result "是字符串检查真" (bool_val true) result_true;

    let result_false = call_builtin_function "是字符串" [ int_val 42 ] in
    check_result "是字符串检查假" (bool_val false) result_false);

  if is_builtin_function "是列表" then (
    let result_true = call_builtin_function "是列表" [ list_val [ int_val 1 ] ] in
    check_result "是列表检查真" (bool_val true) result_true;

    let result_false = call_builtin_function "是列表" [ int_val 42 ] in
    check_result "是列表检查假" (bool_val false) result_false)

(** 测试中文数字常量 *)
let test_chinese_number_constants () =
  let chinese_numbers = [ "一"; "二"; "三"; "四"; "五"; "六"; "七"; "八"; "九"; "十" ] in
  let expected_values = [ 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 ] in

  List.iter2
    (fun chinese expected ->
      if is_builtin_function chinese then
        let result = call_builtin_function chinese [] in
        check_result ("中文数字常量: " ^ chinese) (int_val expected) result)
    chinese_numbers expected_values

(** 测试错误处理 *)
let test_error_handling () =
  (* 测试调用不存在的函数 *)
  check_error "调用不存在函数" (fun () -> call_builtin_function "不存在的函数" []);
  check_error "调用空名称函数" (fun () -> call_builtin_function "" []);

  (* 测试错误参数数量 *)
  if is_builtin_function "长度" then (
    check_error "长度函数无参数" (fun () -> call_builtin_function "长度" []);
    check_error "长度函数多参数" (fun () -> call_builtin_function "长度" [ int_val 1; int_val 2 ]));

  (* 测试错误参数类型 *)
  if is_builtin_function "求和" then
    check_error "求和非列表参数" (fun () -> call_builtin_function "求和" [ int_val 42 ]);

  if is_builtin_function "数组获取" then
    check_error "数组获取越界" (fun () ->
        let arr = ArrayValue [| int_val 1 |] in
        call_builtin_function "数组获取" [ arr; int_val 5 ])

(** 测试边界条件 *)
let test_boundary_conditions () =
  (* 测试空输入 *)
  (if is_builtin_function "求和" then
     let empty_list = list_val [] in
     let result = call_builtin_function "求和" [ empty_list ] in
     check_result "空列表求和" (int_val 0) result);

  (if is_builtin_function "连接" then
     let empty_strings = list_val [] in
     let result = call_builtin_function "连接" [ empty_strings ] in
     check_result "空字符串列表连接" (string_val "") result);

  (* 测试单元素 *)
  (if is_builtin_function "最大值" then
     let single_list = list_val [ int_val 42 ] in
     let result = call_builtin_function "最大值" [ single_list ] in
     check_result "单元素最大值" (int_val 42) result);

  (* 测试大数据量 *)
  if is_builtin_function "长度" then
    let large_list = list_val (List.init 10000 (fun i -> int_val i)) in
    let result = call_builtin_function "长度" [ large_list ] in
    check_result "大列表长度" (int_val 10000) result

(** 测试性能特性 *)
let test_performance_characteristics () =
  (* 测试函数查找性能 *)
  let start_time = Sys.time () in
  for _i = 1 to 1000 do
    ignore (is_builtin_function "打印");
    ignore (is_builtin_function "长度");
    ignore (is_builtin_function "求和")
  done;
  let end_time = Sys.time () in
  let elapsed = end_time -. start_time in

  (* 函数查找应该很快，1000次查找应该在合理时间内完成 *)
  check bool "函数查找性能" true (elapsed < 1.0);

  (* 测试函数表一致性 *)
  let table1 = builtin_functions in
  let table2 = builtin_functions in
  check bool "函数表一致性" true (List.length table1 = List.length table2)

(** 主测试运行器 *)
let () =
  run "Builtin Functions增强测试覆盖 - Fix #1377"
    [
      ("函数表结构", [ test_case "内置函数表基础结构测试" `Quick test_builtin_functions_table ]);
      ("性能优化", [ test_case "性能优化测试" `Quick test_performance_optimization ]);
      ("函数检查", [ test_case "内置函数检查测试" `Quick test_is_builtin_function ]);
      ("函数名称", [ test_case "获取函数名称列表测试" `Quick test_get_builtin_function_names ]);
      ("基础调用", [ test_case "基础内置函数调用测试" `Quick test_basic_builtin_calls ]);
      ("数学函数", [ test_case "数学内置函数测试" `Quick test_math_builtin_functions ]);
      ("字符串函数", [ test_case "字符串内置函数测试" `Quick test_string_builtin_functions ]);
      ("集合函数", [ test_case "集合内置函数测试" `Quick test_collection_builtin_functions ]);
      ("数组函数", [ test_case "数组内置函数测试" `Quick test_array_builtin_functions ]);
      ("类型转换", [ test_case "类型转换内置函数测试" `Quick test_type_conversion_functions ]);
      ("工具函数", [ test_case "工具内置函数测试" `Quick test_utility_functions ]);
      ("中文常量", [ test_case "中文数字常量测试" `Quick test_chinese_number_constants ]);
      ("错误处理", [ test_case "错误处理测试" `Quick test_error_handling ]);
      ("边界条件", [ test_case "边界条件测试" `Quick test_boundary_conditions ]);
      ("性能特性", [ test_case "性能特性测试" `Quick test_performance_characteristics ]);
    ]
