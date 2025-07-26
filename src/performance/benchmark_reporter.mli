(** 基准测试结果分析和报告生成模块接口 *)

module BenchmarkReporter : sig
  (** 生成性能指标摘要 *)
  val summarize_metric : Benchmark_coordinator.performance_metric -> string
  
  (** 基本报告生成功能 *)
  val generate_simple_report : Benchmark_coordinator.benchmark_suite -> string
  
  (** 生成详细的性能指标报告 *)
  val generate_detailed_metrics_report : Benchmark_coordinator.benchmark_suite -> string
  
  (** 生成Markdown格式的报告 *)
  val generate_markdown_report : Benchmark_coordinator.benchmark_suite -> string
  
  (** 生成性能统计摘要 *)
  val generate_performance_statistics : Benchmark_coordinator.benchmark_suite -> string
  
  (** 保存报告到指定文件 *)
  val save_report_to_file : Benchmark_coordinator.benchmark_suite -> string -> string
  
  (** 保存详细报告到文件 *)
  val save_detailed_report_to_file : Benchmark_coordinator.benchmark_suite -> string -> string
  
  (** 保存Markdown报告到文件 *)
  val save_markdown_report_to_file : Benchmark_coordinator.benchmark_suite -> string -> string
end

(** 公共接口函数 *)
val generate_simple_report : Benchmark_coordinator.benchmark_suite -> string
val generate_detailed_report : Benchmark_coordinator.benchmark_suite -> string
val generate_markdown_report : Benchmark_coordinator.benchmark_suite -> string
val generate_statistics : Benchmark_coordinator.benchmark_suite -> string
val save_report_to_file : Benchmark_coordinator.benchmark_suite -> string -> string
val save_detailed_report_to_file : Benchmark_coordinator.benchmark_suite -> string -> string
val save_markdown_report_to_file : Benchmark_coordinator.benchmark_suite -> string -> string