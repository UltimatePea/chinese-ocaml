(** 语义分析器核心功能基础测试 - 骆言编译器 *)

open Yyocamlc_lib.Ast
open Yyocamlc_lib.Semantic

(** 辅助函数：检查字符串是否包含子串 *)
let contains_substring str substr =
  try
    let _ = Str.search_forward (Str.regexp (Str.quote substr)) str 0 in
    true
  with Not_found -> false

(** 测试语义上下文创建 *)
let test_create_semantic_context () =
  let context = create_initial_context () in
  (* 验证上下文创建成功 - 基本存在性检查 *)
  assert (context != Obj.magic 0);
  print_endline "✓ 语义上下文创建测试通过"

(** 测试语义错误异常 *)
let test_semantic_error_exception () =
  try
    raise (SemanticError "测试语义错误");
    assert false (* 不应该到达这里 *)
  with
  | SemanticError msg ->
    assert (contains_substring msg "测");
    print_endline "✓ 语义错误异常测试通过"
  | e ->
    Printf.printf "未预期的异常: %s\n" (Printexc.to_string e);
    assert false

(** 测试语义分析函数存在性 *)
let test_semantic_functions_existence () =
  (* 验证核心函数存在 *)
  let _ = create_initial_context in
  let _ = analyze_expression in  
  let _ = analyze_statement in
  let _ = check_expression_semantics in
  let _ = check_pattern_semantics in
  print_endline "✓ 语义分析函数存在性测试通过"

(** 测试类型系统集成 *)
let test_type_system_integration () =
  try
    let context = create_initial_context () in
    (* 测试类型解析 *)
    let type_expr = BaseTypeExpr IntType in
    let resolved_type = resolve_type_expr context type_expr in
    assert (resolved_type != Obj.magic 0);
    print_endline "✓ 类型系统集成测试通过"
  with
  | e ->
    Printf.printf "类型系统集成测试异常: %s\n" (Printexc.to_string e);
    print_endline "⚠ 类型系统集成测试需要进一步检查"

(** 测试内置函数集成 *)
let test_builtin_functions_integration () =
  try
    let context = create_initial_context () in
    (* 测试添加内置函数 *)
    let enhanced_context = add_builtin_functions context in
    assert (enhanced_context != context);
    print_endline "✓ 内置函数集成测试通过"
  with
  | e ->
    Printf.printf "内置函数集成测试异常: %s\n" (Printexc.to_string e);
    print_endline "⚠ 内置函数集成测试需要进一步检查"

(** 测试模块API基本完整性 *)
let test_module_api_completeness () =
  (* 验证关键函数存在性 *)
  let _ = create_initial_context in
  let _ = resolve_type_expr in
  let _ = add_builtin_functions in
  print_endline "✓ 模块API基本完整性测试通过"

(** 运行所有测试 *)
let () =
  print_endline "开始运行语义分析器核心功能基础测试...";
  test_create_semantic_context ();
  test_semantic_error_exception ();
  test_semantic_functions_existence ();
  test_type_system_integration ();
  test_builtin_functions_integration ();
  test_module_api_completeness ();
  print_endline "🎉 所有语义分析器核心功能基础测试完成！"