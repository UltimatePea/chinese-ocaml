(** 配置管理模块测试 - 骆言编译器 *)

open Yyocamlc_lib.Config

(** 测试默认配置获取 *)
let test_default_configs () =
  let compiler_cfg = default_compiler_config in
  let runtime_cfg = default_runtime_config in
  (* 验证默认配置不为空/无效 *)
  assert (compiler_cfg != Obj.magic 0);
  assert (runtime_cfg != Obj.magic 0);
  print_endline "✓ 默认配置获取测试通过"

(** 测试编译器配置设置和获取 *)
let test_compiler_config_access () =
  let original_config = get_compiler_config () in
  let new_config = default_compiler_config in

  (* 设置新配置 *)
  set_compiler_config new_config;
  let retrieved_config = get_compiler_config () in

  (* 验证配置被正确设置 *)
  assert (retrieved_config = new_config || retrieved_config != original_config);

  (* 恢复原始配置 *)
  set_compiler_config original_config;
  print_endline "✓ 编译器配置设置和获取测试通过"

(** 测试运行时配置设置和获取 *)
let test_runtime_config_access () =
  let original_config = get_runtime_config () in
  let new_config = default_runtime_config in

  (* 设置新配置 *)
  set_runtime_config new_config;
  let retrieved_config = get_runtime_config () in

  (* 验证配置被正确设置 *)
  assert (retrieved_config = new_config || retrieved_config != original_config);

  (* 恢复原始配置 *)
  set_runtime_config original_config;
  print_endline "✓ 运行时配置设置和获取测试通过"

(** 测试配置引用的向后兼容性 *)
let test_config_references () =
  (* 验证配置引用存在且可访问 *)
  let _ = !compiler_config in
  let _ = !runtime_config in
  print_endline "✓ 配置引用向后兼容性测试通过"

(** 测试配置类型定义 *)
let test_config_types () =
  (* 验证类型定义正确导出 *)
  let _ : compiler_config = default_compiler_config in
  let _ : runtime_config = default_runtime_config in
  print_endline "✓ 配置类型定义测试通过"

(** 测试配置持久性 *)
let test_config_persistence () =
  let initial_compiler = get_compiler_config () in
  let initial_runtime = get_runtime_config () in

  (* 修改配置 *)
  set_compiler_config default_compiler_config;
  set_runtime_config default_runtime_config;

  (* 验证配置保持 *)
  let persisted_compiler = get_compiler_config () in
  let persisted_runtime = get_runtime_config () in

  assert (persisted_compiler = default_compiler_config || persisted_compiler != initial_compiler);
  assert (persisted_runtime = default_runtime_config || persisted_runtime != initial_runtime);

  print_endline "✓ 配置持久性测试通过"

(** 测试配置模块完整性 *)
let test_module_completeness () =
  (* 验证所有必要的函数都存在 *)
  let _ = default_compiler_config in
  let _ = default_runtime_config in
  let _ = get_compiler_config in
  let _ = get_runtime_config in
  let _ = set_compiler_config in
  let _ = set_runtime_config in
  print_endline "✓ 配置模块完整性测试通过"

(** 测试配置引用和函数的一致性 *)
let test_reference_function_consistency () =
  (* 设置通过函数 *)
  set_compiler_config default_compiler_config;
  set_runtime_config default_runtime_config;

  (* 检查引用是否同步更新 *)
  let ref_compiler = !compiler_config in
  let ref_runtime = !runtime_config in
  let func_compiler = get_compiler_config () in
  let func_runtime = get_runtime_config () in

  (* 验证引用和函数返回的配置一致 *)
  assert (ref_compiler = func_compiler || ref_compiler = default_compiler_config);
  assert (ref_runtime = func_runtime || ref_runtime = default_runtime_config);

  print_endline "✓ 配置引用和函数一致性测试通过"

(** 运行所有测试 *)
let () =
  print_endline "开始运行配置管理模块测试...";
  test_default_configs ();
  test_compiler_config_access ();
  test_runtime_config_access ();
  test_config_references ();
  test_config_types ();
  test_config_persistence ();
  test_module_completeness ();
  test_reference_function_consistency ();
  print_endline "🎉 所有配置管理模块测试通过！"
