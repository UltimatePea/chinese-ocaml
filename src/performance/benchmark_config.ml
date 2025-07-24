(** 性能基准测试配置管理模块
    
    提供统一的测试配置和阈值管理
    
    创建目的：从performance_benchmark.ml中分离配置逻辑，实现配置的集中管理
    创建时间：技术债务改进 Phase 5.1 - Fix #1083 *)

open Benchmark_core
(* Direct function calls with full paths *)

(** 基准测试配置管理 *)
module BenchmarkConfig = struct
  
  (** 词法分析器测试配置 *)
  let lexer_test_configs = [
    {
      name = "小型文本词法分析";
      iterations = 50;
      data_size = 10;
      description = "小规模文本的词法分析性能测试";
    };
    {
      name = "中型文本词法分析";
      iterations = 20;
      data_size = 100;
      description = "中等规模文本的词法分析性能测试";
    };
    {
      name = "大型文本词法分析";
      iterations = 5;
      data_size = 1000;
      description = "大规模文本的词法分析性能测试";
    };
  ]
  
  (** 语法分析器测试配置 *)
  let parser_test_configs = [
    {
      name = "简单表达式解析";
      iterations = 100;
      data_size = 1;
      description = "简单表达式的语法分析性能测试";
    };
    {
      name = "中等复杂表达式解析";
      iterations = 50;
      data_size = 5;
      description = "中等复杂度表达式的语法分析性能测试";
    };
    {
      name = "复杂嵌套表达式解析";
      iterations = 20;
      data_size = 8;
      description = "复杂嵌套表达式的语法分析性能测试";
    };
  ]
  
  (** 诗词功能测试配置 *)
  let poetry_test_configs = [
    {
      name = "短诗词分析";
      iterations = 30;
      data_size = 2;
      description = "短篇诗词的艺术性分析性能测试";
    };
    {
      name = "中篇诗词分析";
      iterations = 15;
      data_size = 10;
      description = "中篇诗词的艺术性分析性能测试";
    };
    {
      name = "长篇诗词分析";
      iterations = 5;
      data_size = 50;
      description = "长篇诗词的艺术性分析性能测试";
    };
  ]
  
  (** 根据测试类型获取配置 *)
  let get_configs_by_type test_type =
    match test_type with
    | "lexer" -> lexer_test_configs
    | "parser" -> parser_test_configs
    | "poetry" -> poetry_test_configs
    | _ -> []
  
  (** 创建自定义测试配置 *)
  let create_custom_config name iterations data_size description =
    { name; iterations; data_size; description }
    
end

(** 性能阈值配置 *)
module PerformanceThresholds = struct
  
  (** 性能阈值映射表 *)
  let performance_thresholds = [
    ("词法分析器", 1.2);     (* 允许20%的性能波动 *)
    ("语法分析器", 1.3);     (* 允许30%的性能波动 *)
    ("诗词分析器", 1.5);     (* 允许50%的性能波动 *)
    ("默认", 1.2);           (* 默认阈值 *)
  ]
  
  (** 内存使用阈值 *)
  let memory_thresholds = [
    ("词法分析器", 1024 * 1024);      (* 1MB *)
    ("语法分析器", 2 * 1024 * 1024);  (* 2MB *)
    ("诗词分析器", 5 * 1024 * 1024);  (* 5MB *)
    ("默认", 1024 * 1024);            (* 1MB *)
  ]
  
  (** 获取性能阈值 *)
  let get_performance_threshold test_name =
    try
      List.assoc test_name performance_thresholds
    with Not_found ->
      List.assoc "默认" performance_thresholds
  
  (** 获取内存阈值 *)
  let get_memory_threshold test_name =
    try
      List.assoc test_name memory_thresholds
    with Not_found ->
      List.assoc "默认" memory_thresholds
  
  (** 添加自定义阈值 *)
  let add_custom_threshold test_name performance_threshold memory_threshold =
    (* 这里可以实现动态添加阈值的逻辑 *)
    "已添加自定义阈值：" ^ test_name ^ " (性能: " ^ (string_of_float performance_threshold) ^ ", 内存: " ^ (Utils.format_memory_usage memory_threshold) ^ ")"
      
end

(** 测试环境配置 *)
module EnvironmentConfig = struct
  
  (** 测试环境参数 *)
  type test_environment = {
    cpu_cores : int;
    memory_total : int;
    ocaml_version : string;
    os_info : string;
    hostname : string;
    test_date : string;
  }
  
  (** 获取当前测试环境信息 *)
  let get_environment_info () =
    let hostname = try Sys.getenv "HOSTNAME" with Not_found -> "未知主机" in
    let ocaml_version = Sys.ocaml_version in
    let os_info = Sys.os_type in
    let test_date = BenchmarkCore.get_timestamp () in
    
    {
      cpu_cores = 1; (* 这里可以通过系统调用获取实际核心数 *)
      memory_total = 0; (* 这里可以通过系统调用获取实际内存 *)
      ocaml_version;
      os_info;
      hostname;
      test_date;
    }
  
  (** 格式化环境信息 *)  
  let format_environment_info env =
    [
      "主机名: " ^ env.hostname;
      "操作系统: " ^ env.os_info;
      "OCaml版本: " ^ env.ocaml_version;
      "CPU核心数: " ^ (string_of_int env.cpu_cores);
      "测试时间: " ^ env.test_date;
    ]
  
  (** 检查环境兼容性 *)
  let check_environment_compatibility baseline_env current_env =
    let compatibility_issues = ref [] in
    
    if baseline_env.ocaml_version <> current_env.ocaml_version then
      compatibility_issues := "OCaml版本不匹配" :: !compatibility_issues;
    
    if baseline_env.os_info <> current_env.os_info then
      compatibility_issues := "操作系统不匹配" :: !compatibility_issues;
      
    !compatibility_issues
    
end

(** 全局配置管理 *)
module GlobalConfig = struct
  
  (** 全局测试配置 *)
  type global_config = {
    enable_detailed_logging : bool;
    enable_memory_monitoring : bool;
    enable_regression_detection : bool;
    output_format : string; (* "markdown" | "json" | "csv" *)
    save_baseline : bool;
    baseline_file : string;
  }
  
  (** 默认全局配置 *)
  let default_global_config = {
    enable_detailed_logging = true;
    enable_memory_monitoring = true;
    enable_regression_detection = true;
    output_format = "markdown";
    save_baseline = false;
    baseline_file = "performance_baseline.json";
  }
  
  (** 当前配置引用 *)
  let current_config = ref default_global_config
  
  (** 更新全局配置 *)
  let update_config new_config =
    current_config := new_config
  
  (** 获取当前配置 *)
  let get_current_config () =
    !current_config
  
  (** 从环境变量加载配置 *)
  let load_from_env () =
    let get_env_bool key default =
      try
        match String.lowercase_ascii (Sys.getenv key) with
        | "true" | "1" | "yes" -> true
        | "false" | "0" | "no" -> false
        | _ -> default
      with Not_found -> default
    in
    
    let config = {
      enable_detailed_logging = get_env_bool "BENCHMARK_DETAILED_LOGGING" true;
      enable_memory_monitoring = get_env_bool "BENCHMARK_MEMORY_MONITORING" true;
      enable_regression_detection = get_env_bool "BENCHMARK_REGRESSION_DETECTION" true;
      output_format = (try Sys.getenv "BENCHMARK_OUTPUT_FORMAT" with Not_found -> "markdown");
      save_baseline = get_env_bool "BENCHMARK_SAVE_BASELINE" false;
      baseline_file = (try Sys.getenv "BENCHMARK_BASELINE_FILE" with Not_found -> "performance_baseline.json");
    } in
    
    update_config config;
    config
    
end