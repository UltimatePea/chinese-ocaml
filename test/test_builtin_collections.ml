(** 骆言内置集合操作函数模块测试 - Chinese Programming Language Builtin Collection Functions Tests *)

open Alcotest
open Yyocamlc_lib.Value_operations
open Yyocamlc_lib.Builtin_collections

(** 测试工具函数 *)
let create_test_list values = ListValue values
let create_test_string s = StringValue s
let create_test_int i = IntValue i
let create_test_bool b = BoolValue b

let extract_value_from_builtin_function func args =
  match func with
  | BuiltinFunctionValue f -> f args
  | _ -> failwith "期望内置函数值"

(* 检查运行时值是否相等 *)
let check_runtime_value msg expected actual =
  let value_to_string = function
    | IntValue i -> "IntValue(" ^ string_of_int i ^ ")"
    | FloatValue f -> "FloatValue(" ^ string_of_float f ^ ")"
    | StringValue s -> "StringValue(\"" ^ s ^ "\")"
    | BoolValue b -> "BoolValue(" ^ string_of_bool b ^ ")"
    | UnitValue -> "UnitValue"
    | ListValue _ -> "ListValue(...)"
    | _ -> "OtherValue"
  in
  let pp_runtime_value ppf v = Fmt.string ppf (value_to_string v) in
  let runtime_value_testable = testable pp_runtime_value (=) in
  check runtime_value_testable msg expected actual

(** 长度函数测试套件 *)
let test_length_function () =
  (* 测试列表长度 *)
  let test_list = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3] in
  let result = length_function [test_list] in
  check_runtime_value "列表长度测试" (IntValue 3) result;
  
  (* 测试空列表长度 *)
  let empty_list = create_test_list [] in
  let result = length_function [empty_list] in
  check_runtime_value "空列表长度测试" (IntValue 0) result;
  
  (* 测试字符串长度 *)
  let test_string = create_test_string "骆言" in
  let result = length_function [test_string] in
  check_runtime_value "字符串长度测试" (IntValue 2) result

(** 连接函数测试套件 *)
let test_concat_function () =
  (* 测试列表连接 *)
  let list1 = create_test_list [create_test_int 1; create_test_int 2] in
  let list2 = create_test_list [create_test_int 3; create_test_int 4] in
  let concat_func = concat_function [list1] in
  let result = extract_value_from_builtin_function concat_func [list2] in
  let expected = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3; create_test_int 4] in
  check_runtime_value "列表连接测试" expected result;
  
  (* 测试空列表连接 *)
  let empty_list = create_test_list [] in
  let non_empty_list = create_test_list [create_test_int 1] in
  let concat_func = concat_function [empty_list] in
  let result = extract_value_from_builtin_function concat_func [non_empty_list] in
  check_runtime_value "空列表连接测试" non_empty_list result

(** 过滤函数测试套件 *)
let test_filter_function () =
  (* 创建简单谓词函数 - 过滤奇数 *)
  let is_odd_func = BuiltinFunctionValue (function
    | [IntValue n] -> BoolValue (n mod 2 = 1)
    | _ -> BoolValue false) in
  
  (* 测试过滤功能 *)
  let test_list = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3; create_test_int 4; create_test_int 5] in
  let filter_func = filter_function [is_odd_func] in
  let result = extract_value_from_builtin_function filter_func [test_list] in
  let expected = create_test_list [create_test_int 1; create_test_int 3; create_test_int 5] in
  check_runtime_value "过滤奇数测试" expected result;
  
  (* 测试空列表过滤 *)
  let empty_list = create_test_list [] in
  let filter_func = filter_function [is_odd_func] in
  let result = extract_value_from_builtin_function filter_func [empty_list] in
  check_runtime_value "空列表过滤测试" empty_list result

(** 映射函数测试套件 *)
let test_map_function () =
  (* 创建简单映射函数 - 每个数字加1 *)
  let add_one_func = BuiltinFunctionValue (function
    | [IntValue n] -> IntValue (n + 1)
    | _ -> IntValue 0) in
  
  (* 测试映射功能 *)
  let test_list = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3] in
  let map_func = map_function [add_one_func] in
  let result = extract_value_from_builtin_function map_func [test_list] in
  let expected = create_test_list [create_test_int 2; create_test_int 3; create_test_int 4] in
  check_runtime_value "映射测试" expected result;
  
  (* 测试空列表映射 *)
  let empty_list = create_test_list [] in
  let map_func = map_function [add_one_func] in
  let result = extract_value_from_builtin_function map_func [empty_list] in
  check_runtime_value "空列表映射测试" empty_list result

(** 折叠函数测试套件 *)
let test_fold_function () =
  (* 创建简单折叠函数 - 累加 *)
  let add_func = BuiltinFunctionValue (function
    | [IntValue a; IntValue b] -> IntValue (a + b)
    | _ -> IntValue 0) in
  
  (* 测试折叠功能 *)
  let test_list = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3; create_test_int 4] in
  let fold_func = fold_function [add_func] in
  let fold_with_init = extract_value_from_builtin_function fold_func [create_test_int 0] in
  let result = extract_value_from_builtin_function fold_with_init [test_list] in
  check_runtime_value "折叠累加测试" (create_test_int 10) result;
  
  (* 测试空列表折叠 *)
  let empty_list = create_test_list [] in
  let fold_func = fold_function [add_func] in
  let fold_with_init = extract_value_from_builtin_function fold_func [create_test_int 5] in
  let result = extract_value_from_builtin_function fold_with_init [empty_list] in
  check_runtime_value "空列表折叠测试" (create_test_int 5) result

(** 排序函数测试套件 *)
let test_sort_function () =
  (* 测试整数排序 *)
  let int_list = create_test_list [create_test_int 3; create_test_int 1; create_test_int 4; create_test_int 2] in
  let result = sort_function [int_list] in
  let expected = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3; create_test_int 4] in
  check_runtime_value "整数排序测试" expected result;
  
  (* 测试字符串排序 *)
  let string_list = create_test_list [create_test_string "丙"; create_test_string "甲"; create_test_string "乙"] in
  let result = sort_function [string_list] in
  let expected = create_test_list [create_test_string "乙"; create_test_string "丙"; create_test_string "甲"] in
  check_runtime_value "字符串排序测试" expected result;
  
  (* 测试空列表排序 *)
  let empty_list = create_test_list [] in
  let result = sort_function [empty_list] in
  check_runtime_value "空列表排序测试" empty_list result

(** 反转函数测试套件 *)
let test_reverse_function () =
  (* 测试列表反转 *)
  let test_list = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3] in
  let result = reverse_function [test_list] in
  let expected = create_test_list [create_test_int 3; create_test_int 2; create_test_int 1] in
  check_runtime_value "列表反转测试" expected result;
  
  (* 测试字符串反转 *)
  let test_string = create_test_string "骆言" in
  let result = reverse_function [test_string] in
  let expected = create_test_string "言骆" in
  check_runtime_value "字符串反转测试" expected result;
  
  (* 测试空列表反转 *)
  let empty_list = create_test_list [] in
  let result = reverse_function [empty_list] in
  check_runtime_value "空列表反转测试" empty_list result

(** 包含函数测试套件 *)
let test_contains_function () =
  (* 测试列表包含 *)
  let test_list = create_test_list [create_test_int 1; create_test_int 2; create_test_int 3] in
  let contains_func = contains_function [create_test_int 2] in
  let result = extract_value_from_builtin_function contains_func [test_list] in
  check_runtime_value "列表包含测试" (create_test_bool true) result;
  
  (* 测试列表不包含 *)
  let contains_func = contains_function [create_test_int 5] in
  let result = extract_value_from_builtin_function contains_func [test_list] in
  check_runtime_value "列表不包含测试" (create_test_bool false) result;
  
  (* 测试字符串包含 *)
  let test_string = create_test_string "骆言编程" in
  let contains_func = contains_function [create_test_string "骆"] in
  let result = extract_value_from_builtin_function contains_func [test_string] in
  check_runtime_value "字符串包含测试" (create_test_bool true) result

(** 集合函数表测试套件 *)
let test_collection_functions_table () =
  (* 验证所有函数都在表中 *)
  let expected_functions = ["长度"; "连接"; "过滤"; "映射"; "折叠"; "排序"; "反转"; "包含"] in
  let actual_functions = List.map fst collection_functions in
  List.iter (fun expected ->
    check bool ("函数表包含" ^ expected) true (List.mem expected actual_functions)
  ) expected_functions;
  
  (* 验证函数表长度 *)
  check int "函数表长度" 8 (List.length collection_functions)

(** 边界条件和异常测试套件 *)
let test_edge_cases () =
  (* 测试单元素列表 *)
  let single_list = create_test_list [create_test_int 42] in
  let result = length_function [single_list] in
  check_runtime_value "单元素列表长度" (create_test_int 1) result;
  
  (* 测试单字符字符串 *)
  let single_char = create_test_string "骆" in
  let result = length_function [single_char] in
  check_runtime_value "单字符字符串长度" (create_test_int 1) result;
  
  (* 测试大列表操作 *)
  let large_list = create_test_list (List.init 100 (fun i -> create_test_int i)) in
  let result = length_function [large_list] in
  check_runtime_value "大列表长度" (create_test_int 100) result

(** 主测试套件 *)
let () =
  run "骆言内置集合操作函数模块测试" [
    ("长度函数", [test_case "长度函数测试" `Quick test_length_function]);
    ("连接函数", [test_case "连接函数测试" `Quick test_concat_function]);
    ("过滤函数", [test_case "过滤函数测试" `Quick test_filter_function]);
    ("映射函数", [test_case "映射函数测试" `Quick test_map_function]);
    ("折叠函数", [test_case "折叠函数测试" `Quick test_fold_function]);
    ("排序函数", [test_case "排序函数测试" `Quick test_sort_function]);
    ("反转函数", [test_case "反转函数测试" `Quick test_reverse_function]);
    ("包含函数", [test_case "包含函数测试" `Quick test_contains_function]);
    ("函数表", [test_case "集合函数表测试" `Quick test_collection_functions_table]);
    ("边界条件", [test_case "边界条件测试" `Quick test_edge_cases]);
  ]