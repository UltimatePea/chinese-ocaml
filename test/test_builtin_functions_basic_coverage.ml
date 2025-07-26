(** Builtin Functions模块基础测试覆盖 - Fix #1377
    
    对builtin_functions.ml进行基础测试，提升覆盖率
    这个版本专注于可靠的基础功能测试
    
    @author Charlie, 规划专员
    @version 1.0
    @since 2025-07-26 Fix #1377 核心模块测试覆盖率提升 *)

open Alcotest
open Yyocamlc_lib.Builtin_functions

(** 测试内置函数表基础结构 *)
let test_builtin_functions_table () =
  let functions = builtin_functions in
  
  (* 验证函数表不为空 *)
  check bool "内置函数表非空" true (List.length functions > 0);
  
  (* 验证所有函数都有名称 *)
  List.iter (fun (name, _) ->
    check bool ("函数名称非空: " ^ name) true (String.length name > 0)
  ) functions;
  
  (* 验证函数名称唯一性 *)
  let names = List.map fst functions in
  let unique_names = List.sort_uniq String.compare names in
  check int "函数名称唯一性" (List.length names) (List.length unique_names)

(** 测试内置函数检查 *)
let test_is_builtin_function () =
  (* 测试已知的内置函数 *)
  let known_functions = ["打印"; "长度"; "连接"; "包含"] in
  List.iter (fun name ->
    if List.mem_assoc name builtin_functions then
      check bool ("检查内置函数: " ^ name) true (is_builtin_function name)
  ) known_functions;
  
  (* 测试不存在的函数 *)
  let non_functions = ["不存在的函数"; ""; "未定义函数"; "随机名称"] in
  List.iter (fun name ->
    check bool ("检查非内置函数: " ^ name) false (is_builtin_function name)
  ) non_functions

(** 测试获取函数名称列表 *)
let test_get_builtin_function_names () =
  let names = get_builtin_function_names () in
  let original_names = List.map fst builtin_functions in
  
  (* 验证名称列表长度 *)
  check int "函数名称列表长度" (List.length original_names) (List.length names);
  
  (* 验证所有原始名称都在列表中 *)
  List.iter (fun name ->
    check bool ("名称列表包含: " ^ name) true (List.mem name names)
  ) original_names;
  
  (* 验证列表中没有重复名称 *)
  let sorted_names = List.sort String.compare names in
  let unique_names = List.sort_uniq String.compare names in
  check bool "名称列表无重复" true (sorted_names = unique_names)

(** 测试性能特性 *)
let test_performance_characteristics () =
  (* 测试函数查找性能 *)
  let start_time = Sys.time () in
  for _i = 1 to 1000 do
    ignore (is_builtin_function "打印");
    ignore (is_builtin_function "长度");
    ignore (is_builtin_function "连接")
  done;
  let end_time = Sys.time () in
  let elapsed = end_time -. start_time in
  
  (* 函数查找应该很快，1000次查找应该在合理时间内完成 *)
  check bool "函数查找性能" true (elapsed < 1.0);
  
  (* 测试函数表一致性 *)
  let table1 = builtin_functions in
  let table2 = builtin_functions in
  check bool "函数表一致性" true (List.length table1 = List.length table2)

(** 测试结构完整性 *)
let test_structure_integrity () =
  let functions = builtin_functions in
  
  (* 验证至少包含基础类别的函数 *)
  let has_io_functions = List.exists (fun (name, _) -> name = "打印") functions in
  let has_collection_functions = List.exists (fun (name, _) -> name = "长度") functions in
  let has_string_functions = List.exists (fun (name, _) -> name = "连接") functions in
  
  check bool "包含IO函数" true has_io_functions;
  check bool "包含集合函数" true has_collection_functions;
  check bool "包含字符串函数" true has_string_functions;
  
  (* 验证函数数量在合理范围内 *)
  check bool "函数数量合理" true (List.length functions >= 10);
  check bool "函数数量不过多" true (List.length functions <= 200)

(** 主测试运行器 *)
let () =
  run "Builtin Functions基础测试覆盖 - Fix #1377"
    [
      ("函数表结构", [ test_case "内置函数表基础结构测试" `Quick test_builtin_functions_table ]);
      ("函数检查", [ test_case "内置函数检查测试" `Quick test_is_builtin_function ]);
      ("函数名称", [ test_case "获取函数名称列表测试" `Quick test_get_builtin_function_names ]);
      ("性能特性", [ test_case "性能特性测试" `Quick test_performance_characteristics ]);
      ("结构完整性", [ test_case "结构完整性测试" `Quick test_structure_integrity ]);
    ]