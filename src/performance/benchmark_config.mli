(** 性能基准测试配置管理模块接口 *)

open Benchmark_core

(** 基准测试配置管理 *)
module BenchmarkConfig : sig
  val lexer_test_configs : test_config list
  val parser_test_configs : test_config list
  val poetry_test_configs : test_config list
  val get_configs_by_type : string -> test_config list
  val create_custom_config : string -> int -> int -> string -> test_config
end

(** 性能阈值配置 *)
module PerformanceThresholds : sig
  val get_performance_threshold : string -> float
  val get_memory_threshold : string -> int
  val add_custom_threshold : string -> float -> int -> string
end

(** 测试环境配置 *)
module EnvironmentConfig : sig
  type test_environment = {
    cpu_cores : int;
    memory_total : int;
    ocaml_version : string;
    os_info : string;
    hostname : string;
    test_date : string;
  }
  
  val get_environment_info : unit -> test_environment
  val format_environment_info : test_environment -> string list
  val check_environment_compatibility : test_environment -> test_environment -> string list
end

(** 全局配置管理 *)
module GlobalConfig : sig
  type global_config = {
    enable_detailed_logging : bool;
    enable_memory_monitoring : bool;
    enable_regression_detection : bool;
    output_format : string;
    save_baseline : bool;
    baseline_file : string;
  }
  
  val default_global_config : global_config
  val update_config : global_config -> unit
  val get_current_config : unit -> global_config
  val load_from_env : unit -> global_config
end