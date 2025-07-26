(** 基准测试协调器模块接口 *)

type performance_metric = {
  name : string;
  execution_time : float;
  memory_usage : int option;
  cpu_usage : float option;
  iterations : int;
  variance : float option;
}

type benchmark_result = {
  module_name : string;
  test_category : string;
  metrics : performance_metric list;
  baseline : performance_metric option;
  timestamp : string;
  environment : string;
}

type benchmark_suite = {
  suite_name : string;
  results : benchmark_result list;
  summary : string;
  total_duration : float;
}

module TestExecutor : sig
  (** 统一的测试执行框架 *)
  
  val execute_benchmark_tests : 
    Benchmark_core.test_config list -> 
    (string -> 'a) ->
    (unit -> string) ->
    performance_metric list
    
  val execute_benchmark_tests_with_memory : 
    Benchmark_core.test_config list -> 
    (string -> 'a) ->
    (unit -> string) ->
    performance_metric list
end

module SuiteCoordinator : sig
  (** 测试套件协调器 *)
  
  val create_benchmark_result : 
    string -> string -> performance_metric list -> string -> string -> benchmark_result
    
  val get_current_timestamp : unit -> string
  
  val get_system_environment : unit -> string
  
  val run_coordinated_benchmarks : 
    (string * string * (unit -> performance_metric list)) list -> benchmark_suite
end