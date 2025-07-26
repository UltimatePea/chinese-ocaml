(** 基准测试结果分析和报告生成模块

    专注于基准测试结果的格式化、分析和报告生成功能 *)

open Utils.Base_formatter
open Benchmark_coordinator

module BenchmarkReporter = struct
  (** 性能指标摘要生成 *)
  let summarize_metric (metric : performance_metric) =
    concat_strings
      [
        metric.name;
        ": ";
        string_of_float metric.execution_time;
        "秒";
        (match metric.memory_usage with
        | Some mem -> concat_strings [ " | 内存: "; int_to_string mem; " 字节" ]
        | None -> "");
        " | 迭代: ";
        int_to_string metric.iterations;
        "次";
      ]

  (** 基本报告生成功能 *)
  let generate_simple_report (benchmark_suite : benchmark_suite) =
    concat_strings
      [
        "# ";
        benchmark_suite.suite_name;
        "\n\n";
        "总时长: ";
        string_of_float benchmark_suite.total_duration;
        "秒\n";
        "总结: ";
        benchmark_suite.summary;
        "\n\n";
        "结果数量: ";
        int_to_string (List.length benchmark_suite.results);
        "\n";
      ]

  (** 生成详细的性能指标报告 *)
  let generate_detailed_metrics_report (benchmark_suite : benchmark_suite) =
    let detailed_results =
      List.map
        (fun result ->
          let metrics_summary = List.map summarize_metric result.metrics in
          concat_strings
            [
              "## ";
              result.module_name;
              " (";
              result.test_category;
              ")\n";
              "测试时间: ";
              result.timestamp;
              "\n";
              "测试环境: ";
              result.environment;
              "\n\n";
              "### 性能指标:\n";
              String.concat "\n- " ("" :: metrics_summary);
              "\n\n";
            ])
        benchmark_suite.results
    in
    concat_strings
      ([
         "# ";
         benchmark_suite.suite_name;
         " - 详细报告\n\n";
         "**总时长**: ";
         string_of_float benchmark_suite.total_duration;
         "秒\n\n";
         "**总结**: ";
         benchmark_suite.summary;
         "\n\n";
       ]
      @ detailed_results)

  (** 生成Markdown格式的报告 *)
  let generate_markdown_report (benchmark_suite : benchmark_suite) =
    let results_summary =
      List.map
        (fun result ->
          concat_strings
            [
              "## ";
              result.module_name;
              " (";
              result.test_category;
              ")\n\n";
              "测试指标数量: ";
              int_to_string (List.length result.metrics);
              "\n";
              "测试时间: ";
              result.timestamp;
              "\n";
              "测试环境: ";
              result.environment;
              "\n\n";
            ])
        benchmark_suite.results
    in
    concat_strings
      ([
         "# ";
         benchmark_suite.suite_name;
         "\n\n";
         "**总时长**: ";
         string_of_float benchmark_suite.total_duration;
         "秒\n\n";
         "**总结**: ";
         benchmark_suite.summary;
         "\n\n";
       ]
      @ results_summary)

  (** 生成性能统计摘要 *)
  let generate_performance_statistics (benchmark_suite : benchmark_suite) =
    let total_metrics =
      List.fold_left (fun acc result -> acc + List.length result.metrics) 0 benchmark_suite.results
    in

    let avg_execution_time =
      let total_time =
        List.fold_left
          (fun acc result ->
            List.fold_left
              (fun inner_acc metric -> inner_acc +. metric.execution_time)
              acc result.metrics)
          0.0 benchmark_suite.results
      in
      if total_metrics > 0 then total_time /. float_of_int total_metrics else 0.0
    in

    concat_strings
      [
        "# 性能统计摘要\n\n";
        "- 总测试套件数: ";
        int_to_string (List.length benchmark_suite.results);
        "\n";
        "- 总测试指标数: ";
        int_to_string total_metrics;
        "\n";
        "- 平均执行时间: ";
        string_of_float avg_execution_time;
        "秒\n";
        "- 总测试时长: ";
        string_of_float benchmark_suite.total_duration;
        "秒\n\n";
      ]

  (** 保存报告到指定文件 *)
  let save_report_to_file (benchmark_suite : benchmark_suite) filename =
    let report_content = generate_simple_report benchmark_suite in
    let oc = open_out filename in
    output_string oc report_content;
    close_out oc;
    concat_strings [ "报告已保存到文件: "; filename ]

  (** 保存详细报告到文件 *)
  let save_detailed_report_to_file (benchmark_suite : benchmark_suite) filename =
    let report_content = generate_detailed_metrics_report benchmark_suite in
    let oc = open_out filename in
    output_string oc report_content;
    close_out oc;
    concat_strings [ "详细报告已保存到文件: "; filename ]

  (** 保存Markdown报告到文件 *)
  let save_markdown_report_to_file (benchmark_suite : benchmark_suite) filename =
    let report_content = generate_markdown_report benchmark_suite in
    let oc = open_out filename in
    output_string oc report_content;
    close_out oc;
    concat_strings [ "Markdown报告已保存到文件: "; filename ]
end

(** 公共接口函数 *)
let generate_simple_report = BenchmarkReporter.generate_simple_report

let generate_detailed_report = BenchmarkReporter.generate_detailed_metrics_report
let generate_markdown_report = BenchmarkReporter.generate_markdown_report
let generate_statistics = BenchmarkReporter.generate_performance_statistics
let save_report_to_file = BenchmarkReporter.save_report_to_file
let save_detailed_report_to_file = BenchmarkReporter.save_detailed_report_to_file
let save_markdown_report_to_file = BenchmarkReporter.save_markdown_report_to_file
