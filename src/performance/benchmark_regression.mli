(** 性能回归检测模块接口 *)

module RegressionDetector : sig
  type regression_threshold = {
    performance_degradation : float;  (** 性能下降阈值 (百分比) *)
    memory_increase : float;  (** 内存增长阈值 (百分比) *)
    variance_increase : float;  (** 方差增长阈值 (百分比) *)
  }
  (** 回归检测阈值配置 *)

  type regression_result = {
    test_name : string;
    regression_type : string;
    current_value : float;
    baseline_value : float;
    change_percentage : float;
    severity : string;
    description : string;
  }
  (** 回归检测结果类型 *)

  val default_threshold : regression_threshold
  (** 默认回归检测阈值 *)

  val detect_regression :
    ?threshold:regression_threshold ->
    Benchmark_coordinator.performance_metric ->
    Benchmark_coordinator.performance_metric ->
    regression_result list
  (** 检测单个指标的性能回归 *)

  val generate_regression_report :
    ?threshold:regression_threshold ->
    Benchmark_coordinator.performance_metric list ->
    Benchmark_coordinator.performance_metric list ->
    string list
  (** 生成回归检测报告 *)

  val generate_detailed_regression_report :
    ?threshold:regression_threshold ->
    Benchmark_coordinator.performance_metric list ->
    Benchmark_coordinator.performance_metric list ->
    string list
  (** 生成详细的回归分析报告 *)

  val analyze_performance_regression :
    ?threshold:regression_threshold ->
    Benchmark_coordinator.benchmark_suite ->
    Benchmark_coordinator.benchmark_suite ->
    Benchmark_coordinator.benchmark_suite
  (** 执行完整的回归检测分析 *)
end

val detect_regression :
  ?threshold:RegressionDetector.regression_threshold ->
  Benchmark_coordinator.performance_metric ->
  Benchmark_coordinator.performance_metric ->
  RegressionDetector.regression_result list
(** 公共接口函数 *)

val generate_regression_report :
  ?threshold:RegressionDetector.regression_threshold ->
  Benchmark_coordinator.performance_metric list ->
  Benchmark_coordinator.performance_metric list ->
  string list

val generate_detailed_regression_report :
  ?threshold:RegressionDetector.regression_threshold ->
  Benchmark_coordinator.performance_metric list ->
  Benchmark_coordinator.performance_metric list ->
  string list

val analyze_performance_regression :
  ?threshold:RegressionDetector.regression_threshold ->
  Benchmark_coordinator.benchmark_suite ->
  Benchmark_coordinator.benchmark_suite ->
  Benchmark_coordinator.benchmark_suite
