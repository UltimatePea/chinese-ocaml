(** 性能基准测试核心框架接口 *)

(** 性能测试指标数据结构 *)
type performance_metric = {
  name : string;
  execution_time : float;
  memory_usage : int option;
  cpu_usage : float option;
  iterations : int;
  variance : float option;
}

(** 基准测试结果 *)
type benchmark_result = {
  module_name : string;
  test_category : string;
  metrics : performance_metric list;
  baseline : performance_metric option;
  timestamp : string;
  environment : string;
}

(** 基准测试套件 *)
type benchmark_suite = {
  suite_name : string;
  results : benchmark_result list;
  summary : string;
  total_duration : float;
}

(** 测试配置 *)
type test_config = {
  name : string;
  iterations : int;
  data_size : int;
  description : string;
}

(** 核心基准测试接口 *)
module BenchmarkCore : sig
  val create_metric : string -> float -> ?memory_usage:int -> ?cpu_usage:float -> 
                     ?variance:float -> int -> performance_metric
  val create_result : string -> string -> performance_metric list -> 
                     ?baseline:performance_metric -> string -> string -> benchmark_result
  val create_suite : string -> benchmark_result list -> string -> float -> benchmark_suite
  val get_timestamp : unit -> string
  val get_environment_info : unit -> string
  val run_single_test : ('a -> 'b) -> 'a -> test_config -> performance_metric
  val run_batch_tests : ('a -> 'b) -> test_config list -> (int -> 'a) -> performance_metric list
end

(** 统计计算工具 *)
module Statistics : sig
  val calculate_mean : float list -> float
  val calculate_variance : float list -> float
  val calculate_std_dev : float list -> float
  val calculate_confidence_interval : float list -> float -> float * float
end

(** 实用工具函数 *)
module Utils : sig
  val generate_test_data : int -> (unit -> string) -> string
  val simple_content_generator : unit -> string
  val poetry_content_generator : unit -> string
  val format_execution_time : float -> string
  val format_memory_usage : int -> string
end