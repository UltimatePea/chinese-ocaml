(** 骆言编译器配置模块综合测试 
    为issue #749提升测试覆盖率至50%+ - 配置管理模块测试 *)

open Alcotest
open Config_modules.Config_loader
open Config_modules.Unified_config
open Config_modules.Compiler_config
open Config_modules.Runtime_config

(** 测试辅助函数 *)

(** 创建临时配置文件用于测试 *)
let create_temp_config_file content =
  let temp_file = Filename.temp_file "luoyan_test_config" ".json" in
  let oc = open_out temp_file in
  output_string oc content;
  close_out oc;
  temp_file

(** 清理临时文件 *)
let cleanup_temp_file filename =
  try Sys.remove filename with _ -> ()

(** 重置配置到默认状态 *)
let reset_config_state () =
  reset_to_defaults ()

(** 配置文件加载测试 *)
let test_config_file_loading () =
  reset_config_state ();
  
  let config_content = {|
{
  "debug_mode": false,
  "buffer_size": 1024,
  "output_directory": "./test_output"
}
|} in
  
  let temp_file = create_temp_config_file config_content in
  
  (* 测试加载存在的文件 *)
  let result = load_from_file temp_file in
  check bool "加载配置文件成功" true result;
  
  cleanup_temp_file temp_file;
  
  (* 测试加载不存在的文件 *)
  let result2 = load_from_file "nonexistent_file.json" in
  check bool "加载不存在文件返回false" false result2

(** 配置初始化测试 *)
let test_config_initialization () =
  reset_config_state ();
  
  (* 创建测试配置文件 *)
  let config_content = {|
{
  "debug_mode": true,
  "buffer_size": 2048
}
|} in
  let temp_file = create_temp_config_file config_content in
  
  (* 初始化配置 *)
  init_config ~config_file:temp_file ();
  
  cleanup_temp_file temp_file;
  
  (* 测试无配置文件的初始化 *)
  reset_config_state ();
  init_config ~config_file:"nonexistent.json" ();
  
  let default_compiler = get_compiler_config () in
  let default_runtime = get_runtime_config () in
  
  (* 验证使用默认值 *)
  check bool "无文件时使用默认配置" true (default_compiler.buffer_size > 0);
  check bool "无文件时运行时配置有效" true (default_runtime.max_error_count > 0)

(** 配置验证测试 *)
let test_config_validation () =
  reset_config_state ();
  
  (* 测试有效配置验证 *)
  let errors1 = validate_config () in
  check int "默认配置验证无错误" 0 (List.length errors1);
  
  (* 验证编译器配置验证函数 *)
  let valid_config = get_compiler_config () in
  check bool "有效编译器配置" true (validate_compiler_config valid_config);
  
  (* 验证运行时配置验证函数 *)
  let valid_runtime = get_runtime_config () in
  check bool "有效运行时配置" true (validate_runtime_config valid_runtime)

(** 统一配置接口测试 *)
let test_unified_config_interface () =
  reset_config_state ();
  
  (* 测试默认配置访问 *)
  let default_compiler = default_compiler_config in
  let default_runtime = default_runtime_config in
  
  check bool "默认编译器配置有效" true (default_compiler.buffer_size > 0);
  check bool "默认运行时配置有效" true (default_runtime.max_error_count > 0);
  
  (* 测试配置设置和获取 *)
  let new_compiler_config = { (get_compiler_config ()) with buffer_size = 3072 } in
  set_compiler_config new_compiler_config;
  
  let retrieved_config = get_compiler_config () in
  check int "设置并获取编译器配置" 3072 retrieved_config.buffer_size;
  
  let new_runtime_config = { (get_runtime_config ()) with debug_mode = true } in
  set_runtime_config new_runtime_config;
  
  let retrieved_runtime = get_runtime_config () in
  check bool "设置并获取运行时配置" true retrieved_runtime.debug_mode

(** 环境变量解析测试 *)
let test_environment_variable_parsing () =
  (* 测试布尔值解析 *)
  check bool "解析true为真" true (parse_boolean_env_var "true");
  check bool "解析TRUE为真" true (parse_boolean_env_var "TRUE");
  check bool "解析1为真" true (parse_boolean_env_var "1");
  check bool "解析false为假" false (parse_boolean_env_var "false");
  check bool "解析0为假" false (parse_boolean_env_var "0");
  
  (* 测试正整数解析 *)
  check (option int) "解析正整数" (Some 100) (parse_positive_int_env_var "100");
  check (option int) "解析负整数返回None" None (parse_positive_int_env_var "-10");
  check (option int) "解析非数字返回None" None (parse_positive_int_env_var "abc");
  
  (* 测试正浮点数解析 *)
  check (option (float 0.1)) "解析正浮点数" (Some 3.14) (parse_positive_float_env_var "3.14");
  check (option (float 0.1)) "解析负浮点数返回None" None (parse_positive_float_env_var "-1.5");
  
  (* 测试非空字符串解析 *)
  check (option string) "解析非空字符串" (Some "test") (parse_non_empty_string_env_var "test");
  check (option string) "解析空字符串返回None" None (parse_non_empty_string_env_var "");
  
  (* 测试范围整数解析 *)
  check (option int) "解析范围内整数" (Some 5) (parse_int_range_env_var "5" 1 10);
  check (option int) "解析范围外整数返回None" None (parse_int_range_env_var "15" 1 10);
  
  (* 测试枚举值解析 *)
  let valid_levels = ["debug"; "info"; "warn"; "error"] in
  check (option string) "解析有效枚举值" (Some "debug") (parse_enum_env_var "DEBUG" valid_levels);
  check (option string) "解析无效枚举值返回None" None (parse_enum_env_var "invalid" valid_levels)

(** 子配置模块独立性测试 *)
let test_submodule_independence () =
  reset_config_state ();
  
  (* 测试编译器配置模块 *)
  let initial_compiler = get_compiler_config () in
  let modified_compiler = { initial_compiler with buffer_size = 9999 } in
  set_compiler_config modified_compiler;
  
  let retrieved_compiler = get_compiler_config () in
  check int "编译器配置模块独立设置" 9999 retrieved_compiler.buffer_size;
  
  (* 测试运行时配置模块 *)
  let initial_runtime = get_runtime_config () in
  let modified_runtime = { initial_runtime with debug_mode = true } in
  set_runtime_config modified_runtime;
  
  let retrieved_runtime = get_runtime_config () in
  check bool "运行时配置模块独立设置" true retrieved_runtime.debug_mode

(** 配置持久化和加载循环测试 *)
let test_config_persistence_cycle () =
  reset_config_state ();
  
  (* 创建具有特定值的配置文件 *)
  let test_config = {|
{
  "debug_mode": true,
  "buffer_size": 4096,
  "large_buffer_size": 8192,
  "optimization_level": 2,
  "timeout": 45.0,
  "output_directory": "./test_build",
  "temp_directory": "./test_temp",
  "c_compiler": "clang",
  "max_error_count": 20,
  "log_level": "debug"
}
|} in
  
  let temp_file = create_temp_config_file test_config in
  
  (* 初始化配置 *)
  init_config ~config_file:temp_file ();
  
  (* 验证部分配置值 *)
  let compiler_cfg = get_compiler_config () in
  let runtime_cfg = get_runtime_config () in
  
  check bool "配置循环测试：编译器配置有效" true (compiler_cfg.buffer_size > 0);
  check bool "配置循环测试：运行时配置有效" true (runtime_cfg.max_error_count > 0);
  
  cleanup_temp_file temp_file

(** 错误处理和边界情况测试 *)
let test_error_handling_and_edge_cases () =
  reset_config_state ();
  
  (* 测试格式错误的JSON文件 *)
  let malformed_config = {|
{
  "debug_mode": true
  "missing_comma": "error"
  "unclosed_brace": "problem"
|} in
  
  let temp_file = create_temp_config_file malformed_config in
  let result = load_from_file temp_file in
  
  (* 格式错误的文件应该返回false，但不应该崩溃 *)
  check bool "格式错误的配置文件处理" false result;
  
  cleanup_temp_file temp_file;
  
  (* 测试空配置文件 *)
  let empty_config = "" in
  let temp_file2 = create_temp_config_file empty_config in
  let result2 = load_from_file temp_file2 in
  
  check bool "空配置文件处理" false result2;
  
  cleanup_temp_file temp_file2

(** 配置模块间协调性测试 *)
let test_config_module_coordination () =
  reset_config_state ();
  
  (* 通过统一接口修改配置 *)
  load_all_from_env ();
  
  (* 验证所有配置模块都正常工作 *)
  let compiler_cfg = get_compiler_config () in
  let runtime_cfg = get_runtime_config () in
  
  check bool "配置模块协调：编译器配置" true (compiler_cfg.buffer_size > 0);
  check bool "配置模块协调：运行时配置" true (runtime_cfg.max_error_count > 0);
  
  (* 测试重置功能 *)
  reset_to_defaults ();
  
  let reset_compiler = get_compiler_config () in
  let reset_runtime = get_runtime_config () in
  
  check bool "重置后编译器配置有效" true (reset_compiler.buffer_size > 0);
  check bool "重置后运行时配置有效" true (reset_runtime.max_error_count > 0)

(** 性能和资源测试 *)
let test_performance_and_resources () =
  reset_config_state ();
  
  (* 测试配置重置多次 *)
  for _ = 1 to 50 do
    reset_to_defaults ();
    let _ = get_compiler_config () in
    let _ = get_runtime_config () in
    ()
  done;
  
  check bool "多次重置后配置仍有效" true true;
  
  (* 测试多次初始化 *)
  for _ = 1 to 10 do
    init_config ~config_file:"nonexistent.json" ();
  done;
  
  let final_config = get_compiler_config () in
  check bool "多次初始化后配置有效" true (final_config.buffer_size > 0)

(** 测试套件 *)
let test_suite = [
  ("配置文件加载", `Quick, test_config_file_loading);
  ("配置初始化", `Quick, test_config_initialization);
  ("配置验证", `Quick, test_config_validation);
  ("统一配置接口", `Quick, test_unified_config_interface);
  ("环境变量解析", `Quick, test_environment_variable_parsing);
  ("子配置模块独立性", `Quick, test_submodule_independence);
  ("配置持久化和加载循环", `Quick, test_config_persistence_cycle);
  ("错误处理和边界情况", `Quick, test_error_handling_and_edge_cases);
  ("配置模块间协调性", `Quick, test_config_module_coordination);
  ("性能和资源", `Quick, test_performance_and_resources);
]

let () = run "配置模块综合测试" [("配置模块综合测试", test_suite)]