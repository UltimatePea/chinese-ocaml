(** 骆言类型系统性能优化模块全面测试 - Types_cache Module Comprehensive Tests *)

open Alcotest
open Yyocamlc_lib.Core_types
open Yyocamlc_lib.Ast
open Yyocamlc_lib.Types_cache

(** 测试辅助函数 *)
let create_simple_expr name = VarExpr name
let create_binary_expr left op right = BinaryOpExpr (left, op, right)
let create_literal_expr lit = LitExpr lit

let sample_int_type = IntType_T
let sample_string_type = StringType_T
let sample_bool_type = BoolType_T

let sample_substitution = SubstMap.empty

(** 缓存基础操作测试 *)
let test_cache_basic_operations () =
  (* 重置缓存以确保干净状态 *)
  reset_stats ();
  
  let expr = create_simple_expr "test_var" in
  let subst = sample_substitution in
  let typ = sample_int_type in
  
  (* 初始状态：缓存中应该没有这个表达式 *)
  let initial_result = cache_lookup expr in
  check bool "初始状态缓存应该为空" true (initial_result = None);
  
  (* 存储到缓存 *)
  cache_store expr subst typ;
  
  (* 现在应该能够从缓存中找到 *)
  let cached_result = cache_lookup expr in
  check bool "缓存存储后应该能找到结果" true (cached_result <> None);
  
  (* 验证缓存大小 *)
  let size = cache_size () in
  check int "缓存大小应该为1" 1 size

let test_cache_miss_and_hit_statistics () =
  (* 重置缓存统计 *)
  reset_stats ();
  
  let expr1 = create_simple_expr "miss_test" in
  let expr2 = create_simple_expr "hit_test" in
  
  (* 第一次查找应该是miss *)
  let _ = cache_lookup expr1 in
  let (_, _, _, hits1, misses1) = get_cache_stats () in
  check int "第一次查找应该是miss" 0 hits1;
  check int "miss计数应该为1" 1 misses1;
  
  (* 存储后查找应该是hit *)
  cache_store expr2 sample_substitution sample_string_type;
  let _ = cache_lookup expr2 in
  let (_, _, _, hits2, misses2) = get_cache_stats () in
  check int "存储后查找应该是hit" 1 hits2;
  check int "miss计数应该保持" 1 misses2

let test_cache_clear_operations () =
  (* 先添加一些缓存项 *)
  cache_store (create_simple_expr "item1") sample_substitution sample_int_type;
  cache_store (create_simple_expr "item2") sample_substitution sample_string_type;
  
  let initial_size = cache_size () in
  check bool "缓存应该包含项目" true (initial_size > 0);
  
  (* 清空缓存 *)
  cache_clear ();
  
  let final_size = cache_size () in
  check int "清空后缓存大小应该为0" 0 final_size

(** 性能统计测试 *)
let test_performance_stats_basic () =
  (* 重置统计 *)
  reset_stats ();
  
  let (initial_infer, initial_unify, initial_subst, _, _) = get_cache_stats () in
  check int "初始推断调用数应该为0" 0 initial_infer;
  check int "初始合一调用数应该为0" 0 initial_unify;
  check int "初始替换应用数应该为0" 0 initial_subst

let test_cache_enable_disable () =
  (* 默认应该启用 *)
  check bool "缓存默认应该启用" true (is_cache_enabled ());
  
  (* 禁用缓存 *)
  disable_cache ();
  check bool "禁用后缓存应该不可用" false (is_cache_enabled ());
  
  (* 重新启用 *)
  enable_cache ();
  check bool "重新启用后缓存应该可用" true (is_cache_enabled ())

(** 缓存工作流程集成测试 *)
let test_cache_integration_workflow () =
  (* 重置环境 *)
  reset_stats ();
  enable_cache ();
  
  let expr1 = create_simple_expr "integration_test_1" in
  let expr2 = create_simple_expr "integration_test_2" in
  
  (* 模拟完整的缓存工作流程 *)
  
  (* 1. 查找不存在的项目（miss） *)
  let result1 = cache_lookup expr1 in
  check bool "初始查找应该失败" true (result1 = None);
  
  (* 2. 存储项目 *)
  cache_store expr1 sample_substitution sample_int_type;
  cache_store expr2 sample_substitution sample_string_type;
  
  (* 3. 查找已存储的项目（hit） *)
  let result2 = cache_lookup expr1 in
  check bool "存储后查找应该成功" true (result2 <> None);
  
  (* 4. 验证缓存状态 *)
  let cache_sz = cache_size () in
  check int "缓存应该包含2个项目" 2 cache_sz;
  
  (* 5. 清空并验证 *)
  cache_clear ();
  let final_size = cache_size () in
  check int "清空后大小应该为0" 0 final_size

(** 缓存性能测试 *)
let test_cache_performance_impact () =
  (* 重置环境 *)
  reset_stats ();
  
  (* 创建多个表达式进行性能测试 *)
  let expressions = [
    create_simple_expr "perf_test_1";
    create_simple_expr "perf_test_2";
    create_binary_expr (create_simple_expr "x") Add (create_simple_expr "y");
    create_literal_expr (IntLit 42);
    create_literal_expr (StringLit "test");
  ] in
  
  (* 存储所有表达式到缓存 *)
  List.iteri (fun i expr ->
    let typ = if i mod 2 = 0 then sample_int_type else sample_string_type in
    cache_store expr sample_substitution typ
  ) expressions;
  
  (* 验证所有表达式都能从缓存中找到 *)
  let all_found = List.for_all (fun expr ->
    match cache_lookup expr with
    | Some _ -> true
    | None -> false
  ) expressions in
  
  check bool "所有表达式都应该在缓存中找到" true all_found;
  
  (* 验证缓存大小 *)
  let final_size = cache_size () in
  check int "缓存大小应该等于表达式数量" (List.length expressions) final_size

(** 缓存统计接口测试 *)
let test_cache_statistics_interface () =
  (* 重置统计并验证接口 *)
  reset_stats ();
  
  let (infer, unify, subst, hits, misses) = get_cache_stats () in
  check int "统计接口：推断调用数" 0 infer;
  check int "统计接口：合一调用数" 0 unify;
  check int "统计接口：替换应用数" 0 subst;
  check int "统计接口：缓存命中数" 0 hits;
  check int "统计接口：缓存未命中数" 0 misses

let test_performance_reporting () =
  (* 这个测试主要验证性能报告函数不会崩溃 *)
  (* 由于print_performance_stats依赖于debug模式，我们只测试它能正常调用 *)
  print_performance_stats ();
  (* 如果到达这里，说明函数调用成功 *)
  check bool "性能报告函数应该正常执行" true true

(** 缓存一致性测试 *)
let test_cache_consistency () =
  (* 重置缓存 *)
  reset_stats ();
  
  let expr = create_simple_expr "consistency_test" in
  
  (* 存储类型A *)
  cache_store expr sample_substitution sample_int_type;
  
  let result1 = cache_lookup expr in
  check bool "第一次查找应该成功" true (result1 <> None);
  
  (* 覆盖存储类型B（测试缓存更新） *)
  cache_store expr sample_substitution sample_string_type;
  
  let result2 = cache_lookup expr in
  check bool "覆盖后查找应该成功" true (result2 <> None);
  
  (* 缓存大小应该仍为1（相同表达式覆盖） *)
  let size = cache_size () in
  check int "覆盖后缓存大小应该仍为1" 1 size

(** 多种表达式类型缓存测试 *)
let test_different_expression_types () =
  reset_stats ();
  
  let var_expr = VarExpr "variable" in
  let lit_expr = LitExpr (IntLit 100) in
  let bin_expr = BinaryOpExpr (VarExpr "a", Add, VarExpr "b") in
  
  (* 存储不同类型的表达式 *)
  cache_store var_expr sample_substitution sample_int_type;
  cache_store lit_expr sample_substitution sample_string_type;
  cache_store bin_expr sample_substitution sample_bool_type;
  
  (* 验证都能找到 *)
  check bool "变量表达式应该在缓存中" true (cache_lookup var_expr <> None);
  check bool "字面量表达式应该在缓存中" true (cache_lookup lit_expr <> None);
  check bool "二元表达式应该在缓存中" true (cache_lookup bin_expr <> None);
  
  (* 验证缓存大小 *)
  check int "缓存应该包含3个不同表达式" 3 (cache_size ())

(** 缓存边界条件测试 *)
let test_cache_boundary_conditions () =
  reset_stats ();
  
  (* 测试空表达式名称 *)
  let empty_name_expr = VarExpr "" in
  cache_store empty_name_expr sample_substitution sample_int_type;
  check bool "空名称表达式应该能缓存" true (cache_lookup empty_name_expr <> None);
  
  (* 测试相同表达式多次查找 *)
  let test_expr = VarExpr "repeated_lookup" in
  cache_store test_expr sample_substitution sample_string_type;
  
  (* 多次查找应该都成功 *)
  for _i = 1 to 5 do
    let result = cache_lookup test_expr in
    check bool "重复查找应该成功" true (result <> None)
  done;
  
  (* 验证缓存命中统计 *)
  let (_, _, _, hits, _) = get_cache_stats () in
  check bool "应该有多次缓存命中" true (hits >= 5)

(** 测试套件定义 *)
let cache_operations_tests = [
  "缓存基础操作测试", `Quick, test_cache_basic_operations;
  "缓存命中未命中统计测试", `Quick, test_cache_miss_and_hit_statistics;
  "缓存清空操作测试", `Quick, test_cache_clear_operations;
]

let performance_stats_tests = [
  "性能统计基础测试", `Quick, test_performance_stats_basic;
  "缓存启用禁用测试", `Quick, test_cache_enable_disable;
]

let integration_tests = [
  "缓存集成工作流程测试", `Quick, test_cache_integration_workflow;
  "缓存性能影响测试", `Quick, test_cache_performance_impact;
]

let cache_management_tests = [
  "缓存统计接口测试", `Quick, test_cache_statistics_interface;
  "性能报告测试", `Quick, test_performance_reporting;
]

let consistency_tests = [
  "缓存一致性测试", `Quick, test_cache_consistency;
  "不同表达式类型缓存测试", `Quick, test_different_expression_types;
  "缓存边界条件测试", `Quick, test_cache_boundary_conditions;
]

(** 主测试运行器 *)
let () =
  run "Types_cache模块测试" [
    "缓存操作", cache_operations_tests;
    "性能统计", performance_stats_tests;
    "集成测试", integration_tests;
    "缓存管理", cache_management_tests;
    "一致性测试", consistency_tests;
  ]